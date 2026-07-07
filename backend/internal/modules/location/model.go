package location

type UserLocation struct {
	KecamatanID   string `json:"kecamatan_id"`
	KecamatanName string `json:"kecamatan_name"`
	KabupatenID   string `json:"kabupaten_id"`
	KabupatenName string `json:"kabupaten_name"`
	ProvinsiID    string `json:"provinsi_id"`
	ProvinsiName  string `json:"provinsi_name"`
}

type SetLocationRequest struct {
	KecamatanID string `json:"kecamatan_id" binding:"required"`
}

type ProvinsiOption struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

type KabupatenOption struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	Type string `json:"type"`
}

type KecamatanOption struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}
