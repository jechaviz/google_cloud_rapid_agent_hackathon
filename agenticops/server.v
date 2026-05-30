module agenticops

import json
import net.http

pub struct ServerConfig {
pub:
	port int = 8080
}

struct Handler {}

pub fn serve(config ServerConfig) ! {
	port := if config.port <= 0 { 8080 } else { config.port }
	mut server := &http.Server{
		addr:                 '127.0.0.1:${port}'
		handler:              Handler{}
		show_startup_message: true
	}
	server.listen_and_serve()
}

fn (mut handler Handler) handle(req http.Request) http.Response {
	path := request_path(req.url)
	if req.method == .get && path == '/healthz' {
		return json_response(.ok, '{"status":"ok"}')
	}
	if req.method == .get && path == '/api/sample' {
		return json_response(.ok, json.encode(sample_incident()))
	}
	if req.method == .post && path == '/api/agent/run' {
		incident := if req.data.trim_space() == '' || req.data.trim_space() == '{}' {
			sample_incident()
		} else {
			json.decode(IncidentInput, req.data) or {
				return json_response(.bad_request, json.encode({
					'error': 'invalid_incident_json'
				}))
			}
		}
		return json_response(.ok, json.encode(default_agent().run(incident)))
	}
	if req.method == .post && path == '/api/evaluate' {
		run := default_agent().run(sample_incident())
		return json_response(.ok, json.encode(evaluate(run)))
	}
	return json_response(.not_found, '{"error":"not_found"}')
}

fn json_response(status http.Status, body string) http.Response {
	mut header := http.new_header()
	header.add_custom('Content-Type', 'application/json') or {}
	header.add_custom('Cache-Control', 'no-store') or {}
	return http.Response{
		header:       header
		body:         body
		status_code:  status.int()
		status_msg:   status.str()
		http_version: '1.1'
	}
}

fn request_path(url string) string {
	query_index := url.index('?') or { return url }
	return url[..query_index]
}
