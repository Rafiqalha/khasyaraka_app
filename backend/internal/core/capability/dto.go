package capability

type CapabilityResponse struct {
	SkillID          string  `json:"skill_id"`
	DomainSlug       string  `json:"domain_slug"`
	SkillSlug        string  `json:"skill_slug"`
	SkillTitle       string  `json:"skill_title"`
	ProficiencyScore int     `json:"proficiency_score"`
	NormalizedScore  int     `json:"normalized_score"` // 0-100 representation
	EvidenceScore    float64 `json:"evidence_score"`
}
