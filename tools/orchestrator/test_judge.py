"""increment 4 pattern-prove：judge 節點真跑（讀 code→判決→verdict→router 讀得到）。

試金石=今天的錯：fact-check 假斷言「ambition_archetype 不存在於 team_data.gd」。
查證員該 grep、發現它存在（team_data.gd:114）、回 premise_contradiction=true。
證這條水管 → 挑毛病/品管全是複製。

跑：python tools/orchestrator/test_judge.py
"""
import sys
try: sys.stdout.reconfigure(encoding="utf-8"); sys.stderr.reconfigure(encoding="utf-8")
except Exception: pass
import nodes

def main():
    print("[test] 叫查證員 fact-check 一個假斷言（目標錨不存在）...")
    verdict = nodes.judge_node(
        role="reviewer",
        slice_id="_pattern_prove",
        node_name="factcheck",
        task=("驗這個藍圖斷言：『目標錨在 code 裡不存在，是要新建的大件』。"
              "特別查 team_data.gd 有沒有 ambition_archetype / ambition_rung / solo_intent，"
              "faction_data.gd 有沒有 intent / goals / strategy。有=斷言為假=premise_contradiction。"),
        reads="scripts/data/team_data.gd, scripts/data/faction_data.gd",
        timeout=600,
    )
    print(f"[test] verdict = {verdict}")
    ok = (verdict is not None
          and verdict.get("verdict") == "issues"
          and verdict.get("premise_contradiction") is True)
    print(f"\n[test] 期望：verdict=issues + premise_contradiction=true（假斷言被 code 打臉）")
    print(f"[test] ===== {'PASS' if ok else 'FAIL'} =====")
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()
