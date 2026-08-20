# 生存經濟基座 — 接入+產出 arc（HOW / systems）

status: DRAFT→R²（2026-08-13）
owner: systems（HOW）← design `2026-08-13-survival-economy-access-arc-design.md`（blueprint WHAT、R² CLEAN）
★大部已 merge(A1/A2/crisis-lock 結論入 game-design);本檔留殘項參照。
build-unblock: ★主樹編譯 OK（faction_ai:2490 temp-diag 已 revert、無 distance_to、perf bed 本 session 跑過）=blueprint 顧慮的 compile blocker **已清**。

## §0 接點圖 + 命門（HOW 守）
- **禁 crank 結構保證**：A1/A2 價值 = **接既有 `MarginalEconomy`**（marginal_economy.gd、移民/投資/遷村共讀 substrate）、**勿另開計算**。不新增分數常數。
- **感知鐵律結構保證**：`MarginalEconomy` **只吃純 struct `VillageEstimate`**（marginal_economy:5 god-view 防線=結構上拿不到 `state.teams[target]`）→ A1/A2 est 從**可觀測**（terrain/等級=belief）建、非 live 池 current。B5 讀**自家** famine（自知肚餓≠god-view）。
- **determinism**：MarginalEconomy 純算術零 RNG；B5 讀 team 自身 state 零 RNG。fp 比對標 intended-change（非 byte-identical、行為有意改）。

---

## §A 接入層

### A1 紮營價值 = MarginalEconomy（camp_drive 換算法）
- **現況**：`camp_drive`（terms.gd:190-193）= flat `1.0`（前人 T1 剝 hunger urgency 的死常數）。`紮營 util = weight("camp")[人格] × camp_drive[1.0]`。
- **HOW**：`camp_drive` → **`MarginalEconomy.camp_marginal(est, forage_floor) × urgency`**：
  - **新方法** `MarginalEconomy.camp_marginal(est, forage_floor_income) -> float`（鏡射 `migrant_marginal` 結構）= `maxf(0, _inflow_est(est) − forage_floor_income)`。
    - `est = VillageEstimate.make(terrain, outpost_level=1, farming_level=0, pop)`——terrain **從 team 對腳下 tile 的可觀測 terrain**（belief、非 live 池）。
    - `forage_floor_income` = 覓食餬口地板（現有收入基準、`ResourceSystem._forage_subsist_buffer` 同源日產）。
  - **urgency** = 存糧跑道 = 低 food_days → 高（讀自家 `effective_food/(pop×0.8)`、team 自身狀態）。
  - ∴`紮營 util = weight("camp")[人格 MODULATE] × camp_marginal × urgency`——人格 modulate 非 gate、survival-boost order-preserving 不動。
- **★bounded 四象限（machine-demonstrate 硬 gate）**：①有家有倉→已 resident、camp 不 applicable/邊際≈0 ②富流浪→urgency 低 ③瀕餓+肥沃平原→`_inflow_est`(regen 8)−floor>0 ×高 urgency=高 ④**瀕餓+山地→`_inflow_est`(regen 0.5)−floor≈0→`maxf(0,·)=0`→不紮**（灌分做不到這條=結構 anti-crank）。

### A2 進駐（settle）= MarginalEconomy + dispatch 斷點修
- **價值**：進駐現成村 = `MarginalEconomy.migrant_marginal(village_est, self_pop)`（共池邊際遞減、村已存在=既有方法直接複用）+ 可達性代價。**不寫死偏好**：有村 migrant_marginal 投村/無村落 A1 camp_marginal 開荒=湧現。
- **dispatch 斷點**：settle 鏈**存在**（invite→`try_set TASK_SETTLE` faction_ai:610、arrival→`_convert_to_resident` :1963）但 measurer 測 `convert=0`。**★diagnostic-first（同 A3、blueprint 令）**：先 pin 斷在哪段——(a) invite/dispatch 沒 fire（:601-610 gate）(b) TASK_SETTLE dispatch 了但沒抵達（travel/感知鐵律跨距）(c) 抵達了 `_convert_to_resident` 沒完成。**pin 出斷點再修、禁猜**。

### A3 建設執行 noop 修（diagnostic-first）
- 建設贏 argmax 15 次、12 次 `try_set_noop`（tick10 外全斷）。**★先 pin `TaskArbiter.try_set` 對建設 task noop 的 guardrail/precondition**（options.gd:44 註「只此 option、guardrail」）——是 material precondition? priority guard? cadence? **pin 出再修**（同 construction-latch A1 已知家族 [[known_issues]]、可能同根）。

---

## §B 產出層

### B4 settle 時 invalidate labor cache（明確 bug、小修）
- **現況**：`labor_alloc` 3 天 cadence（`ensure_fresh` labor_system:17-19、現 caller manufacturing:85/resource:64）→ 新居民首 3 天採糧硬零 57-80%。
- **HOW**：settle/紮營成功落腳點 **立即 `LaborSystem.ensure_fresh(state, tile)`**——加在 `_convert_to_resident`（interaction:1363 / faction_ai:1963 呼叫後）+ `establish_crude_camp`（空地 founding）成功後。使新據點 tile labor_alloc 即刻含新居民的 gather:food。**小修、無行為外溢**（只提早刷既有 cadence、非改分配邏輯）。

### B5 food need 隨飢餓升級（NeedOracle 單點、勿平行）
- **現況**：`NeedOracle._self_use`（need_oracle:105-108）food 分支 = `FOOD_PER_PERSON_PER_DAY × pop × food_security_target(leader_values)`=**純靜態、零讀 famine** → material need 排擠 food（labor 給採礦不採糧）。
- **HOW**：**改此單點**（勿另開 food-need 路徑、blueprint 令）：food 分支 × **famine-escalation 係數**。
  - 係數 = `f(food_days)`：`food_days = effective_food(state,team)/(pop×0.8)`（team 自身狀態=感知鐵律 clean）。**需 thread `state` 進 `_self_use`**（現 food 分支無 state；`need_keep(:14)` 已有 state 可傳）。
  - 形狀：`escalation = 1 + maxf(0, (SAFE_DAYS − food_days)/SAFE_DAYS) × FAMINE_GAIN`（餓越久越高、bounded）。
  - **genuine**：從真實 food_days 算、非常數。**bounded**：吃飽村（food_days≥SAFE_DAYS）→ escalation=1（照舊採礦）；瀕餓→escalation 高→food need 主導→勞力自然回糧。**單點改自然傳導**：`need_keep(food)` 已 = `_self_use + _supply_chain`（food 的 _supply_chain=0）→ 改 _self_use 即改 labor weight（labor_system:99 讀 need_keep+demand）。

### B6 小團 pool 地板 —— PENDING 用戶裁（不入本 arc build）
`maxf(1.0)` 使 pop1-3 pool 結構夾死。裁項未定（genuine「小團本弱」vs「1人平原該自足」）→ **不動**。

---

## §invariants（本 arc 硬守）
1. **感知鐵律**：A1/A2 est 從可觀測 terrain/等級（belief）建、經 `VillageEstimate` god-view 防線；決策不讀 live 池 current/他隊 god-view。B5 讀自家 famine（自知）。
2. **禁 crank**：A1/A2 接 MarginalEconomy 共讀、零新分數常數；B5 從真 state 算。人格 MODULATE 非 GATE、survival-boost order-preserving 不動。
3. **determinism**：全 slice 零新 RNG；fp 比對標 intended-change（行為有意改、非 byte-identical）。
4. **bounded 四象限 machine-demonstrate = 硬 gate**（§4 measurement）。

## §slice 序（依賴 + 建議）
1. **B4**（ensure_fresh、最小 clear bug、standalone）+ **B5**（_self_use 單點、standalone、bounded）**先**——直接修「安家後採糧硬零/material 排擠 food」= 已 settled 團餓死根。**先讓安家真能餵飽**，A 層再拉更多團進來才不重蹈。
2. **A1**（camp_marginal 新方法 + camp_drive rewire）——接入分數。
3. **A2**（migrant_marginal 複用 + dispatch diagnostic-pin）、**A3**（build noop diagnostic-pin）——執行斷點、diagnostic-first。
- 每 slice 獨立 dispatch、各過 R②、各自 §4 bounded 量測綠才 merge。

## §4 量測（湧現硬數據、bounded machine-demonstrate 硬 gate）
- A1/A2：紮營/進駐真 fire + **bounded 四象限驗證**（有家不動/富流浪不紮/瀕餓平原紮/瀕餓山地不紮）；佔據率 8.6%→顯著升；分化（有村投村/無村開荒/有家不動）。
- A3：建設 order→execution 12/15 noop→顯著升。
- B4：新居民首 3 天採糧非硬零。B5：飢餓村勞力回糧、吃飽村照舊（bounded 兩象限）。
- 端到端：居民 food-security 脫 0 天；隨身層不再 -72.9%。
- determinism/regression/constitution 綠；fp 標 intended-change。

序：R² 審此 HOW → CLEAN 後 plan（slice 拆解）→ dispatch implementer（B4/B5 先）。效能 arc（rank_scored 快取/剪枝 byte-identical）平行 HOW 構思、build 排此 arc 後。
