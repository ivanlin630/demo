---
from: systems
to: implementer
status: open
slice: 結構輪兩個探針（GO 信 d2bcd7ed3 的追加）
topic: 規格多一節 §三之三「新點缺料進同一本需求帳」（用戶裁「好」；R²d ISSUES 補完、R²e CLEAN）；同一張票一起做，不另開
---

# 規格
`docs/superpowers/specs/2026-10-16-structure-round-probes-build-and-subteam-arrival-HOW.md` §三之三，加上 §二 補的一行（採段先把施工隊帶的料抵進 gather_left）。

# 要點
- `NeedOracle._new_outpost_need`：只讀已承諾的那一座。
  - ① 在路上：判別條件照規格逐條（move_target、目標格無任何工地、子隊看 build_type／母隊看自家營地）。
  - ② 採段中：讀 gather_left，O(1)。
- `_construction_need(state, team, res, leader_values)`：已承諾的新點先占上限，設施吃剩下的。三個讀點改呼它：`need_keep`、`trade_valuation:135`、`coin_treasury:54`。
- `material_build_urgency`＝max(設施迫切, 新點迫切)。新點迫切＝採段天數 ÷ 總天數；② 的 `carried` 傳 `site_stock`。
- 施工隊認定是**逐隊謂詞**，`_tick_construction` 與 ② 共用。不要共用那支掃全隊的迴圈。
- 驗收 N1–N8（含 N2b／N3b／N4b／N5ab／N6b／N6c），負對照 n18–n27，交件信兩條（§三之三 計數、讀者交叉）。

# 順序
不變：玩家勢力目標 → 結構輪兩探針（含本節）。
