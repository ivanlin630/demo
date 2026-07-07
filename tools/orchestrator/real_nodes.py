"""真節點 graph（07 increment 5）：judge_node/write_node/gate 包成 langgraph 節點。

整條線 scope 到 state['worktree']（factcheck/系統/挑毛病/建造/品管/閘 全在同一 worktree）。
merge 前依 autonomy 模式煞車（B=interrupt 給用戶批准 / C=自動）。
"""
from __future__ import annotations
import subprocess
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import MemorySaver
from langgraph.types import interrupt
from graph import SliceState, route_factcheck, route_review, route_qa
import nodes, gate


def _mv(state, node, v):
    return {**(state.get("verdicts") or {}), node: v}


# ── 真節點 ──
def rn_factcheck(state: SliceState):
    v = nodes.judge_node("reviewer", state["slice_id"], "factcheck",
        task="驗工單每個 code 事實斷言(file:line)。前提被 code 打臉(如『X不存在』但 grep 到)→premise_contradiction=true。",
        reads=f"{state.get('brief_path','工單 handback')} + 引用的 scripts/ code",
        scope_dir=state["worktree"])
    return {"verdicts": _mv(state, "factcheck", v), "stage": "factchecked"}

def rn_systems(state: SliceState):
    nodes.write_node("systems", state["slice_id"],
        task="讀工單+invariants，把 WHAT 轉成精確 spec 寫 docs/superpowers/specs/(含 file:line 改點+驗收法)；已有對應 spec 則精修。commit。",
        reads="工單 handback + docs/invariants.md + 相關 code",
        worktree=state["worktree"], out_handback_to="reviewer")
    return {"spec_path": f"specs/{state['slice_id']}", "stage": "spec"}

def rn_review(state: SliceState):
    v = nodes.judge_node("reviewer", state["slice_id"], "review",
        task="對抗審 spec：設計健不健全？是真根治還是把問題搬位子(如閉迴路 vs 移閥)？漏洞/退化風險？違反 invariants？",
        reads="spec + docs/invariants.md + docs/game-design.md 相關段",
        scope_dir=state["worktree"])
    return {"verdicts": _mv(state, "review", v), "stage": "reviewed"}

def rn_implementer(state: SliceState):
    r = nodes.write_node("implementer", state["slice_id"],
        task="讀 spec，實作改動(Read/Edit/Write)，跑 godot import+測試驗，逐步 commit，寫 handback。遇矛盾停下記疑點。",
        reads="spec + 相關 scripts/ code",
        worktree=state["worktree"], out_handback_to="qa")
    return {"stage": "built", "verdicts": _mv(state, "impl",
            {"made_commit": r.get("made_commit"), "effect_ok": r.get("effect_ok")})}

def rn_qa(state: SliceState):
    v = nodes.judge_node("qa", state["slice_id"], "qa",
        task="對抗驗已 commit 的改動：行為真變了嗎(非只能力存在)？跑相關 bed 讀率表。green 條件=效果發生+無退化。red 列缺。",
        reads="git diff (worktree 本 slice commits) + 相關 debug bed 輸出",
        scope_dir=state["worktree"])
    # QA verdict schema 對齊 router：verdict clean→綠, issues→red
    vv = {"verdict": "green" if v.get("verdict") == "clean" else "red", **v}
    return {"verdicts": _mv(state, "qa", vv), "stage": "qa"}

def rn_gate(state: SliceState):
    g = gate.run_gate(state["worktree"], state["slice_id"])
    return {"verdicts": _mv(state, "gate", {"verdict": "pass" if g["pass"] else "issues", **g}),
            "stage": "gated"}

def rn_boundary(state: SliceState):
    """B 模式：merge 前煞車，interrupt 給用戶批准。"""
    decision = interrupt({
        "checkpoint": "merge 前煞車 (B 模式)",
        "slice": state["slice_id"],
        "qa": state["verdicts"].get("qa"),
        "gate": state["verdicts"].get("gate"),
        "msg": "QA 綠 + 閘過。批准 merge 進 main？回 'approve' 或 'reject'。",
    })
    return {"resolution": str(decision)}

def rn_merge(state: SliceState):
    """merge worktree 分支 → main。"""
    wt = state["worktree"]
    try:
        branch = subprocess.run(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=wt,
                                capture_output=True, text=True, timeout=30).stdout.strip()
        from runner import MAIN_REPO
        subprocess.run(["git", "merge", "--no-ff", branch, "-m", f"merge: {state['slice_id']} (machine)"],
                       cwd=MAIN_REPO, capture_output=True, text=True, timeout=60)
    except Exception as e:
        return {"done": True, "stage": f"merge-error:{e}"}
    return {"done": True, "stage": "merged"}


# ── router：閘後依模式煞車 ──
def route_gate_mode(state: SliceState):
    g = state["verdicts"]["gate"]
    if g.get("verdict") != "pass":
        return "implementer"
    return "boundary" if state.get("autonomy") == "B" else "merge"


def make_real_graph():
    g = StateGraph(SliceState)
    g.add_node("factcheck", rn_factcheck)
    g.add_node("systems", rn_systems)
    g.add_node("review", rn_review)
    g.add_node("implementer", rn_implementer)
    g.add_node("qa", rn_qa)
    g.add_node("gate", rn_gate)
    g.add_node("boundary", rn_boundary)
    g.add_node("merge", rn_merge)
    g.add_node("interrupt", lambda s: {"resolution": str(interrupt({"reason": s.get("interrupt_reason", "premise_contradiction"), "verdicts": s.get("verdicts")}))})

    g.add_edge(START, "factcheck")
    g.add_conditional_edges("factcheck", route_factcheck, {"systems": "systems", "interrupt": "interrupt"})
    g.add_edge("systems", "review")
    g.add_conditional_edges("review", route_review,
                            {"implementer": "implementer", "systems": "systems", "interrupt": "interrupt"})
    g.add_edge("implementer", "qa")
    g.add_conditional_edges("qa", route_qa, {"gate": "gate", "implementer": "implementer", "interrupt": "interrupt"})
    g.add_conditional_edges("gate", route_gate_mode,
                            {"merge": "merge", "boundary": "boundary", "implementer": "implementer"})
    g.add_edge("boundary", "merge")
    g.add_edge("merge", END)
    g.add_edge("interrupt", END)
    return g


def build_real(checkpointer=None):
    return make_real_graph().compile(checkpointer=checkpointer or MemorySaver())
