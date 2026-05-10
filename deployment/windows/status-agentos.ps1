Get-Service agentos-vllm-tunnel, agentos-backend, agentos-frontend -ErrorAction SilentlyContinue

Write-Host "`nHealth checks:"

$checks = @(
  @{ Name = "vLLM"; Url = "http://127.0.0.1:8000/v1/models" },
  @{ Name = "Backend"; Url = "http://127.0.0.1:8002/api/v1/agents/info" },
  @{ Name = "Frontend"; Url = "http://127.0.0.1:5173/" }
)

foreach ($check in $checks) {
  try {
    $res = Invoke-WebRequest -Uri $check.Url -UseBasicParsing -TimeoutSec 10
    Write-Host "$($check.Name): OK $($res.StatusCode)" -ForegroundColor Green
  } catch {
    Write-Host "$($check.Name): FAILED" -ForegroundColor Red
  }
}
