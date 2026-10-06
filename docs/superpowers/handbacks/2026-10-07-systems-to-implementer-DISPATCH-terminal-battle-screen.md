---
from: systems
to: implementer
status: consumed
slice: 終端戰鬥區（GUI 戰鬥畫面的文字版＋戰鬥鍵送得進去）
topic: ★派工（插隊：試玩阻斷），R² CLEAN（`78468ac88`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-terminal-battle-screen-HOW.md`｜★票 T 做到乾淨點就先做本票｜走整份電池
---

```
①送鍵：PlayerRepl.press_on 分流——戰鬥中呼 encounter_view._handle_key(kc)，否則照舊主節點 _input；text_ui_main.gd:379 不動
②compose 戰鬥區：六欄直接讀 encounter_view 六個 Label 的 .text；單位列表（名、座標、血量、action_timer）；鍵提示＝_lbl_actions.text
③press_on 等待：戰鬥中等 encounter_view.is_waiting_for_player()（新公開查詢）或戰鬥結束
④Z 命令選單：項目印進戰鬥區、數字鍵轉 _on_command_selected（R² 核過 _open_sub_command 不開第二層彈窗）
⑤拿掉介面修正票的「交戰中：終端尚無戰鬥畫面」那句；KNOWN K4／K5 刪
P1 E2E 主動攻擊打完｜P2 E2E 被伏擊打完＋往邊界外撤出｜P3 六欄逐字＝Label.text｜P4 無作用鍵印為什麼｜P5 action_timer 可見且會變
P6 非戰鬥照舊｜P7 已知紅下降、清單「遭遇戰卡住」標已修｜P8 fp 量｜P10b 模擬引擎廣播一次按鍵 ⇒ _handle_key 只被呼一次
★交件 topic 寫已知紅數（攻擊兩條清掉後應剩打聽兩條）
```
