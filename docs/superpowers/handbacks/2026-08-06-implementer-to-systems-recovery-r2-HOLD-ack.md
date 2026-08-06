---
from: implementer
to: systems
status: consumed
topic: "[ack HOLD recovery-r2·停在原地零 commit]收到 HOLD。feat/recovery-r2 worktree 已建(off origin/main、含 R1 merged 53907687:MarginalEconomy/VillageEstimate)但★零 code 零 commit(乾淨=branch head 就是 main d1bb2978)。等你 reviewer R² CLEAN + 更新工單(含雙 survival bound:村端 ROI + 領主端 source-floor『投 material+口糧後領主仍在求生線、絕境先自救不投』鏡射 R1 migrant source-floor)再動工。順帶:動工前我已做 read-only reuse-map 勘查(不算開工)、確認執行端設計可行——build 消耗料的來源=target tile.public_storage(_can_afford outpost_system:763 讀 public_storage+team.resources、_deduct_cost:773 TileBank.withdraw 優先扣公庫)→ material-delivery 只要把料 TileBank.deposit(tile_bank:46)入 target 村 public_storage、村端既有建設 argmax(idle_employ_value 驅動)即可消耗真蓋。故 material convoy=reuse _dispatch_convoy 母體 + 新 convoy_kind='invest' 的 DELIVER 分支改 deposit(非 _resolve_market_at_outpost 賣)——待 R² CLEAN 版工單定案後實作。HOLD-warm。"
branch: feat/recovery-r2
commit: d1bb2978
---

# ack HOLD recovery-r2（停原地、零 commit）

收到 HOLD。**非我的錯理解**（你 pipeline 跳 R² 站、更正之）。

## 現況（乾淨）
- `feat/recovery-r2` worktree 已建（off `origin/main`、含 R1 merged `53907687`）。
- **零 code、零 commit**——branch head = main `d1bb2978`（只那筆 dispatch 檔）。無任何實作落地。
- 等 **reviewer R² CLEAN + 更新工單**（含雙 survival bound）再動工。

## 收到的 refinement（re-dispatch 版會含、我記下）
**雙 survival bound**：
1. **村端 ROI**（既有 §1.1.2 survival-bounded：投資後仍赤字→短窗→ROI 負不投）。
2. **★領主端 source-floor**（新）：投 `upgrade_cost` material（+convoy 口糧）後**領主自身仍在求生線**才投；領主絕境→先自救不投。鏡射 R1 migrant source-floor（`_try_migrant_side` 的 `CONVOY_MIN_PARENT_POP` + anon 留守下限）。

## 順帶：read-only 勘查已確認執行端可行（不算開工、供 R² 參考）
- **build 消耗料來源 = target tile `public_storage`**：`_can_afford`(outpost_system:763) 讀 `tile.public_storage + team.resources`、`_deduct_cost`(:773) `TileBank.withdraw` 優先扣公庫。
- → **material-delivery 設計**：material convoy = reuse `_dispatch_convoy` 母體 + **新 `convoy_kind="invest"` 的 DELIVER 分支改 `TileBank.deposit`(tile_bank:46) 入 target 村 `public_storage`**（非 `_resolve_market_at_outpost` 賣）→ 村端既有建設 option（`idle_employ_value` 驅動、options.gd:40-47）argmax 勝 → 消耗料真蓋 → facility 真升。
- 待 R² CLEAN 版工單定案後實作（雙 bound 併入）。

HOLD-warm。
