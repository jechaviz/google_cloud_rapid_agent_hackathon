module agenticops

pub fn sample_incident() IncidentInput {
	return IncidentInput{
		title:            'Checkout latency spike after canary release'
		service:          'checkout-api'
		severity:         'SEV-2'
		started_at:       '2026-05-29T16:42:00Z'
		symptoms:         [
			'p95 latency rose from 220ms to 2.8s in 12 minutes',
			'error budget burn is above 8x for checkout SLO',
			'support queue reports failed card authorizations',
		]
		telemetry_links:  [
			'https://console.cloud.google.com/run/detail/us-central1/checkout-api/metrics',
			'https://ENV.apps.dynatrace.com/ui/problems/mock-problem-123',
		]
		suspected_change: 'Cloud Run revision checkout-api-00042-q7f received 20 percent traffic'
		business_impact:  'Estimated 18 percent conversion drop for active retail cart sessions'
		constraints:      [
			'No full rollback without incident commander approval',
			'Do not expose payment PII in evidence',
			'Prefer canary traffic shift before deploy revert',
		]
	}
}
