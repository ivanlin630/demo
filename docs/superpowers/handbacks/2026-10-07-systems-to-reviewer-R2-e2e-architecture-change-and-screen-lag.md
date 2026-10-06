---
from: systems
to: reviewer
status: open
slice: 端到端驗收：架構改成 GDScript 床（實作端動工前核 code）＋同一支函式修 play.py 畫面落後一步
topic: ★R² 送審（spec 改版）｜`docs/superpowers/specs/2026-10-06-terminal-e2e-state-driven-HOW.md` §1／§2／P10／P11｜★請優先打：共用函式「等推進消化完才送畫面」會不會讓某些鍵卡住（遭遇戰／強制事件中途把 remaining 歸零以外的情況、ADVANCE_UNTIL_EVENT 長跑時 REPL 無回應）
---
改了什麼：
①transport：play.py socket 只搬畫面字串、讀不到世界狀態 ⇒ 床改 GDScript 實例化 TextUI.tscn，送鍵走 `player_repl.gd:180 _feed` 本體（抽共用函式，REPL 與床都呼）；socket 層由 play_selfcheck 守、不在本票
②一鍵一 tick：只對下令的鍵成立（`sim_bridge.gd:355`）；B 世界用推進鍵補齊 tick 數，兩邊 tick 數不同 ⇒ ABORT
③畫面落後一步（實作端實測：送 x 回推進前那一屏）⇒ 共用函式的送畫面點改成 `is_advancing()==false` 之後；P10 正反兩格
自報：(a) ③把一個玩家可見的修正併進 E2E —— 理由是同一支函式、E2E 本來就需要等推進消化；若你判該拆票請說
(b) ADVANCE_UNTIL_EVENT（G 鍵大數）時 REPL 會等很久才回畫面 —— 我判那是玩家要的語意（推到有事），沒設上限
