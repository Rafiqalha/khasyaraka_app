package users

type Profile struct {
	ID             int64   `json:"id" db:"id"`
	FullName       *string `json:"full_name" db:"full_name"`
	Email          string  `json:"email" db:"email"`
	PictureURL     *string `json:"picture_url" db:"picture_url"`
	TotalXP        int     `json:"total_xp" db:"total_xp"`
	HackLevel      string  `json:"hack_level" db:"hack_level"`
	DecryptedCount int     `json:"decrypted_count" db:"decrypted_count"`
	Streak         int     `json:"streak" db:"streak"`
	LongestStreak  int     `json:"longest_streak" db:"longest_streak"`
	Hearts         int     `json:"hearts" db:"hearts"`
	LastActiveDate *string `json:"last_active_date,omitempty" db:"last_active_date"`
	Timezone       string  `json:"timezone" db:"timezone"`
	IsPro          bool    `json:"is_pro"`
	IsSuperuser    bool    `json:"is_superuser" db:"is_superuser"`
	LocationSet    bool    `json:"location_set" db:"location_set"`
	KecamatanID    *string `json:"kecamatan_id,omitempty" db:"kecamatan_id"`
	KabupatenID    *string `json:"kabupaten_id,omitempty" db:"kabupaten_id"`
	ProvinsiID     *string `json:"provinsi_id,omitempty" db:"provinsi_id"`
	CreatedAt      string  `json:"created_at" db:"created_at"`
	UpdatedAt      string  `json:"updated_at" db:"updated_at"`
}

type PublicProfile struct {
	ID             int64   `json:"id"`
	FullName       *string `json:"full_name"`
	PictureURL     *string `json:"picture_url"`
	TotalXP        int     `json:"total_xp"`
	HackLevel      string  `json:"hack_level"`
	DecryptedCount int     `json:"decrypted_count"`
	Streak         int     `json:"streak"`
	Hearts         int     `json:"hearts"`
}

type UpdateProfileRequest struct {
	FullName *string `json:"full_name"`
	Timezone *string `json:"timezone"`
}

type UpdateAvatarRequest struct {
	PictureURL string `json:"picture_url" binding:"required"`
}
