package ctf

import "time"

const (
	PhaseWaiting  = "waiting"
	PhaseDefense  = "defense"
	PhaseAttack   = "attack"
	PhasePatching = "patching"
	PhaseFinished = "finished"
)

const (
	CipherCaesar   = "caesar"
	CipherVigenere = "vigenere"
	CipherMorse    = "morse"
	CipherKotak    = "kotak"
)

type CulturalImage struct {
	ID     string `json:"id"`
	Name   string `json:"name"`
	URL    string `json:"url"`
	Region string `json:"region"`
}

var CulturalImagePool = []CulturalImage{
	{
		ID:     "tapis_lampung",
		Name:   "Tapis Lampung",
		URL:    "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Tapis_Lampung.jpg/640px-Tapis_Lampung.jpg",
		Region: "Lampung",
	},
	{
		ID:     "batik_solo",
		Name:   "Batik Solo",
		URL:    "https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Batik_Indonesia_by_Crisco_1492.jpg/640px-Batik_Indonesia_by_Crisco_1492.jpg",
		Region: "Jawa Tengah",
	},
	{
		ID:     "ulos_batak",
		Name:   "Ulos Batak",
		URL:    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Ulos.jpg/640px-Ulos.jpg",
		Region: "Sumatera Utara",
	},
	{
		ID:     "tenun_ntt",
		Name:   "Tenun NTT",
		URL:    "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Tenun_ikat_Sumba.jpg/640px-Tenun_ikat_Sumba.jpg",
		Region: "NTT",
	},
	{
		ID:     "songket_palembang",
		Name:   "Songket Palembang",
		URL:    "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Songket_Palembang.jpg/640px-Songket_Palembang.jpg",
		Region: "Sumatera Selatan",
	},
}

type PatchChallengeTemplate struct {
	Type       string
	Difficulty string
	Question   string
	Answer     string
}

var PatchChallengesPool = []PatchChallengeTemplate{
	{
		Type:       "cipher",
		Difficulty: "easy",
		Question:   "Decode sandi Caesar dengan shift 3: 'SUDK'",
		Answer:     "PORT",
	},
	{
		Type:       "binary",
		Difficulty: "easy",
		Question:   "Konversi binary ke desimal: 01010000",
		Answer:     "80",
	},
	{
		Type:       "logic",
		Difficulty: "easy",
		Question:   "Jika firewall memblokir port 80, protokol apa yang terblokir?",
		Answer:     "HTTP",
	},
	{
		Type:       "cipher",
		Difficulty: "medium",
		Question:   "Decode Vigenere cipher dengan key 'PRAMUKA': 'HWEJUKC'",
		Answer:     "WEBSITE",
	},
	{
		Type:       "binary",
		Difficulty: "medium",
		Question:   "Konversi binary ke desimal: 110111011",
		Answer:     "443",
	},
	{
		Type:       "logic",
		Difficulty: "medium",
		Question:   "SSL/TLS menggunakan port berapa secara default?",
		Answer:     "443",
	},
	{
		Type:       "cipher",
		Difficulty: "hard",
		Question:   "Sandi Morse: ... ... .... (3 karakter)",
		Answer:     "SSH",
	},
	{
		Type:       "binary",
		Difficulty: "hard",
		Question:   "Port SSH dalam binary 8-bit adalah?",
		Answer:     "00010110",
	},
	{
		Type:       "logic",
		Difficulty: "hard",
		Question:   "Protokol remote access yang menggunakan enkripsi asymmetric?",
		Answer:     "SSH",
	},
}

type CTFRoom struct {
	ID                 int64      `json:"id" db:"id"`
	RoomID             int64      `json:"room_id" db:"room_id"`
	Phase              string     `json:"phase" db:"phase"`
	PhaseStartedAt     *time.Time `json:"phase_started_at" db:"phase_started_at"`
	DefenseDurationSec int        `json:"defense_duration_sec" db:"defense_duration_sec"`
	AttackDurationSec  int        `json:"attack_duration_sec" db:"attack_duration_sec"`
	CreatedAt          time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt          time.Time  `json:"updated_at" db:"updated_at"`
}

type CTFTeam struct {
	ID              int64      `json:"id" db:"id"`
	CTFRoomID       int64      `json:"ctf_room_id" db:"ctf_room_id"`
	TeamID          int64      `json:"team_id" db:"team_id"`
	Flag            string     `json:"flag" db:"flag"`
	DefenseImageURL string     `json:"defense_image_url" db:"defense_image_url"`
	CipherMethod    string     `json:"cipher_method" db:"cipher_method"`
	CipherKey       string     `json:"cipher_key" db:"cipher_key"`
	FlagFound       bool       `json:"flag_found" db:"flag_found"`
	FlagFoundAt     *time.Time `json:"flag_found_at" db:"flag_found_at"`
	FlagFoundBy     *int64     `json:"flag_found_by" db:"flag_found_by"`
	PatchCompleted  bool       `json:"patch_completed" db:"patch_completed"`
	PatchTimeSec    *int       `json:"patch_time_sec" db:"patch_time_sec"`
	Score           int        `json:"score" db:"score"`
	CreatedAt       time.Time  `json:"created_at" db:"created_at"`
}

type CTFAttackLog struct {
	ID              int64     `json:"id" db:"id"`
	CTFRoomID       int64     `json:"ctf_room_id" db:"ctf_room_id"`
	AttackingTeamID int64     `json:"attacking_team_id" db:"attacking_team_id"`
	UserID          int64     `json:"user_id" db:"user_id"`
	Prompt          string    `json:"prompt" db:"prompt"`
	AIResponse      string    `json:"ai_response" db:"ai_response"`
	TokensUsed      int       `json:"tokens_used" db:"tokens_used"`
	CreatedAt       time.Time `json:"created_at" db:"created_at"`
}

type CTFPatchChallenge struct {
	ID            int64      `json:"id" db:"id"`
	CTFRoomID     int64      `json:"ctf_room_id" db:"ctf_room_id"`
	TeamID        int64      `json:"team_id" db:"team_id"`
	ChallengeType string     `json:"challenge_type" db:"challenge_type"`
	Difficulty    string     `json:"difficulty" db:"difficulty"`
	Question      string     `json:"question" db:"question"`
	CorrectAnswer string     `json:"correct_answer" db:"correct_answer"`
	UserAnswer    *string    `json:"user_answer" db:"user_answer"`
	Solved        bool       `json:"solved" db:"solved"`
	SolvedAt      *time.Time `json:"solved_at" db:"solved_at"`
	TimeTakenSec  *int       `json:"time_taken_sec" db:"time_taken_sec"`
	CreatedAt     time.Time  `json:"created_at" db:"created_at"`
}

type CreateCTFRoomRequest struct {
	RoomID             int64 `json:"room_id"`
	DefenseDurationSec int   `json:"defense_duration_sec"`
	AttackDurationSec  int   `json:"attack_duration_sec"`
}

type SubmitDefenseRequest struct {
	CipherMethod    string `json:"cipher_method"`
	CipherKey       string `json:"cipher_key"`
	CulturalImageID string `json:"cultural_image_id"`
}

type SubmitAttackRequest struct {
	Prompt string `json:"prompt"`
}

type SubmitFlagRequest struct {
	Flag string `json:"flag"`
}

type SubmitPatchRequest struct {
	Answer       string `json:"answer"`
	TimeTakenSec int    `json:"time_taken_sec"`
}

type CTFStateResponse struct {
	Room           CTFRoom             `json:"room"`
	PhaseTimeLeft  int                 `json:"phase_time_left"` // in seconds
	MyTeam         CTFTeam             `json:"my_team"`
	OpponentTeam   CTFTeamPublicView   `json:"opponent_team"`
	RecentLogs     []CTFAttackLog      `json:"recent_logs"`
	PatchChallenge *CTFPatchChallenge  `json:"patch_challenge,omitempty"`
}

type CTFTeamPublicView struct {
	ID              int64      `json:"id"`
	CTFRoomID       int64      `json:"ctf_room_id"`
	TeamID          int64      `json:"team_id"`
	DefenseImageURL string     `json:"defense_image_url"`
	CipherMethod    string     `json:"cipher_method"`
	FlagFound       bool       `json:"flag_found"`
	FlagFoundAt     *time.Time `json:"flag_found_at"`
	FlagFoundBy     *int64     `json:"flag_found_by"`
	PatchCompleted  bool       `json:"patch_completed"`
	Score           int        `json:"score"`
}
