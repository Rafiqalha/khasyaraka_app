// Pradigi OS — Cognitive Capability Configuration
//
// This file defines the Skill Vector Graph taxonomy — the single source of
// truth for all cognitive dimensions tracked by the Adaptive Mission Engine.
//
// IMPORTANT: These scores represent real cognitive telemetry derived from
// observable user behavior (Layer 1 → Layer 2 deterministic rules).
// They are NOT gamification mechanics. There are no XP multipliers, no
// "level-ups," no streaks, no coins. Score changes are always explained
// to the user with specific behavioral evidence.
//
// The 6-capability taxonomy maps to universal cognitive skills that span
// any learning domain (AI, Cyber, Biomedical, Engineering, etc.).

import 'package:flutter/foundation.dart';

/// Immutable definition of a single cognitive capability dimension.
@immutable
class CapabilityConfig {
  final String id;
  final String name;
  final String description;
  final double baselineScore;
  final bool isTestableInMVP;

  const CapabilityConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.baselineScore,
    required this.isTestableInMVP,
  });
}

/// Maps signal IDs to human-readable names for AI explanation generation.
/// Stored alongside capability definitions so AssessmentEngine can read
/// them without hardcoding capability-specific logic.
@immutable
class SignalConfig {
  final String id;
  final String name;
  final CapabilitySignalType type;
  final String field;
  final dynamic expected;
  final int threshold;
  final double weight;
  final SignalConfidence confidence;

  const SignalConfig({
    required this.id,
    required this.name,
    required this.type,
    this.field = '',
    this.expected,
    this.threshold = 0,
    required this.weight,
    required this.confidence,
  });
}

enum CapabilitySignalType { binary, verified, threshold, perFinding }

enum SignalConfidence { high, medium, low }

/// The complete Pradigi OS Cognitive Telemetry Model (v1.0).
///
/// Baseline scores are intentionally differentiated — AI Safety starts
/// lowest because prompt injection defense is a specialized skill rarely
/// encountered outside security contexts. AI Collaboration starts lowest
/// because multi-agent coordination requires experience most users lack.
abstract class CapabilityRegistry {
  CapabilityRegistry._();

  static const List<CapabilityConfig> capabilities = [
    CapabilityConfig(
      id: 'ai_communication',
      name: 'AI Communication',
      description:
          'Ability to craft precise, well-structured prompts that '
          'include constraints, context, and expected output formats '
          'to guide AI systems toward accurate and useful responses.',
      baselineScore: 0.40,
      isTestableInMVP: true,
    ),
    CapabilityConfig(
      id: 'ai_reasoning',
      name: 'AI Reasoning',
      description:
          'Ability to critically evaluate AI-generated content, detect '
          'hallucinations and factual errors, and verify claims against '
          'independent data sources before accepting them as true.',
      baselineScore: 0.35,
      isTestableInMVP: true,
    ),
    CapabilityConfig(
      id: 'ai_planning',
      name: 'AI Planning',
      description:
          'Ability to decompose complex problems into logical sequences '
          'of sub-tasks that AI agents can execute independently, '
          'maintaining correct ordering and dependency relationships.',
      baselineScore: 0.25,
      isTestableInMVP: false,
    ),
    CapabilityConfig(
      id: 'ai_automation',
      name: 'AI Automation',
      description:
          'Ability to orchestrate AI tools and APIs into automated '
          'workflows, selecting the appropriate tool for each step '
          'and validating intermediate outputs before proceeding.',
      baselineScore: 0.20,
      isTestableInMVP: false,
    ),
    CapabilityConfig(
      id: 'ai_safety',
      name: 'AI Safety',
      description:
          'Ability to identify prompt injection attacks, jailbreak '
          'attempts, and adversarial inputs designed to bypass AI '
          'safety boundaries or extract protected information.',
      baselineScore: 0.15,
      isTestableInMVP: true,
    ),
    CapabilityConfig(
      id: 'ai_collaboration',
      name: 'AI Collaboration',
      description:
          'Ability to coordinate human-in-the-loop oversight and '
          'multi-agent AI systems, delegating tasks between human '
          'and machine participants based on comparative advantage.',
      baselineScore: 0.10,
      isTestableInMVP: false,
    ),
  ];

  /// Convenience accessor: lookup a capability by its string ID.
  static CapabilityConfig? byId(String id) {
    try {
      return capabilities.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns only capabilities that are testable in the current MVP.
  static List<CapabilityConfig> get mvpTestable =>
      capabilities.where((c) => c.isTestableInMVP).toList();
}
