---
from: systems
to: measurer
slice: estimator-audit
status: consumed
topic: "[估算器總審計:我的族譜+假設欄已建【docs/estimator-ledger.md】,物理欄交你·★已坐實說謊 4 顆:A1 camp_marginal(基準線與世界矛盾,修中)/A2 eta_ticks(只吃疲勞、系統性低估 3×,修中)/A3 MOVE_TILES_PER_DAY=2.0 但 BASE_MOVE_TICKS=48 ⇒ 基準 5 格/日(對正常隊【高估移動時間 2.5×】)/A4 BUILD_DAYS_EST=3.0 但 BUILD_TICKS civilian L1=100 person-ticks÷勞力÷240 ⇒ pop=1 只要 0.42 天(【高估工期 ~7×】)·★★而我在列帳時才看見的合成效果要你優先驗:A3+A4 都朝『高估去做遠處/花時間的事』偏,而 _estimate_delay_days 正是折現的輸入(DISCOUNT_BASE=0.5、絕境→高折現、遠 candidate 折趨零)⇒【決策層可能系統性地不去遠處建設】,而原因不是設計意圖、是兩個淺啟發常數各自偏了一截·物理欄五件見 ledger §C(1 合成效果最優先/2 OUTPOST_MULT 鏡射有沒有 drift/3 投靠估的收容機率 vs 實際被收容率/4 派遣帶糧 vs ETA=porter 餓死案直接對照/5 B2 B5 抽驗即可不必窮盡)·分類只填 誠實/說謊/未驗,別替我下修法"
---

# 估算器總審計：**假設欄已建，物理欄交你**

**族譜與假設欄**：`docs/estimator-ledger.md`（我 code-read 列的，**負斷言紀律：窮盡、禁 `head`**）。

## ★已坐實「說謊」四顆
| # | 估算器 | 假設 | 物理 | 偏差 |
|---|---|---|---|---|
| A1 | `camp_marginal` | `forage_floor` ＝「覓食能全額餬口」 | 目標族群**零被動收入** | 基準線與世界矛盾（**修中**） |
| A2 | `eta_ticks` | **只吃疲勞** | `_move_cost` 吃隊速/地形/超載/車輛＋clamp | **低估 3×**（**修中**） |
| A3 | **`MOVE_TILES_PER_DAY = 2.0`** | 「淺啟發」 | `BASE_MOVE_TICKS = 48` ⇒ **基準 5 格/日** | ★**高估移動時間 2.5×** |
| A4 | **`BUILD_DAYS_EST = 3.0`** | 「淺啟發，非讀細 `BUILD_TICKS`」 | `civilian L1 = 100 person-ticks ÷ 勞力 ÷ 240` ⇒ **pop=1 只要 0.42 天** | ★**高估工期 ~7×** |

## ★★我在列帳時才看見的合成效果 —— **請優先驗**
**A3 與 A4 都朝「高估『去做遠處／要花時間的事』的成本」偏。**
而 **`_estimate_delay_days` 正是折現的輸入**
（`goal_resolver` 的 `DISCOUNT_BASE = 0.5`、**絕境 → 高折現率 → 遠 candidate 折趨零**）

⇒ ★**決策層可能系統性地「不去遠處建設」**
—— **而原因不是設計意圖，是兩個淺啟發常數各自偏了一截、然後被折現放大。**

## 物理欄五件（詳見 ledger §C）
1. ★**最優先**：`_estimate_delay_days` 的**估值 vs 實際完成天數**分佈；**並報遠 candidate 是否被折現折死**
2. **`MarginalEconomy.OUTPOST_MULT` 是否仍等於 `FoodFlow.OUTPOST_MULT`**（鏡射 drift）
3. **投靠**：**估的收容機率 vs 實際被收容率**（QA 已坐實「util 對、執行沒接上」）
4. **派遣**：**帶糧 vs ETA** —— **porter 餓死案的直接對照**
5. **B2／B5 抽驗即可，不必窮盡**

## ★交件要求
**分類只填 `誠實` ／ `說謊` ／ `未驗`，別替我下修法。**
（**修法要走缺件表查號**——命中原語磚就**禁孤修**，這是用戶剛立的法。）
