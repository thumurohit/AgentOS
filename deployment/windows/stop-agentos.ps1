Write-Host "Stopping AgentOS..."

Stop-Service agentos-frontend -ErrorAction SilentlyContinue
Stop-Service agentos-backend -ErrorAction SilentlyContinue
Stop-Service agentos-vllm-tunnel -ErrorAction SilentlyContinue

Write-Host "AgentOS stopped."
