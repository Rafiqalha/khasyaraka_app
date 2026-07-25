package evidence_validator

import (
	"github.com/pradigi/backend/internal/sandbox"
	"strings"
)

type Diagnostic string

const (
	DiagLoopBoundary    Diagnostic = "LOOP_BOUNDARY_ERROR"
	DiagSyntax          Diagnostic = "SYNTAX_ERROR"
	DiagTimeout         Diagnostic = "INFINITE_LOOP"
	DiagIndexOutOfRange Diagnostic = "INDEX_OUT_OF_RANGE"
	DiagNone            Diagnostic = "NONE"
)

type DiagnosticAnalyzer struct{}

func NewDiagnosticAnalyzer() *DiagnosticAnalyzer {
	return &DiagnosticAnalyzer{}
}

func (d *DiagnosticAnalyzer) Analyze(verdict Verdict, result sandbox.ExecutionResult) Diagnostic {
	if verdict == VerdictTimeLimit {
		return DiagTimeout
	}

	if verdict == VerdictCompileError {
		return DiagSyntax
	}

	// Python specific checks for MVP
	stderr := result.Stderr
	if strings.Contains(stderr, "IndexError: list index out of range") {
		// Differentiate between generic index error and specific loop boundary error
		if strings.Contains(result.Stdout, "for") || strings.Contains(result.Stdout, "while") || strings.Contains(result.Stderr, "line") {
			return DiagLoopBoundary
		}
		return DiagIndexOutOfRange
	}

	return DiagNone
}
