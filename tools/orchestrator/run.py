"""啟動器 — 你的 WHAT → 真生產線（07 increment 5）。

用法：
  python run.py --slice A1a --brief-file briefs/A1a.md --mode B
  （--mode B = merge 前煞車；C = 每 arc 自動）

流程：建 worktree → 寫工單 handback → 跑真 graph（串流每站進度）→ interrupt/煞車停下等你。
"""
import sys, os, argparse, subprocess
try: sys.stdout.reconfigure(encoding="utf-8"); sys.stderr.reconfigure(encoding="utf-8")
except Exception: pass
from runner import MAIN_REPO
import bus
from real_nodes import build_real
from langgraph.checkpoint.memory import MemorySaver
from langgraph.types import Command


def create_worktree(slice_id: str) -> str:
    wt = os.path.join(MAIN_REPO, ".worktrees", f"machine-{slice_id}")
    branch = f"feat/machine-{slice_id}"
    if not os.path.exists(wt):
        r = subprocess.run(["git", "worktree", "add", "-b", branch, wt, "HEAD"],
                           cwd=MAIN_REPO, capture_output=True, text=True)
        if r.returncode != 0 and "already exists" not in r.stderr:
            print(f"[run] worktree add 失敗：{r.stderr}"); sys.exit(1)
    return wt


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--slice", required=True)
    ap.add_argument("--brief-file")
    ap.add_argument("--brief")
    ap.add_argument("--mode", default="B", choices=["B", "C"])
    ap.add_argument("--resume")  # interrupt 後 resume 值（approve/reject/...）
    a = ap.parse_args()

    wt = create_worktree(a.slice)
    print(f"[run] slice={a.slice} mode={a.mode} worktree={wt}")

    app = build_real(MemorySaver())
    cfg = {"configurable": {"thread_id": a.slice}}

    if a.resume is not None:
        stream = app.stream(Command(resume=a.resume), cfg, stream_mode="updates")
    else:
        brief = open(a.brief_file, encoding="utf-8").read() if a.brief_file else (a.brief or "")
        bp = bus.write_handback("blueprint", "systems", f"{a.slice} 工單", brief, repo=wt)
        initial = {"slice_id": a.slice, "autonomy": a.mode, "worktree": wt,
                   "brief_path": os.path.relpath(bp, wt).replace("\\", "/")}
        stream = app.stream(initial, cfg, stream_mode="updates")

    interrupted = None
    for chunk in stream:
        if "__interrupt__" in chunk:
            interrupted = chunk["__interrupt__"]
            continue
        for node, upd in (chunk or {}).items():
            v = (upd or {}).get("verdicts", {})
            last = list(v.values())[-1] if v else {}
            print(f"[run] ✓ {node}  stage={upd.get('stage')}  "
                  f"{('verdict=' + str(last.get('verdict'))) if last else ''}")

    if interrupted:
        print("\n[run] ⏸ 生產線停下等你：")
        for it in (interrupted if isinstance(interrupted, (list, tuple)) else [interrupted]):
            print("   ", getattr(it, "value", it))
        print(f"[run] 繼續：python run.py --slice {a.slice} --resume approve   （或 reject / 你的指示）")
    else:
        st = app.get_state(cfg).values
        print(f"\n[run] ✅ 完成：done={st.get('done')} stage={st.get('stage')}")
    print(f"[run] 帳單/進度：docs/process/metrics.jsonl；判決：{wt}/docs/process/verdicts/")


if __name__ == "__main__":
    main()
