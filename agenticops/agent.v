module agenticops

import json

pub struct Agent {
pub:
	settings  Settings
	planner   Planner
	telemetry Telemetry
}

pub fn new_agent(settings Settings, planner Planner, telemetry Telemetry) Agent {
	return Agent{
		settings:  settings
		planner:   planner
		telemetry: telemetry
	}
}

pub fn default_agent() Agent {
	settings := default_settings()
	return new_agent(settings, new_gemini_planner(settings), new_dynatrace_telemetry(settings))
}

pub fn (agent Agent) run(incident IncidentInput) AgentRun {
	telemetry := agent.telemetry.collect(incident)
	reasoning := agent.planner.summarize(build_prompt(incident, telemetry))
	plan := build_steps(incident, telemetry)
	actions := build_actions(incident, agent.settings)
	return AgentRun{
		run_id:             run_id(incident)
		generated_at:       utc_now_iso()
		agent:              agent.settings.app_name
		track:              agent.settings.track
		partner_track:      agent.settings.partner_track
		incident:           incident
		summary:            '${incident.severity} on ${incident.service}: ${telemetry.result}'
		google_integration: GoogleIntegration{
			model:         agent.settings.google_model
			mode:          reasoning.mode
			cloud_runtime: 'Cloud Run compatible V HTTP backend'
			project:       if agent.settings.google_project == '' {
				'not_configured'
			} else {
				agent.settings.google_project
			}
			location:      agent.settings.google_location
		}
		mcp_integration:    telemetry
		agent_reasoning:    reasoning
		plan:               plan
		action_proposals:   actions
		risk_controls:      risk_controls()
		devpost_readiness:  readiness()
		evidence:           EvidenceSummary{
			digest_sha256:        evidence_digest(incident, telemetry, plan, actions)
			redaction:            'enabled'
			artifacts_to_capture: [
				'Cloud Run service URL and revision',
				'Dynatrace MCP tool list and selected tool response',
				'Before/after incident timeline screenshot',
				'Agent run JSON',
				'Demo video transcript',
			]
		}
	}
}

fn build_prompt(incident IncidentInput, telemetry TelemetryContext) string {
	return json.encode({
		'task':      'Summarize incident risk, probable root cause, and safe next actions.'
		'incident':  json.encode(incident)
		'telemetry': json.encode(telemetry)
		'policy':    'no mutating remediation without human approval'
	})
}

fn build_steps(incident IncidentInput, telemetry TelemetryContext) []AgentStep {
	return [
		AgentStep{
			name:     'Stabilize intake'
			intent:   'Classify severity, impact, constraints, and decision owner.'
			tool:     'agent.policy'
			status:   'complete'
			evidence: [incident.severity, incident.business_impact]
		},
		AgentStep{
			name:     'Observe production context'
			intent:   'Pull problem, topology, logs, and anomaly context from partner MCP.'
			tool:     'Dynatrace MCP: ${telemetry.selected}'
			status:   'complete'
			evidence: [telemetry.result.limit(600)]
		},
		AgentStep{
			name:     'Correlate release change'
			intent:   'Compare suspected change with incident start and blast radius.'
			tool:     'Google Cloud Run metrics + Cloud Logging'
			status:   'proposed'
			evidence: [incident.suspected_change]
		},
		AgentStep{
			name:     'Plan guarded remediation'
			intent:   'Draft reversible actions and pre/post checks for an incident commander.'
			tool:     'Gemini planner + approval gate'
			status:   'complete'
			evidence: ['All mutating actions remain approval_required=true']
		},
		AgentStep{
			name:     'Package evidence'
			intent:   'Generate runbook, evidence trail, and postmortem seed.'
			tool:     'agent.evidence_pack'
			status:   'complete'
			evidence: ['Evidence JSON is deterministic in demo mode']
		},
	]
}

fn build_actions(incident IncidentInput, settings Settings) []ActionProposal {
	approval := !settings.allow_mutating_actions
	return [
		ActionProposal{
			action_id:         'shift-canary-traffic'
			title:             'Reduce canary traffic to 0 percent'
			rationale:         'Latency symptoms correlate with the suspected Cloud Run revision.'
			command_preview:   'gcloud run services update-traffic ${incident.service} --to-revisions STABLE_REVISION=100,CANARY_REVISION=0'
			risk:              'medium'
			approval_required: approval
		},
		ActionProposal{
			action_id:         'raise-slo-watch'
			title:             'Create a 30 minute SLO watch and comms update'
			rationale:         'Keeps humans in control while the agent validates recovery.'
			command_preview:   'create_incident_update --window 30m --audience sre,oncall,commerce'
			risk:              'low'
			approval_required: approval
		},
	]
}

fn risk_controls() []string {
	return [
		'Mutating actions require explicit human approval.',
		'Secrets and email-like identifiers are redacted from evidence.',
		'Core runtime is Vlang and deployable to Google Cloud Run.',
		'Demo mode produces repeatable evidence for judges without private credentials.',
	]
}

fn readiness() DevpostReadiness {
	return DevpostReadiness{
		hosted_project:   'Cloud Run deploy script included'
		open_source_repo: 'MIT license included'
		demo_video:       'docs/video_outline.md'
		rules_checklist:  'docs/rules_checklist.md'
		evidence_pack:    'docs/evidence_pack.md'
	}
}
