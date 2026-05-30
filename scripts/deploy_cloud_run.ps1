param(
  [Parameter(Mandatory=$true)]
  [string]$ProjectId,
  [string]$Region = "us-central1",
  [string]$ServiceName = "aegisops-incident-agent"
)

$ErrorActionPreference = "Stop"

gcloud config set project $ProjectId
gcloud run deploy $ServiceName `
  --source . `
  --region $Region `
  --allow-unauthenticated `
  --set-env-vars "GOOGLE_CLOUD_PROJECT=$ProjectId,GOOGLE_CLOUD_LOCATION=$Region,AGENT_ENV=prod" `
  --set-secrets "GEMINI_API_KEY=GEMINI_API_KEY:latest,DYNATRACE_MCP_TOKEN=DYNATRACE_MCP_TOKEN:latest,DYNATRACE_MCP_URL=DYNATRACE_MCP_URL:latest"
