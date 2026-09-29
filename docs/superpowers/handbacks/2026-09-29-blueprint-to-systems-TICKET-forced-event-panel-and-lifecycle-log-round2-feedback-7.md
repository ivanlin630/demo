---
from: blueprint
to: systems
status: open
slice: 第二輪玩測回饋 #7（用戶 2026-09-29）：強制事件看不懂、按 1 一直排、按 T 出來變拒絕；UI 與終端 log 都不夠
topic: ★三件：①強制事件面板要用人話說【誰／要什麼／接受會發生什麼】（現況 mapper 只有「Team11 提議 alliance」這種半生字串，proposal id 原樣印）②回應入列後面板要鎖住並顯示「已排入回應：接受」，同一事件的重複回應去重（同 refresh_targets 那條）③強制事件生命週期三點（到達／玩家回應／逾時自動拒絕）全部進玩家事件流＋終端 print；★而「按 T 出來後變拒絕」的真因我【不下斷言】——要一支床走完「到達→入列接受→推進一小時→結果」，床會說是逾時競態、還是重複回應的「無待處理強制事件」被讀成拒絕、還是 _accept_diplomacy 回 ok=false
---

# 一、用戶逐字

```
「途中遇到team11 對我提強制事件 但我不知道是啥事件 但我能一直按1選接受 產很待辦代辦 不會跳離事件表單
  其次我按T跳出表單後 還是寫我拒絕事件
  UI跟CMD紀錄的log實在不夠多 像team11找我要幹嘛我UI看不到 至少終端LOG要記錄吧?」
```

# 二、我讀到的（file:line）

```
player_api_mapper.gd:300-311  message：diplomacy ⇒ 「Team%d 要求你納貢」或「Team%d 提議 %s」——★proposal 原樣（alliance/…），其餘型別有人話
text_ui_main.gd:1541-1544     互動清單印「⚠ <msg>：<label>」⇒ 玩家看到的就是「⚠ Team11 提議 alliance：✓ 接受」
text_ui_main.gd:1449-1460     按 1 ⇒ command_player("respond_to_forced") 入列；★面板不變、不鎖 ⇒ 每按一次多一道（用戶看到的「產很多待辦」）
sim_bridge.gd:322-323         同病：refresh_targets 每按 T 一道（#6 已裁去重，可比照）
sim_runner.gd:637-668         逾時：hour-tick 寫入、下一個 hour-tick 未回應即自動拒絕，print 只在終端
player_command_system.gd:933-  respond_to_forced：第二次以後回「無待處理強制事件」ok=false ⇒ 畫面印 ✗ 句
diplomatic_ai_system.gd:180   到達只有終端 print「Team%d 向玩家發起 %s → 寫入 forced_event」；★玩家事件流沒有（#4 的 emit 清單沒含它）
text_ui_main.gd:271-278       到達時 U19 自動 cancel_advance + 進互動模式 ⇒ 用戶會看到面板（這條活著）
```

# 三、裁（WHAT）

```
①面板三行人話：「Team11（<勢力名>，關係：<恩怨帳摘要>）向你提議<結盟／納貢／…>」「接受＝<後果一句：你加入他的勢力、每月納貢 N、…>」「不回應＝一小時後視同拒絕」。
   proposal id 全部要有中文表（跟 _forced_label 同一處維護，不另開表）；「不知道的 id」印「提議（未知：id）」不吞。
②按下回應 ⇒ 面板鎖成「已排入回應：接受（推進時生效）」，其他回應鍵無效；同一 interaction_id 的重複 respond 入列去重（入列時看佇列尾端同 id，不讀世界可當場做）。
③生命週期三點都進玩家事件流（#4 那條專用佇列，自家隊 self-knowledge）：到達「Team11 向你提議 X」／回應結果「你接受了 X：<後果>」或「你拒絕了」／逾時「你沒回應，Team11 視同被拒」。終端 print 三點齊（現況缺回應那一點）。
④「按 T 出來變拒絕」：★先量再修。床：到達→入列 accept→按 X 推進一小時→斷言事件流含「你接受了」且沒有「逾時」；再一格：入列 accept 三次→推進→只有一句接受、沒有 ✗ 句。床紅在哪，真因就在哪；我列的三個候選（逾時競態／重複回應的 ✗ 被讀成拒絕／_accept_diplomacy 回 false）床會挑一個。
```

# 四、序

```
排第二輪回饋第一張（它擋玩家理解每一個外交互動）。#2 故事結束仍在後面。
```
