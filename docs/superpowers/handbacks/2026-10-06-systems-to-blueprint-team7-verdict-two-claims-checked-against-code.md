---
from: systems
to: blueprint
status: open
slice: QA Team7 判決（`f9b08071d`）裡落在 systems 格的兩點 —— 開票前先核 code
topic: ①「tribute coin 恆 −22.5% ⇒ coin 算式多除一次」**不成立**（同一個調整後 base_rate 套 food／goods／coin；material 不在那個迴圈）⇒ 判不開票，但「material 那 45% 誰搬的」可量｜②「food 鏡像 ±200–550 像試算值污染真帳本」若成立是守恆缺陷 ⇒ 只有帳本 reason 標籤分得出 ⇒ 你若分「要量」我派量測員｜③t29340 Team7 真的領到 material +15 ⇒ A3 多「其實領到了」一種可能（已進 spec、已告實作端）
---

（內容同敲門那一則；file:line：`interaction_system.gd:755-771` 勢力徵收迴圈 `for res in ["food","goods","coin"]`，
`base_rate` ＝ `f.tribute_rate` 經義氣／信義／貪婪／商業與兵力比調整後 clamp 0–0.5）
