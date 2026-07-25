package observation

import (
	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"
)

type ValidationContext struct {
	ObservationID string
	RawOutput     string
	ParsedOutput  *RawAIOutput
	Reports       []ValidationReport
}

type Validator interface {
	Validate(ctx *ValidationContext) error
	Next(v Validator) Validator
}

type baseValidator struct {
	next Validator
}

func (b *baseValidator) Next(v Validator) Validator {
	b.next = v
	return v
}

func (b *baseValidator) callNext(ctx *ValidationContext) error {
	if b.next != nil {
		return b.next.Validate(ctx)
	}
	return nil
}

// 1. Syntax & Schema Validator
type syntaxValidator struct {
	baseValidator
}

func NewSyntaxValidator() Validator {
	return &syntaxValidator{}
}

func (v *syntaxValidator) Validate(ctx *ValidationContext) error {
	start := time.Now()
	report := ValidationReport{
		ID:            ulid.Make().String(),
		ObservationID: ctx.ObservationID,
		ValidatorName: "SyntaxAndSchema",
		Status:        "PASS",
		CreatedAt:     time.Now(),
	}

	var out RawAIOutput
	if err := json.Unmarshal([]byte(ctx.RawOutput), &out); err != nil {
		report.Status = "FAIL"
		report.Errors = append(report.Errors, err.Error())
		report.DurationMs = int(time.Since(start).Milliseconds())
		ctx.Reports = append(ctx.Reports, report)
		return err
	}

	ctx.ParsedOutput = &out
	report.DurationMs = int(time.Since(start).Milliseconds())
	ctx.Reports = append(ctx.Reports, report)

	return v.callNext(ctx)
}

// 2. Ontology Validator
type ontologyValidator struct {
	baseValidator
}

func NewOntologyValidator() Validator {
	return &ontologyValidator{}
}

func (v *ontologyValidator) Validate(ctx *ValidationContext) error {
	start := time.Now()
	report := ValidationReport{
		ID:            ulid.Make().String(),
		ObservationID: ctx.ObservationID,
		ValidatorName: "Ontology",
		Status:        "PASS",
		CreatedAt:     time.Now(),
	}

	for _, skill := range ctx.ParsedOutput.Skills {
		if skill.Direction != "POSITIVE" && skill.Direction != "NEGATIVE" && skill.Direction != "NEUTRAL" {
			report.Status = "FAIL"
			report.Errors = append(report.Errors, "invalid direction "+skill.Direction)
		}
		if skill.Strength < 0 || skill.Strength > 1.0 {
			report.Status = "FAIL"
			report.Errors = append(report.Errors, "strength out of bounds")
		}
	}

	report.DurationMs = int(time.Since(start).Milliseconds())
	ctx.Reports = append(ctx.Reports, report)

	if report.Status == "FAIL" {
		return nil // Depending on design, we might stop or continue
	}

	return v.callNext(ctx)
}

// Helper to construct the chain
func BuildValidationChain() Validator {
	syntax := NewSyntaxValidator()
	ontology := NewOntologyValidator()
	// we could add business and reasoning here

	syntax.Next(ontology)
	return syntax
}
