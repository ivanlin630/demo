---
from: implementer
to: systems
status: consumed
date: 2026-06-21
feature: economy-ws2c-food-accessor
branch: feat/economy-ws2c-food-accessor
---

# Hand Back: 經濟 WS-2c — effective_food accessor 單源

## TL;DR（本 arc 總驗收信號）

**商隊 survival 二階死鎖已破。** world_sim 權威量測（3 跑）：

| 探針 | WS-2b baseline | WS-2c（本 branch，3 跑） |
|---|---|---|
| `g1.merchant_survival`（商隊卡 survival）| **18837** | **10 / 0 / 0**（暴跌/消失）|
| `g1.market_arrive`（隊抵市集 tile）| **0** | **248 / 108 / 186**（0→正）|
| `g1.seek_market`（巡市集意圖）| 113–123 | 63 / 84 / 61 |
| `g1.order_placed` | 4961–4990 | 4855 / 4897 / 4873 |
| `g1.board_read`（親讀看板筆數）| n/a | **1 / 0 / 0**（仍近 0）|
| `訂單履約率`（order_fulfilled/placed）| 0% | **0.0%（仍未脫 0）** |
| 存活隊（2 年）| — | 8→6，月 3–24 **穩定 6 隊**（無過餓）|

**WS-2c 的任務目標（破 survival 壓制）達成**：merchant_survival 從 18837 崩到個位數、market_arrive 從 0 升到 100–250。**但履約仍 0%** —— 這是 plan Self-Review 預判的下一段（「market_arrive 升但履約仍 0 → co-location/settle 問題（再查）」），**不在 WS-2c scope**，root 已定位（見下「待主 session 確認」#1）。

## 實作摘要（改檔，每檔一行）

- `scripts/simulation/resource_system.gd`：`_own_granary_tile`→`static own_granary_tile`；加 `static effective_food(state, team)` = 私產 food + 自家糧倉 food（決策讀者單源）；`_pos_to_tile_id` 轉 static（被 static 呼叫）。消耗扣除路徑（resolve_consumption）caller 同步改名，行為不變。
- `scripts/simulation/faction_ai_system.gd`：survival/trade/ambition/設施/復工/急徵稅/戰備/缺糧 stress 決策讀者路由過 `effective_food`（per-site 清單見下）。`calc_readiness` 加 `state` 參數（唯一 caller :179 同步）。
- `scripts/simulation/ambition_ladder.gd`：`target_rung` 的 surplus gate 路由（定居隊不再卡 RUNG_SURVIVE）。
- `scripts/debug/headless_test.gd`：新增 4 測（accessor / survival 不誤判 / 真絕境仍 survival / solo 商隊不誤判餓）+ 註冊。

## per-site 決策讀者：路由 vs 保留

**路由（語意 =「本隊有多少糧」，定居隊 food 在糧倉→誤判）：**
- `:2070` `_evaluate_survival` food（**核心 unblock**，Task1；釋放檢查同變數受惠）
- `:1001` `_evaluate_solo` food_pc（**solo FLEE gate**，商隊永逃元兇之一）
- `:649` `_update_goals` food_per_cap（急徵稅 emergency）
- `:1610` `_try_resume_construction` days_left（餓肚子不復工 gate）
- `:1906` `_pick_facility` hungry（缺糧→優先建農 override）
- `:1979` `_facility_deficit` farming 缺口（缺口驅動建農 score）
- `:2509` `_count_stress_sources` 缺糧 stress 源
- `:1327` `_check_food_shortage` total_food（faction food per-capita；**聚合但逐成員 = 各隊有效糧**，跨隊 granary 各自獨立 keyed，安全）
- `:92` `calc_readiness` food_days（戰備 food_factor；加 state 參數路由）
- `ambition_ladder:48` `target_rung` surplus gate（ambition 階梯）

**保留（特殊語意/非「本隊現量」，per-site 判斷後不改 + 標註）：**
- `:1477` `_calc_team_need`：food return = pop×14，是**需求目標常數**非現量讀取 → 不路由。
- `:2377` `_find_aid_target` reserve：讀**他隊**（discovered `t`）`t.resources food` 判「該隊有無餘糧可捐助」。語意 = 別隊私產可施捨量，**非本隊決策糧量**；且捐助走 team.resources interaction，非糧倉。保守保留（如後續要讓「定居富隊也能當捐助源」，可再評估改 effective_food，但屬獨立行為調整，非 WS-2c unblock 範圍）。

## 回歸閘（headless，全綠）

- `=== DONE ===`、`SCRIPT ERROR / Assertion failed / Parse Error` 計數 = **0**。
- 新測 4 條全 OK：`effective_food accessor OK` / `survival reads granary OK` / `true desperation still survival OK` / `solo trade not starved OK`。
- 既有飢荒鏈全綠（Task1a–3c）、WS-1 糧倉測（`consume from granary OK 糧倉剩=476`）綠。
- `投靠守恆整合 OK`（coin_eq=0）、`InvariantAudit population/faction/subteam 雙向 OK`。

## 守恆 / 無飢荒回歸

- **守恆**：純決策讀取改（AI 以為有多少糧），消耗扣除 WS-1 已正確 → 不碰 resources/coin。coin_eq=0、InvariantAudit 0 確認。
- **真絕境仍進 survival**：team+糧倉皆空 → effective_food≈0 → 仍正確觸發（新測 `true desperation still survival` + world_sim trace 中 `vault=-`（不在自家 outpost）的空包羅游隊仍正確 `return_home(p80)[survival]`）。accessor 不掩真飢荒。
- **世界無過餓**：2 年存活隊 8→6 後**月 3–24 穩定 6 隊**，無 accessor 引發的滅團潮。

## 待主 session 確認 / 建議後續

1. **【高優先・下一 measure-first WS】履約仍 0% 的真因 = 抵達市集但讀不到看板**。`market_arrive=108–248`（隊**確實站上**市集 outpost tile）但 `board_read=0–1`（幾乎沒注入任何看板單）。同一函數 `read_market_board` 兩探針差距 → 商隊站上市集 tile 後 `tile.market_orders` 對它**幾乎都空/已知/全自己單**（不是 survival 鎖了，是看板供需 co-location 對不上）。建議下一 WS measure-first：抽樣印 market_arrive 當下的 `tile.market_orders` 內容 vs 該商隊 team_known，定位是「賣家不在該 tile 掛單」還是「dedup/expire 吃掉」。**WS-2c 已把上游 survival 解鎖到位，此為純下游問題。**

2. **trace `food=` 欄位是 raw `t.resources food`（team_trace.gd:23），非 effective_food**。定居隊站糧倉時 trace 顯示 `food=0` 但 `vault=food1993`，AI 經 accessor 已正確看到糧（task 為 生產/訓練/貿易 而非 survival 即證）。**非 bug**，但若要 trace 反映 AI 真實視角，可考慮顯示 effective_food（純觀測改，留主 session 定）。

3. **`:2377` aid reserve 保留**（見 per-site）。若藍圖/系統認為「定居富隊也該被選為救濟捐助源」，需把它改 effective_food —— 但那是行為擴張（非 unblock），且須確認捐助 interaction 能從糧倉提領，留呈報。

4. **偏離**：無。plan File Structure 列的 4 檔 + 本 handback，未碰 game-design/invariants/progress/known_issues/CLAUDE.md/process。`calc_readiness` 加 state 參數為 plan `:92` 路由的必要簽名改（唯一 caller 同步，無 test 依賴 `calc_readiness`，僅 `calc_readiness_threshold` 有 test）。
