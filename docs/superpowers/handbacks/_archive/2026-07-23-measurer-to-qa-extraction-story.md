---
from: measurer
to: qa
status: consumed
topic: "[extraction de-patch 故事·機制真動但脫貧鏈沒接上] branch 29c44ad9 vs baseline main f1d2a2b4。★故事:extraction fire率 66%兩seed一致(原幾乎不fire)、真取回152-169coin、無新餓死——機制本身健康運作。★但下游:coin_urg chronic(>0.5)90-95% vs baseline 91%(統計持平非改善)、facility built Δ+2~3 vs baseline Δ+4(同方向偏低)。你判:『領袖真的取回自己的錢,但取回後沒有轉化成脫貧(chronic 率不降、蓋得更少不是更多)』這故事 coherent 嗎?是否符合『機制對但撞到別的閘』(material afford×1.5/facility 排隊限額,前幾輪已驗)的解讀?判完 to:systems。"
measured_at_head: "branch 29c44ad9 vs baseline main f1d2a2b4"
---

# extraction de-patch 故事 → QA（機制真動，脫貧鏈沒接上）

extraction 工單 item7。branch 29c44ad9、seed42/1337。full verdict → systems（`2026-07-23-measurer-to-systems-extraction-need-driven-verdict`）。

## 故事：領袖真的取回了自己的錢，但沒有變成脫貧
- ✓ **extraction 機制健康**：fire 率 66.0-66.3%（兩 seed 幾乎相同），原本幾乎不 fire 的死常數閘真的被砍掉了。總取回 152-169 coin，team.coin 總持有 +36~37%。
- ✓ 無新餓死（starve 1/1）、doom 不惡化、無迴歸。
- ✗ **但 coin_urg chronic(>0.5) 沒有降**：90-95% vs baseline 91%——統計上持平，看不出「拿到錢 → 不再窮」的效果。
- ✗ **facility built 沒有升，反而略低**：Δ+2/+3 vs baseline Δ+4（兩 seed 同方向）。

## 你判什麼 → 判完 to:systems
1. 「領袖真的取回自己的 treasury coin（機制對），但 chronic coin_urg 率不降、facility 蓋得沒更多（甚至略少）」——這故事 **coherent** 嗎？
2. 是否符合「coin 側閘修好了，但撞到 material 側自己的閘（reserve_factor/afford×1.5）+ facility 排隊限額（前幾輪已驗）」的解讀——即 **coin liquidity 是必要非充分條件**？
3. extraction 本身該算增量 merge（機制對、無迴歸）還是要等疊加 material 側一起修才有意義？

## 溯源
raw：`docs/measurements/2026-07-23-povertychain-{1337,42}.txt`。baseline 重用（main f1d2a2b4=branch merge-base，code 同）。instrumentation revert、branch clean、determinism-safe。
