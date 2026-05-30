# Google Cloud Rapid Agent Hackathon Core

Vlang product module for AegisOps, an agentic incident operations MVP built for
the Google Cloud Rapid Agent Hackathon Dynatrace track.

## Commands

```powershell
v run cmd\agent --sample
v run cmd\agent --sample --output ..\contests\worth_it\google_cloud_rapid_agent_hackathon\evidence\v_agent_run.json
v run cmd\agent serve --port 8080
v test .
```

## Cloud Run

```powershell
.\scripts\deploy_cloud_run.ps1 -ProjectId YOUR_PROJECT_ID -Region us-central1
```

GitHub Actions deploy is also available through `.github/workflows/deploy-cloud-run.yml`
with repository secrets `GCP_SA_KEY`, `GCP_PROJECT_ID`, `GEMINI_API_KEY`,
`DYNATRACE_MCP_TOKEN` and `DYNATRACE_MCP_URL`.

## Architecture

- `agenticops`: domain, ports, policies, adapters, orchestrator and evaluator.
- `cmd/agent`: CLI and HTTP backend entrypoint.
- `tests`: V smoke coverage for planning, redaction and evidence.

The core is dependency-injected: `Agent` depends on `Planner` and `Telemetry`
interfaces, with Gemini and Dynatrace as replaceable adapters.
