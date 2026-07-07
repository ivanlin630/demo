"""真節點 graph（07；含 2026-07-07 三裁定）。

★註冊安全：模組載入時零 sibling import（SliceState/router 內聯、nodes/gate 延遲 import）。
三裁定（今天 A1a 燒錢教訓）：
  裁1 退回不 silent 重試 → halt 中斷通知藍圖。
  裁2 刪 GATE → QA 後強制中斷，藍圖判(真 bug vs godot 框架噪音)，approve 才 merge。
  裁3 API 限流/超時 → 原地定格(interrupt)，保留狀態，不自動重試。
"""
from __future__ import annotations
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from typing import TypedDict
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import MemorySaver
from langgraph.types import interrupt


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


def _mv(state, node, v):
    return {**(state.get("verdicts") or {}), node: v}


def _freeze_if_api(v, node):
    """裁3：撞 API 限流/超時 → 原地定格。resume(額度回來後)會重跑本站，不自動重試。"""
    if isinstance(v, dict) and v.get("api_error"):
        interrupt({"frozen": True, "node": node, "detail": v.get("note"),
                   "msg": f"API 限流/超時於 {node}，原地定格保留狀態。額度恢復後 resume 續跑（重跑本站），不自動重試。"})


# ── 真節點（nodes/gate 延遲 import）──
def rn_factcheck(state: SliceState):
    import nodes
    v = nodes.judge_node("reviewer", state["slice_id"], "factcheck",
        task="驗工單每個 code 事實斷言(file:line)。前提被 code 打臉(如『X不存在』但 grep 到)→premise_contradiction=true。",
        reads=f"{state.get('brief_path','工單 handback')} + 引用的 scripts/ code",
        scope_dir=state["worktree"])
    _freeze_if_api(v, "factcheck")
    return {"verdicts": _mv(state, "factcheck", v), "stage": "factchecked"}

def rn_systems(state: SliceState):
    import nodes
    r = nodes.write_node("systems", state["slice_id"],
        task="讀工單+invariants，把 WHAT 轉成精確 spec 寫 docs/superpowers/specs/(含 file:line 改點+驗收法)；已有對應 spec 則精修。commit。★別跑 godot/測試(那是 implementer 的事)。",
        reads="工單 handback + docs/invariants.md + 相關 code",
        worktree=state["worktree"], out_handback_to="reviewer")
    _freeze_if_api(r, "systems")
    return {"spec_path": f"specs/{state['slice_id']}", "stage": "spec"}

def rn_review(state: SliceState):
    import nodes
    v = nodes.judge_node("reviewer", state["slice_id"], "review",
        task="對抗審 spec：設計健不健全？真根治還是把問題搬位子(如閉迴路 vs 移閥)？漏洞/退化風險？違反 invariants？",
        reads="spec + docs/invariants.md + docs/game-design.md 相關段",
        scope_dir=state["worktree"])
    _freeze_if_api(v, "review")
    return {"verdicts": _mv(state, "review", v), "stage": "reviewed"}

def rn_implementer(state: SliceState):
    import nodes
    r = nodes.write_node("implementer", state["slice_id"],
        task="讀 spec，實作改動(Read/Edit/Write)，跑 godot import+測試驗，逐步 commit，寫 handback。遇矛盾停下記疑點。",
        reads="spec + 相關 scripts/ code",
        worktree=state["worktree"], out_handback_to="qa")
    _freeze_if_api(r, "implementer")
    return {"stage": "built", "verdicts": _mv(state, "impl",
            {"made_commit": r.get("made_commit"), "effect_ok": r.get("effect_ok")})}

def rn_qa(state: SliceState):
    import nodes
    v = nodes.judge_node("qa", state["slice_id"], "qa",
        task="對抗驗已 commit 的改動：行為真變了嗎(非只能力存在)？跑相關 bed 讀率表。green=效果發生+無退化。red 列缺。★分清『真 bug』vs『godot 框架噪音』寫進 note。",
        reads="git diff (worktree 本 slice commits) + 相關 debug bed 輸出",
        scope_dir=state["worktree"])
    _freeze_if_api(v, "qa")
    vv = {"verdict": "green" if v.get("verdict") == "clean" else "red", **v}
    return {"verdicts": _mv(state, "qa", vv), "stage": "qa"}

# 裁2：刪 gate。QA 後強制中斷，藍圖判(真 bug vs godot 框架噪音)，approve→merge。
def rn_qa_review(state: SliceState):
    qa = state["verdicts"].get("qa", {})
    decision = interrupt({
        "checkpoint": "QA 後強制中斷（裁2：GATE 已刪，人判）",
        "slice": state["slice_id"],
        "qa_verdict": qa.get("verdict"),
        "qa_note": qa.get("note"),
        "impl": state["verdicts"].get("impl"),
        "msg": "藍圖判定：QA 若紅，是真 bug 還是 godot 框架噪音？approve=merge進main / reject=停(修後重跑)。",
    })
    return {"resolution": str(decision)}

# 裁1：退回(查證/挑毛病 issues)=中斷通知藍圖，不 silent 重試。
def rn_halt(state: SliceState):
    decision = interrupt({
        "halt": True, "slice": state["slice_id"],
        "stage": state.get("stage"),
        "verdicts": state.get("verdicts"),
        "msg": "查證/挑毛病退回——已暫停通知藍圖(不自動重試)。藍圖修 brief/spec 後重跑，或 override 續。",
    })
    return {"resolution": str(decision)}

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


# ── 內聯 router（退回一律 → halt，無 silent 重試迴圈）──
def route_factcheck(state: SliceState):
    v = state["verdicts"]["factcheck"]
    return "halt" if (v.get("premise_contradiction") or v.get("verdict") == "issues") else "systems"

def route_review(state: SliceState):
    v = state["verdicts"]["review"]
    return "halt" if (v.get("premise_contradiction") or v.get("verdict") == "issues") else "implementer"

def route_resolution(state: SliceState):
    return "merge" if str(state.get("resolution", "")).lower().startswith("approve") else "end"


def make_real_graph():
    g = StateGraph(SliceState)
    g.add_node("factcheck", rn_factcheck)
    g.add_node("systems", rn_systems)
    g.add_node("review", rn_review)
    g.add_node("implementer", rn_implementer)
    g.add_node("qa", rn_qa)
    g.add_node("qa_review", rn_qa_review)
    g.add_node("halt", rn_halt)
    g.add_node("merge", rn_merge)

    g.add_edge(START, "factcheck")
    g.add_conditional_edges("factcheck", route_factcheck, {"systems": "systems", "halt": "halt"})
    g.add_edge("systems", "review")
    g.add_conditional_edges("review", route_review, {"implementer": "implementer", "halt": "halt"})
    g.add_edge("implementer", "qa")
    g.add_edge("qa", "qa_review")                 # 裁2：無 gate，直接人判
    g.add_conditional_edges("qa_review", route_resolution, {"merge": "merge", "end": END})
    g.add_edge("halt", END)
    g.add_edge("merge", END)
    return g


def build_real(checkpointer=None):
    return make_real_graph().compile(checkpointer=checkpointer or MemorySaver())
