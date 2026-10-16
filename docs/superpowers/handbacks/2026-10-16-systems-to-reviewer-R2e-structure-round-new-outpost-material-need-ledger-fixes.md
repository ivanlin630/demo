---
from: systems
to: reviewer
status: open
slice: 結構輪探針 §三之三 新點缺料進同一本需求帳
topic: R²d M9–M13＋小項已補；M9／M10 改了語意，請再看 §三之三 diff 一次
---

# 怎麼補的
- **M9**：① 改成全部成立才算：
  - `TASK_BUILD`；
  - `move_target` 不是 (-1,-1)，也不是腳下；
  - 目標格 `outpost_level == 0` 且 `construction_team_id == -1`；
  - 承諾來源：子隊看 `task_extra_data.build_type`；母隊看目標格是自己的營地（`camp_team_id`、`camp_level == 1`，同 :7300）。
  - type／level 各讀哪一欄已寫明。驗收補 N2b（三種不是 ① 的 TASK_BUILD），負對照補 n23。
- **M10**：② 的迫切照 §三 進行中工地的既有規則，`carried` 傳 `site_stock`（＝need − gather_left），不另加參數。驗收補 N6b，負對照補 n24。
- **M11**：現況段補上五個讀者與預期效果，並說明 labor 不扣持有照留。驗收補 N8（承諾不被自己的需求換掉）。交件信補兩項：讀者交叉數、labor 權重修前修後。
- **M12**：
  - ② 改成 O(1)：子隊讀 `tile_pos`，母隊讀 `corvee_site`。
  - 「施工隊」的認定與 `_tick_construction` 的 `active_team` 同一支，抽出來兩邊都呼。
  - 吃料者＝`active_team`，接手的工人也吃。
  - 驗收補 N4b（走 InvariantAudit），N4 也改走 InvariantAudit；負對照補 n25。
- **M13**：N5 拆成兩格：(a) 斷言 reserve 的值；(b) 隊暫離 TASK_BUILD 時的賣盤。n21 對準 (a)(b)。現況段改正：施工隊的賣盤整段跳過、不呼 reserve。

# 小項
- **上限**：已承諾的新點先占，設施吃剩下的。驗收補 N6c（80＋80 ⇒ 新點 80、設施 20），負對照補 n26。
- **`coin_treasury.gd:54`**：改讀 `_construction_need`（同一本帳，要買新點料的隊也替買料留錢）。
- **`"for"` 鍵**：實作端確認 `_sync_board`／存檔不受影響，交件信寫一句。
- **Probe 計數**：N1／N3 斷言 `need.new_outpost.walk`／`.gather` > 0。
