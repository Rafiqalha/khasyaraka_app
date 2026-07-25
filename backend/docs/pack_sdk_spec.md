# Pradigi Pack SDK Specification

## Overview
A `Pack` is an encapsulated bundle of learning activities, assets, and curriculum mappings. The Pradigi Pack SDK allows third-party educators, AI engines, and the community to develop and publish content to the Pradigi Ecosystem seamlessly. 

A Pack is distributed as a `.pack` file, which is essentially a compressed archive (e.g., `.tar.gz` or `.zip`) containing a specific directory structure and manifest files.

## Directory Structure

```text
my-cyber-pack.pack/
├── manifest.yaml          # Core metadata (Title, Author, Version)
├── competencies.yaml      # The list of competencies taught in this pack
├── prerequisites.yaml     # The competencies required to start this pack
├── capabilities/          # Macro-skills that this pack builds (for Capability Engine)
│   └── backend_api.yaml
├── activities/            # The actual learning modules
│   ├── 01_intro.yaml
│   ├── 02_arena.yaml
│   └── 03_reflection.yaml
├── assets/                # Media files and attachments
│   ├── diagram.png
│   └── data.csv
└── sandbox/               # (Optional) Dockerfiles and init scripts for Arena/Workspace
    ├── Dockerfile
    └── setup.sh
```

## Manifest Examples

### `manifest.yaml`
```yaml
id: "pack_cyber_101"
title: "Introduction to Cybersecurity"
version: "1.0.0"
author: "Pradigi Core Team"
description: "A beginner-friendly pack for understanding cyber fundamentals."
tags: ["cybersecurity", "beginner", "networking"]
```

### `competencies.yaml`
Defines the skills granted by completing this pack. These tie into the global Competency Graph.
```yaml
competencies:
  - id: "comp_network_basics"
    weight: 1.0
  - id: "comp_threat_modeling"
    weight: 0.5
```

### `prerequisites.yaml`
```yaml
requires:
  - id: "comp_basic_computing"
    min_mastery: 0.8
suggests:
  - id: "comp_linux_basics"
```

### `capabilities/backend_api.yaml`
Defines macro-capabilities built by this pack, consumed by the Capability Engine.
```yaml
id: "cap_backend_api"
title: "Can Build Backend API"
requires:
  - "comp_http"
  - "comp_rest"
  - "comp_jwt"
  - "comp_database"
```

### `activities/01_intro.yaml`
An example of an activity definition.
```yaml
id: "act_cyber_intro_01"
type: "interactive_lesson"
title: "What is a network?"
content: "..." # Markdown or reference to an asset file
grants_competencies:
  - id: "comp_network_basics"
    weight: 0.2
```

## Ingestion Workflow
When a `.pack` is uploaded to the Pradigi platform:
1. **Validation**: The backend verifies the schema of all YAML files.
2. **Graph Linking**: The system checks if the required and granted competencies exist in the global Knowledge Graph. If not, it can propose adding them.
3. **Asset Upload**: Images and sandbox files are uploaded to cloud storage (e.g., S3).
4. **Database Insertion**: The pack is normalized into relational tables (`packs`, `pack_activities`, `activity_competencies`).
5. **Availability**: The pack becomes available in the Recommendation Engine and Trajectory Engine for users to consume.
