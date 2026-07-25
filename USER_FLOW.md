# USER_FLOW.md

Version: 2.0 (OS Kernel Lifecycle)
Product: Pradigi Learning OS
Status: Living Document

---

# Overview

Pradigi is designed around one continuous, unbroken execution loop:

```text
Identity → Journey → Provisioning → Mission 0 (Diagnostic) → Workspace Loop (Execute → Evaluate → Reflect → Evidence → Knowledge Graph → Planner → Next Mission)
```

Unlike traditional LMS platforms where users "take courses" and navigate dashboards, Pradigi is a **Workspace-Centric Learning Operating System**. The user operates within an ongoing journey composed of dynamic runtime sessions, mission executions, reflection evidence, and continuous knowledge graph adaptations.

---

# Master OS Lifecycle Flow

```text
┌──────────────────────────────┐
│ Learning Identity            │ (Name, Account, Career Target)
└──────────────┬───────────────┘
               │
               ▼
      Explore Learning Paths     (Academies & Specializations)
               │
               ▼
      Select Blueprint Pack      (e.g., PyTorch / ML Engineer Pack)
               │
               ▼
     Kernel Journey Provisioning (Registry → Loader → Planner → Create Runtime)
               │
               ▼
     Mission 0 (AI Diagnostic)   (First targeted runtime assessment)
               │
               ▼
         Planner Engine          (Calculates initial capability & trajectory)
               │
               ▼
      Command Center (Home)      (Minimalist launcher: Active Runtime & Next Directive)
               │
               ▼
      Open Active Runtime        (Transfers focus to Workspace Engine)
               │
               ▼
        Workspace Engine         (Editor, Terminal, Notebook, Director Panel)
               │
               ▼
   Execute → Evaluate → Reflect  (Mission execution, AI evaluation, Learner reflection)
               │
               ▼
       Evidence Collection       (Artifacts, verified code, certificates)
               │
               ▼
      Knowledge Graph Update     (Single Source of Truth for capability)
               │
               ▼
         Planner Engine          (Calculates next optimal mission)
               │
               ▼
          Next Mission
               │
               └───────────────► (Continuous Execution Loop)
```

---

# Key Architectural Principles

### 1. Targeted AI Diagnostic (`Mission 0`)
- **Diagnostic runs AFTER Journey/Blueprint Selection**, not before.
- Knowing the learner's explicit target (e.g., *Machine Learning Engineer*) allows the Director to run a highly specific diagnostic (*Python, NumPy, Linear Algebra, Gradient Descent*) rather than a broad/irrelevant test (*Linux, Security, Web*).
- **Mission 0 is a Workspace Runtime**, not an interview modal. From minute 1, the user is already building and solving inside the OS.

### 2. Kernel Journey Provisioning
- When a user selects a Blueprint Pack from Explore, the Kernel triggers:
  ```text
  Registry → Blueprint Loader → Planner → Create Runtime → Create Enrollment
  ```
- The environment is fully provisioned before the user enters Mission 0.

### 3. Command Center (`Home`)
- **Home is a transit Command Center**, answering only two questions:
  1. *What is my active runtime?*
  2. *What is my next directive?*
- There are no generic dashboards, news feeds, or progress charts on Home.

### 4. Workspace Engine (`Workspace`)
- **90%+ of user time is spent in the Workspace**.
- Workspace is a **Context/State**, not a static top-level navigation page. It displays when an active runtime session exists.

### 5. Reflection & Evidence Pipeline
- Execution is followed by:
  ```text
  Execute → Evaluate → Reflect → Evidence Collection
  ```
- Learner reflection provides rich qualitative signals for the Director to store in AI Memory.

### 6. Knowledge Graph as Single Source of Truth
- Evidence updates the **Knowledge Graph**.
- The **Planner Engine reads exclusively from the Knowledge Graph** to calculate difficulty and next mission recommendations. Planner never parses raw evidence files directly.

### 7. Continuous Unbroken Loop
- There is no "Course Completed → Select New Course" friction.
- The OS operates as an ongoing engineering lifecycle: `Mission → Mission → Mission`.