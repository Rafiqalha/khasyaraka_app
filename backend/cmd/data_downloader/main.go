package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"sync"
	"time"
)

type Province struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

type Regency struct {
	ID         string `json:"id"`
	ProvinceID string `json:"province_id"`
	Name       string `json:"name"`
}

type District struct {
	ID        string `json:"id"`
	RegencyID string `json:"regency_id"`
	Name      string `json:"name"`
}

func fetchJSON(url string, target any) error {
	client := http.Client{Timeout: 30 * time.Second}
	resp, err := client.Get(url)
	if err != nil {
		return fmt.Errorf("GET %s: %w", url, err)
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("read %s: %w", url, err)
	}
	return json.Unmarshal(body, target)
}

func main() {
	base := "https://emsifa.github.io/api-wilayah-indonesia/api"

	rawDir := os.Getenv("RAW_DIR")
	if rawDir == "" {
		wd, _ := os.Getwd()
		rawDir = filepath.Join(wd, "..", "data", "raw")
	}

	fmt.Println("Raw dir:", rawDir)
	os.MkdirAll(rawDir, 0755)

	fmt.Println("Downloading provinces.json...")
	var provinces []Province
	if err := fetchJSON(base+"/provinces.json", &provinces); err != nil {
		panic(err)
	}
	saveJSON(filepath.Join(rawDir, "provinces.json"), provinces)
	fmt.Printf("  -> %d provinces\n", len(provinces))

	fmt.Println("Downloading regencies...")
	var (
		allRegencies []Regency
		regMu        sync.Mutex
		regWg        sync.WaitGroup
	)
	regWg.Add(len(provinces))
	for _, prov := range provinces {
		go func(provID string) {
			defer regWg.Done()
			var regencies []Regency
			if err := fetchJSON(base+"/regencies/"+provID+".json", &regencies); err != nil {
				fmt.Printf("  !! regencies/%s: %v\n", provID, err)
				return
			}
			regMu.Lock()
			allRegencies = append(allRegencies, regencies...)
			regMu.Unlock()
		}(prov.ID)
	}
	regWg.Wait()
	saveJSON(filepath.Join(rawDir, "regencies.json"), allRegencies)
	fmt.Printf("  -> %d regencies\n", len(allRegencies))

	fmt.Println("Downloading districts...")
	var (
		allDistricts []District
		disMu        sync.Mutex
		disWg        sync.WaitGroup
		sem          = make(chan struct{}, 20)
	)
	disWg.Add(len(allRegencies))
	for _, reg := range allRegencies {
		go func(regID string) {
			defer disWg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()
			var districts []District
			if err := fetchJSON(base+"/districts/"+regID+".json", &districts); err != nil {
				fmt.Printf("  !! districts/%s: %v\n", regID, err)
				return
			}
			disMu.Lock()
			allDistricts = append(allDistricts, districts...)
			disMu.Unlock()
		}(reg.ID)
	}
	disWg.Wait()
	saveJSON(filepath.Join(rawDir, "districts.json"), allDistricts)
	fmt.Printf("  -> %d districts total\n", len(allDistricts))

	fmt.Println("Done! All data saved to", rawDir)
}

func saveJSON(path string, data any) {
	f, err := os.Create(path)
	if err != nil {
		panic(fmt.Sprintf("create %s: %v", path, err))
	}
	defer f.Close()
	enc := json.NewEncoder(f)
	enc.SetIndent("", "  ")
	if err := enc.Encode(data); err != nil {
		panic(fmt.Sprintf("encode %s: %v", path, err))
	}
	info, _ := os.Stat(path)
	fmt.Printf("  wrote %s (%d bytes)\n", path, info.Size())
}
