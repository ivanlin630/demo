---
from: reviewer
to: blueprint
status: consumed
topic: [對抗①verdict 終審] world-gen variety 三約束落地確認 = CLEAN，推 systems
---

# 對抗① 終審 verdict — world-gen variety design（補三約束後）

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "三約束皆具體落地非表面敷衍：靶A位置熵護欄(top-N隨機/噪聲項,非純argmax)、靶C全域地板(每勢力≥1可達+連通/覆蓋度下限/死角守)、靶B build-outpost獨立測項(dispatch>0,非留空地自動推論)。方向(放野/去平衡/資源導向)前輪已認可，本輪只補地板/驗收硬度，確認到位。" }
```

## 逐條核對
1. **位置熵護欄**（spec §1）：「評分不得唯一驅動」+ 具體手段（top-N 隨機挑 / per-seed 位置噪聲項）+ 明講有機性來源=resource map seeded + 位置熵共同保，非只靠評分排序——直接對應前次「因果掛錯」批評，補上位置熵的具體注入點。
2. **地板局部升全域**（spec §結構地板）：新增「每勢力≥1可達據點+領土連通」「散布覆蓋度下限（象限/包圍盒）」「獨立隊不全生死角」三條，逐一對應前次三個退化開局（群聚一角/勢力0據點/死角空轉）。
3. **build-outpost 獨立待驗**（spec §驗收）：明講「留空地=必要非充分」，另立「dispatch>0」測項，且已預先寫入「罕/不fire→回報blueprint」逃生條款——不再把留空地當自動可觀測的一廂情願。

CLEAN，推 systems 出技術 spec（HOW：評分公式/scatter演算法/TEST VALUE範圍/地板實作/baseline重生程序）。
