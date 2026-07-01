# 征服名vs實 measure（掠奪 vs prosperity-attack）— 設計 spec（measure-first）

> 系統 HOW spec。承藍圖 `trio-rulings`（征服名vs實=修非接受;但 measure-first 先量根）。統一矩陣後續、首燒 follow-up。
> **問題**：unified 好戰獨立隊 `想=征服` 但 `做=掠奪`（首燒 handback 揭 `_decide_unified` 掠奪 option 搶在 prosperity-attack 前）→ 想征服的 raider ≠ 征服者 → 征服者 emergence 沒真完成。
> **本 spec 只量測**（掠奪 vs prosperity-attack 排序 + 掠奪有沒達成 conquest）→ 修根據數據另定,別直接猜改 [[feedback_avoid_rabbithole]]。

## 假設（首燒 handback）
- 好戰獨立隊 select_strategic_intent → 征服;但 `_decide_unified` 的 `掠奪` option util 勝出、搶在 prosperity-attack（scout-gated、會導向 capture）前 → winner=掠奪。
- 掠奪 = 機會性搶資源（TASK_LOOT，對目標 aggression 但**不奪地/不俘虜/不吸收**）;prosperity-attack → 失能-capture → 吸收（真征服鏈）。

## 探針設計（純觀測、零行為變）
量「征服 intent 的隊實際做什麼 + 掠奪達成什麼」：
- `Probe.bump("conq.intent")`：隊 solo_intent/intent=征服 時。
- `Probe.bump("conq.winner_loot")` / `conq.winner_prosperity` / `conq.winner_other`：該隊當 tick winner option 分類。
- `Probe.bump("loot.achieved_capture")`：掠奪後有沒有觸發任何 capture/吸收/奪地（預期 0=掠奪不達 conquest）。
- `Probe.bump("conq.prosperity_reached")`：征服 intent 隊實走到 prosperity-attack→capture 的次數。
- 記掠奪 vs prosperity util 差（`note`）：證掠奪搶排序。

落點：`faction_ai_system._decide_unified`（winner + 征服 intent 交叉）+ prosperity-attack 路徑 + capture 點（npc_combat absorb/capture）。

## 量測
- warring seed（好戰隊多）跑 → 讀：
  - 征服 intent 隊 winner 分布（loot vs prosperity vs other）→ 證掠奪搶多少。
  - 掠奪達成 conquest 率（預期 ~0）→ 證「想征服→做掠奪→沒征服」。
  - 掠奪 vs prosperity util 差 → 排序根。
- **產出**：征服名實斷點量化 + 修向（掠奪降權 when 征服 intent / prosperity-attack 優先 / 掠奪 escalate to capture）。

## 驗收
- 探針零行為變（headless 綠、coin_eq 0）。
- warring 量出征服 intent→實際 action 分布 + 掠奪 conquest 達成率。
- handback 回報：斷點級別 + 修向（數據支持哪個）。**修不在本 spec**（measure 先）。

## 檔案
- `probe_stats.gd`：counter（複用 bump/note）。
- `faction_ai_system.gd`：`_decide_unified` winner×征服intent 埋點 + util 差。
- `npc_combat_system.gd`：capture 點埋點（掠奪 vs 真 capture）。
- warring seed：開 Probe 跑讀。

## 風險 + 緩解
- **埋點誤改行為**：純 Probe.bump/note（no-op unless enabled）。
- **與單寫者/B 食物並行**：本軌碰 faction_ai(_decide_unified 埋點)+npc_combat(capture 埋點)+probe → 單寫者碰 faction_ai roster 寫（不同函數）、npc_combat coin（已 merged,不同）;B 食物不碰 faction_ai/npc_combat → 同檔不同函數,merge 序解。
- **scope**：只量測。修按數據另 spec。

## 開放細節（plan 定）
- winner 分類粒度（option name → loot/prosperity/other）。
- capture 達成的判定點（absorb_as_captive/capture_wounded 觸發對上該掠奪隊）。
