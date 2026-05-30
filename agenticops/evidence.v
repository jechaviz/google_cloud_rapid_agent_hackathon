module agenticops

import crypto.sha256
import json
import time

pub fn utc_now_iso() string {
	return time.utc().format_ss() + 'Z'
}

pub fn evidence_digest(incident IncidentInput, telemetry TelemetryContext, plan []AgentStep, actions []ActionProposal) string {
	material := json.encode(incident) + '\n' + json.encode(telemetry) + '\n' + json.encode(plan) +
		'\n' + json.encode(actions)
	return sha256.hexhash(material)
}

pub fn run_id(incident IncidentInput) string {
	material := '${incident.title}|${incident.service}|${incident.started_at}'
	return sha256.hexhash(material)[..12]
}
