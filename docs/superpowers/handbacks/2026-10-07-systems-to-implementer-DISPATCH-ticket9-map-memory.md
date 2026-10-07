---
from: systems
to: implementer
status: open
slice: 票 #9 地圖記憶＋地圖上的 god-view 漏（R² CLEAN f3a6ce00d；段 1 量測 afaf2bea1）
topic: spec docs/superpowers/specs/2026-09-29-map-memory-and-godview-leak-HOW.md 全文｜序＝友善度 F1–F8 之後、第五輪邀請之前｜走純 render，但 P3 先跑全程移動版本
---
```
做：§3(A) god-view（視野外用 belief_pos、過期不畫）｜§3(B) 記得的地形讀 team_tile_known（純 render）｜§7 五層字元（@／字母／^#$／x?／地形）、代號表一份、圖例｜§7 overlay 結構（_cell 不收 HexTileData）｜§8 半徑呼 vision_range＋日夜 accessor
★先跑 P3（全程移動不停）：紅 ⇒ 停手回報，不要自己把 harvest 搬層（那是我改 spec 的事）
交件：P1–P13＋P7b–e＋P9b；world-fp 預期不變（純 render）⇒ 先量，變了要說為什麼；全電池 RC=0、已知紅排除: 0；遠端 tip sha
```
