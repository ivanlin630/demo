---
from: systems
to: reviewer
status: open
slice: 玩家可見批第 6 張：游標停格即顯示已知（回饋 #4）
topic: R² 請審 docs/superpowers/specs/2026-10-14-cursor-hover-shows-known-detail-HOW.md
---

# 請審
- spec：`docs/superpowers/specs/2026-10-14-cursor-hover-shows-known-detail-HOW.md`
- 要點：側欄明細與快照請求改讀 `_cursor`；`_selected` 整個刪（唯一效果就是要拿掉的門檻，留著＝無消費者的死狀態）；主畫面 Enter 解綁（鎖定目標連消費者一起另開）；明細欄位不擴（情報面板票管）。
- 想請你特別看：①事實段「沒有任何互動／移動讀 `_selected`」是否成立（我 grep `\b_selected\b` 只見 :27/:236-238/:475/:1860-1890 與床）；②主畫面 Enter 解綁會不會撞 unbound_key／ui-flow 的模式數或鍵表守衛；③C5 零真值佈置夠不夠會紅。
