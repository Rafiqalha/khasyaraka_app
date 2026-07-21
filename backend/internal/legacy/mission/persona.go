package mission

import (
	"fmt"
	"math/rand"
	"time"
)

func GetPersonas() map[string]PersonaConfig {
	return map[string]PersonaConfig{
		"beginner":     beginnerPersona(),
		"scriptkiddie": scriptKiddiePersona(),
		"apt":          aptPersona(),
	}
}

func beginnerPersona() PersonaConfig {
	p := PersonaConfig{
		ID:          "beginner",
		Name:        "Rookie Attacker",
		Description: "Lambat, no stealth, predictable. Mulai dari port scan, brute force dasar.",
		AttackSpeed: 25,
		Stealth:     false,
		Vectors:     []string{"port_scan", "brute_force"},
	}

	p.Transitions = []StateTransition{
		{
			ID: "b1_port_scan",
			Condition: func(s *MissionState) bool {
				return s.Phase == "recon" && s.AttackerProgress < 20
			},
			Execute: func(s *MissionState) {
				s.Phase = "scanning"
				s.AttackerProgress = 20
				s.RecentEvents = append(s.RecentEvents, fmt.Sprintf("[%s] Port scan detected from %s", now(), s.Servers[0].IP))
				s.ActiveThreats = append(s.ActiveThreats, "port_scan")
			},
			Event: EnvironmentEvent{Type: "port_scan", Severity: "low", Message: "Port scan detected from external IP", ServerID: "server-01", SourceIP: randomIP()},
		},
		{
			ID: "b2_brute_force",
			Condition: func(s *MissionState) bool {
				return s.Phase == "scanning" && s.AttackerProgress < 50
			},
			Execute: func(s *MissionState) {
				s.Phase = "bruteforcing"
				s.AttackerProgress = 50
				s.Logs = append(s.Logs, generateBruteForceLogs(10)...)
				s.RecentEvents = append(s.RecentEvents, fmt.Sprintf("[%s] Brute force SSH attempt", now()))
				s.ActiveThreats = append(s.ActiveThreats, "brute_force")
			},
			Event: EnvironmentEvent{Type: "brute_force", Severity: "medium", Message: "Multiple failed SSH login attempts", ServerID: "server-01"},
		},
		{
			ID: "b3_credential_dump",
			Condition: func(s *MissionState) bool {
				return s.Phase == "bruteforcing" && s.AttackerProgress < 75
			},
			Execute: func(s *MissionState) {
				s.Phase = "cred_dumping"
				s.AttackerProgress = 75
				s.Processes = append(s.Processes, ActiveProcess{PID: 9876, Name: "mimikatz.exe", User: "SYSTEM", IsThreat: true})
				s.RecentEvents = append(s.RecentEvents, fmt.Sprintf("[%s] Suspicious process detected: mimikatz.exe", now()))
			},
			Event: EnvironmentEvent{Type: "credential_dump", Severity: "high", Message: "Mimikatz credential dumping detected", ServerID: "server-01"},
		},
		{
			ID: "b4_ransomware",
			Condition: func(s *MissionState) bool {
				return s.Phase == "cred_dumping" && s.AttackerProgress >= 75 && s.TimeRemaining < 60
			},
			Execute: func(s *MissionState) {
				s.Phase = "ransomware"
				s.AttackerProgress = 100
				s.ServerHealth = 0
				s.BreachedServers = append(s.BreachedServers, "server-01")
				s.RecentEvents = append(s.RecentEvents, fmt.Sprintf("[%s] 🎯 RANSOMWARE DEPLOYED — Database encrypted", now()))
			},
			Event: EnvironmentEvent{Type: "ransomware", Severity: "critical", Message: "Ransomware deployed on server-01", ServerID: "server-01"},
		},
	}
	return p
}

func scriptKiddiePersona() PersonaConfig {
	p := PersonaConfig{
		ID:          "scriptkiddie",
		Name:        "Script Kiddie",
		Description: "Tool-based, noisy, fast. SQLi, brute force, known exploits.",
		AttackSpeed: 18,
		Stealth:     false,
		Vectors:     []string{"sqli", "brute_force", "known_exploit"},
	}

	p.Transitions = []StateTransition{
		{
			ID: "sk1_recon",
			Condition: func(s *MissionState) bool {
				return s.Phase == "recon" && s.AttackerProgress < 15
			},
			Execute: func(s *MissionState) {
				s.Phase = "scanning"
				s.AttackerProgress = 15
				s.Logs = append(s.Logs, generateScanLogs(8)...)
				s.ActiveThreats = append(s.ActiveThreats, "port_scan")
			},
			Event: EnvironmentEvent{Type: "port_scan", Severity: "low", Message: "Rapid port scan detected", ServerID: "server-01"},
		},
		{
			ID: "sk2_sqli",
			Condition: func(s *MissionState) bool {
				return s.Phase == "scanning" && s.AttackerProgress < 40
			},
			Execute: func(s *MissionState) {
				s.Phase = "sqli"
				s.AttackerProgress = 40
				s.Logs = append(s.Logs, generateSQLLogs(6)...)
				s.ActiveThreats = append(s.ActiveThreats, "sqli_attack")
			},
			Event: EnvironmentEvent{Type: "sqli", Severity: "high", Message: "SQL injection attempts on web server", ServerID: "server-01"},
		},
		{
			ID: "sk3_exploit",
			Condition: func(s *MissionState) bool {
				return s.Phase == "sqli" && s.AttackerProgress < 70
			},
			Execute: func(s *MissionState) {
				s.Phase = "exploiting"
				s.AttackerProgress = 70
				s.ServerHealth -= 20
				s.Logs = append(s.Logs, generateExploitLogs(4)...)
				s.Processes = append(s.Processes, ActiveProcess{PID: 5555, Name: "exploit_cve.sh", User: "www-data", IsThreat: true})
			},
			Event: EnvironmentEvent{Type: "exploit", Severity: "critical", Message: "CVE-2024 exploit executed — server compromised", ServerID: "server-01"},
		},
		{
			ID: "sk4_ransomware",
			Condition: func(s *MissionState) bool {
				return s.Phase == "exploiting" && s.AttackerProgress >= 70 && s.TimeRemaining < 45
			},
			Execute: func(s *MissionState) {
				s.Phase = "ransomware"
				s.AttackerProgress = 100
				s.ServerHealth = 0
				s.BreachedServers = append(s.BreachedServers, "server-01", "server-02")
			},
			Event: EnvironmentEvent{Type: "ransomware", Severity: "critical", Message: "Multi-server ransomware deployment detected", ServerID: "server-01"},
		},
	}
	return p
}

func aptPersona() PersonaConfig {
	p := PersonaConfig{
		ID:          "apt",
		Name:        "APT Group",
		Description: "Stealth, Living off the Land, persistence. Cred dump → lateral movement → exfil.",
		AttackSpeed: 30,
		Stealth:     true,
		Vectors:     []string{"cred_dump", "lateral_movement", "persistence", "exfil"},
	}

	p.Transitions = []StateTransition{
		{
			ID: "apt1_stealth_recon",
			Condition: func(s *MissionState) bool {
				return s.Phase == "recon" && s.AttackerProgress < 10
			},
			Execute: func(s *MissionState) {
				s.Phase = "scanning"
				s.AttackerProgress = 10
				s.Logs = append(s.Logs, generateStealthReconLogs(5)...)
			},
			Event: EnvironmentEvent{Type: "recon", Severity: "low", Message: "Low-and-slow reconnaissance activity", ServerID: "server-01"},
		},
		{
			ID: "apt2_cred_dump",
			Condition: func(s *MissionState) bool {
				return s.Phase == "scanning" && s.AttackerProgress < 35
			},
			Execute: func(s *MissionState) {
				s.Phase = "cred_access"
				s.AttackerProgress = 35
				s.Processes = append(s.Processes, ActiveProcess{PID: 7777, Name: "powershell.exe", User: "svc_backup", IsThreat: true})
				s.Logs = append(s.Logs, generateAPTLogs(4)...)
			},
			Event: EnvironmentEvent{Type: "cred_access", Severity: "high", Message: "LSASS credential dumping via PowerShell", ServerID: "server-01", SourceIP: "192.168.1.105"},
		},
		{
			ID: "apt3_lateral",
			Condition: func(s *MissionState) bool {
				return s.Phase == "cred_access" && s.AttackerProgress < 60
			},
			Execute: func(s *MissionState) {
				s.Phase = "lateral"
				s.AttackerProgress = 60
				s.Servers[1].IsBreached = true
				s.BreachedServers = append(s.BreachedServers, "server-02")
				s.Logs = append(s.Logs, generateLateralMovementLogs(6)...)
				s.Processes = append(s.Processes, ActiveProcess{PID: 8888, Name: "wmi.exe", User: "SYSTEM", IsThreat: true})
			},
			Event: EnvironmentEvent{Type: "lateral_movement", Severity: "critical", Message: "Lateral movement detected — server-02 compromised", ServerID: "server-02", SourceIP: "192.168.1.105"},
		},
		{
			ID: "apt4_persistence",
			Condition: func(s *MissionState) bool {
				return s.Phase == "lateral" && s.AttackerProgress < 85
			},
			Execute: func(s *MissionState) {
				s.Phase = "persistence"
				s.AttackerProgress = 85
				s.ServerHealth -= 15
				s.Logs = append(s.Logs, generatePersistenceLogs(3)...)
			},
			Event: EnvironmentEvent{Type: "persistence", Severity: "high", Message: "Scheduled task persistence established", ServerID: "server-02"},
		},
		{
			ID: "apt5_exfil",
			Condition: func(s *MissionState) bool {
				return s.Phase == "persistence" && s.AttackerProgress >= 85 && s.TimeRemaining < 90
			},
			Execute: func(s *MissionState) {
				s.Phase = "exfil"
				s.AttackerProgress = 100
				s.ServerHealth = 10
				s.RecentEvents = append(s.RecentEvents, fmt.Sprintf("[%s] 🔴 2GB data exfiltration to 45.33.32.156", now()))
			},
			Event: EnvironmentEvent{Type: "exfil", Severity: "critical", Message: "Large data exfiltration detected", ServerID: "server-01"},
		},
	}
	return p
}

func generateBruteForceLogs(count int) []LogEntry {
	var logs []LogEntry
	for i := 0; i < count; i++ {
		logs = append(logs, LogEntry{
			ID: rand.Intn(9000) + 1000, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(5), rand.Intn(60)),
			Server: "server-01", SourceIP: "192.168.1.105", Service: "sshd",
			Status: 401, Message: "Failed password for root from 192.168.1.105 port 22 ssh2", IsAnomaly: true,
		})
	}
	return logs
}

func generateScanLogs(count int) []LogEntry {
	var logs []LogEntry
	for i := 0; i < count; i++ {
		port := []int{22, 80, 443, 3389, 8080}[rand.Intn(5)]
		logs = append(logs, LogEntry{
			ID: rand.Intn(9000) + 1000, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(3), rand.Intn(60)),
			Server: "server-01", SourceIP: "45.33.32.156", Service: fmt.Sprintf("tcp/%d", port),
			Status: 0, Message: fmt.Sprintf("Connection attempt to port %d from 45.33.32.156", port), IsAnomaly: true,
		})
	}
	return logs
}

func generateSQLLogs(count int) []LogEntry {
	var logs []LogEntry
	for i := 0; i < count; i++ {
		logs = append(logs, LogEntry{
			ID: rand.Intn(9000) + 1000, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(5), rand.Intn(60)),
			Server: "server-01", SourceIP: "192.168.1.105", Service: "nginx",
			Status: 500, Message: "GET /login?id=' OR 1=1-- HTTP/1.1 500 Internal Server Error", IsAnomaly: true,
		})
	}
	return logs
}

func generateExploitLogs(count int) []LogEntry {
	return []LogEntry{
		{ID: 9001, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(3), rand.Intn(60)), Server: "server-01", SourceIP: "192.168.1.105", Service: "kernel", Status: 0, Message: "CVE-2024-1234 exploit attempt detected: buffer overflow in web service", IsAnomaly: true},
		{ID: 9002, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(3), rand.Intn(60)), Server: "server-01", SourceIP: "192.168.1.105", Service: "www", Status: 0, Message: "Shell spawned: /bin/bash -i via exploited web process", IsAnomaly: true},
	}
}

func generateStealthReconLogs(count int) []LogEntry {
	var logs []LogEntry
	services := []string{"sshd", "nginx", "mysql", "postgresql"}
	for i := 0; i < count; i++ {
		logs = append(logs, LogEntry{
			ID: rand.Intn(9000) + 1000, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(8)+2, rand.Intn(60)),
			Server: "server-01", SourceIP: "10.0.0.99", Service: services[rand.Intn(4)],
			Status: 200, Message: "Normal connection", IsAnomaly: false,
		})
	}
	return logs
}

func generateAPTLogs(count int) []LogEntry {
	return []LogEntry{
		{ID: 8001, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(5)+3, rand.Intn(60)), Server: "server-01", SourceIP: "192.168.1.105", Service: "windows", Status: 0, Message: "PowerShell encoded command executed", IsAnomaly: true},
		{ID: 8002, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(5)+3, rand.Intn(60)), Server: "server-01", SourceIP: "localhost", Service: "lsass", Status: 0, Message: "Process lsass.exe accessed by powershell.exe", IsAnomaly: true},
	}
}

func generateLateralMovementLogs(count int) []LogEntry {
	return []LogEntry{
		{ID: 7001, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(3)+6, rand.Intn(60)), Server: "server-02", SourceIP: "192.168.1.105", Service: "wmi", Status: 0, Message: "Remote WMI execution from server-01", IsAnomaly: true},
		{ID: 7002, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(3)+6, rand.Intn(60)), Server: "server-02", SourceIP: "192.168.1.105", Service: "smb", Status: 0, Message: "SMB share accessed: \\\\SERVER-02\\ADMIN$", IsAnomaly: true},
		{ID: 7003, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(3)+6, rand.Intn(60)), Server: "server-02", SourceIP: "localhost", Service: "schtasks", Status: 0, Message: "New scheduled task created: WindowsUpdate", IsAnomaly: true},
	}
}

func generatePersistenceLogs(count int) []LogEntry {
	return []LogEntry{
		{ID: 6001, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(2)+8, rand.Intn(60)), Server: "server-02", SourceIP: "localhost", Service: "registry", Status: 0, Message: "Registry key added: HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\winupd", IsAnomaly: true},
		{ID: 6002, Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(2)+8, rand.Intn(60)), Server: "server-02", SourceIP: "localhost", Service: "svchost", Status: 0, Message: "New service installed: WindowsUpdateSvc", IsAnomaly: true},
	}
}

func randomIP() string {
	return fmt.Sprintf("%d.%d.%d.%d", rand.Intn(223)+1, rand.Intn(256), rand.Intn(256), rand.Intn(254)+1)
}

func now() string {
	return time.Now().Format("15:04:05")
}
