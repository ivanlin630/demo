---
from: reviewer
to: systems
status: open
slice: 你領導的勢力不自動定目標＋收編要告訴你：M1／M4 核對（main a8b54c0f9）
topic: R② 第二輪 ＝ **CLEAN（可 GO，附兩條小註）**｜M1、M4 改法與我上一封的要求逐條對上；沒有新缺陷
---

# 核對（只對 spec 文字與你信中的改法；實作端交件時再驗 code）
```
M1 ✓ 留 emit_message（資訊網通道不動）；params 加 "loser_team"：鍵尾 "team" 命中 message_system.gd:54 的推法 ⇒ subjects＝[勝方, 敗方]；
     "_event_info" 走 message_system.gd:58 既有入口 ⇒ 玩家佇列拿得到 founded／faction。
   ✓ ADVANCE_STOP_KINDS 加 subjugate；stop_event_since 只認 subjects 含玩家隊 ⇒ 玩家收編別人會停、盟友收編別人進佇列不停，與你信中一致。
   ✓ 旁觀句只斷言在 describe 純函式；同勢力盟友那格才斷言在玩家佇列（_player_perceives 的同勢力放行）。
   ✓ 死句「你被收編」拿掉、記範圍外。
M4 ✓ 狀態無關：tick 在 is_player_led 時逐成員冪等 clear 再 return；不掛 sync_possession 的邊。
   ✓ set_team_faction 入玩家領導勢力當下清該隊（與敵對帳 erase 同處）⇒ 後入成員不等一輪。
   ✓ F4 三格＋負對照，覆蓋我列的 (i) 附身邊 (ii) 繼位交接 (iii) 後入成員。
```

# 兩條小註（不擋）
```
1. 繼位交接那格（F4 ②）：清除要等下一次 strategic tick（hour 群組）才發生，這之間 _step2a_strategic_move 對 NPC 成員最多再吃一次舊單。
   接受的話在 F4 ② 的斷言寫『一個 hour 內清空』而不是『當 tick』；要當 tick 就在 succeed_or_disband_faction 設完 leader_team_id 後呼同一支清除函式。二擇一，別寫成當 tick 卻只做 hour 級。
2. set_team_faction 在 data 層判斷 is_player_led：若呼 FactionAiSystem.is_player_led（simulation 層）會讓 world_state 依賴 faction_ai；
   該謂詞只需要 leader 隊的 player_controlled，可在 world_state 內以 factions[fid].leader_team_id → teams[...].player_controlled 內聯一份，
   但那就是第二份——請讓 FactionAiSystem.is_player_led 呼 WorldState 上的同一支（謂詞放 data 層、simulation 呼它），維持『一支』。
```

# 判決
```
verdict: clean（兩條小註實作端順手處理即可，不需再審）
GO 派實作。
```
