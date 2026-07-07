"""increment 3 測試：langgraph 骨架拓撲 + 條件路由 + interrupt/resume（stub 節點，無 claude）。

跑：python tools/orchestrator/test_graph.py
"""
import sys
from graph import build, SliceState
from langgraph.types import Command

fails = []
def check(name, cond):
    print(f"  [{'PASS' if cond else 'FAIL'}] {name}")
    if not cond:
        fails.append(name)


def run(initial, thread):
    app = build()
    cfg = {"configurable": {"thread_id": thread}}
    res = app.invoke(initial, cfg)
    return app, cfg, res


def main():
    # 1) happy path：全 clean/green → 跑到 merged
    _, _, res = run({"slice_id": "A1a", "autonomy": "C"}, "happy")
    check("happy: 跑到 merged", res.get("done") is True and res.get("stage") == "merged")
    check("happy: 無 interrupt", "__interrupt__" not in res)
    check("happy: 走完全鏈(有 spec+worktree)", res.get("spec_path") and res.get("worktree"))

    # 2) surprise-interrupt：factcheck 前提矛盾 → 暫停
    app, cfg, res = run(
        {"slice_id": "A1b", "autonomy": "C",
         "interrupt_reason": "前提矛盾：錨聲稱不存在但 code 有",
         "inject": {"factcheck": {"verdict": "issues", "premise_contradiction": True}}},
        "surprise")
    check("surprise: graph 暫停(有 __interrupt__)", "__interrupt__" in res)
    check("surprise: 沒 merge", not res.get("done"))
    # resume：用戶裁「abort」→ 骨架導向 END
    res2 = app.invoke(Command(resume="abort"), cfg)
    check("surprise: resume 後收斂", res2.get("resolution") == "abort")

    # 3) review issues 但未達上限 → 回 systems 重跑（bounded，不無限迴圈）
    _, _, res = run(
        {"slice_id": "A1c", "autonomy": "C",
         "inject": {"review": {"verdict": "issues", "premise_contradiction": False}}},
        "retry")
    # review 每次 issues bump retry；2 次後 route→interrupt（未 resume → 暫停）
    check("retry: issues 超上限最終 interrupt", "__interrupt__" in res)

    # 4) qa red 未達上限 → 回 implementer
    _, _, res = run(
        {"slice_id": "A1d", "autonomy": "C",
         "inject": {"qa": {"verdict": "red"}}},
        "qared")
    check("qa red: 超上限最終 interrupt", "__interrupt__" in res)

    print(f"\n===== {'PASS' if not fails else 'FAIL: ' + ', '.join(fails)} =====")
    sys.exit(0 if not fails else 1)


if __name__ == "__main__":
    main()
