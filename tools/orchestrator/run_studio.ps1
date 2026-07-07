# Launch LangGraph Studio dev server (local-only).
# PYTHONUTF8 forced: Windows default is CP950, but our source/config are UTF-8 (Chinese) -> must force UTF-8 or dotenv/graph load crashes.
# Usage:  .\tools\orchestrator\run_studio.ps1
# Then open the printed Studio UI URL in your browser (needs a free LangSmith login; graph runs LOCAL, tracing OFF).
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
Set-Location $PSScriptRoot
python -m langgraph_cli dev --port 2024
