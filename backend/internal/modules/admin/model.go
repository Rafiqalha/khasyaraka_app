package admin

type CreateSectionRequest struct {
	ID          string `json:"id" binding:"required"`
	Title       string `json:"title" binding:"required"`
	Description string `json:"description"`
	Tier        string `json:"tier" binding:"required,oneof=free premium"`
	Ord         int    `json:"ord"`
}

type UpdateUserRequest struct {
	FullName      *string `json:"full_name"`
	IsActive      *bool   `json:"is_active"`
	IsSuperuser   *bool   `json:"is_superuser"`
	HackLevel     *string `json:"hack_level"`
	Timezone      *string `json:"timezone"`
}

type CreateModuleRequest struct {
	ID             string `json:"id" binding:"required"`
	Title          string `json:"title" binding:"required"`
	OriginalTitle  string `json:"original_title" binding:"required"`
	Difficulty     int    `json:"difficulty"`
	MinReadSeconds int    `json:"min_read_seconds"`
	IntelContent   string `json:"intel_content"`
}
