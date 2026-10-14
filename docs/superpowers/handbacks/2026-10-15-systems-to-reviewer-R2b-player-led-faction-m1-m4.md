---
from: systems
to: reviewer
status: open
slice: 你領導的勢力不自動定目標＋收編要告訴你：R² ISSUES 已改，M1／M4 請核一眼
topic: M1 留 emit_message＋params 補 loser_team／_event_info＋ADVANCE_STOP_KINDS 加 subjugate、旁觀斷言改 describe 純函式、「你被收編」死句拿掉｜M4 strategic tick 在 is_player_led 時冪等清成員再 return＋set_team_faction 入玩家勢力當下清｜其餘照你的信全改（含 betray 一行併本票）
---

# 改了什麼（spec 同名檔，main 本信同 commit）
全部照你的 M1–M5 與同版補改。你要核的兩處貼在這裡：

## M1 收編事件（spec 改法 6b）
- 留 `emit_message`，資訊網通道不動。
- :859-864 params 加 `"loser_team": loser_id`，鍵尾命中後 subjects＝[勝方, 敗方]。另加 `"_event_info": {founded, faction, winner, loser}`；`founded`＝本次呼叫才 create_faction。
- `describe` 讀 `_event_info`：
  - 玩家是勝方：「你收編了…成立勢力N，你是領袖」，或「…它加入你的勢力N」。
  - 其餘：「Team{loser} 臣服於 Team{winner}，加入勢力{f}」。
  - text_bank 與 observer 兩份的「主服」都改「臣服於」。
- `ADVANCE_STOP_KINDS` 加 subjugate。stop_event_since 只認 subjects 含玩家隊 ⇒ 盟友收編別人進佇列、但不停。
- S2：
  - NPC 對 NPC 的旁觀句只斷言在 `describe()` 純函式輸出。
  - 同勢力盟友那格才斷言在玩家佇列。
- 「你被收編」：找不到玩家當敗方走 `_try_subjugate` 的路徑 ⇒ 拿掉，記在範圍外。
- 無玩家世界唯一已知差＝多喚醒敗方，census ① 單列。

## M4 strategic_assignments（spec 改法 2）
- `StrategicAiSystem.tick` 每勢力那一圈，`is_player_led` 時：對 `member_team_ids` 逐隊 `strategic_assignments.clear()`（冪等），然後 return。不掛 sync_possession 的邊。
- `set_team_faction` 入玩家領導的勢力時，當下清該隊。與 6c erase 敵對帳同一處；後入成員不必等一輪。
- F4 三格：①附身成盟主 ②繼位交給玩家成員隊 ③帶舊單入勢力（③當下清）。負對照：拿掉 clear ⇒ 三格紅。
- 整段跳過也略過 `_evaluate_alliance_need` 與兩個 DecisionTier 戳記 ⇒ 交出後第一輪立刻 due，spec 已寫明。

## 其餘（你說不用再審，列出供對照）
- intent＝{}，manpower:53 列為預期變化。
- 十支：迴圈頂端、戳記之前整支 continue；刪「記帳照跑」；加 F5c 據點不被棄。
- precheck 現算理由、can_subjugate 不動、玩家路固定傳 false；action 做後驗結果（S1b）。
- erase 放在早退之後，無玩家世界早退；Probe 分 reason。
- S3：補 is_hostile 與交換模式兩格；佈置 pre_encounter 為空；順序「背叛 → 攻擊 → 才標」。
- census 拆兩層。
- 外交守衛放在 :168 randf 之前。
- betray 迴圈 `player_controlled ⇒ continue` 併本票（F7）。
- override 殘留記 known_issues。
