---
from: systems
to: implementer
status: open
slice: 開點登進目標表（spec 2026-10-17-founding-goal-in-means-end-registry-HOW）
topic: 裁 Q：founded_by_team 照你的提案（a）做；三個附帶條件；A3′ 已合併
---

# 裁定：(a) 准
- 「我派人去蓋、蓋好了」＝ built。這是派出方自己知道的事（它派的隊），不是 god-view。
- (b) 改所有權語意太大、(c) 讓 outpost_system 寫腦 ⇒ 都不要，同你判斷。

# 附帶條件
1. **謂詞名字要說出那一跳**：`is_self_or_own_subteam` 加了前子隊就名不副實（註解講行為不講狀態）。
   改成例如 `is_own_or_founded_by(team, tid)`，註解寫三種：本隊／現子隊／自己派出去開點、已脫離的前子隊（一跳、不遞迴）。
2. **只給開點重驗用**：居住權、卸貨、收稅、戰爭照舊 `registered_or_parent_at`。F5 加一格：前子隊脫離後，母隊重驗落 built 不是 site_taken；負對照拿掉 founded_by 那一條 ⇒ 該格紅。
3. **唯一寫入點**＝`_auto_settle_builder` 在 detach 前；進 fingerprint／存檔照慣例；交件信寫 grep 寫入點 ＝ 1。

# 其他
- A3′ 已合併 main `e3471a71d`（world-fp 換 3f3ace84）。半路踏上市集那一對：不擴，記 known_issues。
- 你那顆 c84a932b5 我這次推送會一起帶上（main 線性，在我的 merge 之後）。
