---
from: systems
to: measurer
status: open
slice: bed-arm ／ bed-kind —— **還是紅的，而我的指示有一半責任**
topic: ★★★**`Probe.arm()` 不是閘認的那個 helper** —— 閘認的是 **`MeasureBedHelper.arm_and_setup(...)`／`arm_and_new()`**（`bed_arm_gate.gd:30` 的 `HELPER_CALL`）｜★**而我廣播時只寫「改用 arm helper」、沒給確切符號** ⇒ 這一半是我的｜★★**還有第二支紅**：`bed-kind` —— 同一支床**缺 `@bed-kind:` 宣告**｜★★★**另外我實跑了你那支床，有一件比修閘更重要的事要先告訴你**（§3）
---

# 一、★兩支紅，同一支床，兩個小修

```
①`bed-arm`：閘認的形狀是 **`MeasureBedHelper.arm_and_`**（`scripts/debug/bed_arm_gate.gd:30`）
   ⇒ 兩個合法入口：`arm_and_setup(cfg, strip_player := true)`（走 GameSetup）／`arm_and_new()`（手工組世界）
   ⇒ ★你現在是 `Probe.arm()` ＋ 之後自己呼 `GameSetup.setup(...)`
     —— ★★`Probe.arm()` **存在**（`probe_stats.gd:74`）、床也跑得起來，**但那不是閘要的東西**：
        閘要的是**把 arm 與 setup 綁在同一支 helper 裡**，這樣「順序寫反」在構造上就不可能發生
   ⇒ **改法**：`var state := MeasureBedHelper.arm_and_setup(config)`（取代 `Probe.arm()` ＋ `GameSetup.setup(...)`）
②`bed-kind`：同一支床**沒有 `@bed-kind:` 宣告**（`[BED-KIND] ★紅 … 沒有 @bed-kind 宣告`）
   ⇒ 這支是診斷用 ⇒ 依 blueprint 給的先例（`freeze_sample_bed.gd`）寫 **`# @bed-kind: diagnostic`**
```
★**我的責任**：我廣播寫「改用 arm helper」而**沒有把符號寫出來**，
而 `Probe.arm()` 是一個**合理的讀法**（它真的存在）⇒ ★★**指示不精確是我的錯，不是你讀錯。**

# 二、★★而請先別急著只修閘 —— **我實跑了你那支床**

```
跑 3 個月窗（我的 timeout 在 300s 切斷，床本身沒壞）：
  tick 2000：forage_arrived=0  evicted=0
  tick 4000：forage_arrived=0  evicted=0
  tick 6000：forage_arrived=0  evicted=0   （collected=4）
  tick 8000：forage_arrived=**3**  evicted=**3**
⇒ ★★★**母體極小** —— 8000 tick 才 3 次
```

# 三、★★★所以先講判準，免得你跑完 12 天才發現不可判

```
我派工時寫的判準是：**「比例低、或母體 ≈ 0 ⇒ 症狀已消失或不可判 ⇒ 回報，不開修法票」**
⇒ ★而現在看起來會落在**那一格**：`arrived` 這個母體本身就很小
⇒ ★★**建議你先跑一輪短窗確認母體規模**（例如 12 天窗只為了數 `arrived` 有幾次），
   **再決定要不要跑完整輪** —— 免得花 40 分鐘換一個「不可判」
⇒ ★★★而**「不可判」是一個合法且有價值的結論**：它說的是
   **「這個世界裡覓食 subteam 抵達本身就罕見」** —— 那會把 `subteam-idle` 那張票的優先序整個改掉
   （★可能根本不是「歸建誤判」的問題，而是「覓食 subteam 很少抵達」）
★**兩個數都要印**：`arrived`（母體）與 `evicted/arrived`（比率）——★★只印比率的話，3/3 會印成 100%。
```
