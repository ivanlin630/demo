"""真節點 graph（machine v2；docs/process/08_machine_workflow_v2.md）。

★註冊安全：模組載入時零 sibling import（SliceState/router 內聯、nodes 延遲 import）。
三裁定：裁1 退回→halt / 裁2 刪gate QA後人判 / 裁3 API異常→定格。
v2 流程：factcheck→systems_spec→review(02②)→bp_review(①00審)→systems_plan→implementer→measure→qa→qa_review(②)→merge。
成本：判斷節點 haiku/sonnet；opus 只給 spec/plan/實作/bp_review(願景判)。scope 限讀。
"""
from __future__ import annotations
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from typing import TypedDict
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import MemorySaver
from langgraph.types import interrupt

# 成本分層。★再試 haiku(用戶要重測)+trace。首跑 factcheck haiku $0.04/25.7s ok但沒寫verdict檔。
MODELS = {"factcheck": "haiku", "review": "sonnet", "qa": "haiku", "measure": "haiku"}

# scope 限讀通用指示（節點只讀 touch_files + 工作需要，別盲掃全庫）
def _scope_hint(slice_id):
    return (f"★scope 限讀（省 token 但★別漏跨系統）：讀 docs/process/verdicts/{slice_id}.scope.json 的 touch_files "
            f"+ ★它們的直接互動面——grep 誰呼叫你要改的函式/常數(callers)、你的改動會影響誰(callees)。"
            f"跨系統互動一定要讀到(否則會踩別系統);不相關的系統/測試檔才別讀。不確定就讀，別為省 token 漏。")


class SliceState(TypedDict, total=False):
    slice_id: str
    autonomy: str
    brief_path: str
    spec_path: str
    worktree: str
    verdicts: dict
    stage: str
    resolution: str
    done: bool
    inject: dict
    systems_session: str    # systems_spec 的 session_id，feature 級 01 session（spec/plan/revise 全續，免重讀）
    revise_feedback: str    # revise 輪：注入 systems_spec 的 review/藍圖 反饋
    revise_round: int        # revise 次數（軟上限防打架）


def _mv(state, node, v):
    return {**(state.get("verdicts") or {}), node: v}


def _freeze_if_api(v, node):
    """裁3：撞 API 限流/超時 → 原地定格。resume(額度回來後)重跑本站，不自動重試。"""
    if isinstance(v, dict) and v.get("api_error"):
        interrupt({"frozen": True, "node": node, "detail": v.get("note"),
                   "msg": f"API 限流/超時於 {node}，原地定格。額度恢復後 resume 續跑（重跑本站），不自動重試。"})


# ── 節點 ──
def rn_factcheck(state: SliceState):
    import nodes
    v = nodes.judge_node("reviewer", state["slice_id"], "factcheck",
        task="驗工單每個 code 事實斷言(file:line)。前提被 code 打臉(如『X不存在』但 grep 到)→premise_contradiction=true。",
        reads=f"{state.get('brief_path','工單 handback')} + 引用的 scripts/ code",
        scope_dir=state["worktree"], model=MODELS["factcheck"])
    _freeze_if_api(v, "factcheck")
    return {"verdicts": _mv(state, "factcheck", v), "stage": "factchecked"}

def rn_systems_spec(state: SliceState):
    """01①：出 spec + scope + 重點 handback（fail-early）。revise 輪=resume 原 01 session 帶 ctx 改。"""
    import nodes
    fb = state.get("revise_feedback")
    if fb:
        # ★revise 輪：續原 01 session（feature 級 ctx，記得自己 spec 推理）+ 注入 review/藍圖 反饋 → 改 spec。
        task = ("你先前寫了本 slice 的 spec（你有原 context）。要修。\n"
                "★先讀藍圖裁定的設計方向 handback：docs/superpowers/handbacks/ 內檔名含 "
                "'blueprint-to-systems' + slice + 'revise' 的那份（★這是藍圖對 review 的裁定，"
                "優先於下面 review 字面——照藍圖方向改，別自行詮釋 review）。\n"
                "review/factcheck 原始反饋（參考，藍圖方向為準）：\n" + fb +
                "\n照藍圖方向改 spec + scope.json + 重點 handback（覆蓋原檔）。"
                "★用 Read/Grep 重讀當前 code 查證每個改點（別憑記憶，code 可能已變——鐵律）。"
                "★別跑 godot、★別寫 plan。commit。")
        r = nodes.write_node("systems", state["slice_id"], task=task,
            reads="藍圖方向 handback（優先）+ 你的原 spec + 回饋涉及的 code（重讀查證）",
            worktree=state["worktree"], out_handback_to="reviewer",
            resume_session=state.get("systems_session"))
    else:
        r = nodes.write_node("systems", state["slice_id"],
            task="讀工單+invariants → 出三樣（★只 spec，先不寫 plan——等審過才寫）："
                 "①精確 spec(docs/superpowers/specs/，含 file:line 改點+驗收法) "
                 "②觸及集 docs/process/verdicts/" + state["slice_id"] + ".scope.json"
                 "(touch_files/touch_systems/depends_on/parallel_safe+理由) "
                 "③★『重點』handback(docs/superpowers/handbacks/，from:systems to:blueprint)："
                 "濃縮給藍圖審——做了啥設計決定、風險點、要不要批的疑慮（藍圖只看這份，不啃全 spec）。commit。"
                 "★別跑 godot、★別寫 plan(那是審過後的事)。",
            reads="工單 handback + docs/invariants.md + 相關 code",
            worktree=state["worktree"], out_handback_to="reviewer")
    _freeze_if_api(r, "systems_spec")
    # feature 級 01 session：存 session_id 供 plan/revise 續（帶 ctx 免重讀）；resume 保留原 id
    return {"spec_path": f"specs/{state['slice_id']}", "stage": "spec",
            "systems_session": r.get("session_id") or state.get("systems_session")}

def rn_review(state: SliceState):
    """02②：對抗審 spec（設計健不健全，讀廣一點抓跨系統）。"""
    import nodes
    v = nodes.judge_node("reviewer", state["slice_id"], "review",
        task="對抗審 spec：設計健不健全？真根治還是把問題搬位子(如閉迴路 vs 移閥)？漏洞/退化風險？"
             "跨系統會不會踩(讀廣一點,不只 touch_files)？違反 invariants？量測方法有沒有坑(如把 lifecycle move 當決策)？",
        reads="spec + docs/invariants.md + docs/game-design.md 相關段 + 觸及系統的互動點",
        scope_dir=state["worktree"], model=MODELS["review"])
    _freeze_if_api(v, "review")
    return {"verdicts": _mv(state, "review", v), "stage": "reviewed"}

def rn_bp_review(state: SliceState):
    """★檢查點①：藍圖(00)審。讀 spec重點+02findings+願景 → 對齊?嚴重? concern 才 interrupt 找用戶。"""
    import nodes
    v = nodes.judge_node("blueprint", state["slice_id"], "bp_review",
        task="你是藍圖(00,願景守護)。讀 systems 的『重點』handback + 02 review verdict + docs/game-design.md 願景。"
             "判：spec 對齊願景嗎？02 的 concern 嚴不嚴重？"
             "verdict='clean'(對齊、可放行寫 plan) 或 'concern'(踩願景/02 concern 嚴重，要藍圖裁)。note 說為什麼。"
             "★你只看重點 handback + verdict + 願景，不啃全 spec。",
        reads="systems→blueprint 重點 handback + review verdict + docs/game-design.md",
        scope_dir=state["worktree"])  # opus(default)：願景判要準
    _freeze_if_api(v, "bp_review")
    concern = v.get("verdict") == "concern" or v.get("premise_contradiction")
    upd = {"verdicts": _mv(state, "bp_review", v), "stage": "bp_reviewed"}
    if concern:
        decision = interrupt({
            "checkpoint": "① spec 後藍圖審——有疑慮",
            "slice": state["slice_id"], "concern": v.get("note"),
            "review": state["verdicts"].get("review", {}).get("note"),
            "msg": "spec 疑慮(踩願景 or 02 concern)。藍圖裁：approve=放行寫plan / reject=停(修spec重跑)。",
        })
        upd["resolution"] = str(decision)
    return upd

def rn_systems_plan(state: SliceState):
    """01②：spec 審過了才寫 plan（fail-early，爛 spec 不浪費 plan）。"""
    import nodes
    r = nodes.write_node("systems", state["slice_id"],
        task="spec 已審過(你剛寫的,有 context)。用 writing-plans 技能出正式 plan(docs/superpowers/plans/)：task 分解，每 task 可獨立驗、對到 spec 的 file:line 改點。commit。★別跑 godot、別改 scripts/ code。",
        reads="你剛寫的 spec + scope.json（已在 context，不用重讀全 code）",
        worktree=state["worktree"], out_handback_to="implementer",
        resume_session=state.get("systems_session"))  # 批次1.6：續 spec session,帶 context 免重讀
    _freeze_if_api(r, "systems_plan")
    return {"stage": "planned"}

def rn_implementer(state: SliceState):
    import nodes
    r = nodes.write_node("implementer", state["slice_id"],
        task=_scope_hint(state["slice_id"]) +
             "照 systems 的 plan(docs/superpowers/plans/)逐 task 做，用 TDD(test-first)。"
             "讀 spec+plan，實作(Read/Edit/Write)，跑 godot import+測試驗，逐步 commit，寫 handback。遇矛盾停下記疑點。",
        reads="spec + plan + scope.json 的 touch_files",
        worktree=state["worktree"], out_handback_to="measurer")
    _freeze_if_api(r, "implementer")
    return {"stage": "built", "verdicts": _mv(state, "impl",
            {"made_commit": r.get("made_commit"), "effect_ok": r.get("effect_ok")})}

def rn_measure(state: SliceState):
    """量測員：跑全探針/bed(godot)出數字餵 QA。藍圖不蹲 godot。"""
    import nodes, bus
    r = nodes.write_node("measurer", state["slice_id"],
        task="量測本 slice 改動(★別改 scripts/ code，只跑探針+寫報告)。跑：①hand_obeys_brain_bed 單點(HOB_SEEDS=1337 HOB_MONTHS=1)抓 obey%/arbiter_latch/各機制/determinism ②constitution_gate ③sanity(headless_test/game_sim_test 無崩+關鍵print) ④TeamTrace 抖動檢。"
             "★★HOB bed 慢(跑 4×一個月 warring≈500s)：**先設 $env:GODOT_TIMEOUT='600' 再跑**，否則 wrapper 360s 預設會誤殺→假 perf 迴歸→假 reject(A2a 血教訓)。timeout 被殺≠迴歸，要區分。"
             "★★★也讀本 slice spec 的 §驗收法 → 把每條行為守衛翻成 seeded 量測(用 WarringHarness/seeded_warring_bed)→ **產 count/delta 數字**(如 leader_conquest_count、tribute_treasury_delta)。**這些數字你產、QA 只判門檻——別推給 QA seeded 遊走**(否則 QA 被迫自跑自判=破 maker/checker)。缺哪條產不出→列 incomplete 報藍圖，別留白。詳 docs/process/03b_measurer.md。"
             "★★★★acceptance/診斷 slice 跑**標準 full_probe 床(03b_measurer.md §④)：全維度一次抓齊**——衝突面(征服/攻擊/交戰/掠奪/血仇/背叛/外交)、生存面(餓死/餓滅/pop/food_flow/team-size 直方圖)、**決策面(option 選擇分布/merge-applicable 隊實際去向)**、結構面(teams/faction 消長/established)、食物經濟。結構化 JSON、**不靠 print 刮、無 quiet 死路、無缺維度**、baseline/slice 並排 → 寫 docs/process/verdicts/" + state["slice_id"] + ".fullprobe.json。**這是治 bounce 的關鍵：LG 下游=autonomous lane，rn_qa 保留硬閘、必須判在完整數據上**(缺維度=rn_qa 判不動=bounce)。"
             "★可行則 before/after 對照(main vs 本 worktree 同 seed，比 per-tick 同規模非撞絕對門檻)。寫 JSON 到 docs/process/verdicts/" + state["slice_id"] + ".measure.json"
             "(obey_pct,arbiter_latch,mechanisms,determinism,constitution,thrash,before_after,fullprobe_dims,incomplete,summary)。commit。",
        reads="worktree 本 slice commits + scripts/debug/ 的 bed",
        worktree=state["worktree"], out_handback_to="qa", model=MODELS["measure"])
    _freeze_if_api(r, "measure")
    m = bus.read_verdict(state["slice_id"], "measure", repo=state["worktree"])
    return {"verdicts": _mv(state, "measure", m or {"summary": "measure 未產出(godot 可能失敗)"}), "stage": "measured"}

def rn_qa(state: SliceState):
    import nodes
    # ★完整性 gate 前置（code-level，不靠 haiku 自覺）：measure 標 incomplete / 未產出
    # → 部分報告不能綠（鏡射手動信箱「measurer 全量才寄一封」規則；LG 順序無 append race，
    #   但仍有「measure 產不齊→qa 拿部分判綠」風險，此 gate 補上）。
    mv = state["verdicts"].get("measure", {}) or {}
    incomplete = mv.get("incomplete") or []
    measure_missing = (not mv) or ("未產出" in str(mv.get("summary", "")))
    v = nodes.judge_node("qa", state["slice_id"], "qa",
        task="對抗驗已 commit 的改動。★讀量測員的 docs/process/verdicts/" + state["slice_id"] + ".measure.json + " + state["slice_id"] + ".fullprobe.json 真數字當證據(別自己跑 godot)。"
             "★★完整性 gate：measure.json 的 incomplete[] 非空 或 spec 守衛/標準床數字缺 或 acceptance slice 缺 fullprobe 全維度(衝突/生存/決策-option去向/結構/食物經濟) = **不完整不能綠**，判 red 並註明缺哪項。"
             "★★★你是 autonomous lane 的硬閘(LG 下游=fire-N-走開，用戶不盯)——**判在完整 full_probe 數據上**，別放行不完整驗證。"
             "green=效果真發生(數字證)+無退化+無抖動+measure 完整；red=數字沒動/退化/抖動/measure 不完整。★分清真 bug vs godot 框架噪音寫進 note。",
        reads="量測員 .measure.json + git diff(worktree 本 slice commits)",
        scope_dir=state["worktree"], model=MODELS["qa"])
    _freeze_if_api(v, "qa")
    if incomplete or measure_missing:
        # override 鍵放 **v 之後 → 保底強制 red（haiku 若誤綠也蓋掉）
        vv = {**v, "verdict": "red", "completeness_gate": True,
              "note": "★完整性 gate 強制 red：measure 不完整 incomplete=%s（不完整驗證不能綠；"
                      "qa_review 判 redo 重量測補齊 或藍圖裁）。原 qa note: %s"
                      % (incomplete or "measure未產出", str(v.get("note", "")))}
    else:
        vv = {**v, "verdict": "green" if v.get("verdict") == "clean" else "red"}
    return {"verdicts": _mv(state, "qa", vv), "stage": "qa"}

def rn_qa_review(state: SliceState):
    """檢查點②：QA 後強制人判(裁2)。approve→merge / redo→回實作 / revise→回 spec / reject→停。"""
    qa = state["verdicts"].get("qa", {})
    rd = state.get("revise_round", 0)
    decision = interrupt({
        "checkpoint": "② QA 後強制中斷（裁2：人判 真bug vs godot噪音）",
        "slice": state["slice_id"], "qa_verdict": qa.get("verdict"), "qa_note": qa.get("note"),
        "measure": state["verdicts"].get("measure", {}).get("summary"),
        "msg": "藍圖+你判：approve=merge / redo=回實作重跑下游(實作/量測/qa掛,如限額) "
               "/ revise=回 spec重寫(QA揭露spec設計缺陷) / reject=停。",
    })
    d = str(decision).lower()
    out = {"resolution": str(decision)}
    if d.startswith("revise"):   # ② 揭 spec 缺陷 → 回 spec（鏡射 halt 的 revise）
        vs = state.get("verdicts") or {}
        parts = []
        for k in ("qa", "measure", "review"):
            vv = vs.get(k)
            if vv:
                parts.append(f"[{k}] {vv.get('note') or vv.get('summary','')}")
        out["revise_feedback"] = "\n".join(parts) or "(② QA 後藍圖要求 re-spec，見藍圖 handback)"
        out["revise_round"] = rd + 1
    return out

MAX_REVISE = 5   # revise 軟上限（藍圖每輪閘，這只防打架失控）

def rn_halt(state: SliceState):
    """裁1：退回=中斷通知藍圖，不 silent 重試。resume 'revise'=丟回原 01 session 帶 ctx 改 spec。"""
    rd = state.get("revise_round", 0)
    decision = interrupt({
        "halt": True, "slice": state["slice_id"], "stage": state.get("stage"),
        "verdicts": state.get("verdicts"), "revise_round": rd,
        "msg": "退回——暫停通知藍圖(不自動重試)。resume：revise=丟回原01(帶feature ctx)照審查反饋改spec / reject=停(手動修後重跑)。",
    })
    d = str(decision).lower()
    out = {"resolution": str(decision)}
    if d.startswith("revise"):
        # 蒐集 review/bp_review/factcheck 的 issues+note 當反饋 → 注入原 01 session 改 spec
        vs = state.get("verdicts") or {}
        parts = []
        for k in ("factcheck", "review", "bp_review"):
            vv = vs.get(k)
            if vv and (vv.get("verdict") in ("issues", "concern") or vv.get("premise_contradiction")):
                parts.append(f"[{k}] {vv.get('note','')}｜issues={vv.get('issues')}")
        out["revise_feedback"] = "\n".join(parts) or "(審查有疑，見 verdicts)"
        out["revise_round"] = rd + 1
    return out

def rn_merge(state: SliceState):
    import subprocess
    wt = state["worktree"]
    try:
        branch = subprocess.run(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=wt,
                                capture_output=True, text=True, timeout=30).stdout.strip()
        main_repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        subprocess.run(["git", "merge", "--no-ff", branch, "-m", f"merge: {state['slice_id']} (machine)"],
                       cwd=main_repo, capture_output=True, text=True, timeout=60)
    except Exception as e:
        return {"done": True, "stage": f"merge-error:{e}"}
    return {"done": True, "stage": "merged"}


# ── router ──
def route_factcheck(state: SliceState):
    v = state["verdicts"]["factcheck"]
    return "halt" if (v.get("premise_contradiction") or v.get("verdict") == "issues") else "systems_spec"

def route_review(state: SliceState):
    v = state["verdicts"]["review"]
    return "halt" if (v.get("premise_contradiction") or v.get("verdict") == "issues") else "bp_review"

def route_bp_review(state: SliceState):
    v = state["verdicts"]["bp_review"]
    concern = v.get("verdict") == "concern" or v.get("premise_contradiction")
    if concern and not str(state.get("resolution", "")).lower().startswith("approve"):
        return "halt"          # 藍圖 reject(或沒 approve) → 停
    return "systems_plan"      # 對齊 or 藍圖 approve → 寫 plan

def route_resolution(state: SliceState):
    return "merge" if str(state.get("resolution", "")).lower().startswith("approve") else "end"

def route_qa_review(state: SliceState):
    """②：approve→merge / redo→implementer(下游掛,救) / revise→systems_spec(QA揭spec缺陷) / else→停。"""
    d = str(state.get("resolution", "")).lower()
    if d.startswith("approve"): return "merge"
    if d.startswith("redo"): return "implementer"
    if d.startswith("revise") and state.get("revise_round", 0) <= MAX_REVISE: return "systems_spec"
    return "end"

def route_halt(state: SliceState):
    """halt resume 'revise'=丟回 systems_spec(原 01 session 帶 ctx 改)；其他=停。軟上限防打架。"""
    d = str(state.get("resolution", "")).lower()
    if d.startswith("revise") and state.get("revise_round", 0) <= MAX_REVISE:
        return "systems_spec"
    return "end"


def make_real_graph():
    g = StateGraph(SliceState)
    for name, fn in [("factcheck", rn_factcheck), ("systems_spec", rn_systems_spec),
                     ("review", rn_review), ("bp_review", rn_bp_review),
                     ("systems_plan", rn_systems_plan), ("implementer", rn_implementer),
                     ("measure", rn_measure), ("qa", rn_qa), ("qa_review", rn_qa_review),
                     ("halt", rn_halt), ("merge", rn_merge)]:
        g.add_node(name, fn)

    g.add_edge(START, "factcheck")
    g.add_conditional_edges("factcheck", route_factcheck, {"systems_spec": "systems_spec", "halt": "halt"})
    g.add_edge("systems_spec", "review")
    g.add_conditional_edges("review", route_review, {"bp_review": "bp_review", "halt": "halt"})
    g.add_conditional_edges("bp_review", route_bp_review, {"systems_plan": "systems_plan", "halt": "halt"})
    g.add_edge("systems_plan", "implementer")
    g.add_edge("implementer", "measure")
    g.add_edge("measure", "qa")
    g.add_edge("qa", "qa_review")
    g.add_conditional_edges("qa_review", route_qa_review,
                            {"merge": "merge", "implementer": "implementer",
                             "systems_spec": "systems_spec", "end": END})  # redo→下游 / revise→spec
    g.add_conditional_edges("halt", route_halt, {"systems_spec": "systems_spec", "end": END})  # revise 迴圈
    g.add_edge("merge", END)
    return g


def build_real(checkpointer=None):
    return make_real_graph().compile(checkpointer=checkpointer or MemorySaver())


def make_impl_graph():
    """★01 下游軌（--from-impl）：01 在 persistent session 已寫好 spec+plan+scope 並 push，
    機器只跑 implementer→measure→qa→②qa_review→merge（省 spec/review/plan 上游）。
    worktree off origin/main → 取得 01 push 的 plan/scope（01 必先 push）。
    ②qa_review 三路在此軌：approve→merge / redo→implementer(重跑下游) /
    revise→END(QA 揭 spec 缺陷=此軌無 spec 站 → halt，01 回 session 改 spec/plan 再 re-fire) / reject→END。"""
    g = StateGraph(SliceState)
    for name, fn in [("implementer", rn_implementer), ("measure", rn_measure),
                     ("qa", rn_qa), ("qa_review", rn_qa_review), ("merge", rn_merge)]:
        g.add_node(name, fn)
    g.add_edge(START, "implementer")
    g.add_edge("implementer", "measure")
    g.add_edge("measure", "qa")
    g.add_edge("qa", "qa_review")
    g.add_conditional_edges("qa_review", route_qa_review,
                            {"merge": "merge", "implementer": "implementer",
                             "systems_spec": END, "end": END})  # revise→END(回 01 改 spec)
    g.add_edge("merge", END)
    return g


def build_impl(checkpointer=None):
    return make_impl_graph().compile(checkpointer=checkpointer or MemorySaver())


def make_measure_graph():
    """★measure-only 下游軌（--from-measure）：opus 手動 impl 已 push code，機器只跑
    measure→qa→②qa_review→merge（省 implementer）。動機：QA/measure=haiku 沒法當持久終端
    自動喚醒（信箱 relay 靠 opus idle-armed）→ 手動 impl 後的驗收段進機器自動跑。
    worktree off 手動 impl branch → 拿已 push 的 code。
    qa_review：approve→merge / redo/revise/reject→END（無 impl 節點；code 需修=回手動 impl session）。"""
    g = StateGraph(SliceState)
    for name, fn in [("measure", rn_measure), ("qa", rn_qa),
                     ("qa_review", rn_qa_review), ("merge", rn_merge)]:
        g.add_node(name, fn)
    g.add_edge(START, "measure")
    g.add_edge("measure", "qa")
    g.add_edge("qa", "qa_review")
    g.add_conditional_edges("qa_review", route_qa_review,
                            {"merge": "merge", "implementer": END,
                             "systems_spec": END, "end": END})  # redo/revise→END（回手動 impl/spec）
    g.add_edge("merge", END)
    return g


def build_measure(checkpointer=None):
    return make_measure_graph().compile(checkpointer=checkpointer or MemorySaver())
