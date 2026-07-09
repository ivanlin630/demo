"""langgraph 骨架 — 節點拓撲 + 條件路由 + interrupt/resume（07 increment 3）。

此檔用 **stub 節點**（無 claude 呼叫）證拓撲對：happy-path 跑到 merged、條件 edge 分流、
surprise-interrupt 暫停+resume。increment 4 把 stub 換成 run_node 真節點。

節點鏈（07_orchestrator_machine.md）：
  blueprint → factcheck(對抗①) → systems → review(對抗②) → implementer → measure → qa → gate → merge
  surprise-interrupt：任一 verdict premise_contradiction → 暫停回用戶。
  ★measure(標準 full_probe 床)→qa(autonomous 硬閘,判完整數據): LG 下游=autonomous lane,rn_qa 保留(2026-07-09)。
"""
from __future__ import annotations
from typing import TypedDict, Optional
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import MemorySaver
from langgraph.types import interrupt, Command

MAX_RETRY = 2


class SliceState(TypedDict, total=False):
    slice_id: str
    autonomy: str            # "B" | "C"
    brief_path: str
    spec_path: str
    worktree: str
    verdicts: dict           # node -> verdict
    retries: dict            # node -> count
    stage: str
    interrupt_reason: str
    resolution: str
    done: bool
    inject: dict             # 測試注入：stub 節點該吐什麼 verdict


def _inject(state: SliceState, node: str) -> Optional[dict]:
    return (state.get("inject") or {}).get(node)


def _put_verdict(state: SliceState, node: str, v: dict) -> dict:
    vs = dict(state.get("verdicts") or {})
    vs[node] = v
    return vs


def _bump(state: SliceState, node: str) -> dict:
    r = dict(state.get("retries") or {})
    r[node] = r.get(node, 0) + 1
    return r


# ── stub 節點（increment 4 換 run_node 真節點）──
def n0_blueprint(state: SliceState):
    return {"brief_path": f"handbacks/{state['slice_id']}-brief.md", "stage": "briefed"}

def n1_factcheck(state: SliceState):
    v = _inject(state, "factcheck") or {"verdict": "clean", "premise_contradiction": False}
    return {"verdicts": _put_verdict(state, "factcheck", v), "stage": "factchecked"}

def n2_systems(state: SliceState):
    return {"spec_path": f"specs/{state['slice_id']}.md", "stage": "spec"}

def n3_review(state: SliceState):
    v = _inject(state, "review") or {"verdict": "clean", "premise_contradiction": False}
    upd = {"verdicts": _put_verdict(state, "review", v), "stage": "reviewed"}
    if v.get("verdict") == "issues":
        upd["retries"] = _bump(state, "review")
    return upd

def n4_implementer(state: SliceState):
    return {"worktree": f".worktrees/{state['slice_id']}", "stage": "built"}

def n4b_measure(state: SliceState):
    # 量測員節點：跑標準 full_probe 床出完整數字餵 qa（real_nodes.rn_measure 對應）。
    # stub 預設完整（inject 可標 incomplete 測 qa 完整性 gate）。
    v = _inject(state, "measure") or {"summary": "measure 完整", "incomplete": []}
    return {"verdicts": _put_verdict(state, "measure", v), "stage": "measured"}

def n5_qa(state: SliceState):
    # autonomous lane 硬閘（LG 下游）：完整性 gate 前置——measure incomplete[] 非空 → 強制 red
    # （鏡射 real_nodes.rn_qa；判在完整 full_probe 數據上，不放行不完整驗證）。
    mv = state.get("verdicts", {}).get("measure", {}) or {}
    v = _inject(state, "qa") or {"verdict": "green"}
    if mv.get("incomplete"):
        v = {"verdict": "red", "completeness_gate": True}
    upd = {"verdicts": _put_verdict(state, "qa", v), "stage": "qa"}
    if v.get("verdict") == "red":
        upd["retries"] = _bump(state, "qa")
    return upd

def n6_gate(state: SliceState):
    v = _inject(state, "gate") or {"verdict": "pass"}
    return {"verdicts": _put_verdict(state, "gate", v), "stage": "gated"}

def n7_merge(state: SliceState):
    return {"done": True, "stage": "merged"}

def n_interrupt(state: SliceState):
    """surprise-interrupt / issue 上限 → 暫停回用戶，等 resume 決策。"""
    decision = interrupt({
        "reason": state.get("interrupt_reason", "unknown"),
        "slice": state["slice_id"],
        "verdicts": state.get("verdicts", {}),
    })
    return {"resolution": str(decision)}


# ── 路由（讀 verdict 決定走向；surprise-interrupt 優先）──
def route_factcheck(state: SliceState):
    v = state["verdicts"]["factcheck"]
    if v.get("premise_contradiction") or v.get("verdict") == "issues":
        return "interrupt"
    return "systems"

def route_review(state: SliceState):
    v = state["verdicts"]["review"]
    if v.get("premise_contradiction"):
        return "interrupt"
    if v.get("verdict") == "issues":
        return "systems" if (state.get("retries") or {}).get("review", 0) < MAX_RETRY else "interrupt"
    return "implementer"

def route_qa(state: SliceState):
    v = state["verdicts"]["qa"]
    if v.get("verdict") == "red":
        return "implementer" if (state.get("retries") or {}).get("qa", 0) < MAX_RETRY else "interrupt"
    return "gate"

def route_gate(state: SliceState):
    return "merge" if state["verdicts"]["gate"].get("verdict") == "pass" else "implementer"


def make_graph():
    """未編譯 StateGraph（langgraph Studio / CLI 載這個，平台自帶 persistence）。"""
    g = StateGraph(SliceState)
    for name, fn in [("blueprint", n0_blueprint), ("factcheck", n1_factcheck),
                     ("systems", n2_systems), ("review", n3_review),
                     ("implementer", n4_implementer), ("measure", n4b_measure), ("qa", n5_qa),
                     ("gate", n6_gate), ("merge", n7_merge), ("interrupt", n_interrupt)]:
        g.add_node(name, fn)

    g.add_edge(START, "blueprint")
    g.add_edge("blueprint", "factcheck")
    g.add_conditional_edges("factcheck", route_factcheck,
                            {"systems": "systems", "interrupt": "interrupt"})
    g.add_edge("systems", "review")
    g.add_conditional_edges("review", route_review,
                            {"implementer": "implementer", "systems": "systems", "interrupt": "interrupt"})
    g.add_edge("implementer", "measure")
    g.add_edge("measure", "qa")
    g.add_conditional_edges("qa", route_qa,
                            {"gate": "gate", "implementer": "implementer", "interrupt": "interrupt"})
    g.add_conditional_edges("gate", route_gate,
                            {"merge": "merge", "implementer": "implementer"})
    g.add_edge("merge", END)
    g.add_edge("interrupt", END)   # stub：resume 後結束；真機器 resolution 導回對應節點
    return g


def build(checkpointer=None):
    """自用（run.py / 測試）：編譯後的 graph，帶 checkpointer。"""
    return make_graph().compile(checkpointer=checkpointer or MemorySaver())
