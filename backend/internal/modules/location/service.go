package location

import (
	"context"
	"errors"
	"fmt"

	"github.com/khasyaraka/backend/data"
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

func (s *Service) GetAllProvinsi() []ProvinsiOption {
	provs := data.GetAllProvinsi()
	opts := make([]ProvinsiOption, len(provs))
	for i, p := range provs {
		opts[i] = ProvinsiOption{ID: p.ID, Name: p.Name}
	}
	return opts
}

func (s *Service) GetKabupatenByProvinsi(provinsiID string) ([]KabupatenOption, error) {
	kabs := data.GetKabupatenByProvinsi(provinsiID)
	opts := make([]KabupatenOption, len(kabs))
	for i, k := range kabs {
		opts[i] = KabupatenOption{ID: k.ID, Name: k.Name, Type: k.Type}
	}
	return opts, nil
}

func (s *Service) GetKecamatanByKabupaten(kabupatenID string) ([]KecamatanOption, error) {
	kecs := data.GetKecamatanByKabupaten(kabupatenID)
	opts := make([]KecamatanOption, len(kecs))
	for i, k := range kecs {
		opts[i] = KecamatanOption{ID: k.ID, Name: k.Name}
	}
	return opts, nil
}

func (s *Service) SetUserLocation(ctx context.Context, userID int64, kecamatanID string) (*UserLocation, error) {
	kec, err := data.GetKecamatanByID(kecamatanID)
	if err != nil {
		return nil, errors.New("invalid kecamatan_id")
	}

	kab, err := data.GetKabupatenByID(kec.KabupatenID)
	if err != nil {
		return nil, fmt.Errorf("invalid kabupaten_id: %v", err)
	}

	prov, err := data.GetProvinsiByID(kab.ProvinsiID)
	if err != nil {
		return nil, fmt.Errorf("invalid provinsi_id: %v", err)
	}

	if err := s.repo.SetUserLocation(userID, kec.ID, kab.ID, prov.ID); err != nil {
		return nil, err
	}

	if s.chatService != nil {
		err = s.chatService.EnsureRoomsForUser(ctx, userID, kec.ID, kec.Name, kab.ID, kab.Name, prov.ID, prov.Name)
		if err != nil {
			fmt.Printf("Warning: failed to ensure chat rooms: %v\n", err)
		}
	}

	return &UserLocation{
		KecamatanID:   kec.ID,
		KecamatanName: kec.Name,
		KabupatenID:   kab.ID,
		KabupatenName: kab.Name,
		ProvinsiID:    prov.ID,
		ProvinsiName:  prov.Name,
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

	kec, _ := data.GetKecamatanByID(loc.KecamatanID)
	if kec != nil {
		loc.KecamatanName = kec.Name
	}
	kab, _ := data.GetKabupatenByID(loc.KabupatenID)
	if kab != nil {
		loc.KabupatenName = kab.Name
	}
	prov, _ := data.GetProvinsiByID(loc.ProvinsiID)
	if prov != nil {
		loc.ProvinsiName = prov.Name
	}

	return loc, nil
}
