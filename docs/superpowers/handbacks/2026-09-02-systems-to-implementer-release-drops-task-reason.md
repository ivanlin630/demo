---
from: systems
to: implementer
status: open
slice: release() 漏清 task_reason（★小刀，但它讓一整欄量測不可信）
topic: ★TaskArbiter.release() 清了 current_task/move_target/task_priority/flee_from_pos,★★唯獨漏 task_reason ⇒ idle+prio0 的隊身上那個 reason 是【上一個任務的殘留】;★★★而同一支裡 flee_from_pos 那行的註解就寫著「避 stale 殘留」——紀律存在,只是漏了一個欄位;★量測後果:床的 reason 欄整欄不可當證據(我今天差點拿它當「引擎想求生」的證據)
---

# ★①事實（file:line）
```
task_arbiter.gd:176-179  release():
    team.current_task  = TASK_IDLE
    team.move_target   = Vector2i(-1, -1)
    team.task_priority = 0
    team.flee_from_pos = Vector2i(-1, -1)   # ★註解原文：「flee 位移根治：清逃離位（避 stale 殘留）」
  ★★而 task_reason 【沒有被清】
```
⇒ ★**紀律是存在的**（`flee_from_pos` 那行就是為了防 stale 殘留而加的）—— ★★**只是漏了一個欄位。**

# ★★②量測後果（★這才是我把它當一票發出來的理由）
```
measurer 的逐隊明細：team 213/219 都是 task=idle、prio=0、★reason=survival
★★我差一點拿那個 reason 當成「引擎現在想求生卻沒派出去」的證據
⇒ ★★★而它其實是【上一個任務的殘留】—— ★整欄不可當證據
```
★**#10 本身不受影響**：它的判準是 `would_dispatch + finder_hits + task==idle`，**不含 reason**。

# ★③要做的（★小，但請照 stale 紀律做完整）
```
①★release() 補清 task_reason（★★清成 "" 還是 "released"，你選——
   ★★★但若選 ""，要確認沒有消費端把 "" 當成別的意思）
②★★同一支裡【還有沒有別的欄位漏清】：請你逐欄看一遍 TeamData 上「屬於當前任務」的欄位
   —— ★我只查了 task_reason 與 survival_committed_option 兩個，★★其餘我沒看
③★★★survival_committed_option 【不要動】：release() 不清它【可能是設計如此】（承諾 ≠ 任務），
   我已送 blueprint 裁 —— ★在他回覆之前那是 WHAT，不是漏
```
★**驗收**：`fp` 會變（清了一個欄位）⇒ 差在哪要說得出來；★★並印出「release 時 task_reason 非空的次數」——
**它現在應該非 0（證明真的有殘留），修完之後這個數本身不變，變的是殘留不再被下游讀到。**
