package mission

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/pradigi/backend/internal/ai_agent"
)

type MissionAI struct {
	client *ai_agent.Client
}

func NewMissionAI(apiKey, model string) *MissionAI {
	return &MissionAI{client: ai_agent.NewClient(apiKey, model)}
}

type AIAttackerDecision struct {
	Action         string `json:"action"`
	Target         string `json:"target"`
	Severity       string `json:"severity"`
	Message        string `json:"message"`
	ProgressDelta  int    `json:"progress_delta"`
	NewLogContent  string `json:"new_log_content"`
	NewProcessName string `json:"new_process_name"`
	NewProcessPID  int    `json:"new_process_pid"`
	TargetServerID string `json:"target_server_id"`
}

func (ai *MissionAI) DecideNextMove(ctx context.Context, state *MissionState) (*AIAttackerDecision, error) {
	sysPrompt := fmt.Sprintf(`
[MISSION CONTEXT]
You are the ATTACKER. You have access to the following live state:
- Server Health: %d%%
- Attacker Progress: %d%%
- Current Phase: %s
- Time Remaining: %d seconds
- Active Threats: %s
- Blocked IPs: %s
- Breached Servers: %s
- Persona: %s
- Recent Events: %s

Decide the NEXT attacker action. Output ONLY valid JSON — no markdown, no explanation.

Output format:
{
  "action": "brute_force|port_scan|sqli|exploit|cred_dump|lateral|persistence|exfil|ransomware|wait",
  "target": "ssh|nginx|mysql|postgresql|kernel",
  "severity": "low|medium|high|critical",
  "message": "Human-readable description in Indonesian",
  "progress_delta": 5 to 25,
  "new_log_content": "Log entry text to inject into logs",
  "new_process_name": "Malicious process name if applicable, empty if not",
  "new_process_pid": 0 if no process, otherwise 4-digit PID,
  "target_server_id": "server-01" or "server-02"
}

Rules:
- If server health below 30%%, consider ransomware
- If blocked IPs include attacker IPs, attacker loses progress
- If breached servers > 0, move laterally or persist
- Match the persona style: %s
- Progress delta should reflect impact: 5=minor recon, 15=cred dump, 25=lateral movement`, state.ServerHealth, state.AttackerProgress, state.Phase, state.TimeRemaining,
		strings.Join(state.ActiveThreats, ", "),
		strings.Join(state.BlockedIPs, ", "),
		strings.Join(state.BreachedServers, ", "),
		state.AttackerPersona,
		strings.Join(state.RecentEvents, "; "),
		getPersonaStyle(state.AttackerPersona),
	)

	resp, _, err := ai.client.Chat(ctx, []ai_agent.Message{
		{Role: "system", Content: sysPrompt},
		{Role: "user", Content: "What is your next attack move?"},
	})
	if err != nil {
		return ai.fallbackDecision(state), nil
	}

	resp = cleanJSON(resp)
	var decision AIAttackerDecision
	if err := json.Unmarshal([]byte(resp), &decision); err != nil {
		return ai.fallbackDecision(state), nil
	}

	return &decision, nil
}

func (ai *MissionAI) fallbackDecision(state *MissionState) *AIAttackerDecision {
	if state.AttackerProgress >= 80 && state.TimeRemaining < 60 {
		return &AIAttackerDecision{Action: "ransomware", Severity: "critical", ProgressDelta: 20, Message: "Ransomware deployed on database", TargetServerID: "server-01", NewLogContent: "RANSOMWARE ENCRYPTION STARTED"}
	}
	if state.Phase == "recon" || state.AttackerProgress < 25 {
		return &AIAttackerDecision{Action: "port_scan", Severity: "low", ProgressDelta: 10, Message: "Port scan initiated from external IP", Target: "ssh", NewLogContent: "Connection attempt to port 22 from 192.168.1.105"}
	}
	if state.AttackerProgress < 50 {
		return &AIAttackerDecision{Action: "brute_force", Severity: "medium", ProgressDelta: 15, Message: "Multiple failed SSH login attempts", Target: "sshd", NewLogContent: "Failed password for root from 192.168.1.105 port 22 ssh2", NewProcessName: "", NewProcessPID: 0}
	}
	return &AIAttackerDecision{Action: "cred_dump", Severity: "high", ProgressDelta: 15, Message: "Mimikatz credential dumping detected", Target: "lsass", NewProcessName: "mimikatz.exe", NewProcessPID: 9876, NewLogContent: "Process lsass.exe accessed by unknown process", TargetServerID: "server-01"}
}

func getPersonaStyle(persona string) string {
	switch persona {
	case "beginner":
		return "Slow, predictable, basic attack vectors"
	case "scriptkiddie":
		return "Fast, noisy, tool-based: SQLi, brute force, known exploits"
	case "apt":
		return "Stealthy, living off the land, lateral movement, persistence"
	default:
		return "Balanced approach"
	}
}

func cleanJSON(s string) string {
	s = strings.TrimSpace(s)
	if strings.HasPrefix(s, "```") {
		lines := strings.Split(s, "\n")
		if len(lines) > 2 {
			s = strings.Join(lines[1:len(lines)-1], "\n")
		}
	}
	return strings.TrimSpace(s)
}

func (d *AIAttackerDecision) applyToMission(s *MissionState) {
	s.Phase = d.Action
	s.AttackerProgress += d.ProgressDelta
	if s.AttackerProgress > 100 {
		s.AttackerProgress = 100
	}
	if d.ProgressDelta > 0 && d.ProgressDelta < 10 {
		s.ServerHealth -= 3
	} else if d.ProgressDelta >= 10 {
		s.ServerHealth -= 8
	}
	if s.ServerHealth < 0 {
		s.ServerHealth = 0
	}
	if d.NewLogContent != "" {
		s.Logs = append(s.Logs, LogEntry{
			ID:        len(s.Logs) + 1000,
			Timestamp: fmt.Sprintf("%02d:%02d:%02d", 10+s.AttackerProgress/10, s.AttackerProgress*3%60, (s.AttackerProgress*7)%60),
			Server:    d.TargetServerID, SourceIP: "192.168.1.105", Service: d.Target,
			Status: 401, Message: d.NewLogContent, IsAnomaly: true,
		})
	}
	if d.NewProcessName != "" {
		s.Processes = append(s.Processes, ActiveProcess{PID: d.NewProcessPID, Name: d.NewProcessName, User: "SYSTEM", IsThreat: true})
	}
	if d.Message != "" {
		s.RecentEvents = append(s.RecentEvents, fmt.Sprintf("[%s] %s", now(), d.Message))
		s.ActiveThreats = append(s.ActiveThreats, d.Action)
	}
	if d.TargetServerID != "" && !containsStrInSlice(s.BreachedServers, d.TargetServerID) && d.ProgressDelta >= 18 {
		s.BreachedServers = append(s.BreachedServers, d.TargetServerID)
	}
}

func containsStrInSlice(slice []string, s string) bool {
	for _, item := range slice {
		if item == s {
			return true
		}
	}
	return false
}
