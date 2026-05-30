module agenticops

pub fn redact(value string) string {
	mut text := value
	text = redact_after_case_insensitive(text, 'bearer ')
	text = redact_after_case_insensitive(text, 'api_key=')
	text = redact_after_case_insensitive(text, 'api-key=')
	text = redact_after_case_insensitive(text, 'token=')
	text = redact_email_like(text)
	return text
}

fn redact_after_case_insensitive(value string, marker string) string {
	lower := value.to_lower()
	pos := lower.index(marker) or { return value }
	start := pos + marker.len
	mut end := start
	for end < value.len {
		ch := value[end]
		if ch.is_space() || ch == `,` || ch == `;` || ch == `"` {
			break
		}
		end++
	}
	return value[..start] + '[redacted]' + value[end..]
}

fn redact_email_like(value string) string {
	parts := value.split(' ')
	mut out := []string{cap: parts.len}
	for part in parts {
		if part.contains('@') && part.contains('.') {
			out << '[redacted-email]'
		} else {
			out << part
		}
	}
	return out.join(' ')
}
