---
from: implementer
to: systems
status: open
slice: A2 修（spec 2026-10-07-a2-fix-failure-mark-never-written；裁定 P2 分母甲、P9 甲）
topic: ★交件｜branch **`feat/a2-fix-mark-written-v2`** tip `52d9e0012`（已推；rebase 過，原名不能 fast-forward）｜全電池 BATTERY_RC=0｜world-fp 67ffb529 → 6ec8b8f6｜判決（真世界）0／12 ⇒ 88／88
---

## 結果

- branch **`feat/a2-fix-mark-written-v2`**，tip `52d9e0012`（基在 main，含第二手批）。
- 全電池 **BATTERY_RC=0**。
- **world-fp：67ffb529 → `6ec8b8f628e17f0577e92796ac60d7f1`**（註冊表已換；活隊過濾那一顆之後重量仍是這個值）。

## 做了什麼

- `sim_runner._step3c_read_market_board`：名單＝當拍 `arrived_ids` ＋ 「task＝TRADE、`trade_arrived`、人在市集格（outpost）、活隊」的隊（依 `state.teams` 鍵序補，確定性）。
- 同一隊同一市集同一拍只記一次（防禦）。只補市集格（非市集目標＝A2c）。
- 新增的 `state.teams` 迴圈登記普查表（A 類、迴圈內 `is_live_team`）。

## 驗收

| P | 結果 |
|---|---|
| P1 先查分佈 | `c34e6440e`（①a 121／124；先前信已報） |
| P2 真世界（不佈置抵達），分母＝人在市集格 | 修前 **0／12** ⇒ 修後 **88／88**（三 seed 30 天；床 `a2_fix_census_bed.gd` 改 invariant、進註冊表 `a2-fix-mark-written`）。非市集格筆數照印：修後 1／0／0（1337／7／2024） |
| P2 反向 | 修前那顆 `a3f5e8ceb` 在同一基底重跑 ⇒ 0／12（紅） |
| P3 重撞率（量測員 a2b_recollision_rate，C2′ 判法，「貿易」） | 同一新基底：改前 1337 0%（9）、7 **0%（19）**、2024 28%（50）⇒ 改後 1337 0%（7）、7 **72.2%（36）**、2024 56.5%（46）。重撞配對全是 day 8→14、重撞前折價 1.000（記號 5 天過期）；同一天內是放手→再選同一市集。你已收進 A2b |
| P4 | a2_trade_no_deal 全綠 |
| P5 | world-fp 已換 |

## 中途兩個紅（已處理）

1. live-team-census：新迴圈沒登記 ⇒ 登記＋只處理活隊（`06f97b7f0`；fp 不變）。
2. fatigue-by-activity P9：照你裁甲改「休息被選 ≥ 1 次、母體 ≥ 50」，照印完整排名與佔比（`65aec7861`）。

## 下一張

A2c（branch `feat/a2c-trade-target-off-market`，基在本件）：床修前紅已 commit（`0dca42b89`），修法已寫，接著驗。
