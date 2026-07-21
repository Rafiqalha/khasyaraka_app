// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package sandi

type SandiType struct {
	ID          int64       `json:"id" db:"id"`
	Codename    string      `json:"codename" db:"codename"`
	Name        string      `json:"name" db:"name"`
	Description string      `json:"description" db:"description"`
	Difficulty  int         `json:"difficulty" db:"difficulty"`
	Category    string      `json:"category" db:"category"`
}

type SandiQuestion struct {
	ID            int64  `json:"id" db:"id"`
	SandiID       int64  `json:"sandi_id" db:"sandi_id"`
	QuestionText  string `json:"question_text" db:"question_text"`
	EncryptedText string `json:"encrypted_text" db:"encrypted_text"`
	CorrectAnswer string `json:"-" db:"correct_answer"`
	Hint          string `json:"hint,omitempty" db:"hint"`
	Difficulty    int    `json:"difficulty" db:"difficulty"`
	XpReward      int    `json:"xp_reward" db:"xp_reward"`
}

type SolveSandiRequest struct {
	Answer string `json:"answer" binding:"required"`
}

type CryptoRequest struct {
	Text    string `json:"text" binding:"required"`
	SandiID int64  `json:"sandi_id" binding:"required"`
	Key     string `json:"key,omitempty"`
}

type CryptoResponse struct {
	Result      string `json:"result"`
	Method      string `json:"method"`
	TypeName    string `json:"type_name"`
	Codename    string `json:"codename"`
	InputLength int    `json:"input_length"`
	OutputLength int   `json:"output_length"`
	KeyUsed     string `json:"key_used,omitempty"`
}
