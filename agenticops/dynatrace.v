module agenticops

import net.http
import time

pub struct DynatraceTelemetry {
pub:
	settings Settings
}

pub fn new_dynatrace_telemetry(settings Settings) DynatraceTelemetry {
	return DynatraceTelemetry{
		settings: settings
	}
}

pub fn (telemetry DynatraceTelemetry) collect(incident IncidentInput) TelemetryContext {
	if !telemetry.settings.dynatrace_configured() {
		return demo_telemetry(incident)
	}
	mut header := http.new_header()
	header.add_custom('Authorization', 'Bearer ${telemetry.settings.dynatrace_mcp_token}') or {
		return telemetry.error_context(err.msg())
	}
	header.add_custom('Content-Type', 'application/json') or {
		return telemetry.error_context(err.msg())
	}
	response := http.fetch(
		url:           telemetry.settings.dynatrace_mcp_url
		method:        .post
		header:        header
		data:          mcp_initialize_body()
		validate:      false
		read_timeout:  30000 * time.millisecond
		write_timeout: 30000 * time.millisecond
	) or { return telemetry.error_context(err.msg()) }
	if response.status_code < 200 || response.status_code >= 300 {
		return telemetry.error_context('HTTP ${response.status_code}')
	}
	return TelemetryContext{
		mode:         'dynatrace_mcp_probe'
		endpoint:     safe_endpoint(telemetry.settings.dynatrace_mcp_url)
		tools:        default_dynatrace_tools()
		selected:     'dynatrace.problems.investigate'
		result:       redact(response.body.limit(900))
		confidence:   0.64
		blast_radius: [incident.service]
	}
}

fn demo_telemetry(incident IncidentInput) TelemetryContext {
	return TelemetryContext{
		mode:         'demo'
		endpoint:     'not_configured'
		tools:        default_dynatrace_tools()
		selected:     'dynatrace.problems.investigate'
		result:       'New canary revision correlates with latency and payment failures.'
		confidence:   0.78
		blast_radius: [incident.service, 'payment-authorizer', 'cart-conversion']
	}
}

fn (telemetry DynatraceTelemetry) error_context(message string) TelemetryContext {
	return TelemetryContext{
		mode:     'configured_but_unavailable'
		endpoint: safe_endpoint(telemetry.settings.dynatrace_mcp_url)
		tools:    default_dynatrace_tools()
		selected: 'dynatrace.problems.investigate'
		result:   redact(message)
	}
}

fn default_dynatrace_tools() []string {
	return [
		'dynatrace.problems.investigate',
		'dynatrace.dql.query',
		'dynatrace.timeseries.forecast',
		'dynatrace.entities.resolve',
	]
}

fn mcp_initialize_body() string {
	return '{"jsonrpc":"2.0","id":"aegisops-init","method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"aegisops-v","version":"0.3.0"}}}'
}

fn safe_endpoint(endpoint string) string {
	if endpoint == '' {
		return ''
	}
	no_scheme := endpoint.replace('https://', '').replace('http://', '')
	return no_scheme.split('/')[0]
}
