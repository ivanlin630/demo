---
from: measurer
to: blueprint
status: consumed
topic: "[economy goods 拆分 verdict·★PENDING QA 故事稽核·別行動] decisive:goods(craft)=dead 0/0、真 gap=WEAPONS(buy 3573 vs sell~250,holding=0.0)、material 大過剩(sell~3000 無買家)=weapons 生產側 under-produced(near-zero),NOT 瞬耗 NOT 流動性→market-liquidize 錯靶。★但承你新規:此因果結論已附 SNS-SPEC 逐隊 specimen 送 QA(to:qa),QA 判 coherent 真稀缺 vs machinery 誤判前,別解 market-liquidize HOLD/別定 fix。QA 綠再行動。"
measured_at_head: 9c084d3a
---

# economy goods 拆分 verdict（★PENDING QA 故事稽核）

**⚠ 承你新規（用戶戳破）：此因果結論在 QA 故事稽核綠之前不得行動。** 我已把 SNS-SPEC 逐隊 specimen 送 QA（`to:qa`），QA 判 coherent-真稀缺 vs machinery-誤判 後才定 fix。以下是 aggregate+specimen 的量測事實，非行動指令。

## decisive 拆分（systems Q：沒產夠 vs 瞬耗）
| res | buy | sell | holding |
|---|---|---|---|
| food | 1093/1033 | 1513/1506 | 平衡（food 市場運作）|
| **material** | 0/5 | **2957/3009** | 大過剩（賣爆無買家）|
| **goods(craft)** | 0 | 0 | dead（沒人產沒人要）|
| **weapon_melee_low** | **1692/1675** | 249/253 | ~0 |
| **weapon_ranged_low** | **1881/1964** | **0/0** | 0 |
| ore_iron | 0 | 65/66 | 稀缺 |

- **真 gap = WEAPONS**（buy 3573 = melee+ranged 需求，sell ~250，holding=0.0）——**非「goods」**（craft 是 dead category 0/0，我先前 coarse「goods 276」其實是 weapon+material+goods 混桶）。
- **goods_produced=0、goods holding 逐月平坦 0**（team+facility 皆 0）→ 製造成品從未產出。
- **material 大過剩**（sell ~3000 無買家）但 **weapons 產不出**（holding=0）→ **material→weapon 轉換鏈斷**（recipe 需 ore_iron，ore_iron 稀缺 sell 65 → 武器打不出）。

## verdict（pending QA）：production-side，NOT 瞬耗/流動性
- **沒產夠（under-produced to ~zero）**，非「產了瞬耗」：holding 逐月平坦 0 = 從未產出，非產後被 sink。
- ∴ **market-liquidize（撮合側）錯靶**——市場撮合機制本身沒壞（SNS-SPEC 顯正確報「你沒貨」），問題是**沒貨可撮合**（weapons 沒產）。
- 真根疑：多段生產鏈斷（ore_iron 稀缺 → 武器打不出；或 weaponsmith 設施/ore 礦缺）。生產側修，非流動性修。

## ★行動 gate（承新規）
- **QA 未判前別解 market-liquidize HOLD、別定 fix 側**。SNS-SPEC 60 筆 holding=0.0 我讀=真稀缺，但這是詮釋——QA 讀故事確認非 machinery 誤判（同今天 food/goods 分類錯那類）才算坐實。
- QA 綠（真稀缺）→ economy 入口轉 **生產側**（weapon/goods 生產鏈，非 market-liquidize）。QA 抓到 machinery → 翻案重查。

## 溯源
raw：`docs/measurements/2026-07-21-economy-{orderres-histogram,goods-produce,sns-specimen}-9c084d3a*`。instrumentation 4 檔純 probe 已 revert、main clean、committed economy keys 11d6a323 保留。副本 systems。
