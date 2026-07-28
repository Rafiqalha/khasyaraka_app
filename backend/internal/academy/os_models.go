package academy

type OSRegistryDomain struct {
	ID              string                     `json:"id"`
	Title           string                     `json:"title"`
	Icon            string                     `json:"icon"`
	Specializations []OSRegistrySpecialization `json:"specializations"`
}

type OSRegistrySpecialization struct {
	ID        string   `json:"id"`
	Title     string   `json:"title"`
	PackFiles []string `json:"pack_files"`
}

type OSPortfolioItem struct {
	Icon       string `json:"icon"`
	Title      string `json:"title"`
	Subtitle   string `json:"subtitle"`
	Tag        string `json:"tag,omitempty"`
	ActionText string `json:"action_text,omitempty"`
}

type OSPortfolioResponse struct {
	Projects     []OSPortfolioItem `json:"projects"`
	Certificates []OSPortfolioItem `json:"certificates"`
	Exports      []OSPortfolioItem `json:"exports"`
}

type OSProfileItem struct {
	Icon     string `json:"icon"`
	Title    string `json:"title"`
	Subtitle string `json:"subtitle"`
}

type OSProfileResponse struct {
	Identity    []OSProfileItem `json:"identity"`
	Preferences []OSProfileItem `json:"preferences"`
	Settings    []OSProfileItem `json:"settings"`
}
