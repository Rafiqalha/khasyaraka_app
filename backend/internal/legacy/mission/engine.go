package mission

import (
	"fmt"
	"math/rand"
	"time"
)

func GenerateMission(persona string) (*MissionState, error) {
	_, ok := GetPersonas()[persona]
	if !ok {
		persona = "beginner"
	}

	state := &MissionState{
		MissionID:        fmt.Sprintf("msn_%d", time.Now().Unix()),
		ServerHealth:     100,
		AttackerProgress: 0,
		TimeRemaining:    300,
		AttackerPersona:  persona,
		Phase:            "recon",
		Servers: []ServerNode{
			{ID: "server-01", Name: "Web Server", IP: "192.168.1.10", Services: []string{"nginx", "sshd", "mysql"}, IsBreached: false},
			{ID: "server-02", Name: "Database Server", IP: "192.168.1.20", Services: []string{"postgresql", "sshd"}, IsBreached: false},
		},
		FirewallRules: []FirewallRule{
			{ID: "fw-01", Action: "ALLOW", Source: "192.168.1.0/24", Dest: "ANY", Port: 0},
			{ID: "fw-02", Action: "DENY", Source: "ANY", Dest: "server-02", Port: 3306},
		},
	}

	baseLogs := generateNormalLogs(65)
	state.Logs = append(state.Logs, baseLogs...)

	return state, nil
}

func (s *MissionState) EvaluateTransitions(persona string) []EnvironmentEvent {
	cfg, ok := GetPersonas()[persona]
	if !ok {
		cfg = GetPersonas()["beginner"]
	}

	var triggered []EnvironmentEvent
	for _, t := range cfg.Transitions {
		if t.Condition(s) {
			t.Execute(s)
			evt := t.Event
			evt.Timestamp = now()
			triggered = append(triggered, evt)
		}
	}
	return triggered
}

func (s *MissionState) ProcessAction(action MissionAction) ActionResult {
	switch action.Type {
	case "search_logs":
		return s.handleSearchLogs(action)
	case "block_ip":
		return s.handleBlockIP(action)
	case "disable_process":
		return s.handleDisableProcess(action)
	case "add_firewall_rule":
		return s.handleFirewallRule(action)
	case "inspect_log":
		return s.handleInspectLog(action)
	case "terminal":
		return s.handleTerminalCommand(action)
	default:
		return ActionResult{Success: false, Message: "unknown action type", NewState: s}
	}
}

func (s *MissionState) handleSearchLogs(action MissionAction) ActionResult {
	query, _ := action.Payload["query"].(string)
	var filtered []LogEntry
	for _, l := range s.Logs {
		if containsStr(l.Message, query) || containsStr(l.SourceIP, query) || containsStr(l.Service, query) || containsStr(fmt.Sprintf("%d", l.Status), query) {
			filtered = append(filtered, l)
		}
	}
	return ActionResult{Success: true, Message: fmt.Sprintf("%d log(s) found", len(filtered)), NewState: s,
		Events: []EnvironmentEvent{{Type: "search", Severity: "info", Message: fmt.Sprintf("Query '%s' returned %d results", query, len(filtered))}},
	}
}

func (s *MissionState) handleBlockIP(action MissionAction) ActionResult {
	ip, _ := action.Payload["ip"].(string)
	for _, r := range s.BlockedIPs {
		if r == ip {
			return ActionResult{Success: false, Message: "IP already blocked", NewState: s, ScoreChange: -2}
		}
	}

	if ip == "192.168.1.105" {
		s.BlockedIPs = append(s.BlockedIPs, ip)
		s.AttackerProgress -= 30
		if s.AttackerProgress < 0 {
			s.AttackerProgress = 0
		}
		s.TimeRemaining += 60
		s.Phase = "mitigation"
		s.ServerHealth += 10
		return ActionResult{
			Success: true,
			Message: "✅ Attacker IP 192.168.1.105 blocked. Attack stalled. +60s added.",
			NewState: s,
			Events:  []EnvironmentEvent{{Type: "block_success", Severity: "info", Message: "IP 192.168.1.105 blocked — attack stalled", SourceIP: ip}},
			ScoreChange: 25,
		}
	}

	if ip == "192.168.1.10" {
		s.ServerHealth -= 40
		s.Score -= 30
		s.TimeRemaining -= 90
		return ActionResult{
			Success:   false,
			Message:   "❌ BLOCKED WEB SERVER ITSELF! 500 users disconnected. CEO angry.",
			NewState:  s,
			Events:    []EnvironmentEvent{{Type: "block_fail", Severity: "critical", Message: "CRITICAL: Blocked own server IP — 500 users disconnected", SourceIP: ip}},
			ScoreChange: -30,
		}
	}

	s.BlockedIPs = append(s.BlockedIPs, ip)
	return ActionResult{Success: true, Message: fmt.Sprintf("IP %s blocked (no effect on attack)", ip), NewState: s, ScoreChange: -5, Events: []EnvironmentEvent{{Type: "block_neutral", Severity: "info", Message: fmt.Sprintf("IP %s blocked — no effect", ip)}}}
}

func (s *MissionState) handleDisableProcess(action MissionAction) ActionResult {
	pid, _ := action.Payload["pid"].(float64)
	for i, p := range s.Processes {
		if p.PID == int(pid) && p.IsThreat {
			s.Processes = append(s.Processes[:i], s.Processes[i+1:]...)
			s.AttackerProgress -= 25
			s.ServerHealth += 15
			return ActionResult{Success: true, Message: fmt.Sprintf("✅ Malicious process PID %d terminated. Attack disrupted.", int(pid)), NewState: s, ScoreChange: 20, Events: []EnvironmentEvent{{Type: "process_killed", Severity: "info", Message: fmt.Sprintf("Process PID %d (%s) terminated", int(pid), p.Name)}}}
		}
	}
	return ActionResult{Success: false, Message: "Process not found or not malicious", NewState: s, ScoreChange: -2}
}

func (s *MissionState) handleFirewallRule(action MissionAction) ActionResult {
	actionStr, _ := action.Payload["action"].(string)
	source, _ := action.Payload["source"].(string)
	port, _ := action.Payload["port"].(float64)

	rule := FirewallRule{ID: fmt.Sprintf("fw-%d", len(s.FirewallRules)+1), Action: actionStr, Source: source, Port: int(port)}
	s.FirewallRules = append(s.FirewallRules, rule)

	if actionStr == "DENY" && source == "192.168.1.105" {
		s.BlockedIPs = append(s.BlockedIPs, "192.168.1.105")
		s.AttackerProgress -= 35
		return ActionResult{Success: true, Message: "✅ Firewall DENY rule added for attacker IP.", NewState: s, ScoreChange: 20, Events: []EnvironmentEvent{{Type: "firewall", Severity: "info", Message: "Firewall rule DENY 192.168.1.105 applied"}}}
	}
	return ActionResult{Success: true, Message: "Firewall rule added.", NewState: s}
}

func (s *MissionState) handleInspectLog(action MissionAction) ActionResult {
	id, _ := action.Payload["id"].(float64)
	for _, l := range s.Logs {
		if l.ID == int(id) {
			return ActionResult{
				Success: true,
				Message: fmt.Sprintf("Log %d inspected: %s", l.ID, l.Message),
				NewState: s,
				Events:   []EnvironmentEvent{{
					Type:     "inspect",
					Severity: "info",
					Message:  fmt.Sprintf("[%s] %s %s %d — %s", l.Timestamp, l.Server, l.Service, l.Status, l.Message),
					SourceIP: l.SourceIP,
				}},
			}
		}
	}
	return ActionResult{Success: false, Message: "Log not found", NewState: s}
}

func (s *MissionState) handleTerminalCommand(action MissionAction) ActionResult {
	cmd, _ := action.Payload["command"].(string)
	server, _ := action.Payload["server"].(string)

	output := executeSandboxCommand(server, cmd)
	return ActionResult{Success: true, Message: output, NewState: s, Events: []EnvironmentEvent{{Type: "terminal", Severity: "info", Message: fmt.Sprintf("$ %s\n%s", cmd, output)}}}
}

func executeSandboxCommand(server, cmd string) string {
	switch {
	case containsStr(cmd, "grep"):
		return "root:192.168.1.105:22:ssh2\nwww-data:45.33.32.156:443:tls\n"
	case containsStr(cmd, "cat"):
		return "GET /login?id=15 200\nPOST /login 302\nGET /login?id='OR 1=1-- 500\n"
	case containsStr(cmd, "ls"):
		return "access.log  error.log  auth.log  mimikatz.dmp\n"
	case containsStr(cmd, "ps"):
		return "PID 9876 mimikatz.exe - SYSTEM\nPID 5555 exploit_cve.sh - www-data\n"
	case containsStr(cmd, "netstat"):
		return "tcp 192.168.1.105:22 ESTABLISHED\ntcp 45.33.32.156:443 ESTABLISHED\n"
	default:
		return fmt.Sprintf("Command '%s' executed on %s", cmd, server)
	}
}

func generateNormalLogs(count int) []LogEntry {
	var logs []LogEntry
	services := []string{"nginx", "sshd", "mysql", "postgresql"}
	messages := []string{
		"GET /index.html HTTP/1.1 200 OK",
		"POST /login HTTP/1.1 302 Found",
		"GET /api/status HTTP/1.1 200 OK",
		"Accepted publickey for admin from 192.168.1.50",
		"SELECT * FROM users WHERE id=15",
		"UPDATE sessions SET last_active=NOW()",
		"GET /dashboard HTTP/1.1 200 OK",
		"Normal cron job executed",
		"SSL handshake completed",
		"Health check ping from monitoring",
	}

	ips := []string{"192.168.1.50", "192.168.1.55", "192.168.1.60", "10.0.0.1", "10.0.0.2"}
	for i := 0; i < count; i++ {
		logs = append(logs, LogEntry{
			ID:        i + 1,
			Timestamp: fmt.Sprintf("10:%02d:%02d", rand.Intn(12), rand.Intn(60)),
			Server:    fmt.Sprintf("server-%02d", rand.Intn(2)+1),
			SourceIP:  ips[rand.Intn(len(ips))],
			Service:   services[rand.Intn(len(services))],
			Status:    200,
			Message:   messages[rand.Intn(len(messages))],
			IsAnomaly: false,
		})
	}
	return logs
}

func containsStr(s, substr string) bool {
	if substr == "" {
		return true
	}
	for i := 0; i <= len(s)-len(substr); i++ {
		match := true
		for j := 0; j < len(substr); j++ {
			if toLower(s[i+j]) != toLower(substr[j]) {
				match = false
				break
			}
		}
		if match {
			return true
		}
	}
	return false
}

func toLower(c byte) byte {
	if c >= 'A' && c <= 'Z' {
		return c + 32
	}
	return c
}
