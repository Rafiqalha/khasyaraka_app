-- ============================================================
-- Cognitive Experiment Platform (Workbench) - Contract v1
-- ============================================================

-- Experiment Layer (Research Container)
CREATE TABLE workbench_experiments (
    id VARCHAR(26) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    epoch_id VARCHAR(26) NOT NULL,
    -- Research Metadata
    hypothesis TEXT,
    variables JSONB,        -- {"independent": [...], "dependent": [...]}
    treatment JSONB,        -- Experiment variant A
    control JSONB,          -- Experiment variant B
    metrics JSONB,          -- Expected measurement points
    research_notes TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'DRAFT', -- DRAFT, ACTIVE, COMPLETED, ARCHIVED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Mission Layer (Objective Container)
CREATE TABLE workbench_missions (
    id VARCHAR(26) PRIMARY KEY,
    experiment_id VARCHAR(26) REFERENCES workbench_experiments(id),
    title VARCHAR(255) NOT NULL,
    -- Capability Declaration (NOT tool specification - Domain Adapter resolves this)
    required_capabilities JSONB NOT NULL, -- ["code_editor", "terminal", "execution", "mentor"]
    -- Narrative & Structure
    narrative TEXT,
    difficulty VARCHAR(50) NOT NULL DEFAULT 'MEDIUM', -- EASY, MEDIUM, HARD, EXPERT
    domain VARCHAR(100) NOT NULL,  -- "python", "cybersecurity", "sql" — used by Domain Adapter
    ai_budget INT NOT NULL DEFAULT 5, -- Max AI calls allowed per session
    -- Evaluation Contract
    completion_conditions JSONB NOT NULL,
    possible_outcomes JSONB NOT NULL, -- ["Solved", "Solved with AI", "Abandoned", "Timed Out"]
    time_limit_seconds INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Scenario Layer (Variant Container)
CREATE TABLE workbench_scenarios (
    id VARCHAR(26) PRIMARY KEY,
    mission_id VARCHAR(26) NOT NULL REFERENCES workbench_missions(id),
    title VARCHAR(255) NOT NULL,
    initial_state_json JSONB NOT NULL, -- Injected broken code, seed data, etc.
    constraints JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Environment Snapshot (Tree-based, Partial Replay supported)
CREATE TABLE workbench_environment_snapshots (
    id VARCHAR(26) PRIMARY KEY,
    session_id VARCHAR(26) NOT NULL,
    scenario_id VARCHAR(26) NOT NULL REFERENCES workbench_scenarios(id),
    -- Tree nodes, each snapshot references a parent
    parent_snapshot_id VARCHAR(26),
    -- Hierarchical components (each is a named node of the tree)
    component VARCHAR(100) NOT NULL, -- "editor", "console", "terminal", "files", "variables", "clock", "processes"
    component_state_json JSONB NOT NULL,
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Cognitive Artifacts (Versioned Scratchpad, Hypotheses, Temp Code)
CREATE TABLE workbench_cognitive_artifacts (
    id VARCHAR(26) PRIMARY KEY,
    session_id VARCHAR(26) NOT NULL,
    artifact_type VARCHAR(100) NOT NULL, -- "scratch_note", "hypothesis", "temp_code", "diagram", "todo"
    title VARCHAR(255),
    version INT NOT NULL DEFAULT 1,
    previous_version_id VARCHAR(26), -- Self-reference for version chain
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Decision Graph (Projection, built from Learning Activity events)
CREATE TABLE workbench_decision_graphs (
    id VARCHAR(26) PRIMARY KEY,
    session_id VARCHAR(26) NOT NULL UNIQUE,
    snapshot_json JSONB NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'LIVE', -- LIVE, SEALED (Mission ended)
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE workbench_decision_nodes (
    id VARCHAR(26) PRIMARY KEY,
    graph_id VARCHAR(26) NOT NULL REFERENCES workbench_decision_graphs(id),
    actor_type VARCHAR(100) NOT NULL, -- "USER", "COMPILER", "MENTOR", "LINTER", "UNIT_TEST"
    actor_id VARCHAR(100),
    action_type VARCHAR(100) NOT NULL, -- "READ_ERROR", "RUN_CODE", "ASK_MENTOR", "SAVE_FILE"
    context_json JSONB,               -- {"current_file": "...", "terminal_output": "...", "mission_stage": "..."}
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
    learning_activity_id VARCHAR(26)  -- Reference to the canonical Learning Activity
);

CREATE TABLE workbench_decision_edges (
    id VARCHAR(26) PRIMARY KEY,
    graph_id VARCHAR(26) NOT NULL REFERENCES workbench_decision_graphs(id),
    from_node_id VARCHAR(26) NOT NULL REFERENCES workbench_decision_nodes(id),
    to_node_id VARCHAR(26) NOT NULL REFERENCES workbench_decision_nodes(id),
    -- Semantic Edge Types
    edge_type VARCHAR(50) NOT NULL -- CAUSES, FOLLOWS, RETRIES, REQUESTS_HELP, VALIDATES, UNDOES, CONFIRMS
);

-- Cognitive State (FSM History)
CREATE TABLE workbench_cognitive_states (
    id VARCHAR(26) PRIMARY KEY,
    session_id VARCHAR(26) NOT NULL,
    -- FSM States: EXPLORING, FOCUSED, BLOCKED, SEEKING_HELP, VERIFYING, COMPLETED
    state VARCHAR(100) NOT NULL,
    previous_state VARCHAR(100),
    trigger_event VARCHAR(100) NOT NULL, -- The event that caused this transition
    transitioned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Mission Summary (Two-Part: Metrics + Narrative)
CREATE TABLE workbench_mission_summaries (
    id VARCHAR(26) PRIMARY KEY,
    session_id VARCHAR(26) NOT NULL UNIQUE,
    mission_id VARCHAR(26) NOT NULL REFERENCES workbench_missions(id),
    -- Metrics (Deterministic Counts)
    compile_count INT NOT NULL DEFAULT 0,
    run_count INT NOT NULL DEFAULT 0,
    ai_calls INT NOT NULL DEFAULT 0,
    hint_count INT NOT NULL DEFAULT 0,
    artifact_count INT NOT NULL DEFAULT 0,
    duration_seconds INT NOT NULL DEFAULT 0,
    outcome VARCHAR(100) NOT NULL, -- "Solved", "Solved with AI", "Abandoned", "Timed Out", "Recovered"
    -- Narrative (Mission Context)
    mission_domain VARCHAR(100) NOT NULL,
    mission_difficulty VARCHAR(50) NOT NULL,
    ai_budget_used INT NOT NULL DEFAULT 0,
    final_cognitive_state VARCHAR(100),
    sealed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Cognitive Timeline (Visual Trace)
CREATE TABLE workbench_timeline_events (
    id VARCHAR(26) PRIMARY KEY,
    session_id VARCHAR(26) NOT NULL,
    relative_ms BIGINT NOT NULL, -- Milliseconds since Mission Start
    event_type VARCHAR(100) NOT NULL, -- "MissionStarted", "ToolExecuted", "AgentResponded"
    actor VARCHAR(100),
    summary TEXT NOT NULL, -- Human readable: "Compiler returned: SyntaxError on line 12"
    learning_activity_id VARCHAR(26),
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Dataset Builder Records (Passive Downstream Consumer)
CREATE TABLE workbench_dataset_records (
    id VARCHAR(26) PRIMARY KEY,
    experiment_id VARCHAR(26) NOT NULL,
    mission_summary_id VARCHAR(26) NOT NULL REFERENCES workbench_mission_summaries(id),
    -- Anonymized Research-Grade Data
    anonymized_decision_graph JSONB,
    anonymized_cognitive_states JSONB,
    anonymized_metrics JSONB,
    tags JSONB, -- ["python", "debugging", "blocked", "ai_assisted"]
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_wb_snapshots_session ON workbench_environment_snapshots(session_id);
CREATE INDEX idx_wb_nodes_graph ON workbench_decision_nodes(graph_id);
CREATE INDEX idx_wb_edges_graph ON workbench_decision_edges(graph_id);
CREATE INDEX idx_wb_states_session ON workbench_cognitive_states(session_id);
CREATE INDEX idx_wb_timeline_session ON workbench_timeline_events(session_id);
