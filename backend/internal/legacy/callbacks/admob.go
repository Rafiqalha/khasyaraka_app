package callbacks

import (
	"bytes"
	"crypto/ecdsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"net/http"
	"strconv"
	"sync"
	"time"
)

// adMobKey holds a parsed ECDSA public key from Google.
type adMobKey struct {
	KeyID     int
	PublicKey *ecdsa.PublicKey
}

var (
	keysMu       sync.RWMutex
	cachedKeys   map[int]*ecdsa.PublicKey
	keysExpireAt time.Time
	keysTTL      = 1 * time.Hour
)

const verifierKeysURL = "https://www.gstatic.com/admob/reward/verifier-keys.json"

// verifierKeysResponse matches the JSON returned by Google.
type verifierKeysResponse struct {
	Keys []struct {
		KeyID int    `json:"keyId"`
		Pem   string `json:"pem"`
	} `json:"keys"`
}

// fetchVerifierKeys downloads and caches Google's AdMob public keys.
func fetchVerifierKeys() (map[int]*ecdsa.PublicKey, error) {
	keysMu.RLock()
	if cachedKeys != nil && time.Now().Before(keysExpireAt) {
		defer keysMu.RUnlock()
		return cachedKeys, nil
	}
	keysMu.RUnlock()

	// Fetch keys
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(verifierKeysURL)
	if err != nil {
		return nil, fmt.Errorf("fetch admob keys: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("admob keys HTTP %d", resp.StatusCode)
	}

	var payload verifierKeysResponse
	if err := json.NewDecoder(resp.Body).Decode(&payload); err != nil {
		return nil, fmt.Errorf("decode admob keys: %w", err)
	}

	keys := make(map[int]*ecdsa.PublicKey)
	for _, item := range payload.Keys {
		if item.Pem == "" {
			continue
		}
		block, _ := pem.Decode([]byte(item.Pem))
		if block == nil {
			continue
		}
		pub, err := x509.ParsePKIXPublicKey(block.Bytes)
		if err != nil {
			continue
		}
		ecKey, ok := pub.(*ecdsa.PublicKey)
		if !ok {
			continue
		}
		keys[item.KeyID] = ecKey
	}

	if len(keys) == 0 {
		return nil, fmt.Errorf("no admob verifying keys available")
	}

	// Cache
	keysMu.Lock()
	cachedKeys = keys
	keysExpireAt = time.Now().Add(keysTTL)
	keysMu.Unlock()

	return keys, nil
}

// extractVerificationMaterial pulls data_to_verify, signature bytes, and key_id
// from the raw query string (percent-encoded), per Google's docs.
func extractVerificationMaterial(rawQuery []byte) (dataToVerify []byte, signature []byte, keyID int, err error) {
	sigMarker := []byte("signature=")
	keyMarker := []byte("&key_id=")

	sigIdx := bytes.Index(rawQuery, sigMarker)
	if sigIdx == -1 {
		return nil, nil, 0, fmt.Errorf("missing signature parameter")
	}

	// Content to verify ends right before '&signature='
	if sigIdx == 0 || rawQuery[sigIdx-1] != '&' {
		return nil, nil, 0, fmt.Errorf("invalid query format")
	}
	dataToVerify = rawQuery[:sigIdx-1]

	keyIdx := bytes.Index(rawQuery[sigIdx:], keyMarker)
	if keyIdx == -1 {
		return nil, nil, 0, fmt.Errorf("missing key_id parameter")
	}
	keyIdx += sigIdx

	sigB64 := rawQuery[sigIdx+len(sigMarker) : keyIdx]
	keyIDBytes := rawQuery[keyIdx+len(keyMarker):]

	// Decode URL-safe base64 signature
	signature, err = urlsafeB64Decode(sigB64)
	if err != nil {
		return nil, nil, 0, fmt.Errorf("decode signature: %w", err)
	}

	keyID, err = strconv.Atoi(string(keyIDBytes))
	if err != nil {
		return nil, nil, 0, fmt.Errorf("parse key_id: %w", err)
	}

	return dataToVerify, signature, keyID, nil
}

// urlsafeB64Decode decodes URL-safe base64 without padding.
func urlsafeB64Decode(data []byte) ([]byte, error) {
	return base64.URLEncoding.WithPadding(base64.NoPadding).DecodeString(string(data))
}

// VerifyAdMobSSV verifies an AdMob SSV callback signature.
func VerifyAdMobSSV(rawQuery []byte) error {
	dataToVerify, signature, keyID, err := extractVerificationMaterial(rawQuery)
	if err != nil {
		return err
	}

	keys, err := fetchVerifierKeys()
	if err != nil {
		return err
	}

	pubKey, ok := keys[keyID]
	if !ok {
		return fmt.Errorf("unknown key_id: %d", keyID)
	}

	// SHA256 hash of data_to_verify
	hash := sha256.Sum256(dataToVerify)

	// Parse DER-encoded ECDSA signature
	if !verifyECDSASignature(pubKey, hash[:], signature) {
		return fmt.Errorf("invalid admob ssv signature")
	}

	return nil
}

// verifyECDSASignature verifies a DER-encoded ECDSA signature.
func verifyECDSASignature(pubKey *ecdsa.PublicKey, hash, sig []byte) bool {
	return ecdsa.VerifyASN1(pubKey, hash, sig)
}
