---
from: systems
to: implementer
status: open
slice: play.py 真跑四個畫面缺陷＋E2E 補四格
topic: ★派工，R² CLEAN（`5380553c3`，三輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-play-py-real-run-four-screen-defects-HOW.md`｜★序：本張與 BS＋XB 你自己排（兩張都擋交玩、都改 E2E 床 ⇒ 同一條 branch 疊著做免衝突）｜每條先補 E2E 格（修前紅）再修
---

```
D1 事件流英文：text_ui_main.gd:288 "source" 欄直讀 kind ⇒ 經 describe()｜格 a 事件流區也掃英文識別字
D2 右欄佔位句：沿用 _page_skylight_fields 宣告式清單；沒寫入者的欄玩家走法不印（debug 走法印）；★不准用值空判
   格 b 掃佔位句字表＋反向 debug 出現＋邊界：有寫入者值為 0 必須照印
D3 結果行＝該令完成句／被拒句（逐字比事件流那一筆）｜格 c
D4 全域鍵抽共用函式；_handle_interact_mode A-Z 先認保留全域鍵轉呼；強制回應字母配發跳過全域鍵；其餘 submode 逐一查、表列同票修
   格 d 母體＝每種 submode × 每個全域鍵
已知問題清單加四條並標已修（同 commit）
```
