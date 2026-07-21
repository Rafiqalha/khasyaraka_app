package sandi

import (
	"encoding/base64"
	"fmt"
	"math/rand"
	"strings"
	"unicode"
)

type Cipher interface {
	Name() string
	Encrypt(plaintext string, key string) (string, error)
	Decrypt(ciphertext string, key string) (string, error)
}

var cipherRegistry = map[string]Cipher{
	"caesar_sandi": CaesarCipher{},
	"atbash":       AtbashCipher{},
	"morse":        MorseCipher{},
	"semaphore":    SemaphoreCipher{},
	"rot13":        ROT13Cipher{},
	"vigenere":     VigenereCipher{},
	"base64":       Base64Cipher{},
	"xor":          XORCipher{},
	"reverse":      ReverseCipher{},
}

func GetCipher(codename string) (Cipher, bool) {
	c, ok := cipherRegistry[codename]
	return c, ok
}

// --- Caesar Cipher ---

type CaesarCipher struct{}

func (CaesarCipher) Name() string { return "Caesar Cipher" }

func (CaesarCipher) shift(text string, shift int) string {
	var result strings.Builder
	for _, ch := range text {
		switch {
		case ch >= 'A' && ch <= 'Z':
			result.WriteRune(rune((int(ch-'A')+shift%26+26)%26) + 'A')
		case ch >= 'a' && ch <= 'z':
			result.WriteRune(rune((int(ch-'a')+shift%26+26)%26) + 'a')
		default:
			result.WriteRune(ch)
		}
	}
	return result.String()
}

func (c CaesarCipher) Encrypt(plaintext string, key string) (string, error) {
	shift := 3
	if key != "" {
		if _, err := fmt.Sscanf(key, "%d", &shift); err != nil {
			return "", fmt.Errorf("invalid caesar key, must be integer: %w", err)
		}
	}
	return c.shift(plaintext, shift), nil
}

func (c CaesarCipher) Decrypt(ciphertext string, key string) (string, error) {
	shift := -3
	if key != "" {
		var k int
		if _, err := fmt.Sscanf(key, "%d", &k); err != nil {
			return "", fmt.Errorf("invalid caesar key, must be integer: %w", err)
		}
		shift = -k
	}
	return c.shift(ciphertext, shift), nil
}

// --- Atbash Cipher ---

type AtbashCipher struct{}

func (AtbashCipher) Name() string { return "Atbash Cipher" }

func (AtbashCipher) transform(text string) string {
	var result strings.Builder
	for _, ch := range text {
		switch {
		case ch >= 'A' && ch <= 'Z':
			result.WriteRune('Z' - (ch - 'A'))
		case ch >= 'a' && ch <= 'z':
			result.WriteRune('z' - (ch - 'a'))
		default:
			result.WriteRune(ch)
		}
	}
	return result.String()
}

func (c AtbashCipher) Encrypt(plaintext string, _ string) (string, error) {
	return c.transform(plaintext), nil
}

func (c AtbashCipher) Decrypt(ciphertext string, _ string) (string, error) {
	return c.transform(ciphertext), nil
}

// --- Morse Code ---

type MorseCipher struct{}

func (MorseCipher) Name() string { return "Morse Code" }

var textToMorse = map[rune]string{
	'A': ".-", 'B': "-...", 'C': "-.-.", 'D': "-..", 'E': ".",
	'F': "..-.", 'G': "--.", 'H': "....", 'I': "..", 'J': ".---",
	'K': "-.-", 'L': ".-..", 'M': "--", 'N': "-.", 'O': "---",
	'P': ".--.", 'Q': "--.-", 'R': ".-.", 'S': "...", 'T': "-",
	'U': "..-", 'V': "...-", 'W': ".--", 'X': "-..-", 'Y': "-.--",
	'Z': "--..",
	'0': "-----", '1': ".----", '2': "..---", '3': "...--", '4': "....-",
	'5': ".....", '6': "-....", '7': "--...", '8': "---..", '9': "----.",
	'.': ".-.-.-", ',': "--..--", '?': "..--..", '!': "-.-.--",
	':': "---...", ';': "-.-.-.", '(': "-.--.", ')': "-.--.-",
	'"': ".-..-.", '@': ".--.-.",
}

var morseToText map[string]rune

func init() {
	morseToText = make(map[string]rune, len(textToMorse))
	for ch, morse := range textToMorse {
		morseToText[morse] = ch
	}
}

func (MorseCipher) Encrypt(plaintext string, _ string) (string, error) {
	var parts []string
	for _, ch := range strings.ToUpper(plaintext) {
		if ch == ' ' {
			parts = append(parts, "/")
			continue
		}
		morse, ok := textToMorse[ch]
		if !ok {
			return "", fmt.Errorf("cannot encode character %q in morse", ch)
		}
		parts = append(parts, morse)
	}
	return strings.Join(parts, " "), nil
}

func (MorseCipher) Decrypt(ciphertext string, _ string) (string, error) {
	var result strings.Builder
	words := strings.Split(ciphertext, "/")
	for wi, word := range words {
		if wi > 0 {
			result.WriteRune(' ')
		}
		letters := strings.Fields(word)
		for _, morse := range letters {
			ch, ok := morseToText[strings.TrimSpace(morse)]
			if !ok {
				return "", fmt.Errorf("unknown morse code %q", morse)
			}
			result.WriteRune(ch)
		}
	}
	return result.String(), nil
}

// --- Semaphore ---

type SemaphoreCipher struct{}

func (SemaphoreCipher) Name() string { return "Semaphore" }

var textToSemaphore = map[rune]string{
	'A': "1,2", 'B': "1,3", 'C': "1,4", 'D': "1,5", 'E': "1,6",
	'F': "1,7", 'G': "2,3", 'H': "2,4", 'I': "2,5", 'J': "2,6",
	'K': "2,7", 'L': "3,4", 'M': "3,5", 'N': "3,6", 'O': "3,7",
	'P': "4,5", 'Q': "4,6", 'R': "4,7", 'S': "5,6", 'T': "5,7",
	'U': "6,7", 'V': "1,8", 'W': "2,8", 'X': "3,8", 'Y': "4,8",
	'Z': "5,8",
}

var semaphoreToText map[string]rune

func init() {
	semaphoreToText = make(map[string]rune, len(textToSemaphore))
	for ch, sem := range textToSemaphore {
		semaphoreToText[sem] = ch
	}
}

func (SemaphoreCipher) Encrypt(plaintext string, _ string) (string, error) {
	var parts []string
	for _, ch := range strings.ToUpper(plaintext) {
		if ch == ' ' {
			parts = append(parts, "|")
			continue
		}
		sem, ok := textToSemaphore[ch]
		if !ok {
			return "", fmt.Errorf("cannot encode character %q in semaphore", ch)
		}
		parts = append(parts, sem)
	}
	return strings.Join(parts, " "), nil
}

func (SemaphoreCipher) Decrypt(ciphertext string, _ string) (string, error) {
	var result strings.Builder
	words := strings.Split(ciphertext, "|")
	for wi, word := range words {
		if wi > 0 {
			result.WriteRune(' ')
		}
		codes := strings.Fields(word)
		for _, code := range codes {
			code = strings.TrimSpace(code)
			if code == "" {
				continue
			}
			ch, ok := semaphoreToText[code]
			if !ok {
				return "", fmt.Errorf("unknown semaphore position %q", code)
			}
			result.WriteRune(ch)
		}
	}
	return result.String(), nil
}

// --- ROT13 ---

type ROT13Cipher struct{}

func (ROT13Cipher) Name() string { return "ROT13" }

func (ROT13Cipher) Encrypt(plaintext string, _ string) (string, error) {
	var result strings.Builder
	for _, ch := range plaintext {
		switch {
		case ch >= 'A' && ch <= 'Z':
			result.WriteRune(rune((int(ch-'A')+13)%26) + 'A')
		case ch >= 'a' && ch <= 'z':
			result.WriteRune(rune((int(ch-'a')+13)%26) + 'a')
		default:
			result.WriteRune(ch)
		}
	}
	return result.String(), nil
}

func (c ROT13Cipher) Decrypt(ciphertext string, _ string) (string, error) {
	return c.Encrypt(ciphertext, "")
}

// --- Vigenère Cipher ---

type VigenereCipher struct{}

func (VigenereCipher) Name() string { return "Vigenère Cipher" }

func (VigenereCipher) process(text string, key string, encrypt bool) (string, error) {
	if key == "" {
		return "", fmt.Errorf("vigenere cipher requires a key")
	}
	key = strings.ToUpper(key)
	if len(key) == 0 {
		return "", fmt.Errorf("key cannot be empty")
	}
	for _, k := range key {
		if k < 'A' || k > 'Z' {
			return "", fmt.Errorf("key must contain only letters")
		}
	}

	var result strings.Builder
	keyIdx := 0
	for _, ch := range text {
		var base rune
		var offset int
		switch {
		case ch >= 'A' && ch <= 'Z':
			base = 'A'
			offset = int(ch - 'A')
		case ch >= 'a' && ch <= 'z':
			base = 'a'
			offset = int(ch - 'a')
		default:
			result.WriteRune(ch)
			continue
		}

		k := int(key[keyIdx%len(key)] - 'A')
		if !encrypt {
			k = -k
		}
		offset = (offset + k%26 + 26) % 26
		result.WriteRune(base + rune(offset))
		keyIdx++
	}
	return result.String(), nil
}

func (c VigenereCipher) Encrypt(plaintext string, key string) (string, error) {
	return c.process(plaintext, key, true)
}

func (c VigenereCipher) Decrypt(ciphertext string, key string) (string, error) {
	return c.process(ciphertext, key, false)
}

// --- Base64 ---

type Base64Cipher struct{}

func (Base64Cipher) Name() string { return "Base64" }

func (Base64Cipher) Encrypt(plaintext string, _ string) (string, error) {
	return base64.StdEncoding.EncodeToString([]byte(plaintext)), nil
}

func (Base64Cipher) Decrypt(ciphertext string, _ string) (string, error) {
	data, err := base64.StdEncoding.DecodeString(ciphertext)
	if err != nil {
		return "", fmt.Errorf("invalid base64: %w", err)
	}
	return string(data), nil
}

// --- XOR Cipher ---

type XORCipher struct{}

func (XORCipher) Name() string { return "XOR Cipher" }

func (XORCipher) process(text string, key string) (string, error) {
	if key == "" {
		return "", fmt.Errorf("xor cipher requires a key")
	}
	keyBytes := []byte(key)
	if len(keyBytes) == 0 {
		return "", fmt.Errorf("key cannot be empty")
	}
	data := []byte(text)
	result := make([]byte, len(data))
	for i, b := range data {
		result[i] = b ^ keyBytes[i%len(keyBytes)]
	}
	return string(result), nil
}

func (c XORCipher) Encrypt(plaintext string, key string) (string, error) {
	return c.process(plaintext, key)
}

func (c XORCipher) Decrypt(ciphertext string, key string) (string, error) {
	return c.process(ciphertext, key)
}

// --- Reverse Text ---

type ReverseCipher struct{}

func (ReverseCipher) Name() string { return "Reverse Text" }

func (ReverseCipher) Encrypt(plaintext string, _ string) (string, error) {
	runes := []rune(plaintext)
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		runes[i], runes[j] = runes[j], runes[i]
	}
	return string(runes), nil
}

func (c ReverseCipher) Decrypt(ciphertext string, _ string) (string, error) {
	return c.Encrypt(ciphertext, "")
}

// --- Random Substitution ---

type SubstitutionCipher struct {
	key     string
}

const substitutionAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

func (SubstitutionCipher) Name() string { return "Substitution Cipher" }

func (c SubstitutionCipher) Encrypt(plaintext string, key string) (string, error) {
	if key == "" {
		key = shuffledAlphabet()
	}
	if len(key) != 26 || !allLetters(key) {
		return "", fmt.Errorf("substitution key must be a 26-letter permutation of A-Z")
	}
	keyUpper := strings.ToUpper(key)
	return c.substitute(plaintext, substitutionAlphabet, keyUpper), nil
}

func (c SubstitutionCipher) Decrypt(ciphertext string, key string) (string, error) {
	if key == "" {
		key = shuffledAlphabet()
	}
	if len(key) != 26 || !allLetters(key) {
		return "", fmt.Errorf("substitution key must be a 26-letter permutation of A-Z")
	}
	keyUpper := strings.ToUpper(key)
	return c.substitute(ciphertext, keyUpper, substitutionAlphabet), nil
}

func (SubstitutionCipher) substitute(text string, from string, to string) string {
	fromMap := make(map[rune]rune)
	for i, ch := range from {
		fromMap[ch] = rune(to[i])
	}
	var result strings.Builder
	for _, ch := range text {
		switch {
		case ch >= 'A' && ch <= 'Z':
			if sub, ok := fromMap[ch]; ok {
				result.WriteRune(sub)
			} else {
				result.WriteRune(ch)
			}
		case ch >= 'a' && ch <= 'z':
			upper := unicode.ToUpper(ch)
			if sub, ok := fromMap[upper]; ok {
				result.WriteRune(unicode.ToLower(sub))
			} else {
				result.WriteRune(ch)
			}
		default:
			result.WriteRune(ch)
		}
	}
	return result.String()
}

func shuffledAlphabet() string {
	letters := []rune(substitutionAlphabet)
	rand.Shuffle(len(letters), func(i, j int) {
		letters[i], letters[j] = letters[j], letters[i]
	})
	return string(letters)
}

func allLetters(s string) bool {
	if len(s) != 26 {
		return false
	}
	seen := make(map[rune]bool)
	for _, ch := range s {
		upper := unicode.ToUpper(ch)
		if upper < 'A' || upper > 'Z' {
			return false
		}
		if seen[upper] {
			return false
		}
		seen[upper] = true
	}
	return true
}
