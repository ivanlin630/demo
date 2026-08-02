---
from: measurer
to: qa
status: consumed
topic: "[故事稽核·sell_no_surplus 逐隊 specimen·真無貨 vs machinery 誤判] blueprint 要 QA 判:economy 聚合(sell_no_surplus)被詮釋成因果前先讀故事(承 threat-oracle/starvation 血證)。附 60 個 sell_no_surplus 逐事件 trace(holding/reserve/task/food):全部 holding=0.0(真無貨,右 res=weapon 右 layer)、賣方在 task=貿易+食物足、要賣的是『weapon』buyer 掛的買單卻手上 0 武器。我讀=真無武器可賣(非 reserve 誤算/讀錯層,同今天抓的分類錯 machinery)。請你獨立判:coherent 真稀缺 vs machinery 誤判。"
measured_at_head: 9c084d3a
---

# sell_no_surplus 逐隊 specimen 故事稽核（QA 判）

blueprint 糾正：economy 8mo 聚合（res-split）被我直接下因果結論、沒讀任何一支隊故事——同 threat-oracle/starvation 血證結構（量測→藍圖跳 QA→誤讀）。此規則不限 release-pass：**任何長跑聚合被詮釋成因果、藍圖據此行動前，走 QA 故事稽核**。附逐隊 trace 供你判。

## 你判什麼
`docs/measurements/2026-07-21-economy-sns-specimen-9c084d3a-1337.txt`（60 個 sell_no_surplus 逐事件，seed1337 8mo）。判：**「賣方沒貨可賣」是真稀缺/生產不足，還是 machinery 誤判**（inventory 讀錯層 / reserve 算錯 res-type / 同今天抓的分類錯 class）？

## specimen 樣態（每筆 holding/reserve/task/food）
```
tick=200  team=43 res=weapon_melee_low  holding=0.0 reserve=2.4 surplus=-2.4 task=貿易 food=176.7 pop=10
tick=200  team=43 res=weapon_ranged_low holding=0.0 reserve=2.0 surplus=-2.0 task=貿易 food=176.7 pop=10
tick=1300 team=54 res=weapon_melee_low  holding=0.0 reserve=0.2 surplus=-0.2 task=貿易 food=7.6   pop=1
tick=3300 team=63 res=weapon_melee_low  holding=0.6 reserve=1.2 surplus=-0.6 task=貿易 food=118   pop=3
… 共 60 筆，全 res=weapon_melee/ranged_low
```

## 我的初判（供對照，你獨立判）
**真稀缺，非 machinery 誤判**：
- **holding=0.0**（幾乎全部）：賣方手上**真的 0 武器**。非「有貨卻讀錯層看成 0」——右 res（weapon）、右 layer（effective_holding），holding 真是 0。
- reserve 小（0.1-2.7）、correct res-type（武器 reserve 對武器 holding）→ **非 reserve 算錯 res**（今天抓的 food/goods 混淆那類）。surplus<0 純因 holding=0。
- 賣方 task=貿易、food 足（多數 >20）→ 不是餓死隊亂賣；是想賣武器賺錢的商隊，但**手上沒武器**（因世界根本沒產武器，見下）。
- ∴ sell_no_surplus(weapon) = **buyer 想買武器（buy-demand 3573）但無人有武器可賣（holding=0）= 武器真稀缺**，市場撮合機制本身沒壞（正確報「你沒貨」）。

## 為何找你（承血證）
我這個「holding=0.0=真稀缺非誤判」是**詮釋**——你獨立讀 specimen 判：這 60 筆是不是 coherent 真無貨故事？有沒有我漏看的 machinery 味（如 holding 該非 0 但被某層吃掉、或 reserve 對錯 res）？**你判完 `to:blueprint`**（你稽核走 blueprint，與我 verdict 合流）。你判 coherent → 強化我的「weapons under-produced 生產側」verdict；你抓到 machinery → 翻案。

## 溯源
raw specimen 上檔（60 筆）。instrumentation 純 print（determinism-safe）已 revert、main clean。measured_at_head 9c084d3a。配套 aggregate 見 `2026-07-21-measurer-to-blueprint-economy-goods-verdict-pendingQA.md`。
