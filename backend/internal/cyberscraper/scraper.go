package cyberscraper

import (
	"context"
	"encoding/xml"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

const (
	defaultTimeout    = 15 * time.Second
	maxArticlesPerRun = 5
)

var feedURLs = []string{
	"https://feeds.feedburner.com/TheHackersNews",
	"https://www.bleepingcomputer.com/feed/",
}

type NewsArticle struct {
	Title       string   `json:"title"`
	URL         string   `json:"url"`
	Source      string   `json:"source"`
	Summary     string   `json:"summary"`
	CVEIDs      []string `json:"cve_ids,omitempty"`
	PublishedAt string   `json:"published_at"`
}

type rssFeed struct {
	XMLName xml.Name   `xml:"rss"`
	Channel rssChannel `xml:"channel"`
}

type rssChannel struct {
	Items []rssItem `xml:"item"`
}

type rssItem struct {
	Title       string `xml:"title"`
	Link        string `xml:"link"`
	Description string `xml:"description"`
	PubDate     string `xml:"pubDate"`
}

type Scraper struct {
	httpClient *http.Client
}

func NewScraper() *Scraper {
	return &Scraper{
		httpClient: &http.Client{Timeout: defaultTimeout},
	}
}

func (s *Scraper) FetchLatestArticles(ctx context.Context) ([]NewsArticle, error) {
	var allArticles []NewsArticle

	for _, url := range feedURLs {
		articles, err := s.fetchFeed(ctx, url)
		if err != nil {
			continue
		}
		for i := range articles {
			articles[i].Source = extractSource(url)
		}
		allArticles = append(allArticles, articles...)
	}

	if len(allArticles) > maxArticlesPerRun {
		allArticles = allArticles[:maxArticlesPerRun]
	}

	return allArticles, nil
}

func (s *Scraper) fetchFeed(ctx context.Context, url string) ([]NewsArticle, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}
	req.Header.Set("User-Agent", "Pradigi-Curriculum-Engine/1.0")

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("fetch feed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("feed returned status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err != nil {
		return nil, fmt.Errorf("read body: %w", err)
	}

	var feed rssFeed
	if err := xml.Unmarshal(body, &feed); err != nil {
		return nil, fmt.Errorf("parse rss: %w", err)
	}

	var articles []NewsArticle
	for _, item := range feed.Channel.Items {
		summary := stripHTML(item.Description)
		if len(summary) > 500 {
			summary = summary[:500]
		}

		articles = append(articles, NewsArticle{
			Title:       item.Title,
			URL:         item.Link,
			Summary:     summary,
			CVEIDs:      extractCVEs(item.Title + " " + item.Description),
			PublishedAt: item.PubDate,
		})
	}

	return articles, nil
}

func extractSource(url string) string {
	if strings.Contains(url, "thehackernews") || strings.Contains(url, "feedburner") {
		return "thehackernews"
	}
	if strings.Contains(url, "bleepingcomputer") {
		return "bleepingcomputer"
	}
	return "unknown"
}

func extractCVEs(text string) []string {
	var cves []string
	seen := map[string]bool{}

	for i := 0; i < len(text)-9; i++ {
		if text[i] == 'C' && text[i+1] == 'V' && text[i+2] == 'E' && text[i+3] == '-' {
			end := min(i+13, len(text))
			candidate := text[i:end]
			for idx, ch := range candidate {
				if !isCVEChar(ch) {
					candidate = candidate[:idx]
					break
				}
			}
			if len(candidate) >= 10 && !seen[candidate] {
				cves = append(cves, candidate)
				seen[candidate] = true
			}
		}
	}
	return cves
}

func isCVEChar(ch rune) bool {
	return (ch >= '0' && ch <= '9') || (ch >= 'A' && ch <= 'Z') || ch == '-'
}

func stripHTML(input string) string {
	var b strings.Builder
	inTag := false
	for _, r := range input {
		if r == '<' {
			inTag = true
			continue
		}
		if r == '>' {
			inTag = false
			continue
		}
		if !inTag {
			b.WriteRune(r)
		}
	}
	return strings.TrimSpace(b.String())
}
