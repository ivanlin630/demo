---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN] 生存經濟基座arc HOW spec——親讀scripts/simulation/marginal_economy.gd全檔確認①感知鐵律結構防線真實:_inflow_est(est)簽名只吃VillageEstimate純struct,零state/team參數,結構上真的拿不到state.teams[target]、非只是道德勸說式註解;camp_marginal目前確實不存在(親grep零命中)是真'新方法'、鏡射migrant_marginal同款maxf(0,差值)pure-arithmetic pattern,零新分數常數,禁crank結構保證坐實②VillageEstimate.make簽名親讀(terrain_,outpost_level_,farming_level_,pop_est)純可觀測欄位確認belief-buildable屬實③B5親讀_self_use(team,res,leader_values)現況確認真的無state參數、need_keep(state,team,res,leader_values)確認已有state可傳,threading是trivial安全改動;escalation公式親算兩端界:food_days>=SAFE_DAYS時maxf(0,負或零)=0→escalation=1不變(吃飽照舊),food_days=0時=1+FAMINE_GAIN(有界非失控),bounded坐實④A2/A3診斷citation親驗:_convert_to_resident定義interaction_system.gd:1363、呼叫點faction_ai_system.gd:1963逐字對得上;options.gd guardrail comment同上輪已讀過位置吻合;⑤slice序(B4/B5先堵漏,A層再開閘)邏輯合理,diagnostic-first(A2/A3先pin斷點禁猜)呼應本session已建立的症狀vs根因方法論;判決=CLEAN→鎖→plan slice拆解→dispatch implementer(B4/B5先)"
---

# R②判決：生存經濟基座 — 接入+產出 arc HOW spec — CLEAN

## 親讀 `marginal_economy.gd` 全檔——感知鐵律結構防線真實存在

`_inflow_est(est: VillageEstimate) -> float` 簽名只吃**純 struct**，零 `state`/`team` 參數——結構上真的拿不到 `state.teams[target]`，這不是「呼叫者答應不濫用」式的道德勸說防線，是函式簽名本身就不給你濫用的管道。`camp_marginal` 目前確實**不存在**（親 grep 全檔零命中）——確認是真「新方法」，且它要鏡射的 `migrant_marginal`（`:27-35`）本身就是同一種 `_inflow_est` 差值計算 pattern，`camp_marginal`（`maxf(0, _inflow_est(est) − forage_floor_income)`）延續同款 pure-arithmetic 結構，沒有引入新的分數常數家族——禁 crank 結構保證坐實。

`VillageEstimate.make` 簽名親讀確認 `(terrain_: String, outpost_level_: int, farming_level_: int, pop_est: int)`——全是可觀測欄位（地形/等級/人口估計），belief-buildable 的宣稱屬實。

## B5：state-threading 是 trivial 安全改動，escalation 公式親算兩端界

親讀 `_self_use(team: TeamData, res: String, leader_values: Dictionary)`——**現況確實沒有 `state` 參數**。`need_keep(state, team, res, leader_values)`——**已經有 `state`**。threading 只是把既有呼叫者手上已經有的 `state` 多傳一層，非新增依賴。

親算 escalation 公式兩端界：`escalation = 1 + maxf(0, (SAFE_DAYS−food_days)/SAFE_DAYS) × FAMINE_GAIN`——`food_days ≥ SAFE_DAYS`（吃飽）時，`maxf(0, 負或零) = 0` → `escalation = 1`（照舊）；`food_days = 0`（瀕餓底線）時 → `escalation = 1 + FAMINE_GAIN`（有界，非隨 food_days 趨近負無限而失控）。bounded 坐實。

## A2/A3 診斷 citation 親驗

`_convert_to_resident` 定義在 `interaction_system.gd:1363`，呼叫點 `faction_ai_system.gd:1963`（另有 `:2638` 一處）——逐字對得上 HOW spec 引述。`options.gd` guardrail comment（「只此 option、guardrail」）跟我上輪審 WHAT spec 時已經讀過的同一段落吻合，位置沒有漂移。

## slice 序 + diagnostic-first 方法論合理

B4/B5 先堵「已 settled 團餓死」這個漏，A 層再開閘拉更多團進來，邏輯順序正確（先讓水管不漏，再開大水量）。A2/A3 採 diagnostic-first（先 pin 斷點在哪段、禁先猜再修）——呼應這 session 已經建立的「症狀 vs 根因」方法論（重試迴圈/execution-break 那幾輪的教訓），是正確的作法，不是拖延。

## 判決
**CLEAN → 鎖 → plan slice 拆解 → dispatch implementer（B4/B5 先）。** 這份 HOW spec 的技術主張逐條可驗、逐條坐實——感知鐵律的防線是結構性的（函式簽名層級），非依賴自律；禁 crank 靠複用既有 `MarginalEconomy` pattern 而非發明新公式；B5 的 state-threading 是最小侵入性改動。
