// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package cyber

type Module struct {
	ID             string      `json:"id" db:"id"`
	Title          string      `json:"title" db:"title"`
	OriginalTitle  string      `json:"original_title" db:"original_title"`
	Difficulty     int         `json:"difficulty" db:"difficulty"`
	MinReadSeconds int         `json:"min_read_seconds" db:"min_read_seconds"`
	IntelContent   interface{} `json:"intel_content" db:"intel_content"`
	Challenges     []Challenge `json:"challenges,omitempty"`
}

type Challenge struct {
	ID              string      `json:"id" db:"id"`
	ModuleID        string      `json:"module_id" db:"module_id"`
	Level           int         `json:"level" db:"level"`
	Category        string      `json:"category" db:"category"`
	Difficulty      int         `json:"difficulty" db:"difficulty"`
	EncryptedData   interface{} `json:"encrypted_data" db:"encrypted_data"`
	DecryptedAnswer string      `json:"-" db:"decrypted_answer"`
	XpReward        int         `json:"xp_reward" db:"xp_reward"`
	IsSolved        bool        `json:"is_solved,omitempty"`
}

type ModuleBrief struct {
	ID         string `json:"id" db:"id"`
	Title      string `json:"title" db:"title"`
	Difficulty int    `json:"difficulty" db:"difficulty"`
	Challenges int    `json:"challenges"`
	Solved     int    `json:"solved"`
}

type LevelProgress struct {
	ModuleID    string `json:"module_id" db:"module_id"`
	Level       int    `json:"level" db:"level"`
	Stars       int    `json:"stars" db:"stars"`
	Score       int    `json:"score" db:"score"`
	IsCompleted bool   `json:"is_completed" db:"is_completed"`
}

type SolveRequest struct {
	Answer string `json:"answer" binding:"required"`
}
