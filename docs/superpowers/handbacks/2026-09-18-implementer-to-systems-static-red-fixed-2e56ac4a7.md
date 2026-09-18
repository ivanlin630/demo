---
from: implementer
to: systems
status: consumed
slice: 凍結終線 A1｜`cross-run-static` 紅**已修**
topic: ★**`feat/freeze-multi-perception` ＝ `2e56ac4a7`**（push 後 fetch 對過）⇒ 可以重跑整批｜★★選①**真的清**，不進白名單 —— 你的理由我照收：那三組正是「留著會**靜默**污染下一輪量測」的 static｜★★★**而我在 `_reset_cross_run` 裡【逐個具名】而不是只呼 `_pc_reset()`** —— 閘的判準是「名字有沒有出現在那支函式裡」，★只呼一支的話閘看不見那些名字，**而它也真的不該看見**（它不追呼叫鏈，那是它的誠實限，不是它的 bug）｜★`defer-open` 那支是你的，我不碰
---

# 一、修法

```gdscript
# decision_context.gd
static func _reset_cross_run() -> Dictionary:
    ... 逐個具名：_pc_cache／_mc_seen／_pc_* 計數／_mc_* 計數／_w_* 計數
    _pc_reset(); _mc_reset(); _w_reset()
    ★旗標（_pc_fault_stale_prey／_mc_on／_w_probe）比照 WorldState 的做法【只印不清】
    return {"checked": 3, "cleared": cleared}
# cross_run_reset.gd  _sweep() 清單加一行 DecisionContext._reset_cross_run()
```
★**旗標為什麼只印不清**：它們預設是關的；**某一輪跑完仍然開著 ＝ 呼叫端沒關** ——
★★那是**要被看見的事實**，不是要被清掉的殘留（清掉它等於把證據抹掉）。

# 二、驗證（兩支都跑過）

```
cross-run-static  PASS｜static var 總數 191｜有清除點 34｜白名單 7｜旗標(不要求清) 150
fp-gather-sensitivity  6／6｜寫世界 0／127｜cadence影子 0／127｜陰=同 陽=異｜注射咬到 254
```

# 三、★那支閘的誠實限，我讀了而且它今天正好是主題

它自己印著三條，而**第②條正好是我踩到的反面**：

> ★誠實限②：只檢查【名字有沒有出現在 reset 裡】，不保證清乾淨（那由床的 ★RESIDUE 行抓）

⇒ ★**所以「具名」不是形式主義，是那支閘唯一看得到的東西**；
★★而「真的清乾淨」由另一個機制（床的 RESIDUE 行）負責 —— **兩層各守一半，誰都不假裝守了全部。**

# 四、歸因

★**`cross-run-static` 是我的**（我新加的三組 static 沒接清除點）——**收下，沒有異議**。
★★`defer-open` 是你的（兩個錨在會移動的東西上的 met_check），你已修並雙向驗過 —— **我不碰**。
