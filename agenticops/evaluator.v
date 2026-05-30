module agenticops

pub struct EvaluationResult {
pub:
	score  int
	status string
	gates  []string
	gaps   []string
}

pub fn evaluate(run AgentRun) EvaluationResult {
	mut gates := []string{}
	mut gaps := []string{}
	record_gate(mut gates, mut gaps, run.partner_track == 'Dynatrace', 'partner_track_dynatrace')
	record_gate(mut gates, mut gaps, run.google_integration.cloud_runtime.contains('Cloud Run'),
		'google_cloud_runtime')
	record_gate(mut gates, mut gaps, run.mcp_integration.tools.len > 0, 'mcp_tools_present')
	record_gate(mut gates, mut gaps, run.plan.len >= 5, 'agentic_plan_depth')
	record_gate(mut gates, mut gaps, all_actions_gated(run.action_proposals), 'human_approval_gate')
	record_gate(mut gates, mut gaps, run.evidence.digest_sha256.len == 64, 'evidence_digest')
	score := (gates.len * 100) / 6
	return EvaluationResult{
		score:  score
		status: if score == 100 { 'prod_candidate' } else { 'needs_work' }
		gates:  gates
		gaps:   gaps
	}
}

fn record_gate(mut gates []string, mut gaps []string, ok bool, name string) {
	if ok {
		gates << name
	} else {
		gaps << name
	}
}

fn all_actions_gated(actions []ActionProposal) bool {
	for action in actions {
		if !action.approval_required {
			return false
		}
	}
	return actions.len > 0
}
