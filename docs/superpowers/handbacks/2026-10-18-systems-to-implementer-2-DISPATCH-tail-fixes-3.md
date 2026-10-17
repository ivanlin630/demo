---
from: systems
to: implementer-2
status: open
slice: 批尾小修三（第二線；跳窗報價交件之後接）
topic: 派件：HOW `docs/superpowers/specs/2026-10-18-tail-fixes-3-HOW.md`（R²b CLEAN＋C1–C4 已併）；建在小修二 A1／A3／D6／E1／E2／E8 上
---

# 什麼時候
- 第二線順序：批尾小修二 → 跳窗報價 → **本張**。
- 依賴小修二（A1 結算句、A3 六欄、D6、E1 結果行、E2 名稱表、E8 情報來源）——小修二合併後從 origin/main 開 `feat/tail-fixes-3`。file:line 是 main `0699350dd` 讀的，動工前重對。

# 跟第一線撞的地方
- 第一線（全員在場）會刪 `_apply_reserve_casualty`、加 `anon_armed_count`。
  - ★N14 的 `armed_breakdown`：誰後合併誰接——全員在場先進 ⇒ 你寫 `armed_breakdown` 時匿名那一項直接呼 `anon_armed_count`；你先進 ⇒ 全員在場那邊改呼（它的派件信已寫）。
  - §三一次性回放的前提「後備陣亡 >0」：全員在場已合併 ⇒ 標「不適用」，不算紅（spec 已寫）。
- `encounter_view`：★N11（結果行）、★N13（單位名字）與全員在場 §五（頂列場上／場外）不同函式，但同檔；後合併的 merge origin/main 解衝突。

# 實作提醒（R²b）
- 讓位判準＝「同一件事已有另一個產生者會對玩家發句」；T7 每列三種角色各一格。
- `betrayed` 在 `_feed_player` 過濾，不動 emit，驗 `pending_rethink` 仍設。
- 停點拆兩個 kind（`faction_member_revolted` 停、`faction_member_left` 不停）。
- 1e：缺項清單先寫進交件信再固化；缺項 0 ⇒ 1e 結案、T3／n2 刪。

# 交回
DONE 寫 to:systems（檔名 `…-implementer-2-to-systems-…`），commit，敲 demo-32。
