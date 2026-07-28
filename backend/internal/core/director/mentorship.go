package director

import (
	"fmt"

	"github.com/pradigi/backend/internal/core/cognitive"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// MentorshipPresenter acts as the natural language presenter layer for AI Director.
// BOUNDARY RULE: Director MUST NOT be the center of logic; it only synthesizes natural language by reading
// Mission Kernel, Learning Memory, Cognitive Graph, and Trajectory Replay reports.
type MentorshipPresenter struct{}

func NewMentorshipPresenter() *MentorshipPresenter {
	return &MentorshipPresenter{}
}

// SynthesizeBrief generates a dynamic, context-aware mentorship brief without templates.
func (p *MentorshipPresenter) SynthesizeBrief(report *cognitive.TrajectoryReport, node *cognitive.CognitiveNode) *DirectorBrief {
	logger.Info().Str("capability", report.TargetCapability).Msg("AI Director synthesizing natural language from Cognitive Time Machine & Graph")

	yesterdaySummary := "Exploring fundamental concepts"
	todayFocus := fmt.Sprintf("Deepen mastery in %s", report.TargetCapability)
	riskAnalysis := "Potential stagnation if trial-and-error is unguided"
	expectedOutcome := "Achieve verified autonomous execution"

	if len(report.TimePoints) > 0 {
		lastPoint := report.TimePoints[len(report.TimePoints)-1]
		yesterdaySummary = fmt.Sprintf("Completed episode %s with signal %s (%s)", lastPoint.EpisodeID, lastPoint.Signal, lastPoint.BehavioralNote)
	}

	// Dynamic reasoning synthesis based on Trajectory Evolution
	if report.ReasoningEvolution != "" {
		if node != nil && node.Debugging < 0.20 {
			todayFocus = "Kemarin kamu berhasil menyelesaikan tantangan, tetapi solusi didapat setelah trial-and-error panjang. Hari ini kita fokus mengurangi debugging time dengan latihan membaca stack trace."
			riskAnalysis = "High reliance on guessing rather than systematic trace isolation."
			expectedOutcome = "Isolate root cause in < 3 compile attempts."
		} else if node != nil && node.Reflection < 0.20 {
			todayFocus = "Implementasimu sudah sangat bersih dan mandiri. Hari ini saatnya membuktikan pemahaman arsitektur dengan menjelaskan alur data ke developer lain."
			riskAnalysis = "Can code proficiently but struggles to explain underlying design trade-offs."
			expectedOutcome = "Produce a comprehensive architecture summary without code pasting."
		} else {
			todayFocus = fmt.Sprintf("Evolusi belajarmu terbukti kuat: %s. Hari ini kita uji di skala produksi dengan beban tinggi.", report.ReasoningEvolution)
			riskAnalysis = "Production edge-cases and concurrency bottlenecks."
			expectedOutcome = "Zero-regression deployment in production simulation."
		}
	}

	return &DirectorBrief{
		Yesterday:       yesterdaySummary,
		Today:           todayFocus,
		Risk:            riskAnalysis,
		Focus:           report.TargetCapability,
		ExpectedOutcome: expectedOutcome,
	}
}
