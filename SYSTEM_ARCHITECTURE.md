# SYSTEM_ARCHITECTURE.md

Version: v1.0
Product: Pradigi
Owner: Rafiq Alhariri Andriansyah

---

# Overview

Pradigi is an AI-native Learning Operating System designed around a modular, event-driven architecture. Every learner has a persistent Learning Identity that continuously evolves through AI analysis, missions, projects, and behavioral signals.

The architecture is built around five principles:

- AI-first
- Mobile-first
- API-first
- Modular
- Horizontally scalable

---

# High-Level Architecture

```text
                   ┌──────────────────────────────┐
                   │         Flutter App          │
                   │  Android • iOS • Desktop     │
                   └──────────────┬───────────────┘
                                  │
                           HTTPS / WebSocket
                                  │
                   ┌──────────────▼───────────────┐
                   │        API Gateway           │
                   │       Gin (Golang)           │
                   └──────────────┬───────────────┘
                                  │
      ┌───────────────────────────┼─────────────────────────────┐
      │                           │                             │
      ▼                           ▼                             ▼

 Authentication          Learning Engine               AI Engine

      │                           │                             │
      ▼                           ▼                             ▼

 PostgreSQL              Mission Engine                Gemini API

      │                           │                             │
      ├──────────────┐            │                      Embedding
      │              │            │                             │
      ▼              ▼            ▼                             ▼

 Redis          Object Storage  Analytics                AI Memory

      │
      ▼

Realtime
Leaderboard
Notifications
Presence
```

---

# Core Components

Pradigi consists of several independent services.

## 1. Client Layer

Platform

- Flutter

Targets

- Android
- iOS
- Desktop
- Web (future)

Responsibilities

- Authentication
- Local cache
- UI rendering
- Offline mode
- Realtime updates
- AI chat interface

---

# 2. API Gateway

Technology

Go (Gin)

Responsibilities

- Routing
- Authentication
- Authorization
- Rate limiting
- Validation
- API versioning

Example

```
/v1/auth
/v1/user
/v1/academy
/v1/mission
/v1/workspace
/v1/mentor
```

---

# 3. Authentication Service

Responsibilities

- User registration

- Login

- Session

- JWT

- Refresh Token

Supported

- Google

- Apple

- Email

Future

- Passkeys

---

# 4. User Service

Stores

Learning Identity

Contains

- profile

- education

- language

- career goal

- preferences

- devices

- onboarding status

---

# 5. Academy Service

Responsible for

- Academy catalog

- Units

- Lessons

- Mission sequencing

- Unlock logic

Academies

- AI

- Cybersecurity

- Robotics

- Language

- Data Science

- UI/UX

---

# 6. Mission Engine

The Mission Engine dynamically creates personalized learning tasks.

Mission Types

- Quiz

- Coding

- Simulation

- AI conversation

- Debugging

- Research

- Project

Input

Learning Identity

Skill Graph

Previous missions

Current roadmap

Output

Personalized mission

Difficulty

Hints

Rewards

---

# 7. AI Engine

The intelligence layer of Pradigi.

Powered by

Gemini

Responsibilities

- Skill estimation

- Roadmap generation

- AI mentor

- Mission generation

- Hint generation

- Feedback

- Reflection

- Career recommendation

Future

Support multiple LLM providers.

---

# 8. AI Memory

Persistent learner memory.

Stores

- strengths

- weaknesses

- misconceptions

- preferred explanations

- interests

- projects

- behavior

Example

```
User

Prefers

Visual explanation

Weak

Statistics

Strong

Python

Learning Speed

Fast

Confidence

Medium

```

AI retrieves this memory before every interaction.

---

# 9. Skill Graph Engine

Every activity updates learner skills.

Nodes

Python

Math

Statistics

English

Machine Learning

Cybersecurity

Leadership

Communication

Edges

Prerequisites

Dependencies

Growth

Skill graph drives

Mission

Roadmap

Difficulty

Career recommendation

---

# 10. Portfolio Engine

Automatically converts completed projects into portfolio assets.

Contains

- title

- description

- screenshots

- technologies

- skills

- assessment

Future

Public portfolio

Resume export

GitHub integration

---

# 11. Workspace Service

Every learner receives a personal workspace.

Modules

Notebook

Projects

Sandbox

Files

Datasets

Artifacts

Certificates

Knowledge

Future

Terminal

Docker Sandbox

Cloud IDE

---

# 12. Analytics Engine

Tracks

Mission completion

Daily streak

Learning time

Retention

Skill growth

Drop-off

Used for

AI optimization

Institution dashboard

Research

---

# Database Architecture

Main Database

PostgreSQL

Responsibilities

- users

- academy

- missions

- projects

- portfolios

- certificates

- analytics

---

# Cache Layer

Redis

Used for

- leaderboard

- realtime progress

- sessions

- notifications

- queues

- hot cache

---

# Object Storage

Stores

- avatars

- certificates

- project assets

- notebooks

Future

Dataset storage

Video storage

---

# AI Pipeline

```text
User Action

↓

Event

↓

Context Builder

↓

Retrieve AI Memory

↓

Retrieve Skill Graph

↓

Retrieve Roadmap

↓

Prompt Builder

↓

Gemini

↓

Response Validator

↓

Store Memory

↓

Return Response
```

---

# Event Flow

Example

Mission Completed

↓

Save Result

↓

Update Skill Graph

↓

Update Learning Identity

↓

Update AI Memory

↓

Generate Reflection

↓

Recommend Next Mission

↓

Notify Dashboard

---

# Learning Flow

```text
Onboarding

↓

Learning Identity

↓

Diagnostic Mission

↓

Skill Graph

↓

Roadmap

↓

Mission

↓

Feedback

↓

AI Reflection

↓

Portfolio

↓

Career Progress
```

---

# Realtime Architecture

Realtime features

Leaderboard

Mission updates

Chat

Institution dashboard

Technology

WebSocket

Redis Pub/Sub

---

# Security

Authentication

JWT

Authorization

RBAC

Encryption

HTTPS

Password

Argon2

Future

Passkeys

Device trust

Risk scoring

---

# AI Safety

Every AI response passes through

Context validation

Prompt validation

Output validation

Safety rules

No direct answer mode

Educational reasoning first

---

# API Design

REST

```
GET

POST

PATCH

DELETE
```

Example

```
GET /academy

GET /missions

POST /mission/start

POST /mentor/chat

GET /workspace

POST /portfolio

GET /roadmap
```

---

# Deployment

Containerized

Docker

Reverse Proxy

Nginx

Cloud

Oracle Cloud

Future

Google Cloud

AWS

---

# Monitoring

Metrics

CPU

Memory

Latency

Token usage

Mission generation

Error rate

Tools

Prometheus

Grafana

Future

OpenTelemetry

---

# Scalability

Stateless API servers

Horizontal scaling

Redis cache

Connection pooling

CDN

Background workers

Future

Microservices

Kubernetes

Message Queue

---

# Engineering Principles

- Mobile-first
- AI-native
- Offline-capable
- Event-driven
- Stateless backend
- Modular services
- API-first
- Security by default
- Observability by default
- Developer-friendly

---

# Long-Term Architecture Vision

Pradigi evolves from a learning platform into a complete AI Operating System.

```text
                    PRADIGI OS

                         │

             Learning Identity

                         │

                    AI Brain

                         │

    ┌────────────┬───────────────┬────────────┐

 Mission      Workspace      Portfolio    Mentor

    │              │              │            │

    └──────────────┼──────────────┘

              Continuous Learning

                      │

                Career Readiness

                      │

              Lifelong AI Companion
```

The operating system continuously observes, understands, teaches, evaluates, and improves every learner throughout their learning journey.