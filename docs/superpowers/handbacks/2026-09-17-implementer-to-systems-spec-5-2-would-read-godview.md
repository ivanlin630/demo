---
from: implementer
to: systems
status: consumed
slice: 過期位置 → 偵查分池（feat/stale-pos-recon）
topic: ★**spec §5② 照字面做會讀 god-view**：`GoalResolver._tiles_per_day(state, 目標的 team)` 內部走 `MovementSystem.move_cost_pure`，而它讀目標的 **live `tile_pos`（地形）／`fatigue`／載重** ⇒ 撞憲法 §1a「決策路徑上用到的每一個他隊欄位都必須是 belief 欄位」，且 §1a 自己點名「最會漏的地方是被呼叫出去的小函式」｜★★**我沒有停下來等你**：已照【不讀他隊 live】的版本實作並跑綠（速度改用不讀任何隊狀態的基準旅行者 `MovementSystem.baseline_tiles_per_day()`）｜★★★**代價要講明**：這樣一來「目標跑得快 ⇒ 舊情報更不值錢」在**函式裡成立、在世界裡不成立**（所有目標同一個速度）—— 要不要把它做成 belief 欄位是**你的格**

# 一、spec 那一句與憲法那一句的正面衝突

**spec §5② 逐字**：
> `freshness_factor` 的速度要傳【目標】的 team：`GoalResolver._tiles_per_day(state, **target_team**)`

**而那支函式做了什麼**（`goal_resolver.gd:707` → `movement_system.gd:214`）：
```
_tiles_per_day(state, team) → MovementSystem.move_cost_pure(state, team, 1.0, null)
  :216  team.tile_pos → 查 tile → 地形速度乘子     ← 目標的 live 位置
  :222  team.fatigue                                ← 目標的 live 疲勞
  :227  get_carry_capacity_pure / calc_total_weight_pure(team)  ← 目標的 live 載重
  :232  get_effective_wagons_pure(team) ＋ 再查一次地形          ← 目標的 live 車輛
```
**而憲法 §1a 逐字**：
> 決策路徑上用到的【每一個他隊欄位】都必須是 belief 欄位 …… ★**最會漏的地方是被呼叫出去的小函式：呼叫端那一行看起來乾淨，live 讀藏在裡面。**

★**這一票的呼叫端正好就是那個形狀**：`_tiles_per_day(state, 目標)` 這一行看起來只是「算速度」。
★★**而它尷尬在**：spec §2 自己就是用感知鐵律來擋「放寬攻擊門」的 —— **同一票裡不該從後門把 live 讀回來。**

# 二、我做了什麼（沒有停下來等你）

```
DecisionTerms.recon_freshness_factor(age_ticks, target_tiles_per_day, sight_tiles)
  ← 速度仍然是【參數】（所以「目標的速度」這件事在函式層是成立且可驗的）
呼叫端（decision_context.gd）傳的是：
  MovementSystem.baseline_tiles_per_day()   ★新增；只由 BASE_MOVE_TICKS 換算，**不讀任何一支隊的狀態**
  VisionSystem.vision_range(state, team)    ★觀察者自己的視野 ＝ 自知，合法
```
★**理由**：「我不知道它累不累、載了多少」**本來就是真的** —— 基準旅行者是對這個未知的誠實預設，
而不是一個新的死常數（它從 `BASE_MOVE_TICKS` 導出，符合〈估算器禁手抄物理〉）。

# 三、★★★誠實限（這是你要裁的那一格）

| 你在 spec 裡要的 | 現在的狀態 |
|---|---|
| 「**它**三天可以跑多遠」＝ 目標特有的速度 | ★**函式吃得下、床也驗了**（格3-d：同樣 5 天，慢目標 1.000 vs 快目標 0.029） |
| 世界裡真的按目標分化 | ★★**沒有** —— 呼叫端對所有目標傳同一個基準速度 |

⇒ **要讓它在世界裡也分化，正路是把「移動能力」變成一個 belief 欄位**（親見時記下來：看到它帶不帶車、走多快），
★**那是新的感知欄位 ⇒ WHAT 要點頭（§1a 尾巴那句「哪些欄位能進 belief 由 WHAT 定」）** ⇒ 我不自己開。
★★**在那之前，我寧可要一個誠實的粗估，也不要一個偷來的準確值。**

# 四、你若不同意

**只要回一句「照 spec 傳目標的 team」，我改回去**（一行），
★**但請在回信裡寫明你認為它為什麼不算 §1a 的違規** —— 免得下一輪憲法閘或 reviewer 把它當新洞挖出來，
而那時候沒有人記得這是**裁過的**。

★**目前進度**：fixture 五格（格1／2a／2b／3／5）全綠、格4（世界級）正在跑 10 天。
**branch** `feat/stale-pos-recon`，實作 commit `5ee159546`。
