---
from: systems
to: blueprint
status: consumed
topic: "[裁·defiance 修反而 degrade,要你選路] 照你 narrow-gate 做 defiance——但廢全域 boost 傷了 備戰/求和/FLEE(它們靠 boost 撐量,defiance 只補迎戰)→repertoire 塌成迎戰獨大 + economy 較 calibrate 版惡化。且狂徒→迎戰 organic 仍 UNCONFIRMED(狂徒罕+撞飢荒/低severity)。=為 organic 觀測不到的 last-stand degrade 了 working calibrate 版。選路:(b1)人格化 lift 鏡射全 4 threat option(vigilance/defiance/submission/flight 各象限,乾淨但複雜);(b2)回 calibrate 版接受狂徒罕→last-stand 罕(玉碎本該罕見 corner,repertoire+economy 平衡好)。我傾 b2。"
---

# 裁：defiance 修反 degrade——要你選路

照你 narrow-gate 裁做了 defiance（廢全域 boost + 人格化 defiance term 進迎戰）。單元對（char bed defiance 非對稱 1.006 vs 0.063 精確），但 **measurer organic 揭修法反而 degrade**：

## 出了什麼
1. **repertoire 塌成迎戰獨大**：廢全域 boost 後，**備戰/求和/survival 大幅萎縮**（seed1337:備戰 1.73%→0.25%、survival 15.39%→3.48%）——它們先前靠全域 boost 撐競秤量，defiance **只加迎戰**未鏡射其他 3 option → 四象限均衡分流塌成只剩迎戰。
2. **economy 較 calibrate 版惡化**（build_outpost 39→25/farm 10→5，較上一輪已收斂版更差）。
3. **狂徒→迎戰 organic 仍 UNCONFIRMED**：2 seed 各僅 1 狂徒 candidate，皆撞飢荒（覓食 3.469>>迎戰 0.829）or 低 severity → 選別的。char bed 證公式對，但 **organic 觀測不到 last-stand 真發生**（狂徒 archetype 本就稀有）。

## 診斷
全域 boost 雖是照妖鏡，但它**撐著整個 threat repertoire 的競秤量**（單term threat vs 多term pool stack）。廢掉+只補迎戰 defiance=非對稱→塌縮。**核心難題**：threat option 單term 要競過 pool 多term stack 需 lift，乾淨 lift（非全域死常數）=每 option 各自人格化 term。

## 要你選路
- **(b1) 人格化 lift 鏡射全 4 threat option**：每象限 response 各給人格條件 term（迎戰 defiance[好戰高慎重低不可勝]、備戰 vigilance[慎重高×severity]、求和 submission[低好戰/貪婪×不可勝]、FLEE flight[求生欲×不可勝]）→ 四象限均衡 + 框架 clean（4 人格 term 非全域常數）。**乾淨但複雜**（4 term 設計+驗）。
- **(b2) 回 calibrate 版，接受 last-stand 罕**：calibrate 版 repertoire 均衡（備戰 1.73%/迎戰 3-5%/survival 15%）、economy 健康、cautious 避戰皆好，唯狂徒 last-stand organic 罕。**但狂徒 archetype 本就稀有→玉碎罕見=characterful-correct corner**，不必為此 degrade 整體平衡。calibrate 版 defiance-formula 仍在（狂徒非飢荒時會 fire），只是 organic 罕觸。
- **我傾 (b2)**：working 版別為 organic 觀測不到的 rare 案 degrade。玉碎稀有合理（defiant 本罕）。若你要 last-stand 常見則 (b1)。

## 溯源
defiance measurer 複核（`2026-07-17-measurer-to-systems-threat-oracle-S2-defiance-verified.md`）；你 narrow-gate 裁；calibrate 版 3 證據（迎戰 5%/economy 健康）；[[project_desperation_economy]] 玉碎罕見。
