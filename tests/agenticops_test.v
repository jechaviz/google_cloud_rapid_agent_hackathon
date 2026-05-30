module tests

import agenticops

fn test_agent_run_meets_core_gates() {
	run := agenticops.default_agent().run(agenticops.sample_incident())
	assert run.track == 'agentic_incident_ops'
	assert run.partner_track == 'Dynatrace'
	assert run.plan.len >= 5
	assert run.google_integration.cloud_runtime.contains('Cloud Run')
	assert run.mcp_integration.tools.len >= 4
	assert run.evidence.digest_sha256.len == 64
}

fn test_evaluator_marks_demo_as_candidate() {
	run := agenticops.default_agent().run(agenticops.sample_incident())
	result := agenticops.evaluate(run)
	assert result.status == 'prod_candidate'
	assert result.gaps.len == 0
}

fn test_redaction_masks_sensitive_markers() {
	redacted := agenticops.redact('Bearer abc token=xyz jane@example.com')
	assert !redacted.contains('abc')
	assert !redacted.contains('xyz')
	assert !redacted.contains('jane@example.com')
}
