package admin

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListUsers() ([]map[string]interface{}, error) {
	return s.repo.ListUsers()
}

func (s *Service) UpdateUser(id int64, req UpdateUserRequest) error {
	return s.repo.UpdateUser(id, req.FullName, req.IsActive, req.IsSuperuser, req.HackLevel, req.Timezone)
}

func (s *Service) CreateSection(req CreateSectionRequest) error {
	ord := req.Ord
	if ord == 0 {
		ord = 1
	}
	return s.repo.CreateSection(req.ID, req.Title, req.Description, req.Tier, ord)
}

func (s *Service) CreateModule(req CreateModuleRequest) error {
	difficulty := req.Difficulty
	if difficulty == 0 {
		difficulty = 1
	}
	minRead := req.MinReadSeconds
	if minRead == 0 {
		minRead = 30
	}
	return s.repo.CreateModule(req.ID, req.Title, req.OriginalTitle, difficulty, minRead, req.IntelContent)
}
