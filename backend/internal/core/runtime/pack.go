package runtime

import (
	"context"
)

// PackNode represents the runtime state and initial data of a node, fetched from a Pack.
type PackNode struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	InitialCode string `json:"initialCode"`
	Language    string `json:"language"`
}

// PackRuntime is the abstraction layer over the Learning Packs.
// For the MVP, it might fetch directly from a simulated JSON mapping or DB,
// but the interface ensures the frontend/backend doesn't couple directly to DB models.
type PackRuntime interface {
	GetNode(ctx context.Context, nodeID string) (*PackNode, error)
}

// MemoryPackRuntime is a temporary MVP implementation that provides static node data.
// In the future, this will parse the actual Pack manifests and extract the node data.
type MemoryPackRuntime struct {
	nodes map[string]*PackNode
}

func NewMemoryPackRuntime() *MemoryPackRuntime {
	return &MemoryPackRuntime{
		nodes: map[string]*PackNode{
			"mission_log_analysis": {
				ID:    "mission_log_analysis",
				Title: "Log Analysis & Anomaly Detection",
				Description: `### 📌 Tujuan Misi
Mendeteksi serangan **Brute Force Attempt** pada server dengan menganalisis catatan log akses harian.

### 📖 Konteks & Skenario
Tim Keamanan Cyber (SOC) mendeteksi adanya lonjakan traffic mencurigakan pada endpoint autentikasi. Penyerang diduga mencoba menebak kata sandi dengan melancarkan ribuan request dalam waktu singkat.
Sebagai analis keamanan, tugasmu adalah menulis fungsi yang dapat mengekstrak alamat IP penyerang dari daftar baris log.

### 💡 Aturan Evaluasi
1. Fungsi ` + "`analyze_logs(log_lines)`" + ` menerima parameter ` + "`log_lines`" + ` (list berisi string baris log).
2. Hitung berapa kali setiap alamat IP mengalami **kegagalan login** (ditandai dengan HTTP Status Code ` + "`401`" + ` di akhir baris).
3. Kembalikan list berisi alamat IP yang gagal login **lebih dari 5 kali** ( > 5 kali).

### 🔍 Contoh Data Log
` + "```" + `
192.168.1.10 - - POST /login HTTP/1.1 - 401
192.168.1.10 - - POST /login HTTP/1.1 - 401
10.0.0.5 - - POST /login HTTP/1.1 - 200
` + "```" + `
*Tips: Gunakan dictionary di Python untuk memetakan jumlah kegagalan per IP.*`,
				InitialCode: `def analyze_logs(log_lines):
    # TODO: Hitung berapa kali setiap IP mengalami gagal login (status 401).
    # Kembalikan list alamat IP yang gagal login lebih dari 5 kali (> 5).
    failed_counts = {}
    
    for line in log_lines:
        parts = line.split()
        if len(parts) >= 6 and parts[-1] == '401':
            ip = parts[0]
            failed_counts[ip] = failed_counts.get(ip, 0) + 1
            
    # Saring IP dengan > 5 kegagalan
    suspicious_ips = [ip for ip, count in failed_counts.items() if count > 5]
    return suspicious_ips

# =====================================================================
# SYSTEM AUTO-EVALUATOR (Jangan ubah kode di bawah ini)
# =====================================================================
if __name__ == '__main__':
    test_data = [
        "192.168.1.10 - - POST /login HTTP/1.1 - 401",
        "192.168.1.10 - - POST /login HTTP/1.1 - 401",
        "192.168.1.10 - - POST /login HTTP/1.1 - 401",
        "192.168.1.10 - - POST /login HTTP/1.1 - 401",
        "192.168.1.10 - - POST /login HTTP/1.1 - 401",
        "192.168.1.10 - - POST /login HTTP/1.1 - 401", # 6x gagal -> terdeteksi
        "10.0.0.5 - - POST /login HTTP/1.1 - 200",     # Sukses login
        "10.0.0.5 - - POST /login HTTP/1.1 - 401",     # 1x gagal -> aman
        "172.16.0.8 - - POST /login HTTP/1.1 - 401",
    ]
    
    print("[*] Menjalankan simulasi evaluasi log analysis...")
    result = analyze_logs(test_data)
    print(f"[*] Hasil deteksi IP mencurigakan: {result}")
    
    assert '192.168.1.10' in result, "TEST FAILED: IP 192.168.1.10 seharusnya terdeteksi!"
    assert '10.0.0.5' not in result, "TEST FAILED: IP 10.0.0.5 tidak boleh terdeteksi!"
    assert len(result) == 1, "TEST FAILED: Jumlah IP terdeteksi tidak tepat!"
    print("\n✅ PASSED! Semua uji kompetensi berhasil dilewati.")
`,
				Language: "python",
			},
			"mission_network_recon": {
				ID:    "mission_network_recon",
				Title: "Network Reconnaissance",
				Description: `### 📌 Tujuan Misi
Melakukan pemetaan jaringan internal dan mengidentifikasi port terbuka pada server target menggunakan simulasi pemindaian port.

### 📖 Konteks & Skenario
Sebelum mengamankan jaringan, seorang analis keamanan harus mengetahui layanan apa saja yang aktif dan berpotensi menjadi titik masuk serangan (attack surface).
Tulis skrip Python yang memeriksa daftar port target dan memfilter port mana saja yang berstatus **OPEN**.

### 💡 Aturan Evaluasi
1. Lengkapi fungsi ` + "`scan_ports(target_host, ports)`" + `.
2. Fungsi menerima host (string) dan list port angka (integers).
3. Untuk simulasi ini, anggap port **22 (SSH)**, **80 (HTTP)**, dan **443 (HTTPS)** adalah port terbuka. Port lainnya tertutup.
4. Kembalikan list port yang terbuka.`,
				InitialCode: `def scan_ports(target_host, ports):
    # TODO: Periksa port mana saja yang terbuka pada target_host.
    # Untuk simulasi, port terbuka adalah: 22, 80, dan 443.
    open_ports = []
    known_open = {22, 80, 443}
    
    for port in ports:
        if port in known_open:
            open_ports.append(port)
            
    return open_ports

# =====================================================================
# SYSTEM AUTO-EVALUATOR (Jangan ubah kode di bawah ini)
# =====================================================================
if __name__ == '__main__':
    target = "10.10.5.100"
    test_ports = [21, 22, 23, 25, 80, 443, 8080]
    
    print(f"[*] Menjalankan port scanner terhadap {target}...")
    result = scan_ports(target, test_ports)
    print(f"[*] Port terbuka terdeteksi: {result}")
    
    assert result == [22, 80, 443], f"TEST FAILED: Harap kembalikan [22, 80, 443], didapat {result}"
    print("\n✅ PASSED! Reconnaissance berhasil dipetakan.")
`,
				Language: "python",
			},
			"mission_vuln_scanning": {
				ID:    "mission_vuln_scanning",
				Title: "Vulnerability Assessment",
				Description: `### 📌 Tujuan Misi
Menganalisis header layanan (service banner) untuk menemukan versi perangkat lunak yang memiliki kerentanan kritis (CVE).

### 📖 Konteks & Skenario
Pemindaian kerentanan mendeteksi server web menjalankan layanan Apache tua yang rentan terhadap serangan Remote Code Execution.
Tulis fungsi untuk memeriksa banner server dan menandai apakah sistem berstatus **VULNERABLE** atau **SECURE**.

### 💡 Aturan Evaluasi
1. Fungsi ` + "`check_vulnerability(banner)`" + ` menerima string banner layanan.
2. Jika banner mengandung kata ` + "`Apache/2.2`" + ` atau ` + "`OpenSSL/1.0.1`" + `, fungsi mengembalikan string ` + "`VULNERABLE`" + `.
3. Selain itu, kembalikan ` + "`SECURE`" + `.`,
				InitialCode: `def check_vulnerability(banner):
    # TODO: Periksa apakah banner mengandung versi rentan ("Apache/2.2" atau "OpenSSL/1.0.1").
    # Kembalikan "VULNERABLE" jika rentan, atau "SECURE" jika aman.
    if "Apache/2.2" in banner or "OpenSSL/1.0.1" in banner:
        return "VULNERABLE"
    return "SECURE"

# =====================================================================
# SYSTEM AUTO-EVALUATOR
# =====================================================================
if __name__ == '__main__':
    banners = [
        "Apache/2.2.15 (CentOS)",
        "nginx/1.24.0",
        "OpenSSL/1.0.1g-heartbleed",
        "Apache/2.4.58 (Ubuntu)"
    ]
    
    print("[*] Menganalisis kerentanan banner layanan...")
    results = [check_vulnerability(b) for b in banners]
    print(f"[*] Hasil pemindaian: {results}")
    
    assert results == ["VULNERABLE", "SECURE", "VULNERABLE", "SECURE"], "TEST FAILED: Analisis banner tidak akurat!"
    print("\n✅ PASSED! Penilaian kerentanan selesai.")
`,
				Language: "python",
			},
			"mission_incident_response": {
				ID:    "mission_incident_response",
				Title: "Incident Response Drill",
				Description: `### 📌 Tujuan Misi
Melakukan isolasi cepat (Containment) terhadap alamat IP penyerang yang sedang melakukan peretasan aktif.

### 📖 Konteks & Skenario
Peringatan IDS berbunyi: Host internal ` + "`192.168.1.50`" + ` sedang mengunduh malware dari IP berbahaya ` + "`45.33.32.156`" + `.
Dalam simulasi ini, kamu bertugas membuat skrip aturan pemblokiran firewall untuk mengisolasi ancaman sebelum menyebar.

### 💡 Aturan Evaluasi
1. Lengkapi fungsi ` + "`generate_block_rule(attacker_ip)`" + `.
2. Fungsi mengembalikan string aturan pemblokiran firewall standar: ` + "`DROP <attacker_ip>`" + `.`,
				InitialCode: `def generate_block_rule(attacker_ip):
    # TODO: Kembalikan format aturan firewall untuk memblokir IP
    # Format yang diharapkan: "DROP <attacker_ip>"
    return f"DROP {attacker_ip}"

# =====================================================================
# SYSTEM AUTO-EVALUATOR
# =====================================================================
if __name__ == '__main__':
    ip = "45.33.32.156"
    print(f"[*] Membuat aturan isolasi untuk IP ancaman {ip}...")
    rule = generate_block_rule(ip)
    print(f"[*] Aturan firewall aktif: {rule}")
    
    assert rule == "DROP 45.33.32.156", f"TEST FAILED: Aturan firewall salah, didapat: {rule}"
    print("\n✅ PASSED! Ancaman berhasil diisolasi (Containment Successful).")
`,
				Language: "python",
			},
			"mission_cryptography_basics": {
				ID:    "mission_cryptography_basics",
				Title: "Applied Cryptography",
				Description: `### 📌 Tujuan Misi
Memverifikasi integritas file bukti digital (digital evidence) menggunakan algoritma hashing kriptografi **SHA-256**.

### 📖 Konteks & Skenario
Dalam investigasi forensik, kamu harus memastikan file barang bukti tidak dimodifikasi oleh pihak tidak bertanggung jawab selama proses analisis.
Tulis fungsi untuk menghitung hash SHA-256 dari teks data dan membandingkannya dengan hash asli.

### 💡 Aturan Evaluasi
1. Lengkapi fungsi ` + "`verify_integrity(data, expected_hash)`" + `.
2. Gunakan modul pustaka standar ` + "`hashlib`" + `.
3. Kembalikan boolean ` + "`True`" + ` jika hash cocok, atau ` + "`False`" + ` jika tidak cocok.`,
				InitialCode: `import hashlib

def verify_integrity(data, expected_hash):
    # TODO: Hitung SHA-256 dari string data dan bandingkan dengan expected_hash
    computed_hash = hashlib.sha256(data.encode('utf-8')).hexdigest()
    return computed_hash == expected_hash

# =====================================================================
# SYSTEM AUTO-EVALUATOR
# =====================================================================
if __name__ == '__main__':
    sample_data = "CONFIDENTIAL_EVIDENCE_LOG_2026"
    # SHA-256 yang benar untuk string di atas
    valid_hash = hashlib.sha256(sample_data.encode()).hexdigest()
    
    print("[*] Memverifikasi integritas barang bukti digital...")
    is_valid = verify_integrity(sample_data, valid_hash)
    print(f"[*] Status integritas: {'VALID' if is_valid else 'COMPROMISED'}")
    
    assert is_valid == True, "TEST FAILED: Verifikasi gagal untuk hash yang sah!"
    assert verify_integrity("MODIFIED_DATA", valid_hash) == False, "TEST FAILED: Seharusnya menolak data yang telah diubah!"
    print("\n✅ PASSED! Integritas bukti kriptografi terverifikasi.")
`,
				Language: "python",
			},
		},
	}
}

func (m *MemoryPackRuntime) GetNode(ctx context.Context, nodeID string) (*PackNode, error) {
	node, exists := m.nodes[nodeID]
	if !exists {
		if defaultNode, ok := m.nodes["mission_log_analysis"]; ok {
			return defaultNode, nil
		}
		return &PackNode{
			ID:          "mission_log_analysis",
			Title:       "Log Analysis & Anomaly Detection",
			Description: "Analisis log sistem access.log untuk menemukan aktivitas percobaan login mencurigakan.",
			InitialCode: "def analyze_logs(log_lines):\n    pass\n",
			Language:    "python",
		}, nil
	}
	return node, nil
}
