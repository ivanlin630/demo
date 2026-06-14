# Hand Back: SoloAI 主動尋家 + 承諾慣性

> branch: `feat/soloai-home`　日期：2026-06-14
> plan: `docs/superpowers/plans/2026-06-14-soloai-proactive-home.md`

## 實作摘要

- `scripts/data/team_data.gd`：加 `var solo_intent: String = ""`（記上次 SoloAI 策略方向）。
- `scripts/simulation/faction_ai_system.gd`：
  - 加 `const SOLO_COMMITMENT_BONUS = 0.15`。
  - `_evaluate_solo`：① 無 own outpost 流浪團加 `紮營`(TASK_CAMP)/`投靠` 評分（純 value，**不乘 `_tag_weight`**，避流亡 tag 歸零）；② 選 best 前對 `solo_intent` 方向加 commitment bonus，選後記 intent；③ match 加 TASK_CAMP/投靠 分支設 target。
  - `_evaluate_survival`（**plan 未列、量測後補**）：糧恢復釋放豁免 PRIO_DISPATCH 的 TASK_CAMP；加「到達目標格卻無法立營 → 釋放」兜底。詳見下「與 spec/plan 的差異」。
- `scripts/debug/headless_test.gd`：加 `_test_solo_commitment` / `_test_solo_seek_home` + 註冊。

## 與 spec/plan 的差異

1. **churn 修正（spec/plan 未涵蓋）**：spec 假設「TASK_CAMP 到達結算復用既有 `establish_crude_camp`」即可，但 `_evaluate_survival` 對 SURVIVAL_TASK 有「糧足→釋放」邏輯。主動紮營**本就在不缺糧時**觸發，往鄰格 farmable 移動途中即被該邏輯釋放 → 到不了 → 每 cadence 重派。首次量測：紮營 dispatch **5952** vs establish 僅 **20**，且 tyrant config 早退(4820 tick)。
   - 修：糧恢復釋放豁免 `PRIO_DISPATCH` 的 TASK_CAMP（survival camp 走 PRIO_SURVIVAL 不受影響）；並補「抵 move_target 仍無法立營（該格被占/變更）→ 釋放重評」兜底，維持 invariant「進得去出得來」。
   - 修後：紮營 dispatch **5952→28**、3 config 全跑滿 21600 tick、died=no。

2. **測試補 `team_discovered` seeding**：plan 給的測試碼未設 `state.team_discovered`，但 `_nearest_independent`/`_find_strong_neighbor` 依賴它（回 -1 → 評分 target 解不出）。已加最小 seeding 讓測試可執行，不改測試意圖。

## 量測（2 年 ×3 config：survival_start / tyrant / warzone）

| 指標 | 結果 |
|---|---|
| died | no ×3 |
| coin_eq delta | ≈0.00 ×3（守恆）|
| SCRIPT ERROR | 0（headless_test 既有 `food 應進公庫` 為 main 既存失敗，非本 branch 引入）|
| SoloAI 行為分佈 | 攻擊 160 / 治理 17 / 紮營 28 / 掠奪·外交·貿易·投靠 0 |
| 安身 | CrudeCamp 27、SurvivalCamp 14、SurvivalJoin 5 |
| 策略連貫 | 紮營 dispatch 28（非 churn 的 5952）→ 慣性生效 |

- **主動安身率↑**：proactive 紮營(28 dispatch，多數 establish) + CrudeCamp 27 > desperation-only。
- **roving 未消失**：攻擊 160 主導 → 非全定居，個性分流有效。
- **連貫**：commitment + churn 修後同隊不每 cadence 抖。

## 連動風險

- `_evaluate_survival` 釋放邏輯：本次對 PRIO_DISPATCH TASK_CAMP 開豁免。若未來有**其他** PRIO_DISPATCH 來源也設 TASK_CAMP（目前僅 SoloAI solo），會共享此豁免 — 行為一致（都想立營），低風險。
- `投靠` 經 SoloAI 設 PRIO_DISPATCH（survival 投靠為 PRIO_SURVIVAL）。到達走既有投靠邏輯；本次未驗到 proactive 投靠實際成交（量測 0 次，門檻嚴），建議後續觀察。
- 其餘系統無已知連動風險。

## 待主 session 確認

- **行為多元度**：SoloAI 的 掠奪/外交/貿易/投靠 量測為 0（攻擊 roving 壓過、投靠門檻嚴）。spec 接受「個性分流非 uniform」，且 desperation 路徑仍出 SurvivalCamp/Join/Loot。是否需調 TEST VALUE 拉高 proactive 投靠/掠奪占比，留主 session 判斷（一次一變因）。
- **proactive 投靠未驗成交**：`_find_strong_neighbor`（rep>0.3 + pop>1.5× + reachable）嚴格，2 年×3 config proactive 投靠 0 次。功能路徑已接，但實戰未觸發 — 建議後續單獨量測或放寬門檻。
- **深層目標錨（②）**：spec 明列待 spec，本 branch 未做。
