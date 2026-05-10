Stop-Service agentos-frontend -ErrorAction SilentlyContinue
Stop-Service agentos-backend -ErrorAction SilentlyContinue
Stop-Service agentos-vllm-tunnel -ErrorAction SilentlyContinue

$Nssm = "C:\Users\rakes\AppData\Local\Microsoft\WinGet\Packages\NSSM.NSSM_Microsoft.Winget.Source_8wekyb3d8bbwe\nssm-2.24-101-g897c7ad\win64\nssm.exe"

& $Nssm remove agentos-frontend confirm
& $Nssm remove agentos-backend confirm
& $Nssm remove agentos-vllm-tunnel confirm

Write-Host "AgentOS services removed."
