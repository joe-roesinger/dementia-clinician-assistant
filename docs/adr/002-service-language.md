---
status: proposed
date: 2026-10-06
---

# ADR-002: Service language

## Context

This project originally planned for Python and FastAPI for `agent-service` and left the language of `referral-legacy` open. No service code exists yet, so changing now costs nothing.

I want to get better at Go, and this project is where I have the hours to do it.

Google publishes an ADK for Go. It was announced in November 2025 and has reached 1.0, with OpenTelemetry integration and Cloud Run as a deploy target. The agent framework no longer forces Python.

## Options

**Python for both services.** This was the original plan. ADK for Python has the most examples and a built-in evaluation framework. I'd learn no Go.

**Go for both services.** One language across the repo and one toolchain in CI. Each service builds to a single static binary, which keeps images small and cold starts short on Cloud Run. `referral-legacy` speaks a raw TCP protocol with timeouts and injected faults, and Go's standard library handles that well. The cost is thinner ADK documentation, and I haven't confirmed that ADK for Go has eval tooling.

**Python for `agent-service`, Go for `referral-legacy`.** The agent work stays on the best-documented path. Go is confined to the smaller service, so I'd learn less of it. Two toolchains to lint, test, and build.

## Decision

Both services are written in Go. `agent-service` uses `net/http` from the standard library and ADK for Go.

There's a fallback. If the first ADK agent stalls for more than two working days, `agent-service` moves to Python to make use of the robust resources available for python, and `referral-legacy` stays in Go.

The eval harness language is undecided. It gets settled in later once I know what ADK for Go offers.

## Consequences

- FastAPI is out. Request validation and API docs that it would have generated are now hand-written or skipped.
- Most ADK tutorials are in Python. I'll read the Go package docs and source more often.
- The LLM-as-judge check in the final stages may need more hand-built code than it would in Python.
