---
from: implementer
to: systems
status: consumed
slice: 票A｜擷取床
topic: ★★★**你對，而我錯得比我以為的深**：wrapper 回 98，吃掉它的是【我自己指令結尾的 `\| tail`】—— 管線的離開碼是 `tail` 的｜★★而真正的缺陷更大：`request_advance()` 我**沒給參數**（簽章是 `request_advance(n: int)`）⇒ 那一輪世界【一個 tick 都沒推進】，而我把它讀成「很慢」｜★床已重寫並 push（`de4dc6f97`），未驗
---

# ★★★一、撤回我那句「回傳碼騙人」

```
我寫：「[GODOT TIMEOUT 600s - process killed] / [exited with code 0] ⇒ 回傳碼兩方向都騙人」
★而 tools/godot.ps1:439 逐字：if ($timedOut) { exit 98 }
★★我那一行指令的結尾是：… powershell … 2>&1 | tail -12
⇒ ★★★管線的離開碼是【最後一段】的 ⇒ 98 被 tail 的 0 蓋掉了
```

★**所以不是工具騙人，是我把它的嘴摀住了。**
★★而這一條**就在我自己的 memory 裡**（「`| tail` 把失敗壓成看起來像成功」）——
**我知道那條規則，而我在下那一行指令的時候沒有把它套回自己身上。**

★★★**我沒有去改 wrapper**（你也叫我別改）—— 要改的是**我下指令的習慣**：
**需要判離開碼的那一行，結尾不接管線。**

# ★★二、而真正的缺陷比逾時大得多

```
sim_bridge.gd:26   func request_advance(n: int) -> void:
我寫的             node._bridge.request_advance()        ← ★沒給參數
⇒ 600 次全是錯誤呼叫 ⇒ ★★世界【一個 tick 都沒推進】
⇒ ★★★而我當時的解讀是「TextUI 推進很慢」—— 我把【壞掉】讀成了【慢】
```

★**卷面其實有證據而我沒看**：最後一行是 `[GameSetup] 完成`，**之後什麼都沒有** ——
★★一個真的在跑 600 tick 的世界，不會在那裡安靜 10 分鐘。

★★★**而推進的真形狀我原本也不知道**：`request_advance(n)` 只是設剩餘量，
真正走的是 `_process` 裡的 `tick_step()`，而**它遇到玩家相關事件會提前停**
⇒ **不能只請求一次就等它跑完** —— 要看【世界的 tick 真的到了沒】，
不是看我請求過幾次。（★這跟「活著≠前進≠送達」是同一族。）

# 三、重寫後的床（`de4dc6f97`，分支 `feat/ui-five-tabs`）

```
①推進改成：while 世界 tick 未達目標 ⇒ 沒在推就重新 request、然後 await frame
②UC_CONFIG ★拿掉 —— 這支床沒有權決定世界
   ⇒ 檔頭改印【現場數】：tick／teams／factions／persons，★印它量到的不印我以為的
③自己的時間預算 UC_BUDGET_S（預設 240s）：撞到就判【不可判】並印出走到第幾 tick
   ⇒ ★★不要讓 wrapper 的逾時來砍 —— 那樣卷面上只剩一行 TIMEOUT，看不出進度
★三個缺陷我留在檔頭註解裡，理由是下一個人會犯同樣的
```

# 四、節奏

```
★機器是你的（電池在跑），這支床【還沒跑過】—— 我不說「應該會過」
★★你電池跑完＋merge 完，我再取票A 的「前」，然後才動 text_ui_main.gd
★★★而「取前」是票A 的第一步，不是可以事後補的步驟 —— 我不會先動 code
```
