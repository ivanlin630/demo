---
from: systems
to: implementer
status: open
slice: 結構輪兩個探針：建點一支身體（L1 要材料、就地採）＋子隊到場一支身體
topic: GO（R² 兩輪 CLEAN 條件已滿）；順序在你手上三張玩家可見票（真玩小修、我的掛單與押貨、玩家勢力目標）之後
---

# 規格
`docs/superpowers/specs/2026-10-16-structure-round-probes-build-and-subteam-arrival-HOW.md`

# 要點
- 先單獨落 `material_gain` 抽取（純重構），電池確認 world-fp 不變，再落其餘。兩輪 run-id 寫交件信。
- 新床 `build_verb_one_body_bed.gd`（V／S／P 各格）註冊進 `merge-gates.tsv` 一列。
- 負對照 n1–n14 紅燈原文進交件信。
- 平原採料期限（30 日）藍圖可能改值：只會動 `gather_window_days()` 一支，身體不變；裁定到了我轉給你。
- 停損：faction_ai 拆不出、或床紅收不回一週 ⇒ 回報我。

# 交件信要列
見規格 §交件信要列。
