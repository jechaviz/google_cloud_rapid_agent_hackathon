module agenticops

import net.http
import time

pub struct GeminiPlanner {
pub:
	settings Settings
}

pub fn new_gemini_planner(settings Settings) GeminiPlanner {
	return GeminiPlanner{
		settings: settings
	}
}

pub fn (planner GeminiPlanner) summarize(prompt string) PlannerResponse {
	if !planner.settings.gemini_configured() {
		return PlannerResponse{
			mode:  'demo'
			model: planner.settings.google_model
			text:  'Gemini key not configured. Deterministic V planner used for demo judging.'
		}
	}
	endpoint := 'https://generativelanguage.googleapis.com/v1beta/models/${planner.settings.google_model}:generateContent?key=${planner.settings.gemini_api_key}'
	mut header := http.new_header()
	header.add_custom('Content-Type', 'application/json') or {
		return planner.provider_error(err.msg())
	}
	response := http.fetch(
		url:           endpoint
		method:        .post
		header:        header
		data:          gemini_body(prompt)
		validate:      false
		read_timeout:  60000 * time.millisecond
		write_timeout: 60000 * time.millisecond
	) or { return planner.provider_error(err.msg()) }
	if response.status_code < 200 || response.status_code >= 300 {
		return planner.provider_error('HTTP ${response.status_code}')
	}
	return PlannerResponse{
		mode:  'gemini'
		model: planner.settings.google_model
		text:  redact(extract_text(response.body))
	}
}

fn (planner GeminiPlanner) provider_error(message string) PlannerResponse {
	return PlannerResponse{
		mode:  'gemini_unavailable'
		model: planner.settings.google_model
		text:  'Gemini call failed safely: ${redact(message)}'
	}
}

fn gemini_body(prompt string) string {
	return '{"contents":[{"parts":[{"text":"${json_escape(prompt)}"}]}]}'
}

fn extract_text(body string) string {
	marker := '"text"'
	start := body.index(marker) or { return body.limit(800) }
	after := body[start + marker.len..]
	colon := after.index(':') or { return body.limit(800) }
	value := after[colon + 1..].trim_space()
	if !value.starts_with('"') {
		return body.limit(800)
	}
	return read_json_string(value[1..])
}

fn read_json_string(value string) string {
	mut out := []u8{}
	mut escaped := false
	for ch in value.bytes() {
		if escaped {
			out << match ch {
				`n` { `\n` }
				`r` { `\r` }
				`t` { `\t` }
				`"` { `"` }
				`\\` { `\\` }
				else { ch }
			}

			escaped = false
			continue
		}
		if ch == `\\` {
			escaped = true
			continue
		}
		if ch == `"` {
			break
		}
		out << ch
	}
	return out.bytestr()
}

fn json_escape(value string) string {
	return value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
}
