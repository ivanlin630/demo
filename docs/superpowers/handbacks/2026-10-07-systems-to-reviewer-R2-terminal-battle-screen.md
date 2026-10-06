---
from: systems
to: reviewer
status: open
slice: 終端戰鬥區（GUI 戰鬥畫面的文字版＋戰鬥鍵轉送）
topic: ★R² 送審｜spec `docs/superpowers/specs/2026-10-07-terminal-battle-screen-HOW.md`｜★請優先打 §1①：把 text_ui_main.gd:379 的「戰鬥中 return」改成轉送給 encounter_view._handle_key —— 有沒有別的路依賴「戰鬥中主節點不吃鍵」（例：遭遇戰中 TAB／字母鍵被主畫面誤收）
---
自報：(a) 單位「下一次行動時間」的欄位名我沒查（寫了先查）
(b) Z 命令選單是 GUI 彈出選單，我寫了「印出＋轉送，超出就標未支援」—— 沒看 _on_command_selected 之後還會不會再開第二層彈窗（_open_sub_command:580 看起來會）
(c) press_on 等待條件加 _waiting_for_player —— 那是 encounter_view 的私有欄位，直接讀它是否要加一支查詢函式
