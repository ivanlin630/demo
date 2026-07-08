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


def create_worktree(slice_id: str, base: str = "HEAD") -> str:
    # base = worktree 起點（預設 HEAD）；--from-measure 傳手動 impl branch（如 origin/feat/A2b-impl）
    # 讓 measure 拿到已 push 的 code。base 是 origin/* 時先 fetch 保新鮮。
    if base.startswith("origin/"):
        subprocess.run(["git", "fetch", "origin", base.split("/", 1)[1]], cwd=MAIN_REPO,
                       capture_output=True, text=True)
    wt = os.path.join(MAIN_REPO, ".worktrees", f"machine-{slice_id}")
    if not os.path.exists(wt):
        r = subprocess.run(["git", "worktree", "add", "-b", f"feat/machine-{slice_id}", wt, base],
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
    wt = create_worktree(a.slice, getattr(a, "base", None) or "HEAD")
    base = {"slice_id": a.slice, "autonomy": a.mode, "worktree": wt.replace("\\", "/")}
    # ★下游軌（--from-impl / --from-measure）：無 spec 階段，不寫工單；plan/code 已在 worktree（先 push）。
    if getattr(a, "from_impl", False) or getattr(a, "from_measure", False):
        return wt, base
    import bus
    brief = open(a.brief_file, encoding="utf-8").read() if a.brief_file else (a.brief or "")
    bp = bus.write_handback("blueprint", "systems", f"{a.slice} 工單", brief, repo=wt)
    base["brief_path"] = os.path.relpath(bp, wt).replace("\\", "/")
    return wt, base


def _studio_url(url):
    return url.replace("http://", "https://smith.langchain.com/studio/?baseUrl=http://")


def _kill_node_procs():
    """殺 node claude -p 子行程（以角色 preamble『職責正典』為記認，非我 session）。Windows best-effort。"""
    import subprocess
    ps = ("Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match '職責正典' } | "
          "ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }")
    try:
        subprocess.run(["powershell", "-NoProfile", "-Command", ps], capture_output=True, timeout=30)
    except Exception:
        pass


def _count_live_nodes():
    """數活的 node claude -p（職責正典 marker）。查不到回 -1。"""
    import subprocess
    ps = "@(Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match '職責正典' }).Count"
    try:
        r = subprocess.run(["powershell", "-NoProfile", "-Command", ps],
                           capture_output=True, text=True, timeout=20)
        return int((r.stdout or "0").strip() or 0)
    except Exception:
        return -1


def _reap_zombies(c):
    """只清殭屍：零活 node 但有 running/pending run = 全殭屍 → 清。有活 node(或查不到)→保守不動(保留並行)。"""
    if _count_live_nodes() != 0:
        return 0
    n = _cancel_others(c)
    if n:
        print(f"[run] 清了 {n} 條殭屍 run（零活 node 卻掛 running）")
    return n


def _cancel_others(c, keep_tid=None):
    """取消所有 running/pending run(除 keep_tid)——清殭屍解堵(server 併發有限,卡住的 run 堵後面)。"""
    n = 0
    for t in c.threads.search(limit=30):
        if keep_tid and t["thread_id"] == keep_tid:
            continue
        for r in c.runs.list(t["thread_id"]):
            if r.get("status") in ("running", "pending"):
                try:
                    c.runs.cancel(t["thread_id"], r["run_id"], wait=False); n += 1
                except Exception:
                    pass
    return n


def cmd_status(a):
    """看板：本地 slice(log)進度 + 花費；server 若開也列。(本地優先，server 死也能用)"""
    import glob, json as _json
    # 每 slice 最後完成的站(讀 metrics,可靠,不受 log buffer 影響)
    mp = os.path.join(MAIN_REPO, "docs/process/metrics.jsonl")
    lastnode = {}
    if os.path.exists(mp):
        for l in open(mp, encoding="utf-8"):
            try: d = _json.loads(l)
            except Exception: continue
            lastnode[d.get("slice")] = (d.get("node"), d.get("effect_ok"), d.get("cost_usd"))
    # 本地 slice：狀態 + 文字路線圖(讀 log 的 ✓ 行,node 名精確)
    print("[status] 本地 slice:")
    for lg in sorted(glob.glob(os.path.join(RUNS_DIR, "*.log"))):
        sid = os.path.basename(lg)[:-4]
        txt = open(lg, encoding="utf-8", errors="replace").read()
        state = "✅完成" if "✅ 完成" in txt else ("⏸停下等你" if "⏸ 停下等你" in txt else "🔄跑中")
        ln = lastnode.get(sid)
        lnstr = f"最後站={ln[0]}" if ln else ""
        print(f"  {sid:8} {state}  {lnstr}")
        print(f"           {_route_map(txt, state)}")


_STAGES = ["factcheck", "systems_spec", "review", "bp_review", "systems_plan",
           "implementer", "measure", "qa", "qa_review", "merge"]

def _route_map(log_txt, state):
    """文字路線圖：讀 log 的『✓ <node>』標完成,現正在跑的標●(或停下⏸),未到的暗。"""
    done = {s for s in _STAGES if f"✓ {s}" in log_txt}
    cur = next((s for s in _STAGES if s not in done), None)
    out = []
    for s in _STAGES:
        short = s.replace("systems_", "sys_").replace("implementer", "impl").replace("qa_review", "②判").replace("bp_review", "①審")
        if s in done:
            out.append(f"{short}✓")
        elif s == cur:
            out.append(f"[{short}{'⏸' if state == '⏸停下等你' else '●'}]")
        else:
            out.append(short)
    return " → ".join(out)
    # 花費
    mp = os.path.join(MAIN_REPO, "docs/process/metrics.jsonl")
    if os.path.exists(mp):
        cost = {}
        for l in open(mp, encoding="utf-8"):
            try: d = _json.loads(l)
            except Exception: continue
            cost[d.get("slice")] = cost.get(d.get("slice"), 0) + (d.get("cost_usd") or 0)
        if a.slice:
            print(f"[status] {a.slice} 累計 ${round(cost.get(a.slice,0),2)}")
        else:
            print("[status] 花費:", {k: round(v, 2) for k, v in cost.items() if v})
    # server（選配）
    if server_up(a.url):
        from langgraph_sdk import get_sync_client
        c = get_sync_client(url=a.url)
        stuck = [t["thread_id"][:8] for t in c.threads.search(limit=15)
                 for r in c.runs.list(t["thread_id"]) if r.get("status") in ("running", "pending")]
        if stuck:
            print(f"[status] server 上還在跑/卡: {stuck}")


def cmd_cancel(a):
    """控制：停 run + 殺 worker/node/godot 行程。--slice X 停該條；不帶 slice 清全部。"""
    import subprocess
    # 可靠殺：python --_worker(+slice) + claude 節點(職責正典) + 殘留 Godot。按 Name+cmdline 精確配。
    sfilter = f" -and $_.CommandLine -match '{a.slice}'" if a.slice else ""
    ps = (
        "$k=Get-CimInstance Win32_Process | Where-Object { "
        f"($_.Name -match 'python' -and $_.CommandLine -match '_worker'{sfilter}) "
        "-or ($_.Name -match 'claude' -and $_.CommandLine -match '職責正典') "
        "-or ($_.Name -match 'Godot') }; "
        "$k | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }; "
        "$k.Count")
    try:
        subprocess.run(["powershell", "-NoProfile", "-Command", ps], capture_output=True, timeout=30)
    except Exception:
        pass
    # server 若開也 cancel
    if server_up(a.url):
        from langgraph_sdk import get_sync_client
        c = get_sync_client(url=a.url)
        if a.slice:
            try:
                tid, rid = _load_ids(a.slice); c.runs.cancel(tid, rid, wait=False)
            except Exception:
                pass
        else:
            _cancel_others(c)
    print(f"[cancel] 停了 {a.slice or '全部'}（worker+node 殺，server run 若有也取消）。可重發。")


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
        # 不 cancel 別的 run（保留並行紅利：非衝突 slice 各自 worktree 可同跑）。
        # 殭屍(死 node 卡 running)由 --status 看、--cancel 手動清，或 _reap_zombies 只清死的。
        _reap_zombies(c)   # 只收「node 已死但 run 還 running」的殭屍，不動健康並行 run
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
    from real_nodes import build_real, build_impl, build_measure
    from langgraph.checkpoint.sqlite import SqliteSaver
    from langgraph.types import Command
    os.makedirs(RUNS_DIR, exist_ok=True)
    db = os.path.join(RUNS_DIR, f"{a.slice}.sqlite")
    cfg = {"configurable": {"thread_id": a.slice}}
    with SqliteSaver.from_conn_string(db) as cp:
        if getattr(a, "from_measure", False):
            app = build_measure(cp)
        elif getattr(a, "from_impl", False):
            app = build_impl(cp)
        else:
            app = build_real(cp)
        if a.resume is not None:
            cmd_in = Command(resume=a.resume)
        else:
            wt, initial = _prep(a)
            print(f"[run] slice={a.slice} mode={a.mode}  (本地跑：console 印這，無 Studio)")
            cmd_in = initial
        # ★暫停不退迴圈：interrupt → 寫 pause 檔 + poll decision 檔（藍圖寫檔即續，免 re-fire）。
        while True:
            for ch in app.stream(cmd_in, cfg, stream_mode="updates"):
                if not isinstance(ch, dict):
                    continue
                for node, upd in ch.items():
                    if node == "__interrupt__" or not isinstance(upd, dict):
                        continue                # interrupt chunk 的值是 tuple,非節點更新→跳過
                    _print_node(node, upd)
            snap = app.get_state(cfg)
            ints = [it.value for t in snap.tasks for it in getattr(t, "interrupts", [])]
            if not snap.next:                   # 真跑完
                _report(None, [], snap.values, a.slice)
                _clear_pause(a.slice)
                return
            if ints:                            # interrupt → 暫停等 decision 檔（不退出）
                decision = _pause_and_wait(a.slice, ints, snap.values)
                if decision is None:            # poll 逾時 → 退出（sqlite 在，可 re-fire resume）
                    return
                cmd_in = Command(resume=decision)
                continue
            cmd_in = None                       # next 但無 interrupt（罕見）→ 續跑


def _decision_path(sid): return os.path.join(RUNS_DIR, f"{sid}.decision")
def _pause_path(sid): return os.path.join(RUNS_DIR, f"{sid}.pause")

def _clear_pause(sid):
    for p in (_pause_path(sid), _decision_path(sid)):
        try: os.remove(p)
        except Exception: pass

def _pause_and_wait(slice_id, interrupts, values, poll_s=6, timeout_s=7200):
    """暫停不退：寫 pause 檔(等啥)+ poll decision 檔。藍圖寫 decision 檔即續，免 re-fire。逾時回 None。"""
    import time, json as _json
    try:
        with open(_pause_path(slice_id), "w", encoding="utf-8") as f:
            _json.dump({"slice": slice_id, "stage": values.get("stage"),
                        "interrupts": [str(i)[:500] for i in interrupts]}, f, ensure_ascii=False)
    except Exception:
        pass
    print("\n[run] ⏸ 停下等你（進程活著、poll decision 檔）：")
    for v in interrupts: print("   ", str(v)[:400])
    dp = _decision_path(slice_id)
    print(f"[run] 續：寫 {dp}（內容 approve/reject/revise/redo）→ 進程自動續，免 re-fire")
    print("[run] 帳單：docs/process/metrics.jsonl")
    waited = 0
    while waited < timeout_s:
        if os.path.exists(dp):
            d = ""
            try: d = open(dp, encoding="utf-8").read().strip()
            except Exception: pass
            try: os.remove(dp)
            except Exception: pass
            if d:
                try: os.remove(_pause_path(slice_id))
                except Exception: pass
                print(f"[run] ▶ 收到 decision={d}，續跑")
                return d
        time.sleep(poll_s)
        waited += poll_s
    print("[run] ⏸ poll 逾時，退出（sqlite 在，re-fire --resume 可續）")
    return None


def _report(nxt, interrupts, values, slice_id):
    if nxt:
        print("\n[run] ⏸ 停下等你：")
        for v in interrupts: print("   ", v)
    else:
        print(f"\n[run] ✅ 完成：done={values.get('done')} stage={values.get('stage')}")
    print("[run] 帳單：docs/process/metrics.jsonl")


def cmd_decompose(a):
    """批次2 分解階段：feature A → 子片 briefs + 依賴/並行圖(01 架構師)。"""
    import nodes, bus
    wt = create_worktree(a.slice)
    brief = open(a.brief_file, encoding="utf-8").read() if a.brief_file else (a.brief or "")
    bus.write_handback("blueprint", "systems", f"{a.slice} feature 工單", brief, repo=wt)
    nodes.write_node("systems", a.slice,
        task="你是架構師(01)。把此 feature 分解成可獨立實作+驗收的子片(A1~An)。"
             "①每子片寫自足工單 tools/orchestrator/briefs/" + a.slice + ".<sub>.md"
             "(WHAT+file:line改點+驗收；學 A1a 教訓:自足、不引用未merge的東西)。"
             "②宣告每子片 touch_files(會碰的檔) + depends_on(前置子片)。"
             "③寫 docs/process/verdicts/" + a.slice + ".decompose.json："
             "{sub_slices:[{id,brief_file,touch_files,depends_on}], parallel_groups:[[可同跑的子片],...], note}。"
             "★並行判斷:touch_files 不相交且無依賴=同組(可並行);相交或有依賴=不同組(序列)。commit。★別跑 godot、別改 scripts/。",
        reads="feature 工單 + 相關 code + docs/invariants.md",
        worktree=wt, out_handback_to="blueprint")
    d = bus.read_verdict(a.slice, "decompose", repo=wt)
    if not d:
        print(f"[decompose] {a.slice} 未產出 decompose.json（看 worktree {wt}）"); return
    print(f"[decompose] {a.slice} → {len(d.get('sub_slices', []))} 子片：")
    for s in d.get("sub_slices", []):
        print(f"  {s.get('id')}  deps={s.get('depends_on')}  touch={s.get('touch_files')}")
    print(f"[decompose] 並行組: {d.get('parallel_groups')}")
    print(f"[decompose] 藍圖審過 → --fan-out --slice {a.slice} 發第一並行組")


def cmd_fanout(a):
    """批次2：讀 decompose.json，發第一並行組(無依賴的子片,各自 fire_local 並行)。"""
    import bus, copy
    wt = os.path.join(MAIN_REPO, ".worktrees", f"machine-{a.slice}")
    d = bus.read_verdict(a.slice, "decompose", repo=wt)
    if not d:
        print(f"[fan-out] 沒 {a.slice}.decompose.json，先 --decompose"); return
    subs = {s["id"]: s for s in d.get("sub_slices", [])}
    groups = d.get("parallel_groups") or [list(subs.keys())]
    first = groups[0]
    print(f"[fan-out] 發第一並行組(無依賴): {first}")
    briefs_dir = os.path.join(os.path.dirname(__file__), "briefs")
    for sid in first:
        sub = subs.get(sid)
        if not sub:
            continue
        aa = copy.copy(a)
        aa.slice = sid
        aa.brief_file = os.path.join(briefs_dir, os.path.basename(sub.get("brief_file", f"{sid}.md")))
        aa.resume = None
        fire_local(aa)
    if len(groups) > 1:
        print(f"[fan-out] 後續組(有依賴，前組 merge 後再 --fan-out or 手動發): {groups[1:]}")


def fire_local(a):
    """發動 local detached worker：背景跑(不阻塞 `!`)、sqlite 持久、VS Code 關也活。"""
    import subprocess
    # ★防呆：已有同 slice worker 在跑 → 別 double-fire(會撞同 worktree/sqlite)。
    if os.name == "nt" and a.resume is None:
        chk = ("@(Get-CimInstance Win32_Process | Where-Object { $_.Name -match 'python' "
               f"-and $_.CommandLine -match '_worker' -and $_.CommandLine -match '{a.slice}' }}).Count")
        try:
            r = subprocess.run(["powershell", "-NoProfile", "-Command", chk],
                               capture_output=True, text=True, timeout=15)
            if int((r.stdout or "0").strip() or 0) > 0:
                print(f"[run] ⚠ {a.slice} 已有 worker 在跑——不 double-fire(會撞)。先 --cancel --slice {a.slice} 再發，或用別的 slice 名。")
                return
        except Exception:
            pass
    os.makedirs(RUNS_DIR, exist_ok=True)
    log = os.path.join(RUNS_DIR, f"{a.slice}.log")
    cmd = [sys.executable, os.path.abspath(__file__), "--_worker", "--slice", a.slice, "--mode", a.mode]
    if a.brief_file: cmd += ["--brief-file", a.brief_file]
    if a.brief: cmd += ["--brief", a.brief]
    if getattr(a, "from_impl", False): cmd += ["--from-impl"]
    if getattr(a, "from_measure", False): cmd += ["--from-measure"]
    if getattr(a, "base", None): cmd += ["--base", a.base]
    if a.resume is not None: cmd += ["--resume", a.resume]
    flags = 0
    if os.name == "nt":
        flags = subprocess.DETACHED_PROCESS | subprocess.CREATE_NEW_PROCESS_GROUP
    env = dict(os.environ); env["PYTHONUTF8"] = "1"; env["PYTHONUNBUFFERED"] = "1"  # log 即時寫(非buffer到結束)
    lf = open(log, "w", encoding="utf-8")
    subprocess.Popen(cmd, stdout=lf, stderr=subprocess.STDOUT, creationflags=flags,
                     close_fds=True, env=env)
    print(f"[run] 🚀 已發動 {a.slice}（mode={a.mode}）——本地 detached 背景跑，不卡對話、VS Code 關也活、sqlite 持久。")
    print(f"[run] log: {log}")
    print(f"[run] 進度：藍圖(我)讀 log+git 判決盯著，暫停/完成報你。")


def watch_local(a):
    """讀 log 到出現終態行(完成/停下等你)才報告。（藍圖背景跑；外層 timeout 兜底）"""
    import time
    log = os.path.join(RUNS_DIR, f"{a.slice}.log")
    for _ in range(500):
        if os.path.exists(log):
            txt = open(log, encoding="utf-8", errors="replace").read()
            if "✅ 完成" in txt or "⏸ 停下等你" in txt:
                # 印 log 末段(從最後一個節點區塊起)
                print(txt[-2500:]); return
        time.sleep(8)
    print(f"[watch] 逾時，log: {log}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--slice")
    ap.add_argument("--brief-file"); ap.add_argument("--brief")
    ap.add_argument("--mode", default="B", choices=["B", "C"])
    ap.add_argument("--resume")
    ap.add_argument("--url", default="http://127.0.0.1:2025")
    ap.add_argument("--graph", default="pipeline_real")
    ap.add_argument("--from-impl", dest="from_impl", action="store_true",
                    help="01 下游軌：spec+plan 已在 session 寫好+push，只跑 implementer→measure→qa→②→merge")
    ap.add_argument("--from-measure", dest="from_measure", action="store_true",
                    help="measure 下游軌：opus 手動 impl 已 push code，只跑 measure→qa→②→merge（QA/measure=haiku 進機器）")
    ap.add_argument("--base", help="worktree 起點 branch（--from-measure 傳手動 impl branch，如 origin/feat/A2b-impl）")
    ap.add_argument("--local", action="store_true", help="(已成預設) 本地 detached 跑")
    ap.add_argument("--server", action="store_true", help="改投 server（要 Studio live 圖時；需先開 run_studio.ps1）")
    ap.add_argument("--watch", action="store_true", help="背景盯一條已發動的 run（藍圖用）")
    ap.add_argument("--status", action="store_true", help="看板：所有 run 狀態+花費")
    ap.add_argument("--cancel", action="store_true", help="控制：取消 run+殺 node（--slice X 取消該條；無 slice 清全部殭屍）")
    ap.add_argument("--decompose", action="store_true", help="批次2：feature A 分解成子片+並行圖")
    ap.add_argument("--fan-out", dest="fanout", action="store_true", help="批次2：發分解後的第一並行組")
    ap.add_argument("--_worker", dest="worker", action="store_true", help="(內部) detached worker 實跑 graph")
    a = ap.parse_args()

    if a.status:
        cmd_status(a)
    elif a.cancel:
        cmd_cancel(a)
    elif a.decompose:
        cmd_decompose(a)
    elif a.fanout:
        cmd_fanout(a)
    elif a.worker:
        run_local(a)                 # 內部：detached worker 在此實跑(sqlite 持久)
    elif a.watch:
        (watch_server if a.server else watch_local)(a)
    elif not a.slice:
        print("[run] 要 --slice（發動）或 --status/--cancel（控制）")
    elif a.server:
        if server_up(a.url):
            run_server(a)            # 選配：投 server(Studio live)
        else:
            print("[run] --server 但 server 沒開 → 改本地 detached")
            fire_local(a)
    else:
        fire_local(a)                # ★預設：本地 detached(不阻塞/sqlite持久/VS Code關也活)


if __name__ == "__main__":
    main()
