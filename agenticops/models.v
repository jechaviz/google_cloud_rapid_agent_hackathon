module agenticops

pub struct IncidentInput {
pub:
	title            string
	service          string
	severity         string
	started_at       string
	symptoms         []string
	telemetry_links  []string
	suspected_change string
	business_impact  string
	constraints      []string
}

pub struct TelemetryContext {
pub:
	mode         string
	endpoint     string
	tools        []string
	selected     string
	result       string
	confidence   f64
	blast_radius []string
}

pub struct PlannerResponse {
pub:
	mode  string
	model string
	text  string
}

pub struct AgentStep {
pub:
	name     string
	intent   string
	tool     string
	status   string
	evidence []string
}

pub struct ActionProposal {
pub:
	action_id         string
	title             string
	rationale         string
	command_preview   string
	risk              string
	approval_required bool
}

pub struct EvidenceSummary {
pub:
	digest_sha256        string
	redaction            string
	artifacts_to_capture []string
}

pub struct GoogleIntegration {
pub:
	model         string
	mode          string
	cloud_runtime string
	project       string
	location      string
}

pub struct DevpostReadiness {
pub:
	hosted_project   string
	open_source_repo string
	demo_video       string
	rules_checklist  string
	evidence_pack    string
}

pub struct AgentRun {
pub:
	run_id             string
	generated_at       string
	agent              string
	track              string
	partner_track      string
	incident           IncidentInput
	summary            string
	google_integration GoogleIntegration
	mcp_integration    TelemetryContext
	agent_reasoning    PlannerResponse
	plan               []AgentStep
	action_proposals   []ActionProposal
	risk_controls      []string
	devpost_readiness  DevpostReadiness
	evidence           EvidenceSummary
}
