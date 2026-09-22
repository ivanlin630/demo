---
from: systems
to: implementer
status: open
slice: `arrived-subteam` 的**前置量測** —— 按 task 型別數 blanket 歸建
topic: ★**純 tap，不改行為**｜★★★**為什麼要它**：R² 指出我驗的母體是 1 種 task，而那條 blanket 管的是 **24 種** —— 這顆數字決定「這是一張 slice 還是一條 arc」｜★★**修法票已降級，數字回來之前不動 code**
---

# 一、加什麼（純記帳，★依不變量 #7：語意不得依附 `Probe.enabled`，而 tap 可以）

```
`scripts/simulation/faction_ai_system.gd`
  ①`:3972` 那條 blanket 命中時 ⇒ `Probe.bump("merge.blanket_evicted." + sub.current_task)`
  ②子隊**抵達**（`move_target == Vector2i(-1,-1)`）且 task 非 IDLE 時 ⇒ `Probe.bump("subteam.arrived." + sub.current_task)`
     ★★**②要放在 blanket【之前】** —— 否則分母只會數到被歸建的那些（分子分母同一批 ＝ 恆 100%）
     ⇒ ★★★這正是今天抓過兩次的那個病（**比率的分子分母不同母體**）
```

# 二、★要回答的那個數

```
**24 種落到 blanket 的 task 型別裡，實際上有幾種真的會抵達？各自幾次？被歸建幾次？**
  （24 種 ＝ ATTACK BEG CAMP DEFEND DIPLOMACY FLEE GOVERN HOLD JOIN LOOT MANUFACTURE MERGE
    PACIFY PATROL PRODUCE REST RETURN_HOME REVOLT SEEK_HOME SHELTER TRADE TRAIN TRIBUTE TRIBUTE_OFFER）
★★卷面要**逐型別一行**：`<task>  arrived=N  evicted=M  ratio`
★★★**母體 0 的型別也要印**（印成 `arrived=0`）—— ★**不要只印有數字的那幾種**：
   「24 種裡只有 3 種會發生」與「24 種都在發生」是**完全不同的兩張票**，而**只印非零看不出是哪一種**。
```

# 三、★共同要求

```
兩顆種子｜8 天窗｜`warring_states`｜四要素｜硬體戳**直接貼 `[HW] cpu=…`**｜世代戳 世代 6（`3fb2c3201`）
★`GODOT_TIMEOUT` 要給夠（wrapper 預設 360s ⇒ 超過 **exit 98 且一行結果都沒有**）
★★長跑前看記憶體（`[HW]` 那行會印 `mem_free=`）
★★★**你只量、不判**；門檻與「是 slice 還是 arc」由我依這顆數字裁。
```
