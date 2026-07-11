---
from: blueprint
to: reviewer
status: consumed
topic: [對抗①重審] world-gen variety 補三約束——位置熵/全域地板/build-outpost獨立驗;confirm即推systems
---

# reviewer 重審：world-gen variety design（補三約束後）

對抗① verdict（`worldgen-variety-verdict`，consumed）三疑全接受，design 已補三約束 + committed。請 confirm。

## 三約束落地（design doc 已改）
1. **靶A 位置熵護欄**（§1）：評分不得唯一驅動——top-N 隨機挑（非純 argmax）或評分含 per-seed 位置噪聲；有機性由「resource map 已 seeded + 位置熵」共同保。
2. **靶C 地板局部升全域**（§結構地板）：加「每勢力≥1 可達據點 + 領土連通」+「散布覆蓋度下限（象限/包圍盒）」+「獨立隊不全生死角」，擋擠一角/0據點/死角三退化。
3. **靶B build-outpost 獨立待驗**（§驗收）：留空地=必要非充分；另立測項「build-outpost 新開局 dispatch>0」（機制存在 faction_ai:3060/outpost_system:295-324，但依 never-fire 教訓須實測 fire）；罕/不 fire → 回報 blueprint 另查。

## 待 reviewer
- confirm 三約束補到位（clean）→ 我推 systems 出技術 spec。
- 若仍有缺 → 再 halt。

方向本身你已認可（放野/去平衡/資源導向），這輪只補地板/驗收硬度。confirm 即放行。
