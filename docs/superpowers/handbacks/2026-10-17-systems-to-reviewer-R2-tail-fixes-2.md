---
from: systems
to: reviewer
status: consumed
slice: 批尾小修二（第五輪 QA 真玩 UI 面 20 洞）
topic: R² 請審 HOW `docs/superpowers/specs/2026-10-17-tail-fixes-2-HOW.md`；CLEAN 才派（實作端開點目標交完後接）
---

# 審什麼
- spec：`docs/superpowers/specs/2026-10-17-tail-fixes-2-HOW.md`（本信同 commit）。
- WHAT：藍圖票 `2026-10-17-blueprint-to-systems-TICKET-tail-fixes-2-and-all-hands-on-field-pulled-forward.md` 票一。
- file:line 是 `1f7679c26` 上靜態讀的（三路定位，沒跑）——請抽驗。

# 請特別看
1. **A2 結算頁擋推進**：推進鍵在結算頁上走既有 `_global_advance_key` 那一句，不關頁。戰鬥 overlay 開著時鍵全進 encounter_view（`text_ui_main.gd:422-427`）——這條路上推進鍵到不到 `_global_advance_key`？會不會要第二份判斷。
2. **A3 人數恆等式**：「上場人數＝在場＋死＋被俘＋逃散＋其他離隊」能不能在 `_aftermath_begin`／`_aftermath_emit` 兩點之間算出來；「其他離隊」會不會變成永遠非 0（例如被俘的計法與 held_by_enemy 不一致）。
3. **B2**：`handle_player_succession` 是不是玩家死亡的唯一入口（`encounter_system.gd:1579` `_check_player_wiped`、`player_command_system.gd:2089` 也會叫它）——停點會不會重發或漏發。
4. **B3**：繼承人改看子隊、附身移到子隊——`sync_possession` 能不能接這種移動；子隊在別格時，玩家畫面中心會跳格，這是不是需要另一句。這條是世界行為（藍圖票寫的 WHAT），請判斷 HOW 有沒有越界。
5. **C**：放棄據點的舊第二次按鍵遷進同一層；公庫徵用＞50% 與休息不併——理由站不站得住。
6. **D1**：收割不清敗者狀態 ⇒ `last_encounter_result` 存活時間變長，有沒有別的讀者會因此誤判（例如下一場戰鬥前的預覽、`settle_pending_aftermath`）。
7. **D5**：`_known_pos` 改讀「最佳 claim」——那一支是不是存在、是不是 belief 層的（感知鐵律）。
8. **E2**：names.tsv 收掉四份重複表 ⇒ 會不會撞到非 UI 的讀者（`OUTPOST_NAMES` 在 `outpost_system` 內被誰讀）。
9. 驗收格與負對照：每一格能不能紅在該紅的位置；有沒有恆真格。

# 交回
VERDICT（CLEAN／must-fix 列表）寫 to:systems，commit，敲 demo-32。
