"""increment 1 承重測試：headless 節點能否真的寫檔（不只回話）。

PONG 只證 claude 會回話。真節點要寫 handback + commit。此測證「節點能改世界」+
effect_check 抓「claude 回了但沒真寫」的差（驗效果非能力）。

跑：python tools/orchestrator/test_runner.py <一個可寫的空 cwd>
"""
import sys, os, tempfile, shutil
try: sys.stdout.reconfigure(encoding="utf-8"); sys.stderr.reconfigure(encoding="utf-8")
except Exception: pass
from pathlib import Path
from runner import run_node, effect_check, PROFILE_WRITE

TOKEN = "NODE_WORKS_7f3a"
PROBE = "_node_probe.txt"


def main():
    cwd = sys.argv[1] if len(sys.argv) > 1 else tempfile.mkdtemp(prefix="node_test_")
    os.makedirs(cwd, exist_ok=True)
    probe_path = Path(cwd) / PROBE
    if probe_path.exists():
        probe_path.unlink()

    prompt = (
        f"You are a pipeline node test. Create a file named exactly `{PROBE}` "
        f"in the current directory containing exactly this text: {TOKEN}\n"
        f"Do nothing else. Reply with DONE when the file is written."
    )

    print(f"[test] cwd={cwd}")
    print(f"[test] running role node (bypassPermissions, writes a file)...")
    res = run_node(
        profile=PROFILE_WRITE,
        role="implementer",
        prompt=prompt,
        scope_dir=cwd,
        output_format="json",
        timeout=180,
    )

    def probe_ok():
        return probe_path.exists() and TOKEN in probe_path.read_text(encoding="utf-8", errors="replace")

    effect_check(res, probe_ok)

    print(f"[test] claude ok={res.ok} rc={res.returncode} dur={res.duration_s:.1f}s "
          f"timed_out={res.timed_out} cost={res.cost_usd}")
    print(f"[test] result(text): {str(res.result)[:200]}")
    if res.error:
        print(f"[test] error: {res.error}")
    print(f"[test] ★effect_ok (檔真的寫了?) = {res.effect_ok}")

    verdict = "PASS" if (res.ok and res.effect_ok) else "FAIL"
    print(f"[test] ===== {verdict} =====")
    print(f"[test]   node.ok（claude 回了）        = {res.ok}")
    print(f"[test]   effect_ok（世界真變了）       = {res.effect_ok}")
    sys.exit(0 if verdict == "PASS" else 1)


if __name__ == "__main__":
    main()
