$Project = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Frontend = Join-Path $Project "frontend"
$Logs = Join-Path $Project "deployment\logs"
$Nssm = "C:\Users\rakes\AppData\Local\Microsoft\WinGet\Packages\NSSM.NSSM_Microsoft.Winget.Source_8wekyb3d8bbwe\nssm-2.24-101-g897c7ad\win64\nssm.exe"

New-Item -ItemType Directory -Force -Path $Logs | Out-Null

Write-Host "Building frontend..."
Set-Location -LiteralPath $Frontend
npm install
npm run build

Write-Host "Installing AgentOS vLLM tunnel service..."
& $Nssm install agentos-vllm-tunnel "C:\Windows\System32\OpenSSH\ssh.exe" "-i `"C:\ProgramData\AgentOS\keys\amd-ai-platform`" -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=accept-new -N -L 8000:localhost:8000 root@129.212.188.1"
& $Nssm set agentos-vllm-tunnel AppDirectory $Project
& $Nssm set agentos-vllm-tunnel AppStdout "$Logs\vllm-tunnel.log"
& $Nssm set agentos-vllm-tunnel AppStderr "$Logs\vllm-tunnel-error.log"
& $Nssm set agentos-vllm-tunnel Start SERVICE_AUTO_START
& $Nssm set agentos-vllm-tunnel AppRestartDelay 5000

Write-Host "Installing AgentOS backend service..."
& $Nssm install agentos-backend "$Project\.venv\Scripts\python.exe" "-m uvicorn main:app --host 127.0.0.1 --port 8002"
& $Nssm set agentos-backend AppDirectory $Project
& $Nssm set agentos-backend AppEnvironmentExtra "PYTHONPATH=$Project"
& $Nssm set agentos-backend AppStdout "$Logs\backend.log"
& $Nssm set agentos-backend AppStderr "$Logs\backend-error.log"
& $Nssm set agentos-backend Start SERVICE_AUTO_START
& $Nssm set agentos-backend AppRestartDelay 5000
& $Nssm set agentos-backend DependOnService agentos-vllm-tunnel

Write-Host "Installing AgentOS frontend service..."
& $Nssm install agentos-frontend "cmd.exe" "/c npm run preview -- --host 127.0.0.1 --port 5173"
& $Nssm set agentos-frontend AppDirectory $Frontend
& $Nssm set agentos-frontend AppStdout "$Logs\frontend.log"
& $Nssm set agentos-frontend AppStderr "$Logs\frontend-error.log"
& $Nssm set agentos-frontend Start SERVICE_AUTO_START
& $Nssm set agentos-frontend AppRestartDelay 5000
& $Nssm set agentos-frontend DependOnService agentos-backend

Write-Host "Starting services..."
Start-Service agentos-vllm-tunnel
Start-Sleep -Seconds 5
Start-Service agentos-backend
Start-Sleep -Seconds 5
Start-Service agentos-frontend

Write-Host "AgentOS services installed and started."
Write-Host "Open: http://127.0.0.1:5173"
