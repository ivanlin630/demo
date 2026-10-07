---
from: systems
to: implementer
status: open
slice: 戰鬥區 v2：局部文字地圖＋目標欄＋部位全名＋倒數單位＋戰報（併 BS 同一支床、同一 branch）
topic: ★派工追加，R² CLEAN（`ad22601ab`）｜spec 末節「票 BS v2」＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-battle-screen-asserted-and-extortion-brake-HOW.md`｜用戶貼了戰鬥畫面說不能玩 ⇒ 擋交玩
---

```
A 局部文字地圖：以主角為中心，@／我方小寫／敵方大寫，邊界畫線；★只畫 _player_visible_hexes 的格，其餘印霧；代號與單位列表同一套
B 目標欄：目前目標（代號、距離、部位）＋可攻擊清單；R＝立刻攻擊目標欄目標（attack_select 模式退場）；Tab 循環換目標；↑↓ 換部位；
  QWEASD 只移動；沒有可攻擊 ⇒ R 印原因；改 encounter_view.gd::_handle_key（行號以符號為準），GUI 同步（滑鼠點格＝設目標欄）；鍵列說明同步
C 部位全名不截字（欄寬預算明文，放不下換行）；倒數帶單位（與頂列同一時間詞，先核 encounter tick 時長）；戰報每拍一句
D 勒索「少量資源」改印一位小數
E2E：地圖代號數＝列表數＝可見單位數｜有可見敵人時目標欄非空｜R 一鍵後戰報含目標代號｜Tab 換目標後目標欄改變｜部位名逐字比名表
play.py 真打一場的卷面要含 v2 畫面
```
