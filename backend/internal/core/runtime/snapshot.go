package runtime

import (
	"context"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

type SnapshotDomain string

const (
	DomainTrajectory  SnapshotDomain = "trajectory"
	DomainDirector    SnapshotDomain = "director"
	DomainPortfolio   SnapshotDomain = "portfolio"
	DomainAnalytics   SnapshotDomain = "analytics"
	DomainLeaderboard SnapshotDomain = "leaderboard"
)

type SnapshotStore struct {
	rdb *redis.Client
}

func NewSnapshotStore(rdb *redis.Client) *SnapshotStore {
	return &SnapshotStore{rdb: rdb}
}

// Save isolates the snapshot to a specific domain prefix
func (s *SnapshotStore) Save(ctx context.Context, userID string, domain SnapshotDomain, data string, ttl time.Duration) error {
	key := fmt.Sprintf("snapshot:%s:%s", domain, userID)
	return s.rdb.Set(ctx, key, data, ttl).Err()
}

// Load retrieves a domain-isolated snapshot
func (s *SnapshotStore) Load(ctx context.Context, userID string, domain SnapshotDomain) (string, error) {
	key := fmt.Sprintf("snapshot:%s:%s", domain, userID)
	return s.rdb.Get(ctx, key).Result()
}
