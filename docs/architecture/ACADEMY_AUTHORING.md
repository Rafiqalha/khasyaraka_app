# Pradigi Academy Authoring Guide

Welcome to the Pradigi OS! As an Academy Developer, your job is not to build backend logic or UI frameworks. Your job is strictly to map out knowledge, curate learning assets, and define missions. The Universal Learning OS handles the rest (rendering, adaptation, competency tracking, and behavior analysis).

This guide will show you how to structure and build a new Academy from scratch.

## 1. Academy Standard Structure
Every Academy in Pradigi is a self-contained bundle defined in the `academies/` directory.

```text
academies/
  <academy_name>/
    ├── academy.yaml          # Meta info (Name, Theme, Version)
    ├── curriculum/           # YAML files defining Syllabus (Units, Lessons, LOs)
    ├── knowledge/            # knowledge_graph.yaml (Concepts and Relations)
    ├── missions/             # Mission specifications and fixtures
    ├── assets/               # Markdown, JSON animations, Mermaid diagrams
    └── workspace/            # workspace.yaml (WDL definitions for tools & layout)
```

## 2. How to Create an Academy
Create a folder `academies/my_academy/` and create `academy.yaml`:
```yaml
id: "cyber_academy"
name: "Cyber Security Academy"
version: "1.0.0"
theme:
  primary_color: "#00FF00"
```

## 3. How to Create a Concept (Knowledge Graph)
Concepts are the atomic units of learning. Define them in `knowledge/knowledge_graph.yaml`:
```yaml
concepts:
  - id: "log_analysis"
    title: "Log Analysis"
    description: "Understanding system and application logs."
    assets:
      - id: "asset_log_theory"
        type: "notebook"
      - id: "asset_log_mission"
        type: "mission"

relations:
  - source_id: "log_analysis"
    target_id: "anomaly_detection"
    type: "builds_on"
```

## 4. How to Create Learning Assets
Assets are attached to concepts.
- **Notebook**: Place a Markdown file in `assets/log_theory.md`. Use `:::adaptive:::` for AI injection placeholders.
- **Visualizations**: Place `.mmd` (Mermaid) or `.json` (Lottie) files in `assets/`.

## 5. How to Create a Lesson (Curriculum)
Lessons act as containers in the syllabus, mapped to Concepts. In `curriculum/syllabus.yaml`:
```yaml
units:
  - id: "u1_fundamentals"
    title: "Cyber Fundamentals"
    lessons:
      - id: "l1_logs"
        title: "Introduction to Logs"
        concept_id: "log_analysis" # Links back to the Knowledge Graph!
```

## 6. How to Create a Mission
Missions are active tasks executed in the Workspace. In `missions/log_01/mission.yaml`:
```yaml
id: "mission_log_01"
title: "Find the Suspicious Login"
difficulty: "medium"
workspace_layout: ["editor", "terminal", "mentor"]
fixtures:
  - file: "auth.log"
    type: "text/plain"
```

## 7. How to Create a Workspace
Define the exact tools your Academy uses in `workspace/workspace.yaml` (WDL format).
```yaml
layout:
  panels:
    - id: "terminal"
      type: "cli"
    - id: "packet_analyzer"
      type: "network_tool"
```

## Compilation and Loading
In **Development Mode**, Pradigi automatically parses these YAML files on boot. Simply edit and refresh.
In **Production Mode**, run the `Pradigi Compiler` to bundle the academy into a `.pack` file for fast, validated loading.
