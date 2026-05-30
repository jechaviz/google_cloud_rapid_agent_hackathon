module main

import agenticops
import json
import os
import strconv

fn main() {
	args := os.args[1..]
	if args.len > 0 && args[0] == 'serve' {
		agenticops.serve(agenticops.ServerConfig{
			port: arg_int(args, '--port', 8080)
		}) or { panic(err) }
		return
	}
	incident := agenticops.sample_incident()
	run := agenticops.default_agent().run(incident)
	if args.len > 0 && args[0] == 'eval' {
		emit(json.encode(agenticops.evaluate(run)), arg_value(args, '--output'))
		return
	}
	emit(json.encode(run), arg_value(args, '--output'))
}

fn emit(body string, output string) {
	if output == '' {
		println(body)
		return
	}
	os.write_file(output, body + '\n') or { panic(err) }
}

fn arg_value(args []string, key string) string {
	for i, arg in args {
		if arg == key && i + 1 < args.len {
			return args[i + 1]
		}
	}
	return ''
}

fn arg_int(args []string, key string, fallback int) int {
	value := arg_value(args, key)
	if value == '' {
		return fallback
	}
	return strconv.atoi(value) or { fallback }
}
