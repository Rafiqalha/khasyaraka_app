package runtime

import (
	"context"
	"encoding/json"
	"fmt"
	"sort"
	"sync"
	"time"

	"github.com/pradigi/backend/internal/core/ai_gateway"
	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/core/mission_compiler"
	"github.com/pradigi/backend/internal/core/mission_engine"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// WorkspaceBundle represents resolved panels, services, and dynamic UI layout.
type WorkspaceBundle struct {
	Layout   string   `json:"layout"`   // e.g., "ide_split_terminal", "api_client_layout", "mentorship_reflection_layout"
	Panels   []string `json:"panels"`   // e.g., ["editor", "terminal", "browser", "reflection"]
	Services []string `json:"services"` // e.g., ["sandbox_service", "postgres_container"]
}

// WorkspaceManifest is the final UI-agnostic layout and panel list sent to Flutter.
// BOUNDARY RULE: Flutter only calls render(manifest) without domain knowledge.
type WorkspaceManifest struct {
	ManifestID string   `json:"manifest_id"`
	Layout     string   `json:"layout"` // e.g., "ide_split_terminal", "api_client_layout"
	Panels     []string `json:"panels"` // e.g., ["editor", "terminal", "reflection"]
	Services   []string `json:"services"`
}

// PluginDefinition defines an active tool plugin in the Runtime Registry.
type PluginDefinition struct {
	ID       string   `json:"id"`
	Name     string   `json:"name"`
	Category string   `json:"category"`
	Panels   []string `json:"panels"`
	Services []string `json:"services"`
	Active   bool     `json:"active"`
}

// RuntimeRegistry acts as the Plugin Registry that resolves abstract needs into concrete Workspace bundles.
type RuntimeRegistry struct {
	plugins map[string]*PluginDefinition
	bus     kernel.EventBus
	mu      sync.RWMutex
}

func NewRuntimeRegistry(bus kernel.EventBus) *RuntimeRegistry {
	r := &RuntimeRegistry{
		plugins: make(map[string]*PluginDefinition),
		bus:     bus,
	}
	r.registerDefaults()
	return r
}

func (r *RuntimeRegistry) registerDefaults() {
	// Coding & IDE Sandbox plugins
	r.Register(&PluginDefinition{
		ID:       "plugin_editor_default",
		Name:     "Standard Code Editor",
		Category: "coding",
		Panels:   []string{"editor", "terminal"},
		Services: []string{"sandbox_service", "file_service"},
		Active:   true,
	})
	r.Register(&PluginDefinition{
		ID:       "plugin_terminal_exec",
		Name:     "Linux Terminal Sandbox",
		Category: "terminal_execution",
		Panels:   []string{"file_tree", "terminal"},
		Services: []string{"sandbox_service", "linter_service"},
		Active:   true,
	})

	// API & Database Inspection plugins
	r.Register(&PluginDefinition{
		ID:       "plugin_api_tester",
		Name:     "Live API Tester & Proxy",
		Category: "api_testing",
		Panels:   []string{"terminal", "browser"},
		Services: []string{"http_proxy_service"},
		Active:   true,
	})
	r.Register(&PluginDefinition{
		ID:       "plugin_postgres_db",
		Name:     "PostgreSQL Sandbox Container",
		Category: "database",
		Panels:   []string{"api_client", "db_viewer", "terminal"},
		Services: []string{"postgres_container_service"},
		Active:   true,
	})

	// Architecture & Mentorship Reflection plugins
	r.Register(&PluginDefinition{
		ID:       "plugin_ai_reflection",
		Name:     "AI Director Reflection Panel",
		Category: "reflection",
		Panels:   []string{"reflection"},
		Services: []string{"ai_director_service", "telemetry_service"},
		Active:   true,
	})
	r.Register(&PluginDefinition{
		ID:       "plugin_arch_canvas",
		Name:     "Architecture Design Canvas",
		Category: "architecture_design",
		Panels:   []string{"architecture_canvas", "director_mentorship", "reflection"},
		Services: []string{"ai_director_service", "cognitive_time_machine_service"},
		Active:   true,
	})

	// Web Browser preview
	r.Register(&PluginDefinition{
		ID:       "plugin_web_browser",
		Name:     "Headless Web Browser Preview",
		Category: "browser",
		Panels:   []string{"browser"},
		Services: []string{"web_preview_service"},
		Active:   true,
	})
}

func (r *RuntimeRegistry) Register(plugin *PluginDefinition) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.plugins[plugin.ID] = plugin
}

func (r *RuntimeRegistry) GetPluginsByCategory(category string) []*PluginDefinition {
	r.mu.RLock()
	defer r.mu.RUnlock()
	var result []*PluginDefinition
	for _, p := range r.plugins {
		if p.Category == category && p.Active {
			result = append(result, p)
		}
	}
	return result
}

// Resolve takes an abstract MissionSpecification and resolves its "needs" into a concrete WorkspaceBundle.
func (r *RuntimeRegistry) Resolve(spec *mission_compiler.MissionSpecification) (*WorkspaceBundle, error) {
	return r.resolveNeeds(spec.RuntimeRequirements.Needs)
}

func (r *RuntimeRegistry) resolveNeeds(needs []string) (*WorkspaceBundle, error) {
	panelSet := make(map[string]bool)
	serviceSet := make(map[string]bool)
	needSet := make(map[string]bool)

	for _, need := range needs {
		needSet[need] = true
		plugins := r.GetPluginsByCategory(need)
		if len(plugins) == 0 {
			return nil, fmt.Errorf("no active runtime plugin registered for abstract capability need: %s", need)
		}
		for _, p := range plugins {
			for _, panel := range p.Panels {
				panelSet[panel] = true
			}
			for _, service := range p.Services {
				serviceSet[service] = true
			}
		}
	}

	var panels []string
	for p := range panelSet {
		panels = append(panels, p)
	}
	sort.Strings(panels)

	var services []string
	for s := range serviceSet {
		services = append(services, s)
	}
	sort.Strings(services)

	// Dynamic Layout Selection based on capability needs
	layout := "ide_split_terminal" // Default for coding
	if needSet["database"] {
		layout = "api_client_layout"
	} else if needSet["architecture_design"] {
		layout = "mentorship_reflection_layout"
	} else if needSet["browser"] && !needSet["coding"] {
		layout = "fullstack_web_preview"
	}

	return &WorkspaceBundle{
		Layout:   layout,
		Panels:   panels,
		Services: services,
	}, nil
}

// OnEvent subscribes to EventMissionGenerated emitted by AI Gateway.
func (r *RuntimeRegistry) OnEvent(ctx context.Context, event kernel.Event) error {
	if event.Type != mission_engine.EventMissionGenerated {
		return nil
	}

	var instance ai_gateway.RichMissionInstance
	if err := json.Unmarshal(event.Payload, &instance); err != nil {
		return fmt.Errorf("failed to unmarshal RichMissionInstance in Runtime Registry: %w", err)
	}

	logger.Info().Str("session", event.SessionID).Str("instance", instance.InstanceID).Msg("Runtime Registry resolving plugin needs to Workspace Manifest")

	bundle, err := r.resolveNeeds(instance.RuntimeRequirements.Needs)
	if err != nil {
		return err
	}

	manifest := &WorkspaceManifest{
		ManifestID: fmt.Sprintf("wsm_%d", time.Now().Unix()),
		Layout:     bundle.Layout,
		Panels:     bundle.Panels,
		Services:   bundle.Services,
	}

	payloadBytes, _ := json.Marshal(manifest)
	provEvent := kernel.Event{
		ID:        fmt.Sprintf("evt_prov_%d", time.Now().UnixNano()),
		SessionID: event.SessionID,
		Type:      mission_engine.EventWorkspaceProvisioned,
		Source:    "runtime_registry_plugin_manager",
		Timestamp: time.Now(),
		Payload:   payloadBytes,
	}

	logger.Info().Str("session", event.SessionID).Str("layout", manifest.Layout).Msg("Runtime Registry emitting WorkspaceProvisioned event to OS Event Bus")
	if r.bus != nil {
		return r.bus.Publish(ctx, provEvent)
	}
	return nil
}
