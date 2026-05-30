param(
  [Parameter(Mandatory=$true)]
  [string]$ProjectId,
  [string]$Region = "us-central1",
  [string]$ServiceName = "aegisops-incident-agent"
)

$ErrorActionPreference = "Stop"

gcloud config set project $ProjectId

function Get-SecretMap {
  $pairs = @()
  foreach ($name in @("GEMINI_API_KEY", "DYNATRACE_MCP_TOKEN", "DYNATRACE_MCP_URL")) {
    $exists = $false
    try {
      gcloud secrets describe $name --project $ProjectId *> $null
      $exists = $true
    } catch {
      Write-Host "skip $name: Secret Manager secret not found"
    }
    if ($exists) {
      $pairs += "$name=$name`:latest"
    }
  }
  return ($pairs -join ",")
}

$secretMap = Get-SecretMap
$secretArgs = @()
if ($secretMap) {
  $secretArgs = @("--set-secrets", $secretMap)
}

gcloud run deploy $ServiceName `
  --source . `
  --region $Region `
  --allow-unauthenticated `
  --set-env-vars "GOOGLE_CLOUD_PROJECT=$ProjectId,GOOGLE_CLOUD_LOCATION=$Region,AGENT_ENV=prod" `
  @secretArgs
