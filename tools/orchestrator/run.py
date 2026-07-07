"""啟動器 — 你的 WHAT → 真生產線。自動 fallback（07 increment 5）。

  server 開著 → 投 server 跑（Studio 即時可看）。
  server 沒開 → 本地行程內跑（console 印對話裡，不用 server）；sqlite 存檔 → B 模式暫停/resume 照樣行。
  --local 強制本地。

用法：
  發動： python run.py --slice A1a --brief-file briefs/A1a.md --mode B
  批准： python run.py --slice A1a --resume approve
"""
import sys, os, argparse, subprocess, urllib.request
try: sys.stdout.reconfigure(encoding="utf-8"); sys.stderr.reconfigure(encoding="utf-8")
except Exception: pass
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

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


def server_up(url: str) -> bool:
    try:
        urllib.request.urlopen(url.rstrip("/") + "/ok", timeout=2)
        return True
    except Exception:
        return False


def _print_node(node, upd):
    v = (upd or {}).get("verdicts", {})
    last = list(v.values())[-1] if v else {}
    print(f"[run] ✓ {node}  stage={(upd or {}).get('stage')}  "
          f"{('verdict=' + str(last.get('verdict'))) if last else ''}")


def _prep(a):
    """建 worktree + 寫工單，回 initial state。"""
    wt = create_worktree(a.slice)
    import bus
    brief = open(a.brief_file, encoding="utf-8").read() if a.brief_file else (a.brief or "")
    bp = bus.write_handback("blueprint", "systems", f"{a.slice} 工單", brief, repo=wt)
    return wt, {"slice_id": a.slice, "autonomy": a.mode, "worktree": wt.replace("\\", "/"),
                "brief_path": os.path.relpath(bp, wt).replace("\\", "/")}


def run_server(a):
    from langgraph_sdk import get_sync_client
    c = get_sync_client(url=a.url)
    tf = os.path.join(RUNS_DIR, f"{a.slice}.thread"); os.makedirs(RUNS_DIR, exist_ok=True)
    if a.resume is not None:
        tid = open(tf).read().strip()
        stream = c.runs.stream(tid, a.graph, command={"resume": a.resume}, stream_mode="updates")
    else:
        wt, initial = _prep(a)
        tid = c.threads.create()["thread_id"]; open(tf, "w").write(tid)
        print(f"[run] slice={a.slice} mode={a.mode}  (server：Studio 即時可看)")
        print(f"[run] ★Studio：{a.url.replace('http://', 'https://smith.langchain.com/studio/?baseUrl=http://')}")
        stream = c.runs.stream(tid, a.graph, input=initial, stream_mode="updates")
    for ch in stream:
        if ch.event == "updates" and ch.data:
            for node, upd in ch.data.items(): _print_node(node, upd)
    st = c.threads.get_state(tid)
    _report(st.get("next"),
            [it.get("value") for t in st.get("tasks", []) for it in t.get("interrupts", [])],
            st.get("values", {}), a.slice)


def run_local(a):
    from real_nodes import build_real
    from langgraph.checkpoint.sqlite import SqliteSaver
    from langgraph.types import Command
    os.makedirs(RUNS_DIR, exist_ok=True)
    db = os.path.join(RUNS_DIR, f"{a.slice}.sqlite")
    cfg = {"configurable": {"thread_id": a.slice}}
    with SqliteSaver.from_conn_string(db) as cp:
        app = build_real(cp)
        if a.resume is not None:
            stream = app.stream(Command(resume=a.resume), cfg, stream_mode="updates")
        else:
            wt, initial = _prep(a)
            print(f"[run] slice={a.slice} mode={a.mode}  (本地跑：console 印這，無 Studio)")
            stream = app.stream(initial, cfg, stream_mode="updates")
        for ch in stream:
            for node, upd in (ch or {}).items(): _print_node(node, upd)
        snap = app.get_state(cfg)
        ints = [it.value for t in snap.tasks for it in getattr(t, "interrupts", [])]
        _report(snap.next, ints, snap.values, a.slice)


def _report(nxt, interrupts, values, slice_id):
    if nxt:
        print("\n[run] ⏸ 停下等你：")
        for v in interrupts: print("   ", v)
        print(f"[run] 繼續： python run.py --slice {slice_id} --resume approve   (或 reject)")
    else:
        print(f"\n[run] ✅ 完成：done={values.get('done')} stage={values.get('stage')}")
    print("[run] 帳單：docs/process/metrics.jsonl")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--slice", required=True)
    ap.add_argument("--brief-file"); ap.add_argument("--brief")
    ap.add_argument("--mode", default="B", choices=["B", "C"])
    ap.add_argument("--resume")
    ap.add_argument("--url", default="http://127.0.0.1:2025")
    ap.add_argument("--graph", default="pipeline_real")
    ap.add_argument("--local", action="store_true", help="強制本地跑（不投 server）")
    a = ap.parse_args()

    if not a.local and server_up(a.url):
        run_server(a)
    else:
        if not a.local:
            print("[run] server 沒開 → 本地跑（要 Studio 就先開 run_studio.ps1）")
        run_local(a)


if __name__ == "__main__":
    main()
