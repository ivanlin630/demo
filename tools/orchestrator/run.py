"""啟動器 — 你的 WHAT → 真生產線，投給 server 跑（Studio 即時可看）（07 increment 5）。

用法：
  發動：  python run.py --slice A1a --brief-file briefs/A1a.md --mode B
  批准：  python run.py --slice A1a --resume approve   （interrupt/煞車後）

投給 langgraph server（預設 127.0.0.1:2025）→ server 跑真工人 → Studio 即時顯示。
console 也串流每站進度。thread_id 存檔，--resume 接得回同一條。
"""
import sys, os, argparse, subprocess, json
try: sys.stdout.reconfigure(encoding="utf-8"); sys.stderr.reconfigure(encoding="utf-8")
except Exception: pass
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from langgraph_sdk import get_sync_client

MAIN_REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
RUNS_DIR = os.path.join(os.path.dirname(__file__), "runs")


def create_worktree(slice_id: str) -> str:
    wt = os.path.join(MAIN_REPO, ".worktrees", f"machine-{slice_id}")
    if not os.path.exists(wt):
        r = subprocess.run(["git", "worktree", "add", "-b", f"feat/machine-{slice_id}", wt, "HEAD"],
                           cwd=MAIN_REPO, capture_output=True, text=True)
        if r.returncode != 0 and "already exists" not in (r.stderr or ""):
            print(f"[run] worktree 失敗：{r.stderr}"); sys.exit(1)
    return wt


def _thread_file(slice_id):
    os.makedirs(RUNS_DIR, exist_ok=True)
    return os.path.join(RUNS_DIR, f"{slice_id}.thread")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--slice", required=True)
    ap.add_argument("--brief-file"); ap.add_argument("--brief")
    ap.add_argument("--mode", default="B", choices=["B", "C"])
    ap.add_argument("--resume")
    ap.add_argument("--url", default="http://127.0.0.1:2025")
    ap.add_argument("--graph", default="pipeline_real")
    a = ap.parse_args()

    c = get_sync_client(url=a.url)
    tf = _thread_file(a.slice)

    if a.resume is not None:
        if not os.path.exists(tf):
            print(f"[run] 找不到 {a.slice} 的 thread，無法 resume"); sys.exit(1)
        tid = open(tf).read().strip()
        stream = c.runs.stream(tid, a.graph, command={"resume": a.resume}, stream_mode="updates")
    else:
        wt = create_worktree(a.slice)
        import bus
        brief = open(a.brief_file, encoding="utf-8").read() if a.brief_file else (a.brief or "")
        bp = bus.write_handback("blueprint", "systems", f"{a.slice} 工單", brief, repo=wt)
        th = c.threads.create()
        tid = th["thread_id"]
        open(tf, "w").write(tid)
        print(f"[run] slice={a.slice} mode={a.mode} worktree={wt}")
        print(f"[run] thread={tid[:8]}  ★Studio 即時看：{a.url.replace('http://','https://smith.langchain.com/studio/?baseUrl=http://')}")
        initial = {"slice_id": a.slice, "autonomy": a.mode,
                   "worktree": wt.replace("\\", "/"),
                   "brief_path": os.path.relpath(bp, wt).replace("\\", "/")}
        stream = c.runs.stream(tid, a.graph, input=initial, stream_mode="updates")

    for chunk in stream:
        if chunk.event == "updates" and chunk.data:
            for node, upd in chunk.data.items():
                v = (upd or {}).get("verdicts", {})
                last = list(v.values())[-1] if v else {}
                print(f"[run] ✓ {node}  stage={(upd or {}).get('stage')}  "
                      f"{('verdict=' + str(last.get('verdict'))) if last else ''}")

    # 收尾：查 thread 狀態，看是完成還是 interrupt 停下
    st = c.threads.get_state(tid)
    interrupts = st.get("tasks") and any(t.get("interrupts") for t in st["tasks"])
    if st.get("next"):
        print("\n[run] ⏸ 停下等你：")
        for t in st.get("tasks", []):
            for it in t.get("interrupts", []):
                print("   ", it.get("value"))
        print(f"[run] 繼續： python run.py --slice {a.slice} --resume approve   (或 reject)")
    else:
        vals = st.get("values", {})
        print(f"\n[run] ✅ 完成：done={vals.get('done')} stage={vals.get('stage')}")
    print(f"[run] 帳單：docs/process/metrics.jsonl")


if __name__ == "__main__":
    main()
