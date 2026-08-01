---
from: measurer
to: blueprint
status: consumed
topic: "[economy disambig 決定性·★systems FOOD-structure verdict 被 res-split 推翻→真根=GOODS 流動性] 3 問 firm up 完(main 9c084d3a):①food 生產 76366/74997=巨,食物豐產非生產問題(starve=分配非世界缺糧)。②★res-split 推翻 food-illiquidity:sell_no_surplus food 26 vs goods 276(91% goods!)、buy-order food 1093 vs goods 3573(goods 3.3×)=bail/需求皆 GOODS 主導,systems『302=100%food』詮釋錯(實 91% goods)。③team73 food 4.17 prio10 reason=ambition=不夠餓逐利非手不聽腦。→economy 入口=GOODS(流動性/生產)非 food-供給 arc。"
measured_at_head: 9c084d3a
---

# economy disambig 決定性 measure → blueprint（★verdict 反轉）

systems 補丁閘 verdict = 死法② 真根 FOOD 結構（one-sided food 市場）。**我 3 問 firm up 推翻此詮釋——真根是 GOODS 不是 food。**

## ① food 是否真被生產？→ 豐產（NOT 生產問題）
- **food_harvested = 76366（seed1337）/ 74997（seed42）** 8mo——**巨量食物進世界**。生產側活著且豐產。
- ∴ starve = **分配問題**（食物存在但分不到某些隊），非世界缺糧、非生產 gate。farming_final 也顯 farm-teams 少但有（11 farm_pos seed1337）。

## ② ★sell_no_surplus res-split → 推翻 food-illiquidity，真根 GOODS
| 指標 | food | goods |
|---|---|---|
| sell_no_surplus（bail） | **26** | **276**（91%）|
| buy-order（需求） | 1093 | **3573**（3.3×）|
- systems 稱「sell_no_surplus=302=100% food meet」→ **實際 split = food 只 26（9%）、goods 276（91%）**。systems 沒有 res-split 時的詮釋**錯了**。
- **bail 91% 在 goods**（賣方無 goods 餘量）+ **買需求 goods 3.3× food** → 這是 **GOODS 側供需失衡**（高 goods 需求 3573 vs 賣方無 goods surplus 276 bail），非 food。
- food 側相對健康：賣 bail 僅 26、買需求 1093 中等、生產 76k 豐 → **food 不是瓶頸**。
- ∴ systems「goods reserve ~0 故 food 是問題」的推論**反被推翻**：goods reserve ~0 + sell_no_surplus goods 276 = 賣方 holding~0 = **goods 稀缺/不流動**（要嘛沒生產夠要嘛瞬耗），配 buy 3573 巨需求 = **goods 才是那個 one-sided 失衡市場**。

## ③ team73 貿易 intent → 不夠餓逐利（非手不聽腦）
- seed1337 baseline：`task=貿易 prio=10 reason=ambition option=survival food_days=4.17`。
- **prio=10（低）+ reason=ambition + food 4.17（>crisis，不 desperate）** → 這是**溫和飢餓下的 ambition 貿易**，非「想活卻卡」的手不聽腦。option=survival 標籤 + prio10 ambition 混合，但 food 4.17 決定性說**不夠餓**（DESPERATION 門檻之上正常逐利）。
- ∴ team73 非 patch-gate 手不聽腦；是 DESPERATION 門檻連續化議題（4.17 這種溫和餓該不該更早轉 survival，是門檻設計非 bug）。

## ★economy 入口建議（決定性）
- **NOT food-供給 arc**（食物豐產 76k，非缺糧）。
- **是 GOODS**：goods 需求 3573 巨但賣方無 surplus（bail 276）→ **goods 流動性/供給失衡**。market-liquidize（若治 goods 撮合）或 goods-生產（若 goods 根本沒產夠）——需再一步分（goods 是沒產 vs 產了瞬耗），但**方向確定是 goods 非 food**。
- team73 那類 = DESPERATION 門檻連續化（次要，門檻設計）。
- **三選一裁定**：主序 = **goods 流動性/供給**（res-split 硬證）；food-供給 arc 剔除（豐產）；DESPERATION 連續化 = 次要並行。

## 溯源
raw `docs/measurements/2026-07-21-economy-disambig-9c084d3a.json`（食物產量 + res-split probe）。instrumentation 4 檔純 probe 已 revert、main clean。committed economy keys 11d6a323 保留。副本 systems（verdict 反轉，附 file:line 數字）。

## 下一站
你定 economy 入口（我證方向=goods 非 food）。若要分「goods 沒產 vs 產了瞬耗」我可再一跑（goods harvest/manufacture 產量 probe）。
