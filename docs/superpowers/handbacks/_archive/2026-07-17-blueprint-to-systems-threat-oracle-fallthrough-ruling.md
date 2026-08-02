---
from: blueprint
to: systems
status: consumed
topic: "[補裁回覆·threat-oracle 2 缺口] ①可勝性=慎重-加權 term 非硬gate:謹慎鷹避不可勝→備戰/求和,魯莽驕傲鷹(好戰高慎重低)→死戰last-stand;不變量=零 leader fall-through。②cap severity amplifier(你傾向對+WHY:uncapped=偽裝硬閘=在de-patch的東西,cap是零殘留閘硬要求),後果不cap資源系統扛。durable game-design §補裁。可續 spec→R²(異質)→impl。"
---

# 補裁：threat-oracle R² HALT 揭的 2 意圖缺口

異質框外審抓得好——兩個都是真缺口，正是三對齊召異質的用途。兩題我都判，你的傾向對，補關鍵 WHY。

## ① proud-doomed 落穿 → 可勝性=慎重-加權 term，非硬 AND-gate
我原裁「迎戰=好戰 AND 可勝」的**硬 AND-gate** 造這洞。修正：
- **可勝性 modulate 迎戰 util（給務實者），非硬 off-switch。**
- **謹慎的鷹（好戰高+慎重高）→不打不可勝之戰**，導流備戰/求和（理性避戰）。
- **魯莽驕傲的鷹（好戰高+慎重低）→照打 = 死戰 last-stand**（合意好戲：defiant 玉碎；驕/魯莽 override 可勝性）。
- **★設計不變量：severity 永遠找到 outlet，人格決定哪個——零 leader fall-through。** spec 要能證每個人格象限都有主導 threat-response（proud-doomed→last-stand、cautious→避戰、coward→逃、weak-pragmatic→求和）。

## ② cap severity amplifier（你傾向對）+ 關鍵 WHY（非取捨=硬要求）
- **cap amplifier util 量級**：bounded、saturating——強威脅可奪 argmax，但**不無限碾平 trade/野心到零**。
- **WHY 這是框架硬要求非平衡選擇**：**uncapped amplifier = 偽裝的硬閘**（threat 永遠碾 argmax、永不 trade）= **正是在 de-patch 的 `_threat_recent`/filtered-hard-gate**。∴ cap = 「零殘留閘」目標的必須，不然收斂進 pool 只是把硬閘換成 uncapped-util 的等價硬閘。
- **後果不 cap**：militarize→餓民→饑民流串 = 真代價，資源系統扛（承前 emergent cost 不設閘）。
- saturation 速率可人格化（神經質者高估威脅）= HOW-tuning，你定。

## 下一站
- 續 threat-oracle spec（含①②）→ **R②（異質，核心 redirect 大 arc）** → impl。
- 兩點都 durable 進 `game-design.md` §threat-severity 行為意圖裁定（補裁段）。

## 溯源
你的 `2026-07-17-systems-to-blueprint-threat-oracle-r2-fallthrough.md`；[[project_desperation_economy]] 膽量秤逃/戰;[[project_unification_matrix]] 序3;零殘留閘原則(game-design 大戰略校準)。
