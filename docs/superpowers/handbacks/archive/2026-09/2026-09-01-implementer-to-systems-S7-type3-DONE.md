---
from: implementer
to: systems
status: consumed
slice: S7-reconcile-type3 → bed-arm-helper
tier: probe
topic: ★型③做完(c836a813,只盤不修 production 0 行)——★★四個真命中,而最重的是③:manufacturing 自述「產線在 NEAR pass」但 registry 是 LOD_BOTH+shape teams(不吃 cadence) ⇒ 同一座工坊在遠區每日真產量只有近區的 1/10,★★★而同張 registry 上四個系統都用 teams_cadence、reactions 還明寫「far 用 trials 補回」⇒ 補回機制存在、被別人用了、它沒用;★「查不到執行端」欄 0 列,而我把它標成【判準的限制】不是好消息
---

# ★①母體先寫死再數（★而它當場又證明一次「名字列舉會發散」）

```
母體B（估算端）判準：函式名以底線切開後
  ①任一段 ∈ {eta, est, estimate, forecast, predict, runway, expected, expect}
  ②或名字結尾 ∈ {_days, _per_day, per_day, _rate}
⇒ 命中 25
★★而只用【子字串】比對 ⇒ 88，多出來的 53 全是誤抓：
   nearest / best / establish / request / richest / weakest / invest / harvest…
⇒ ★★★判準要落在 token 邊界，不是子字串。53 條我全列出來，可複驗。
```
★**母體A 我沒有用 `-=` 當軸**：實查 61 處 `-=`，**幾乎全是區域累加器**（score／base／remaining）
⇒ ★★它不是「消耗」的軸。改成【逐個估算端反查誰真的在改那個量】。

# ★★②四個命中（★依「錯得多大 × 有沒有人看得到」排）

## ★★★③ manufacturing：估算端宣稱的 cadence 與 registry 不符（★本輪最重）
```
估算端 manufacturing_system.gd:78-81 註解自述：
   「★一天跑幾次：產線在 NEAR pass ⇒ 次數 ＝ TICKS_PER_DAY / NEAR_CADENCE」＝ 24
執行端 sim_runner.gd:164：
   {"name":"manufacture", "lod": LOD_BOTH, "shape":"teams"}
   ★lod = LOD_BOTH ⇒ far 隊在 far pass 也跑（每 FAR_ZONE_INTERVAL = 600 tick ⇒ 2.4 次/日）
   ★★shape = "teams"（不是 "teams_cadence"）⇒ sim_runner.gd:199 呼叫時【不傳 cadence】
      ⇒ 每次呼叫產固定量，不因間隔變長而補回
```
⇒ ①估算面：`runs_per_day()` 對 far 隊**高估 10×**
⇒ ②世界面：★★**同一座工坊，隊在遠區時每日真產量只有近區的 1/10**
   —— 而這不是估算誤差，**是世界本身的行為隨 LOD 改變**。

★**對照組坐實它是【漏做】不是【設計】**：同一張 registry 上
`collect` / `consumption` / `fatigue` / `reactions` **四個都是 `teams_cadence`**，
而 `reactions` 更在 `sim_runner.gd:515-517` 明寫「far pass 用 trials 補回被跳過的窗次」。
⇒ ★★★**補回機制存在、被別人用了、manufacture 沒用。**

★**對照組②**：`outpost_tick` 是 `LOD_NEAR`，而 `build_ticks_per_day()` 還多帶一顆
`_outpost_tick_runs_in_near_pass()` 假設告警 ⇒ **manufacturing 沒有那顆，所以它的假設壞了也不會叫。**

★★**誠實標**：`1/10` 是**推導**不是量測（靜態讀 registry）。要坐實需要一支床：
同一座工坊、同一組人，near vs far 各跑 N 日比產量。**我沒跑**（本票只盤不修，且世界層是量測員的線）。

## ★① 食物 burn：估算端與執行端【母體不同】，而分岔在估算端自己內部
```
執行端 resource_system.gd:205-206  total_pop = population + minor_population
                                   （★同函式 :198-200 另扣馬匹草料 FOOD_PER_MOUNT_PER_DAY）
估算端 55 處使用點：★含 minor 的只有 4（food_flow:19／resource_system:206,272／goal_resolver:295）
                    ★★只用 population 的 51
```
⇒ 估算端**低估 burn** ⇒ `food_days` **高估** ⇒ ★隊以為自己撐得比實際久。
⇒ ★★而馬匹草料**沒有任何估算端算進去** ⇒ 有馬的隊高估更多。
★★★**誠實標：51 是【上界】不是「51 個 bug」**——其中少數是每人份常數
（`MIGRANT_UPKEEP`／`JOIN_ONBOARD_MEAL`），minor 對它們不適用。**逐條分類本輪沒做。**

## ★② 移動速度：三個獨立來源，共用的只有一顆常數
```
執行端 movement_system.gd:170-195  base speed(mount×wagon) × 地形 × 分段疲勞 × 超載 × 車輛
                                   + clamp[MIN, MAX]
估算端① path_system.gd:158         clampf(1 - fatigue, 0.1, 1.0)  ★就這一項，★★無 clamp
估算端② path_system.gd:209 / :256  同族同缺項
估算端③ goal_resolver.gd:896       MOVE_TILES_PER_DAY = 2.0 手寫（物理真值 6.0＝S7 病3）
⇒ 三源共用的只有 BASE_MOVE_TICKS
```
★**具體差多少**：fatigue=0.6 時 估 0.40 vs 執行 0.76 ⇒ **估算悲觀約 1.9×**。
★★**而它有下游後果**：`_return_is_hopeless` 判準是「已耗時 > MULT × 預期 ETA」
⇒ 估算偏悲觀 ⇒ **放棄門檻被推高** ⇒ ★★★該放棄的子隊更晚放棄。

## ★④ inflow：手抄鏡像，★★而且【已經開始分岔】
```
food_flow.gd:12        OUTPOST_MULT = [1.0, 1.4, 2.0]
marginal_economy.gd:10 OUTPOST_MULT = [1.0, 1.4, 2.0]   # 鏡射 FoodFlow.OUTPOST_MULT
★★公式已不完全一樣：food_flow:49 用 LaborSystem.farm_labor(tile)
                     marginal_economy:26 用【inline 重算】的 est_farm_labor
```
★★★**但這一顆我不建議直接合併** —— 它有**正當的架構理由且寫在 code 裡**：
`marginal_economy.gd:4-7` 明寫「禁呼 live `_sustainable_inflow`——結構上只吃純 struct，
拿不到 `state.teams[target]` → **結構上不可能違憲**」。
⇒ ★這是【憲法（感知鐵律）】與【單一真值】的**真實衝突**，不是疏忽。
⇒ 可行形狀（★建議非裁定）：把公式抽成一支**只吃純數值參數**的函式，兩邊各自餵自己的來源
   —— 憲法防線保住，而公式只有一份。

# ★★★③「查不到執行端」欄：0 列 —— ★而我把它標成【判準的限制】

```
★本輪沒有任何一列落在那一格
★★而那不是好消息：母體B 是【從估算端出發】的
★★★而「估算一個不存在的量」這種病，在【名字像估算器】的函式裡不一定看得到——
   它更可能長成「一個 ctx 欄位被算出來、被讀、而世界上沒有對應的執行」
⇒ 要真的掃那一格，母體要換成【decision ctx / terms 的每一個欄位】，
  判準＝「這個欄位影響 util ⇒ 對應的世界動作真的存在嗎」
⇒ ★那是另一票（母體不同、判準不同）。我不在本票裡假裝掃過。
```

# ④紀律
```
★只盤不修：production diff = 0 行（git status -- scripts/simulation scripts/data scripts/ui 空）
★★落地 docs/measurements/2026-09-01-s7-type3-estimator-vs-executor.txt（commit c836a813，已 push）
★★★每一條命中都帶 file:line；沒查到的地方我標「沒做」而不是留白
```

# ⑤下一票
★**床 arm helper 我還沒開始**（spec `2026-09-01-bed-arm-helper-HOW.md` 已在 repo，我會照 R² 反轉後的形狀做：
自檢放進 `GameSetup.setup()`、★★且繞過 `Probe.enabled` 閘、直接寫獨立欄位 `setup_saw_unarmed`）。
★★★**而 reviewer 反轉的那一點我看懂了**：包在 `if Probe.enabled` 裡的話，arm 太晚時**偵測器自己也不執行**
—— 那是【偵測「儀器沒開」的儀器自己沒開】，循環自證。
