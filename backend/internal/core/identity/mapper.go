package identity

func MapUpdateToModel(req *UpdateProfileRequest, model *LearnerProfile) error {
	if req.DisplayName != nil {
		model.DisplayName = *req.DisplayName
	}
	if req.BirthYear != nil {
		model.BirthYear = *req.BirthYear
	}
	if req.Country != nil {
		model.Country = *req.Country
	}
	if req.Timezone != nil {
		model.Timezone = *req.Timezone
	}
	if req.NativeLanguage != nil {
		model.NativeLanguage = *req.NativeLanguage
	}
	if req.PreferredLanguage != nil {
		model.PreferredLanguage = *req.PreferredLanguage
	}
	if req.EducationLevel != nil {
		model.EducationLevel = *req.EducationLevel
	}
	if req.ExperienceLevel != nil {
		model.ExperienceLevel = *req.ExperienceLevel
	}
	if req.CareerSlug != nil {
		model.CareerSlug = *req.CareerSlug
	}
	if req.LearningGoalType != nil {
		if !ValidateGoal(*req.LearningGoalType) {
			return ErrInvalidGoal
		}
		model.LearningGoalType = *req.LearningGoalType
	}
	if req.LearningGoalDetail != nil {
		model.LearningGoalDetail = *req.LearningGoalDetail
	}
	if req.MotivationType != nil {
		model.MotivationType = *req.MotivationType
	}
	if req.MotivationText != nil {
		model.MotivationText = *req.MotivationText
	}
	if req.DailyMinutes != nil {
		model.DailyMinutes = *req.DailyMinutes
	}
	if req.PrefersVideo != nil {
		model.PrefersVideo = *req.PrefersVideo
	}
	if req.PrefersText != nil {
		model.PrefersText = *req.PrefersText
	}
	if req.PrefersProject != nil {
		model.PrefersProject = *req.PrefersProject
	}
	if req.PrefersQuiz != nil {
		model.PrefersQuiz = *req.PrefersQuiz
	}
	if req.AIPersona != nil {
		if !ValidatePersona(*req.AIPersona) {
			return ErrInvalidPersona
		}
		model.AIPersona = *req.AIPersona
	}
	if req.CurrentStage != nil {
		if !ValidateStage(*req.CurrentStage) {
			return ErrInvalidStage
		}
		model.CurrentStage = *req.CurrentStage
	}
	return nil
}
