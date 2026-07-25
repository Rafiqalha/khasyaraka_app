package sandbox

import (
	"context"
	"fmt"
	"log"
	"sync"
	"time"
)

type ContainerState string

const (
	StateCreating  ContainerState = "CREATING"
	StateIdle      ContainerState = "IDLE"
	StateBusy      ContainerState = "BUSY"
	StateDraining  ContainerState = "DRAINING"
	StateDestroyed ContainerState = "DESTROYED"
)

type CircuitState string

const (
	CircuitClosed   CircuitState = "CLOSED"
	CircuitOpen     CircuitState = "OPEN"
	CircuitHalfOpen CircuitState = "HALF_OPEN"
)

type PoolConfig struct {
	MinIdle        int
	MaxPool        int
	MaxUse         int
	MaxLifetime    time.Duration
	AcquireTimeout time.Duration
}

type managedContainer struct {
	runner    Runner
	state     ContainerState
	uses      int
	createdAt time.Time
}

type WarmPool struct {
	config PoolConfig

	mu         sync.Mutex
	containers map[string]*managedContainer

	// Channels for acquiring idle containers
	idleChan chan *managedContainer

	// Circuit Breaker
	circuitState        CircuitState
	consecutiveFailures int
	lastFailureTime     time.Time
}

func NewWarmPool(ctx context.Context, config PoolConfig) *WarmPool {
	p := &WarmPool{
		config:       config,
		containers:   make(map[string]*managedContainer),
		idleChan:     make(chan *managedContainer, config.MaxPool),
		circuitState: CircuitClosed,
	}

	// Pre-warm minimum containers
	for i := 0; i < config.MinIdle; i++ {
		go p.spawnContainer(context.Background())
	}

	// Start background manager for auto-scaling and heartbeats
	go p.managerLoop(ctx)

	return p
}

func (p *WarmPool) spawnContainer(ctx context.Context) {
	// Create placeholder in map
	mc := &managedContainer{
		state:     StateCreating,
		createdAt: time.Now(),
	}

	runner, err := NewDockerRunner(ctx, "python:3.11-slim")
	if err != nil {
		log.Printf("Failed to spawn container: %v\n", err)
		p.recordFailure()
		return
	}

	mc.runner = runner
	mc.state = StateIdle

	p.mu.Lock()
	p.containers[runner.GetID()] = mc
	p.mu.Unlock()

	// Push to idle pool
	select {
	case p.idleChan <- mc:
	default:
		// Pool is somehow full, destroy the excess
		mc.state = StateDraining
		go p.destroyContainer(mc)
	}
	p.recordSuccess()
}

func (p *WarmPool) destroyContainer(mc *managedContainer) {
	p.mu.Lock()
	mc.state = StateDestroyed
	delete(p.containers, mc.runner.GetID())
	p.mu.Unlock()
	mc.runner.Destroy()
}

func (p *WarmPool) Acquire(ctx context.Context, language string) (Runner, error) {
	p.mu.Lock()
	state := p.circuitState
	p.mu.Unlock()

	if state == CircuitOpen {
		return nil, fmt.Errorf("circuit breaker is OPEN")
	}

	// Timeout context
	acqCtx, cancel := context.WithTimeout(ctx, p.config.AcquireTimeout)
	defer cancel()

	for {
		select {
		case mc := <-p.idleChan:
			p.mu.Lock()
			if mc.state == StateDraining || mc.state == StateDestroyed {
				p.mu.Unlock()
				continue // Skip and try again
			}
			mc.state = StateBusy
			mc.uses++
			p.mu.Unlock()
			return mc.runner, nil
		case <-acqCtx.Done():
			return nil, fmt.Errorf("timeout waiting for idle container")
		}
	}
}

func (p *WarmPool) Release(r Runner) {
	p.mu.Lock()
	mc, exists := p.containers[r.GetID()]
	if !exists {
		p.mu.Unlock()
		return
	}

	if mc.uses >= p.config.MaxUse || time.Since(mc.createdAt) > p.config.MaxLifetime {
		mc.state = StateDraining
		p.mu.Unlock()
		go p.destroyContainer(mc)
		return
	}

	mc.state = StateIdle
	p.mu.Unlock()

	select {
	case p.idleChan <- mc:
	default:
		// Should not happen, but safe fallback
		go p.destroyContainer(mc)
	}
}

func (p *WarmPool) recordFailure() {
	p.mu.Lock()
	defer p.mu.Unlock()

	p.consecutiveFailures++
	if p.circuitState == CircuitHalfOpen {
		// Failed while half-open, immediately back to open
		p.circuitState = CircuitOpen
		p.lastFailureTime = time.Now()
		log.Println("Circuit Breaker state changed: HALF_OPEN -> OPEN")
	} else if p.circuitState == CircuitClosed && p.consecutiveFailures >= 20 {
		p.circuitState = CircuitOpen
		p.lastFailureTime = time.Now()
		log.Println("Circuit Breaker state changed: CLOSED -> OPEN")
	}
}

func (p *WarmPool) recordSuccess() {
	p.mu.Lock()
	defer p.mu.Unlock()

	p.consecutiveFailures = 0
	if p.circuitState == CircuitHalfOpen {
		p.circuitState = CircuitClosed
		log.Println("Circuit Breaker state changed: HALF_OPEN -> CLOSED")
	}
}

func (p *WarmPool) managerLoop(ctx context.Context) {
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	heartbeatDeepTick := time.NewTicker(5 * time.Minute)
	defer heartbeatDeepTick.Stop()

	heartbeatLightTick := time.NewTicker(10 * time.Second)
	defer heartbeatLightTick.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			p.checkScaling()
			p.checkCircuitBreaker()
		case <-heartbeatLightTick.C:
			p.runHeartbeats(false)
		case <-heartbeatDeepTick.C:
			p.runHeartbeats(true)
		}
	}
}

func (p *WarmPool) checkScaling() {
	p.mu.Lock()

	idleCount := 0
	busyCount := 0
	totalCount := len(p.containers)

	for _, mc := range p.containers {
		if mc.state == StateIdle {
			idleCount++
		} else if mc.state == StateBusy {
			busyCount++
		}
	}
	p.mu.Unlock()

	busyRatio := 0.0
	if totalCount > 0 {
		busyRatio = float64(busyCount) / float64(totalCount)
	}

	// Auto-scale condition
	if totalCount < p.config.MaxPool {
		if idleCount < p.config.MinIdle || busyRatio > 0.8 {
			go p.spawnContainer(context.Background())
		}
	}
}

func (p *WarmPool) checkCircuitBreaker() {
	p.mu.Lock()
	defer p.mu.Unlock()

	if p.circuitState == CircuitOpen && time.Since(p.lastFailureTime) > 30*time.Second {
		p.circuitState = CircuitHalfOpen
		log.Println("Circuit Breaker state changed: OPEN -> HALF_OPEN")
	}
}

func (p *WarmPool) runHeartbeats(deep bool) {
	p.mu.Lock()
	// Copy the map to avoid holding lock during network I/O
	containers := make([]*managedContainer, 0, len(p.containers))
	for _, mc := range p.containers {
		if mc.state == StateIdle { // Only heartbeat idle containers
			containers = append(containers, mc)
		}
	}
	p.mu.Unlock()

	for _, mc := range containers {
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		var err error
		if deep {
			err = mc.runner.HeartbeatDeep(ctx)
		} else {
			err = mc.runner.HeartbeatLight(ctx)
		}
		cancel()

		if err != nil {
			log.Printf("Heartbeat failed for container %s: %v\n", mc.runner.GetID(), err)
			p.mu.Lock()
			mc.state = StateDraining
			p.mu.Unlock()

			// Remove from idle pool and destroy
			// Note: This is tricky because it might still be in idleChan.
			// The easiest way is to let the next Acquire fail or just destroy it.
			// When Acquire pops a draining container, it will skip it.
			go p.destroyContainer(mc)
		}
	}
}

func (p *WarmPool) Metrics() PoolMetrics {
	p.mu.Lock()
	defer p.mu.Unlock()

	metrics := PoolMetrics{}
	for _, mc := range p.containers {
		switch mc.state {
		case StateIdle:
			metrics.Idle++
		case StateBusy:
			metrics.Busy++
		case StateDraining:
			metrics.Draining++
		case StateCreating:
			metrics.Creating++
		}
	}
	return metrics
}
