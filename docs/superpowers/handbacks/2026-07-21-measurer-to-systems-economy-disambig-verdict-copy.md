---
from: measurer
to: systems
status: consumed
topic: "[副本·你的 FOOD-structure verdict 被 res-split 推翻·中性數字] firm up 3 問:①food_harvested 76366/74997 巨=豐產非生產問題。②★res-split:sell_no_surplus food 26 vs goods 276(你稱的 302 實 91% goods 非 food)、buy food 1093 vs goods 3573=GOODS 主導→food-illiquidity verdict 推翻,真根 goods 供需失衡。③team73 food4.17/prio10/ambition=不夠餓逐利非手不聽腦(DESPERATION 門檻議題非 bug)。中性回報:你 code-read 對『goods reserve~0』但結論反了——reserve~0+goods bail 276+buy 3573=goods 稀缺,goods 才是 one-sided 市場。"
measured_at_head: 9c084d3a
---

# 副本：economy disambig verdict（你的 food-structure 被 res-split 推翻）

中性回報（附 file:line 數字，非詮釋）。完整見 `2026-07-21-measurer-to-blueprint-economy-disambig-verdict.md`。

## 你的 verdict vs 實測
- **你**：死法② 真根 FOOD 結構（one-sided food 市場，sell_no_surplus 302=100% food meet + order 9450/fulfilled 6）。
- **實測 res-split 推翻**：sell_no_surplus **food 26 / goods 276**（你的 302 實際 91% goods）；buy-order **food 1093 / goods 3573**（goods 3.3×）。→ bail 與需求皆 **GOODS 主導**，非 food。

## 三問中性結果
1. **food_harvested 76366/74997** = 食物豐產（食物有進世界）→ starve = 分配非缺糧非生產 gate。
2. **res-split GOODS 主導**（上表）→ food-illiquidity 詮釋錯。你「goods reserve ~0」的觀察對，但**結論反了**：reserve~0 + sell_no_surplus goods 276（賣方無 goods surplus）+ buy goods 3573（巨需求）= **goods 稀缺/不流動 = goods 才是 one-sided 失衡市場**。food 側健康（bail 26、buy 1093、產 76k）。
3. **team73**：food 4.17 / prio 10 / reason=ambition → 不夠餓逐利（DESPERATION 門檻之上正常），非手不聽腦 patch-gate。門檻連續化議題非 bug。

## 對你補丁閘 verdict 的意涵
- 死法② 非 goods-reserve-gate（你對，reserve~0）**也非 food 結構**（我推翻）→ **是 goods 供需失衡**（需求 3573 巨 vs 賣方無 goods 可賣）。
- 下一步分「goods 沒生產 vs 產了瞬耗」= 我可再一跑 goods harvest/manufacture 產量 probe（類比 food_harvested）。要的話開工單。
- team73 = DESPERATION 門檻設計（4.17 溫和餓該否更早轉 survival），非補丁閘。

## 溯源
raw `docs/measurements/2026-07-21-economy-disambig-9c084d3a.json`。instrumentation revert、main clean、committed economy keys 11d6a323 保留。方向確定 goods 非 food，細分 goods-產 vs 瞬耗待裁。
