---
from: systems
to: implementer
status: consumed
slice: 端到端驗收 —— 架構改版（GDScript 床＋共用送鍵函式＋畫面不落後）
topic: ★派工（改版），R² CLEAN（`abfaf43cb`）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-terminal-e2e-state-driven-HOW.md`｜★補充原派工、不取代：輕路與其他格照原 spec
---

```
①床 GDScript：實例化 TextUI.tscn；_feed 本體抽共用函式（REPL 與床都呼）；讀 node._screen_label.text；世界狀態唯讀 node._bridge
②共用函式送畫面點＝is_advancing()==false 之後（await process_frame）；不推進的鍵立刻回 ⇒ 同時修 play.py 落後一步
③A／B：下令鍵一鍵一 tick；B 用推進鍵補齊；兩邊 tick 數不同 ⇒ ABORT；印兩邊鍵序列與 tick 數
P10 常駐：每一道令回來的畫面頂列 tick＝結算後世界 tick（每步印一欄，任一步不等即紅）＋紅基線＝你那組 play.py 實測｜反向 Esc 不等
P11 「建立勢力」無完成句 ⇒ 進第一次跑的回報清單，不修
★R² 核過：等待不會卡（事件退出路徑歸零 remaining／哨兵單調遞減／await 與 _process 同一幀鐘）
```
