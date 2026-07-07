# Launch LangGraph Studio dev server (local-only, port 2025).
# PYTHONUTF8 forced: Windows default CP950 crashes on our UTF-8 (Chinese) source/config.
# --no-reload: avoid the reloader spawning multiple hard-to-kill worker processes.
# Usage:  .\tools\orchestrator\run_studio.ps1     (keep this window open)
# Then open:  https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2025
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
Set-Location $PSScriptRoot

# best-effort: free port 2025 first
$pids = (Get-NetTCPConnection -LocalPort 2025 -State Listen -ErrorAction SilentlyContinue).OwningProcess | Select-Object -Unique
if ($pids) { $pids | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue } }

python -m langgraph_cli dev --no-reload --port 2025
