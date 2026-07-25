package sdk

// SafetyPolicy represents the rules defined in policies/safety.yaml.
// This is read by the Policy Engine to enforce constraints on the Activity Graph and Capability Resolver.
type SafetyPolicy struct {
	Constraints    []Constraint `yaml:"constraints" json:"constraints"`
	RestrictedAPIs []string     `yaml:"restricted_apis" json:"restricted_apis"` // e.g. "os.system"
	AgeRestriction int          `yaml:"age_restriction" json:"age_restriction"`
}

type Constraint struct {
	Rule        string   `yaml:"rule" json:"rule"`
	Description string   `yaml:"description" json:"description"`
	Action      string   `yaml:"action" json:"action"`         // e.g. "deny", "warn", "redact"
	AppliesTo   []string `yaml:"applies_to" json:"applies_to"` // Node types or Sandbox components
}
