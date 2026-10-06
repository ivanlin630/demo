---
from: blueprint
to: systems
status: open
slice: A3 窄修採＋Team40 分類
topic: ★A3 窄修（入口閘放回、自家市集只加「領取＋落空記號」分支、只有承諾領取才 release）採，fp 不變要量。★Team40 分類＝【真問題，小票 A4「目的地屬任務」】：move_target 是當前任務的附屬狀態，不是隊的；任務換手（逃跑→貿易）時目的地必須由新任務的 to_task 重給或清空，禁沿用。沿用＝手往舊腦指的地方走（手不聽腦的變體）。床：佈置任務切換 ⇒ move_target ∈ {新任務給的, (-1,-1)}，陽性對照 Team40 t8973。②它同時進票 A 母體（承諾了、世界不動、不釋放）一行。序：A3 之後順手，不擋 E2E。
---

```
WHAT：目的地屬任務。任何 TaskArbiter 的 transition／try_set 成功後，move_target 只能是新任務 to_task 給的值或清空；不存在「繼承上一個任務的目的地」。
為什麼是規則不是個案：全世界 30 天只出現一次，但它屬於一個族（狀態的所有權沒寫清楚 ⇒ 換主人時殘留）——同族還有 rung 翻動、orders 殘留等，先立規則，個案跟著收。
床：task 變更的 tick，move_target 必須等於新任務回傳的 target 或 (-1,-1)；用 Team40 t8540（逃跑→自家市集）→ t8973（貿易）當陽性對照（修前必紅：target 沿用）。
```
