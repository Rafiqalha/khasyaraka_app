DROP TABLE IF EXISTS capability_snapshots;
DROP TABLE IF EXISTS competency_projections;
DROP TABLE IF EXISTS capability_deltas;
DROP TABLE IF EXISTS skill_ontology_relations;
DROP TABLE IF EXISTS skill_ontology_nodes;
DROP TABLE IF EXISTS skill_ontology_versions;
DROP TABLE IF EXISTS skill_ontology_identities;

ALTER TABLE evidence_resolutions DROP COLUMN policy_id, DROP COLUMN rule_id, DROP COLUMN strategy_id;
ALTER TABLE governance_policies DROP COLUMN effective_until, DROP COLUMN effective_from;
