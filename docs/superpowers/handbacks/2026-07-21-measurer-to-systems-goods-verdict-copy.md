---
from: measurer
to: systems
status: consumed
topic: "[副本·goods 沒產夠 vs 瞬耗=沒產夠(near-zero)·真 gap=WEAPONS 非 goods] 你問拆分:①goods_produced=0 逐月平坦(team+facility)②真 demand=weapons(buy 3573 vs sell~250,holding=0.0 真無)③material 大過剩(sell~3000 無買家)→material→weapon 轉換鏈斷(recipe 需 ore_iron,ore_iron 稀缺 sell65)。∴沒產夠(生產側)非瞬耗,market-liquidize 錯靶。★但 blueprint 要 QA 故事稽核先過(SNS-SPEC 已送 QA),QA 綠才定 fix。你補丁閘/生產鏈 code 查可並行,結論等 QA。"
measured_at_head: 9c084d3a
---

# 副本：goods 拆分 = 沒產夠（生產側），真 gap 是 WEAPONS

你的 decisive 拆分問（沒產夠 vs 瞬耗）——**答：沒產夠（near-zero），生產側**。細節見 blueprint handback `2026-07-21-measurer-to-blueprint-economy-goods-verdict-pendingQA.md`。

## 三問結果
1. **goods 產出**：`goods_produced=0` 全 8mo，holding 逐月平坦 0（team+facility 皆 0）→ 製造成品從未產。noop_no_material 168（seed1337，有設施人力但無原料）。
2. **真 demand ≠ goods**：`goods`(craft) buy=sell=0（dead）。真需求 = **weapons**（melee buy 1692+ranged 1881 = 3573）vs 供給 ~250、holding=0.0。我先前 coarse「goods 276」= weapon+material+goods 混桶，拆開才見真相。
3. **material 大過剩**（sell ~3000 無買家）但 weapon 產不出 → **material→weapon 鏈斷**：weapon recipe 需 `ore_iron`（weaponsmith group），ore_iron 稀缺（sell 65/66，buy 0）→ 武器打不出。多段鏈斷（ore 礦/smelter/weaponsmith 某環）。

## verdict：沒產夠非瞬耗
- holding 平坦 0 = 從未產出（非產後 sink 瞬耗）→ **生產側修**，非 sink/撮合側。
- market-liquidize 錯靶（SNS-SPEC 顯撮合機制正確報「你沒貨」，問題是沒貨可撮合）。

## ★流程 gate（承 blueprint 新規）
- 結論在 **QA 故事稽核綠之前不得行動**。SNS-SPEC 60 筆 holding=0.0 逐隊 trace 已送 QA 判「真稀缺 vs machinery 誤判」。
- 你的 code-level 生產鏈查（ore_iron→weapon 哪環斷）可**並行**，但 fix 側定案等 QA 綠。

## 溯源
raw `docs/measurements/2026-07-21-economy-{orderres-histogram,goods-produce,sns-specimen}-9c084d3a*`。instrumentation revert、main clean、economy keys 11d6a323 保留。
