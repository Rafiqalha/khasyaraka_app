package ai_agent

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type ChatCompletionsRequest struct {
	Model       string    `json:"model"`
	Messages    []Message `json:"messages"`
	Temperature float64   `json:"temperature"`
	MaxTokens   int       `json:"max_tokens"`
}

type ChatCompletionsResponse struct {
	ID      string   `json:"id"`
	Choices []Choice `json:"choices"`
	Usage   Usage    `json:"usage"`
}

type Choice struct {
	Message Message `json:"message"`
}

type Usage struct {
	PromptTokens     int `json:"prompt_tokens"`
	CompletionTokens int `json:"completion_tokens"`
}

type TokenUsageTracker struct {
	PromptTokens     int `json:"prompt_tokens"`
	CompletionTokens int `json:"completion_tokens"`
}

type PradigiResponse struct {
	StatusSimulasi           string `json:"status_simulasi"`
	DialogAI                 string `json:"dialog_ai"`
	ComputationalScoreChange int    `json:"computational_score_change"`
	EthicalScoreChange       int    `json:"ethical_score_change"`
	DockerEvalCommand        string `json:"docker_eval_command,omitempty"`
	TechnicalHint            string `json:"technical_hint"`
	NextObjective            string `json:"next_objective,omitempty"`
	ThreatMutation           string `json:"threat_mutation,omitempty"`
	AdaptiveNarrative        string `json:"adaptive_narrative,omitempty"`
	DifficultyAdjustment     int    `json:"difficulty_adjustment,omitempty"`
}

type ToolAction struct {
	Action  string `json:"action"`
	Command string `json:"command"`
	Reason  string `json:"reason"`
}
