package mission

import "time"

type Mission struct {
	ID        string    `json:"id" db:"id"`
	UserID    int64     `json:"user_id" db:"user_id"`
	Persona   string    `json:"persona" db:"persona"`
	Objective string    `json:"objective" db:"objective"`
	Narrative string    `json:"narrative" db:"narrative"`
	Status    string    `json:"status" db:"status"`
	Score     int       `json:"score" db:"score"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

type ServerNode struct {
	ID       string   `json:"id"`
	Name     string   `json:"name"`
	IP       string   `json:"ip"`
	Services []string `json:"services"`
	IsBreached bool  `json:"is_breached"`
}

type LogEntry struct {
	ID        int    `json:"id"`
	Timestamp string `json:"timestamp"`
	Server    string `json:"server"`
	SourceIP  string `json:"source_ip"`
	Service   string `json:"service"`
	Status    int    `json:"status"`
	Message   string `json:"message"`
	IsAnomaly bool   `json:"is_anomaly"`
}

type FirewallRule struct {
	ID     string `json:"id"`
	Action string `json:"action"`
	Source string `json:"source"`
	Dest   string `json:"dest"`
	Port   int    `json:"port"`
}

type ActiveProcess struct {
	PID     int    `json:"pid"`
	Name    string `json:"name"`
	User    string `json:"user"`
	IsThreat bool  `json:"is_threat"`
}

type MissionState struct {
	MissionID        string           `json:"mission_id"`
	ServerHealth     int              `json:"server_health"`
	AttackerProgress int              `json:"attacker_progress"`
	TimeRemaining    int              `json:"time_remaining"`
	Score            int              `json:"score"`
	ActiveThreats    []string         `json:"active_threats"`
	RecentEvents     []string         `json:"recent_events"`
	Servers          []ServerNode     `json:"servers"`
	Logs             []LogEntry       `json:"logs"`
	FirewallRules    []FirewallRule   `json:"firewall_rules"`
	Processes        []ActiveProcess  `json:"processes"`
	BreachedServers  []string         `json:"breached_servers"`
	BlockedIPs       []string         `json:"blocked_ips"`
	AttackerPersona  string           `json:"attacker_persona"`
	Phase            string           `json:"phase"`
}

type StateTransition struct {
	ID        string
	Condition func(*MissionState) bool
	Execute   func(*MissionState)
	Event     EnvironmentEvent
}

type EnvironmentEvent struct {
	Type      string `json:"type"`
	Severity  string `json:"severity"`
	Message   string `json:"message"`
	Timestamp string `json:"timestamp"`
	ServerID  string `json:"server_id,omitempty"`
	SourceIP  string `json:"source_ip,omitempty"`
}

type MissionAction struct {
	Type    string                 `json:"type"`
	Payload map[string]interface{} `json:"payload"`
}

type ActionResult struct {
	Success       bool              `json:"success"`
	Message       string            `json:"message"`
	NewState      *MissionState     `json:"new_state"`
	Events        []EnvironmentEvent `json:"events"`
	ScoreChange   int               `json:"score_change"`
	MissionStatus string            `json:"mission_status"`
}

type PersonaConfig struct {
	ID          string              `json:"id"`
	Name        string              `json:"name"`
	Description string              `json:"description"`
	AttackSpeed int                 `json:"attack_speed"`
	Stealth     bool                `json:"stealth"`
	Vectors     []string            `json:"vectors"`
	Transitions []StateTransition   `json:"-"`
}
