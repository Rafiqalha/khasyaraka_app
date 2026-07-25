package experience

import (
	"github.com/pradigi/backend/internal/core/learning_graph"
)

// OrchestrationEngine (XOE) is the "Nervous System" that translates logical Route recommendations
// into concrete Experience Manifests (UI DSL).
type OrchestrationEngine struct{}

func NewOrchestrationEngine() *OrchestrationEngine {
	return &OrchestrationEngine{}
}

// Orchestrate reads a RouteRecommendation and resolves the required Assets into a Scene/Section/Component hierarchy.
func (e *OrchestrationEngine) Orchestrate(journeyID string, route *learning_graph.RouteRecommendation) *ExperienceManifest {
	manifest := &ExperienceManifest{
		JourneyID: journeyID,
		Scenes:    []Scene{},
	}

	// For demonstration, let's build the Scenes based on the recommended assets.
	// E.g., if route recommends: notebook -> viz -> practice -> mission

	// Scene 1: Introduction (Notebook + Viz)
	introScene := Scene{
		ID:       "scene_intro",
		Title:    "Introduction",
		Sections: []Section{},
	}

	for _, assetID := range route.RecommendedAssets {
		// Mock resolver: Depending on the asset suffix, we generate different Sections.
		if assetID == "asset_"+route.GoalConceptID+"_notebook" {
			introScene.Sections = append(introScene.Sections, Section{
				Type:  "notebook",
				Title: "Theory",
				Components: []Component{
					{Type: "markdown", Content: "# " + route.GoalConceptID + "\nLearn the basics here."},
				},
			})
		}
		if assetID == "asset_"+route.GoalConceptID+"_viz" {
			introScene.Sections = append(introScene.Sections, Section{
				Type:  "notebook",
				Title: "Visualization",
				Components: []Component{
					{Type: "diagram", Data: map[string]string{"source": "visualization_engine"}},
				},
			})
		}
		if assetID == "asset_"+route.GoalConceptID+"_mission" {
			// A Mission usually gets its own Scene
			missionScene := Scene{
				ID:    "scene_mission",
				Title: "Mission",
				Sections: []Section{
					{
						Type:  "workbench",
						Title: "Execution Environment",
						Components: []Component{
							{Type: "editor"},
							{Type: "terminal"},
							{Type: "timeline"},
						},
					},
				},
			}
			manifest.Scenes = append(manifest.Scenes, missionScene)
		}
	}

	if len(introScene.Sections) > 0 {
		// Prepend intro scene if it has content
		manifest.Scenes = append([]Scene{introScene}, manifest.Scenes...)
	}

	return manifest
}
