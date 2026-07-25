package data

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"sort"
	"strings"
)

//go:embed raw/provinces.json
var provincesJSON []byte

//go:embed raw/regencies.json
var regenciesJSON []byte

//go:embed raw/districts.json
var districtsJSON []byte

type Provinsi struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

type Kabupaten struct {
	ID         string `json:"id"`
	ProvinsiID string `json:"province_id"`
	Name       string `json:"name"`
	Type       string `json:"-"` // Not provided in emsifa, we'll infer KABUPATEN/KOTA from name
}

type Kecamatan struct {
	ID          string `json:"id"`
	KabupatenID string `json:"regency_id"`
	Name        string `json:"name"`
}

var (
	allProvinsi  []Provinsi
	allKabupaten []Kabupaten
	allKecamatan []Kecamatan
	provinsiMap  map[string]*Provinsi
	kabupatenMap map[string]*Kabupaten
	kecamatanMap map[string]*Kecamatan
	kabByProvMap map[string][]Kabupaten
	kecByKabMap  map[string][]Kecamatan
)

func init() {
	if err := json.Unmarshal(provincesJSON, &allProvinsi); err != nil {
		panic(fmt.Sprintf("Failed to load provinces: %v", err))
	}
	if err := json.Unmarshal(regenciesJSON, &allKabupaten); err != nil {
		panic(fmt.Sprintf("Failed to load regencies: %v", err))
	}
	if err := json.Unmarshal(districtsJSON, &allKecamatan); err != nil {
		panic(fmt.Sprintf("Failed to load districts: %v", err))
	}

	// Sort alphabetically
	sort.Slice(allProvinsi, func(i, j int) bool {
		return allProvinsi[i].Name < allProvinsi[j].Name
	})

	provinsiMap = make(map[string]*Provinsi)
	for i := range allProvinsi {
		provinsiMap[allProvinsi[i].ID] = &allProvinsi[i]
	}

	kabupatenMap = make(map[string]*Kabupaten)
	kabByProvMap = make(map[string][]Kabupaten)
	for i := range allKabupaten {
		k := &allKabupaten[i]
		if strings.HasPrefix(strings.ToUpper(k.Name), "KOTA ") {
			k.Type = "Kota"
		} else {
			k.Type = "Kabupaten"
		}
		kabupatenMap[k.ID] = k
		kabByProvMap[k.ProvinsiID] = append(kabByProvMap[k.ProvinsiID], *k)
	}

	for provID := range kabByProvMap {
		sort.Slice(kabByProvMap[provID], func(i, j int) bool {
			return kabByProvMap[provID][i].Name < kabByProvMap[provID][j].Name
		})
	}

	kecamatanMap = make(map[string]*Kecamatan)
	kecByKabMap = make(map[string][]Kecamatan)
	for i := range allKecamatan {
		k := &allKecamatan[i]
		kecamatanMap[k.ID] = k
		kecByKabMap[k.KabupatenID] = append(kecByKabMap[k.KabupatenID], *k)
	}

	for kabID := range kecByKabMap {
		sort.Slice(kecByKabMap[kabID], func(i, j int) bool {
			return kecByKabMap[kabID][i].Name < kecByKabMap[kabID][j].Name
		})
	}
}

func GetAllProvinsi() []Provinsi {
	return allProvinsi
}

func GetKabupatenByProvinsi(provinsiID string) []Kabupaten {
	if kabs, ok := kabByProvMap[provinsiID]; ok {
		return kabs
	}
	return []Kabupaten{}
}

func GetKecamatanByKabupaten(kabupatenID string) []Kecamatan {
	if kecs, ok := kecByKabMap[kabupatenID]; ok {
		return kecs
	}
	return []Kecamatan{}
}

func GetProvinsiByID(id string) (*Provinsi, error) {
	if p, ok := provinsiMap[id]; ok {
		return p, nil
	}
	return nil, fmt.Errorf("provinsi %s not found", id)
}

func GetKabupatenByID(id string) (*Kabupaten, error) {
	if k, ok := kabupatenMap[id]; ok {
		return k, nil
	}
	return nil, fmt.Errorf("kabupaten %s not found", id)
}

func GetKecamatanByID(id string) (*Kecamatan, error) {
	if k, ok := kecamatanMap[id]; ok {
		return k, nil
	}
	return nil, fmt.Errorf("kecamatan %s not found", id)
}
