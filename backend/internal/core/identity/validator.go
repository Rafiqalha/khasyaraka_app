package identity

func ValidatePersona(persona string) bool {
	valid := map[string]bool{
		PersonaMentor:     true,
		PersonaCoach:      true,
		PersonaTeacher:    true,
		PersonaChallenger: true,
		PersonaFriend:     true,
	}
	return valid[persona]
}

func ValidateStage(stage string) bool {
	valid := map[string]bool{
		StageDiscover:  true,
		StageLearn:     true,
		StagePractice:  true,
		StageBuild:     true,
		StagePortfolio: true,
		StageInterview: true,
		StageCareer:    true,
	}
	return valid[stage]
}

func ValidateGoal(goal string) bool {
	valid := map[string]bool{
		GoalInterview:     true,
		GoalBuildStartup:  true,
		GoalFreelance:     true,
		GoalCompetition:   true,
		GoalResearch:      true,
		GoalCertification: true,
		GoalCareerSwitch:  true,
	}
	return valid[goal]
}

func ValidateCapability(cap string) bool {
	valid := map[string]bool{
		CapabilityLow:    true,
		CapabilityMedium: true,
		CapabilityHigh:   true,
	}
	return valid[cap]
}
