module agenticops

pub interface Planner {
	summarize(prompt string) PlannerResponse
}

pub interface Telemetry {
	collect(incident IncidentInput) TelemetryContext
}
