---
from: systems
to: measurer
status: consumed（已被後續 magnet-controlled-scenario/magnet-final18/zero-drift 三張工單取代吸收，「完整utility仍dispatch=0」最終被磁鐵§3b解決，此張補標避免信箱重複提醒）
topic: [big-window 終確認] 完整utility @076b237——9383evals決策到位仍dispatch0,跨seed確認真抗拒→to:blueprint
---

# 量測：完整 utility big-window（升 user 前最終跨-seed 確認）

§HOW-8 完整 utility done @076b237。3mo 單 seed **9383 evals**：slack_pos 68%/yield_pos 82%（決策真算）但 absorb.dispatch=0（吸納恆輸征服）。**big-window 跨 seed 確認「決策到位仍~0=真世界抗拒」非單 seed artifact**（升 user a/b/c 前最終實證）。

## 跑（長跑 tooling）
- worktree `feat/consolidation-s-a @076b237`（§HOW-1~8 全 + 完整雙向漏斗 + utility 分布探針）。**先 rebase/merge 最新 main 拿新 bed**。
- `tools/godot-detach.ps1`+`WARRING_RESUME=1`+`WARRING_PROGRESS`（03b SOP §大窗）：18 seed×3mo 單批脫離、輪詢、resume。seed=1 估耗時。★`--path`，禁原地 checkout。

## 量（完整 utility 雙向 + 對照征服）
- **吸納**：`absorb.util_n`→`slack_pos`/`yield_pos`（決策真算證）→`absorb.dispatch`→completion。
- **併入**：`consolidate_dispatch`(威脅-ungate 後)→completion。
- **對照征服**：`conq.intent`/攻擊 dispatch（證強隊選征服>吸納）。
- gate#1 非搬餓 / 隊數不崩 / determinism。

## 判準（→to:blueprint 升 user）
- big-window 跨 seed 仍 slack/yield 正但 absorb.dispatch≈0、征服常勝 → **真世界抗拒確認**（決策到位、非樣本）→ blueprint 升 user a/b/c。
- 若某 seed consolidation 顯著起量 → 3mo 假象，翻案（世界不抗拒）→ signoff。
數字 to:blueprint。
