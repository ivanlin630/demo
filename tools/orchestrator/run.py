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


def _studio_url(url):
    return url.replace("http://", "https://smith.langchain.com/studio/?baseUrl=http://")


def _save_ids(slice_id, tid, rid):
    os.makedirs(RUNS_DIR, exist_ok=True)
    open(os.path.join(RUNS_DIR, f"{slice_id}.thread"), "w").write(f"{tid}\n{rid}")

def _load_ids(slice_id):
    parts = open(os.path.join(RUNS_DIR, f"{slice_id}.thread")).read().split("\n")
    return parts[0].strip(), (parts[1].strip() if len(parts) > 1 else None)


def run_server(a):
    """發動即返回（不卡對話）。server 背景跑；監視由 --watch（事件驅動 join）或 Studio。"""
    from langgraph_sdk import get_sync_client
    c = get_sync_client(url=a.url)
    if a.resume is not None:
        tid, _ = _load_ids(a.slice)
        run = c.runs.create(tid, a.graph, command={"resume": a.resume})
    else:
        wt, initial = _prep(a)
        tid = c.threads.create()["thread_id"]
        run = c.runs.create(tid, a.graph, input=initial)
    rid = str(run.get("run_id", ""))
    _save_ids(a.slice, tid, rid)
    print(f"[run] 🚀 已發動 {a.slice}（mode={a.mode}）——背景在 server 跑，不卡對話。")
    print(f"[run] thread={tid[:8]} run={rid[:8]}")
    print(f"[run] ★Studio 即時看：{_studio_url(a.url)}")
    print(f"[run] 進度：藍圖(我)事件驅動盯著，暫停/完成才叫醒我回報你。")


def watch_server(a):
    """事件驅動：loop join 直到『真終態』(有 interrupt task ∨ 跑完)才報告。
    修:next 非空只是『有待跑節點』(正常執行中)≠ interrupt；只有 tasks 帶 interrupts 才是真暫停。"""
    import time
    from langgraph_sdk import get_sync_client
    c = get_sync_client(url=a.url)
    tid, rid = _load_ids(a.slice)
    for _ in range(200):
        try:
            c.runs.join(tid, rid)   # 阻塞到這個 run 結束
        except Exception as e:
            print(f"[watch] join：{type(e).__name__} {str(e)[:80]}")
        st = c.threads.get_state(tid)
        vals = st.get("values", {}) or {}
        ints = [it.get("value") for t in st.get("tasks", []) for it in t.get("interrupts", [])]
        status = c.threads.get(tid).get("status")
        if ints:                                   # 真 interrupt（有人要答）
            for node, v in (vals.get("verdicts") or {}).items():
                print(f"[watch] ✓ {node}  verdict={v.get('verdict')}")
            _report(True, ints, vals, a.slice); return
        if status != "busy" and not st.get("next"):  # 真跑完
            for node, v in (vals.get("verdicts") or {}).items():
                print(f"[watch] ✓ {node}  verdict={v.get('verdict')}")
            _report(None, [], vals, a.slice); return
        time.sleep(5)                              # 還在跑(next 有待跑但無 interrupt)→ 續等
    print("[watch] loop 上限，去 Studio 看")


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
    ap.add_argument("--watch", action="store_true", help="背景盯一條已發動的 run（藍圖用）")
    a = ap.parse_args()

    if a.watch:
        watch_server(a)
    elif not a.local and server_up(a.url):
        run_server(a)
    else:
        if not a.local:
            print("[run] server 沒開 → 本地跑（要 Studio 就先開 run_studio.ps1）")
        run_local(a)


if __name__ == "__main__":
    main()
