package curriculum

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	"github.com/rs/zerolog"

	"github.com/pradigi/backend/internal/blueprint"
	"github.com/pradigi/backend/internal/cyberscraper"
)

const (
	defaultInterval = 6 * time.Hour
	questionExpiry  = 7 * 24 * time.Hour
)

type Worker struct {
	db       *sqlx.DB
	gen      *blueprint.Generator
	scraper  *cyberscraper.Scraper
	logger   zerolog.Logger
	interval time.Duration
}

func NewWorker(db *sqlx.DB, deepseekAPIKey, deepseekModel string, logger zerolog.Logger) *Worker {
	return &Worker{
		db:       db,
		gen:      blueprint.NewGenerator(deepseekAPIKey, deepseekModel),
		scraper:  cyberscraper.NewScraper(),
		logger:   logger,
		interval: defaultInterval,
	}
}

func (w *Worker) Start(ctx context.Context) {
	w.logger.Info().
		Dur("interval", w.interval).
		Msg("curriculum worker started")

	ticker := time.NewTicker(w.interval)
	defer ticker.Stop()

	if err := w.RunCycle(ctx); err != nil {
		w.logger.Warn().Err(err).Msg("initial cycle had errors")
	}

	for {
		select {
		case <-ctx.Done():
			w.logger.Info().Msg("curriculum worker shutting down")
			return
		case <-ticker.C:
			if err := w.RunCycle(ctx); err != nil {
				w.logger.Error().Err(err).Msg("cycle failed")
			}
		}
	}
}

func (w *Worker) RunCycle(ctx context.Context) error {
	w.logger.Info().Msg("curriculum cycle started")

	articles, err := w.scraper.FetchLatestArticles(ctx)
	if err != nil {
		return fmt.Errorf("scrape: %w", err)
	}

	var newArticles []cyberscraper.NewsArticle
	for _, a := range articles {
		exists, err := w.articleExists(ctx, a.URL)
		if err != nil {
			w.logger.Warn().Err(err).Str("url", a.URL).Msg("dedup check failed, skipping")
			continue
		}
		if !exists {
			newArticles = append(newArticles, a)
		}
	}

	if len(newArticles) == 0 {
		w.logger.Info().Int("scraped", len(articles)).Msg("no new articles, skipping generation")
		return w.expireOldQuestions(ctx)
	}

	w.logger.Info().Int("new_articles", len(newArticles)).Msg("generating questions")

	batches, err := w.gen.Generate(ctx, newArticles)
	if err != nil {
		return fmt.Errorf("generate: %w", err)
	}

	totalInserted := 0
	for _, batch := range batches {
		levelIDs, err := w.getActiveCyberLevels(ctx)
		if err != nil {
			w.logger.Warn().Err(err).Msg("failed to get cyber levels, skipping batch")
			continue
		}
		if len(levelIDs) == 0 {
			w.logger.Warn().Msg("no active cyber levels found, skipping insert")
			continue
		}

		for i, q := range batch.Questions {
			levelID := levelIDs[i%len(levelIDs)]
			payloadJSON, err := json.Marshal(q.Payload)
			if err != nil {
				continue
			}

			questionID := fmt.Sprintf("ai_%s_q%d", shortHash(batch.SourceURL), i)

			_, err = w.db.ExecContext(ctx, `
				INSERT INTO training_questions (id, level_id, type, question, payload, xp, ord, is_active, source, difficulty_level, generated_at, source_url)
				VALUES ($1, $2, $3, $4, $5::jsonb, $6, $7, TRUE, 'ai_generated', $8, NOW(), $9)
				ON CONFLICT (id) DO NOTHING
			`, questionID, levelID, q.Type, q.Question, string(payloadJSON), q.XP, i+1, q.DifficultyLevel, batch.SourceURL)

			if err != nil {
				w.logger.Warn().Err(err).Str("question_id", questionID).Msg("insert failed")
				continue
			}
			totalInserted++
		}
	}

	w.logger.Info().Int("inserted", totalInserted).Msg("cycle complete")

	if err := w.expireOldQuestions(ctx); err != nil {
		w.logger.Warn().Err(err).Msg("question expiry had errors")
	}

	return nil
}

func (w *Worker) articleExists(ctx context.Context, url string) (bool, error) {
	var count int
	err := w.db.QueryRowContext(ctx,
		"SELECT COUNT(*) FROM training_questions WHERE source_url = $1 AND source = 'ai_generated'",
		url,
	).Scan(&count)
	return count > 0, err
}

func (w *Worker) expireOldQuestions(ctx context.Context) error {
	cutoff := time.Now().Add(-questionExpiry)
	result, err := w.db.ExecContext(ctx,
		"UPDATE training_questions SET is_active = FALSE WHERE source = 'ai_generated' AND generated_at < $1 AND is_active = TRUE",
		cutoff,
	)
	if err != nil {
		return fmt.Errorf("expire questions: %w", err)
	}
	n, _ := result.RowsAffected()
	if n > 0 {
		w.logger.Info().Int64("expired", n).Msg("expired old questions")
	}
	return nil
}

func (w *Worker) getActiveCyberLevels(ctx context.Context) ([]string, error) {
	rows, err := w.db.QueryContext(ctx, `
		SELECT l.id FROM training_levels l
		JOIN training_units u ON l.unit_id = u.id
		JOIN training_sections s ON u.section_id = s.id
		WHERE s.id LIKE 'cyber%' AND l.is_active = TRUE AND u.is_active = TRUE
		ORDER BY l.level_number
		LIMIT 50
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, nil
}

func shortHash(s string) string {
	h := 0
	for _, c := range s {
		h = h*31 + int(c)
	}
	if h < 0 {
		h = -h
	}
	return fmt.Sprintf("%08x", h%0x100000000)
}
