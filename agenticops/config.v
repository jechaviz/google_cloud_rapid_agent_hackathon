module agenticops

import os

pub struct Settings {
pub:
	app_name               string = 'AegisOps Incident Agent'
	track                  string = 'agentic_incident_ops'
	partner_track          string = 'Dynatrace'
	environment            string = env_default('AGENT_ENV', 'demo')
	google_project         string = os.getenv('GOOGLE_CLOUD_PROJECT')
	google_location        string = env_default('GOOGLE_CLOUD_LOCATION', 'us-central1')
	google_model           string = env_default('GOOGLE_GENAI_MODEL', 'gemini-2.5-flash')
	gemini_api_key         string = env_any(['GEMINI_API_KEY', 'GOOGLE_API_KEY'])
	dynatrace_mcp_url      string = os.getenv('DYNATRACE_MCP_URL')
	dynatrace_mcp_token    string = os.getenv('DYNATRACE_MCP_TOKEN')
	allow_mutating_actions bool   = os.getenv('ALLOW_MUTATING_ACTIONS').to_lower() == 'true'
}

pub fn default_settings() Settings {
	return Settings{}
}

pub fn (settings Settings) gemini_configured() bool {
	return settings.gemini_api_key != ''
}

pub fn (settings Settings) dynatrace_configured() bool {
	return settings.dynatrace_mcp_url != '' && settings.dynatrace_mcp_token != ''
}

fn env_default(key string, fallback string) string {
	value := os.getenv(key)
	if value == '' {
		return fallback
	}
	return value
}

fn env_any(keys []string) string {
	for key in keys {
		value := os.getenv(key)
		if value != '' {
			return value
		}
	}
	return ''
}
