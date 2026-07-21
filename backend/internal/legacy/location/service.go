package location

import (
	"context"
	"errors"
	"fmt"

	"github.com/pradigi/backend/data"
)

type ChatService interface {
	EnsureRoomsForUser(ctx context.Context, userID int64, kecID, kecName, kabID, kabName, provID, provName string) error
}

type Service struct {
	repo        *Repository
	chatService ChatService
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) SetChatService(cs ChatService) {
	s.chatService = cs
}

func (s *Service) GetCountries() ([]CountryOption, error) {
	return s.repo.GetCountries()
}

func (s *Service) GetProvinsiByCountry(countryID string) ([]ProvinsiOption, error) {
	if countryID == "" {
		countryID = "ID"
	}
	return s.repo.GetProvincesByCountry(countryID)
}

func (s *Service) GetKabupatenByProvinsi(provinsiID string) ([]KabupatenOption, error) {
	opts, err := s.repo.GetRegenciesByProvince(provinsiID)
	if err != nil {
		return nil, err
	}
	if len(opts) > 0 {
		return opts, nil
	}

	kabs := data.GetKabupatenByProvinsi(provinsiID)
	opts = make([]KabupatenOption, len(kabs))
	for i, k := range kabs {
		opts[i] = KabupatenOption{ID: k.ID, Name: k.Name, Type: k.Type}
	}
	return opts, nil
}

func (s *Service) GetKecamatanByKabupaten(kabupatenID string) ([]KecamatanOption, error) {
	opts, err := s.repo.GetDistrictsByRegency(kabupatenID)
	if err != nil {
		return nil, err
	}
	if len(opts) > 0 {
		return opts, nil
	}

	kecs := data.GetKecamatanByKabupaten(kabupatenID)
	opts = make([]KecamatanOption, len(kecs))
	for i, k := range kecs {
		opts[i] = KecamatanOption{ID: k.ID, Name: k.Name}
	}
	return opts, nil
}

func (s *Service) SetUserLocation(ctx context.Context, userID int64, kecamatanID string) (*UserLocation, error) {
	kecID, kecName, kabID, kabName, provID, provName, err := s.repo.ResolveLocationChain(kecamatanID)
	if err != nil {
		return nil, err
	}

	if kecID == "" {
		kec, err := data.GetKecamatanByID(kecamatanID)
		if err != nil {
			return nil, errors.New("invalid kecamatan_id")
		}
		kecID = kec.ID
		kecName = kec.Name
		kabID = kec.KabupatenID

		kab, err := data.GetKabupatenByID(kabID)
		if err != nil {
			return nil, fmt.Errorf("invalid kabupaten_id: %v", err)
		}
		kabName = kab.Name
		provID = kab.ProvinsiID

		prov, err := data.GetProvinsiByID(provID)
		if err != nil {
			return nil, fmt.Errorf("invalid provinsi_id: %v", err)
		}
		provName = prov.Name
	}

	if err := s.repo.SetUserLocation(userID, kecID, kabID, provID); err != nil {
		return nil, err
	}

	if s.chatService != nil {
		err := s.chatService.EnsureRoomsForUser(ctx, userID, kecID, kecName, kabID, kabName, provID, provName)
		if err != nil {
			fmt.Printf("Warning: failed to ensure chat rooms: %v\n", err)
		}
	}

	return &UserLocation{
		KecamatanID:   kecID,
		KecamatanName: kecName,
		KabupatenID:   kabID,
		KabupatenName: kabName,
		ProvinsiID:    provID,
		ProvinsiName:  provName,
	}, nil
}

func (s *Service) GetUserLocation(ctx context.Context, userID int64) (*UserLocation, error) {
	loc, err := s.repo.GetUserLocation(userID)
	if err != nil {
		return nil, err
	}
	if loc == nil {
		return nil, nil
	}

	if d, err := s.repo.GetDistrictByID(loc.KecamatanID); err == nil && d != nil {
		loc.KecamatanName = d.Name
	} else {
		kec, _ := data.GetKecamatanByID(loc.KecamatanID)
		if kec != nil {
			loc.KecamatanName = kec.Name
		}
	}

	if r, err := s.repo.GetRegencyByID(loc.KabupatenID); err == nil && r != nil {
		loc.KabupatenName = r.Name
	} else {
		kab, _ := data.GetKabupatenByID(loc.KabupatenID)
		if kab != nil {
			loc.KabupatenName = kab.Name
		}
	}

	if p, err := s.repo.GetProvinceByID(loc.ProvinsiID); err == nil && p != nil {
		loc.ProvinsiName = p.Name
	} else {
		prov, _ := data.GetProvinsiByID(loc.ProvinsiID)
		if prov != nil {
			loc.ProvinsiName = prov.Name
		}
	}

	return loc, nil
}
