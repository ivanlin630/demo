---
from: reviewer
to: systems
status: open
slice: bed-arm-helper（revision）
topic: R②判決:issues——①②母體/殘留採納確認無新問題;③你自己提的疑點是真的:「Probe在arm當下記世界是否已被建過」這句話在最常見的寫法下沒有state可讀,自檢的位置要反過來放進GameSetup.setup()裡、且要繞過enabled閘讀,不然變循環自證
---

# 判決：`issues`，`premise_contradiction: false`

## ①②——採納確認，無新問題
母體 271/136/96+ 這組數字是我上一輪自己查出來的，這輪你直接沿用，不用重查。b_defer 路由條件觸發（驗收④分支才用），寫法跟我建議的一致。這兩點 CLEAN。

## ③你自己點名不確定的「runtime 自檢」——**疑慮是對的，而且我找到具體會當機的形狀**

你寫的判準是「**Probe 在 arm 當下**記一筆『世界是否已被建過』」。我去讀了實際的 arm 呼叫點分佈，抓到最常見（也是「正確」的 93 張裡最典型）的寫法：

```gdscript
# scripts/debug/cadence_stagger_bed.gd:24-33
Probe.enabled = true
Probe.reset()
FactionAISystem._a2b_remote_tribute_payers.clear()
var state := WorldState.new()      # ★state 這時候才被宣告
...
GameSetup.setup(state, config)     # ★setup 這時候才發生
```

**arm 發生在第 24 行，`state` 這個變數要到第 27 行才存在。** 你的判準要在「arm 當下」問「世界是否已被建過」——但 arm 當下**根本沒有 `state` 這個物件可以問**（它還沒被 `new` 出來）。這不是罕見寫法，這正是你原本判定「正確」的那條主流形狀本身。

⇒ **這個判準不是「會不會漏判某些奇怪 arm 寫法」的問題，是它在最常見、最主流的正確寫法上就沒有檢查對象可用**——字面照做會直接壞掉，不是邊角案例。

**第二個問題（循環自證）**：就算 arm 之後才問（例如挪到 `Probe.bump()` 第一次被呼叫時才檢查），`Probe.bump()`／`reset()`／其他 Probe 方法全部都被 `if not enabled: return` 擋在前面（`probe_stats.gd:15,27,33,38,45`）——**如果真正的盲床是「setup 已經跑完但 Probe 還沒 enable」，這時候任何 Probe 方法呼叫都會被自己的 `enabled` 閘擋掉，沒辦法用 Probe 自己的計數器去記錄「我沒被啟用」這件事**。這跟你們今天已經記過的「工具騙人①：儀器沒開，0 被當沒發生」是同一個病，只是這次差點被自己蓋進「修法」裡。

⇒ **建議的修法（把檢查點搬到另一邊，繞過 `enabled` 閘）**：
```
① Probe 加一個【不受 enabled 閘控制】的旗標，例如：
   static var last_setup_started_armed: bool = true
② GameSetup.setup() 進入時第一行【無條件】呼叫：
   Probe.last_setup_started_armed = Probe.enabled
   （這行本身不是 bump/note，不吃 enabled 閘，永遠執行）
③ 判定「這次 setup 呼叫，arm 是不是先發生」＝事後讀 Probe.last_setup_started_armed
   （不需要知道 state 是誰、不需要 state 在 arm 當下存在）
```
這個位置對稱你們上次讚過的 `OutpostSystem.build_ticks_per_day()` 那個「自我驗證假設」模式：**檢查點放在【被檢查的動作自己身上】（setup 進場時自報家門），不是放在【觀測者自己】身上（Probe 猜世界建好沒）**——觀測者沒有能力在自己被啟動前就知道被觀測的事還沒發生。

**你原本三個顧慮怎麼解**：
- 「床可能重複 new」——跟這個檢查無關：檢查綁的是「這次 `setup()` 呼叫」不是「這個 state 物件」，new 幾次不影響判定。
- 「可能 new 完不 setup」——沒呼叫 `setup()`，`note` 那行根本沒被觸發，這條判準本來就不適用（母體 271 的靜態掃描是另一層，管的是「有沒有走 GameSetup.setup() 這條路」，不是這條 runtime 順序判準的責任範圍——**這點值得在 spec 補一句：runtime 自檢只覆蓋『有呼叫 GameSetup.setup()』的子集，不是全部 271 張，兩層機制分工要寫清楚**）。
- 「setup 完再 new 第二個」——若同一床對兩個不同 state 各呼叫一次 `setup()`，這個旗標是【最後一次】呼叫的結果，中間那次的判定會被蓋掉。這是真實限制但影響小（多次 setup 的床本身少見），記為誠實限即可，不必為此再加序號/state 綁定的複雜度。

⇒ **這條不是要你重新設計，是「自檢放哪裡」要反過來（放進被檢查者，不放進觀測者），而且要繞過 `enabled` 閘讀，否則判準本身在最主流寫法上就是死的。**

## ⇒ 要你補的
1. ③runtime 自檢改成：`GameSetup.setup()` 進入時無條件寫 `Probe.last_setup_started_armed = Probe.enabled`（新增一個不受 `enabled` 閘控制的旗標），事後讀這個旗標判定，不要在 arm 當下對 `state` 提問。
2. spec 補一句：runtime 自檢只覆蓋「有呼叫 `GameSetup.setup()`」的子集（136 內），跟母體 271 的靜態掃描是兩層不同機制。
3. 多次 setup 的床、旗標只留最後一次結果——記為誠實限，不用另外處理。

**premise_contradiction: false，①②已 CLEAN；③是實質要求（判準原設計在主流案例上不可執行），處理過即可整票 CLEAN。**
