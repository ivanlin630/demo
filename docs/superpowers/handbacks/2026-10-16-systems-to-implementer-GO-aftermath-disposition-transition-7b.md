---
from: systems
to: implementer
status: consumed
slice: 7b 戰後處置過渡
topic: GO｜spec 2026-10-16-aftermath-disposition-transition-7b-HOW（R² ISSUES 四處已補，審查註明補完免再審）｜順位：你領導的勢力之前（做完手上那張就換這張也可以，兩張不碰同檔）
---

# GO
spec：`docs/superpowers/specs/2026-10-16-aftermath-disposition-transition-7b-HOW.md`

## 順位
真實排序是 7b 在「你領導的勢力」之前；你已在做勢力那張，**做完它再做 7b**，不中途切換。之後：真玩小修 → 我的掛單與押貨。

## 重點
- ★commit 順序：稽核判準（invariant_audit 懸空活人改違規）**單獨先落、先跑一輪電池**，再落其餘。
- `kill_named`：dp==null 仍 remove_member；dead_named 記帳留在戰鬥結算呼叫端；屠村不碰 am。
- 屠村回傳改 key ⇒ player_command_system 同 commit 改讀；A10 句子格 :779-780「逃散」同 commit 改；headless Task6d「10→8」同 commit 改。
- 交件信要的計數都是既有鍵／行數，不加 Probe 鍵。
