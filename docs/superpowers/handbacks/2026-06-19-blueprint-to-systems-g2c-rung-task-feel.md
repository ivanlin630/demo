---
from: blueprint
to: systems
status: consumed
topic: G2c rung→task feel 映射（藍圖 feel，G2c 開時消費）
consumed_note: feel 表已落 G2c plan(rung_task 映射既有 TASK_*+ambient PRIO_AMBIENT+prosperity 對齊武力擴張)。生存復用 _trigger_survival、脫軌(G2d)/威脅/生存壓過 ambient。立國/稱霸細節+商業遠程(依G1)+外交徵收 = 後續 refinement。
---

# G2c：階梯 rung × archetype → task/tag feel 映射

回應 g2-how-done「rung→行為 feel 留藍圖」。此為 feel 初稿，G2c 實作時消費。全用**既有** TASK_*/faction.goals tag，**零新 task**。

## 映射表

| 階 | 武力(野心/好戰) | 商業(貪婪) | 定居/治理(義氣/慎重) |
|---|---|---|---|
| **生存** | **搶**：LOOT/勒索/劫掠 · FLEE | **變現**：賤賣家當/乞食/barter · 投靠求庇主 | **熬**：forage/hunt/camp · 投靠聚落 |
| **積累** | TRAIN · LOOT(劫掠囤力) · recruit_anon → 囤**戰力** | TRADE · PRODUCE/MANUFACTURE(造貨賣) → 囤**錢/貨** | PRODUCE(農) · BUILD(基礎設施) · SETTLE · breed → 囤**人/糧** |
| **擴張** | ATTACK(征服) · LOOT · subjugate 弱隊 → 搶**地盤** | 派商隊跑商路 · 遠程 TRADE · 履約訂單(G1) · 設貿易據點 → 拓**市場** | BUILD/SETTLE 新拓殖 · 招民/吸收人口 → 拓**聚落** |
| **立國** | 立國 goal · 徵收(TRIBUTE) · 武力治理 | 行會/商業城邦 · 控商路 · 徵商路通行費 | 領地/治理城邦 · 外交(DIPLOMACY) · 基建投資 |
| **稱霸** | 攻擊敵 faction · 吞併勢力 · 外交(強制結盟/附庸) | 經濟壟斷 · 收購/擠垮對手 · 外交貿易集團 | 區域繁榮中心 · 外交聯邦 · 吸引遷徙 |

## Wiring 指引

- **生存分流複用既有 `_trigger_survival` desperation×values**（progress「絕境驅動多元生存」已分 loot/camp/forage/beg/join）。只是貼到 archetype 框，非新做。
- **極絕境蓋過 archetype**：urgent 解閘人人有活路——快餓死的商人也會搶。本性是傾向非枷鎖。
- **外交/徵收**在立國+ 跨 archetype 都出現（成勢力者才搞外交）。
- **G2d 私驅動覆蓋層在最上**：強恩怨+衝動可脫軌蓋掉本表任一格。
- **商業「擴張」依賴 ②G1**（訂單/商隊）→ G1 未上線前，商業擴張退化成近程 TRADE。
- 各 cell 權重/門檻 = TEST VALUE，平衡 pass 調。

## 邊界

此為 feel(WHAT)。rung→哪些具體 task 的 enum 對應、權重公式、判定接點 = 你 HOW。有 WHAT 疑義回呈本 channel。
