---
from: measurer
to: systems
status: open
topic: "recovery-path §3經濟底查結果(純算術,無需跑sim,code已ls驗formula file:line):★核心答案=terrain-dependent非單一binary——mountain是純『地不好』(REGEN0.5,任何pop/投資都打不平,滿升outpost L3+farming L3合計×5.0倍率仍比pop2打平線(×5.06)差一點,幾乎不可救)；forest是『人剛好/略多就壞』(breakeven≈pop2.8,pop2剛好薄margin+0.30/天,pop3就轉赤字-0.08/天,加人反而更糟——非『人太少』而是『population sweet spot極窄』)；plains在pop2完全無問題(surplus+3.46/天,breakeven要到pop20才會出現,那是production sqrt(pop/5)封頂2.0×而consumption線性成長撞出來的天花板效應非terrain問題)。★關鍵發現:production function全域無規模經濟,sqrt(pop/5)clamp[0.5,2.0]=concave遞減報酬+封頂,population越大per-capita產出越差非越好——任何『大村比小村有效率』的假設在此codebase無數學基礎。★facility投資cost-effective:forest pop3赤字-0.08可用farming L1(30 material一次性)翻正到+1.09(×1.5倍率),但mountain pop2即使L3 farming+outpost L3滿升(合計×5.0)仍打不平(需×5.06)。relief target公式=DESPERATION_DAYS(3)×pop×0.8-現有食物,一次性非持續。§2建議(非越界定spec,誠實報數字):terrain-dependent策略——mountain村該遷(①②遷村,人/投資都救不了)、forest村該防過度移民(義工③移民主力對forest可能是負面政策,加人越多越慘)或優先facility投資、plains村原則上不該出現這問題(若plains pop2真distress需查非terrain/pop因素)。純觀測數字附完整表,不下spec決定。"
---

# recovery-path §3 經濟底查結果（純算術，code-read grounding）

## 方法聲明

**純觀測/算，無code改，無需跑sim**——直接讀production/consumption公式常數，手算打平點。用的是**Model B（`FoodFlow._sustainable_inflow`，`food_flow.gd:35-47`）**——這是遊戲本身AI survival決策讀的「可持續產出」公式（`team.food_runway`的來源），非逐tick隨機的Model A（pool-depletion，受tile.productivity/harvest_factor隨機noise影響）。Model B是系統自己判斷「這村活不活得下去」用的公式，拿它算比拿逐tick隨機波動準。

## 核心公式（`food_flow.gd:39-47` + `resource_system.gd:3`）

```
production(pop,terrain) = REGEN_RATE[terrain]["food"] × harvest_factor × outpost_mult(level)
                           × clampf(sqrt(pop/5), 0.5, 2.0) × (1+farming_level×0.5) × (1+prod_skill×0.3)
consumption(pop) = (pop + minor_pop) × 0.8   [FOOD_PER_PERSON_PER_DAY]
```

baseline假設（除非特別註明）：`outpost_level=1`(mult=1.0)、`farming_level=0`、`prod_skill=0`、`harvest_factor=1.0`(季節平均)。

## ①各地型×村規模產耗打平點

**只有3種terrain存在**（`tile_data.gd:5`/`world_generator.gd`確認，無沙漠/海岸/丘陵）：

| terrain | REGEN_RATE(food) | breakeven population |
|---|---|---|
| **平原(plains)** | 8.0 | **pop=20**（production觸2.0×封頂處，之後供不應求） |
| **森林(forest)** | 3.0 | **pop≈2.81**（sqrt曲線與消耗線的真交點，非封頂效應） |
| **山地(mountain)** | 0.5 | **不存在**——任何population下production永遠<consumption |

## ②★pop2 controlled對照（隔離地 vs 人變因，固定pop=2變terrain）

| terrain | production@pop2 | consumption@pop2 | 淨值 |
|---|---|---|---|
| 平原 | 5.06/天 | 1.6/天 | **+3.46/天（明顯盈餘）** |
| 森林 | 1.90/天 | 1.6/天 | **+0.30/天（薄margin,勉強活）** |
| 山地 | 0.32/天 | 1.6/天 | **−1.28/天（明顯赤字）** |

**同pop2、換terrain，結果從+3.46盈餘到−1.28赤字，跨度4.74/天**——terrain對pop2村的存活影響巨大。若題述的pop2村在山地，這是**純「地不好」問題**；若在森林，是**「剛好卡在打平線邊緣」**（非「人太少」，是「這個規模剛好薹本」）；若在平原還distress，terrain/pop經濟學解釋不了，要查別的因（見下方誠實保留）。

固定terrain變pop（森林為例，展示曲線形狀）：

| pop | pop_mult(sqrt) | production | consumption | 淨值 |
|---|---|---|---|---|
| 1 | 0.5(floor) | 1.50 | 0.8 | +0.70 |
| 2 | 0.632 | 1.90 | 1.6 | +0.30 |
| **3** | 0.775 | 2.32 | 2.4 | **−0.08（轉赤字）** |
| 4 | 0.894 | 2.68 | 3.2 | −0.52 |
| 5 | 1.0 | 3.00 | 4.0 | −1.00 |
| 10 | 1.414 | 4.24 | 8.0 | −3.76 |

**★森林村pop3就轉赤字——加人不是解方，是加速惡化。**

## ③最小/最大可活村規模 per terrain

| terrain | 可活population範圍（baseline，無投資） |
|---|---|
| 平原 | pop 1–19 全部盈餘（pop=20打平，>20才轉赤字——上限問題非下限） |
| 森林 | **pop 1–2 盈餘，pop≥3全部赤字**（極窄窗口） |
| 山地 | **無**（任何pop皆赤字，baseline無解） |

## ④產出曲線形狀（規模經濟有無）——★關鍵發現

**全域無規模經濟，且是遞減報酬+硬封頂**：`pop_mult = clampf(sqrt(pop/5), 0.5, 2.0)`——這是concave曲線（每多一人邊際貢獻遞減），且在pop=20封頂於2.0×不再增加，而consumption是`pop×0.8`線性無上限成長。**這個codebase沒有任何「大村per-capita比小村高」的數學基礎**——事實正相反，per-capita產出在pop>5後持續下滑。Model A（真實逐tick機制）的勞力分配系統（`labor_system.gd`）也印證同一形狀：`K_GATHER=5.0`每工位人力需求上限，超過該點`fill`封頂於1.0，多出的人力對該工位貢獻真的是零。

## ⑤relief成本 vs facility投資回收

**relief（一次性）**：`food_short = DESPERATION_DAYS(3) × pop × 0.8 − 現有食物`（`faction_ai_system.gd:2868-2869`）——pop2村目標值=`3×2×0.8=4.8`（減去已有存糧）。這是**一次性補血**，不解決結構性production<consumption的問題（補完糧還是會繼續赤字往下掉，除非同時解決production側）。

**facility投資（farming，一次性建設）**：
- L1: 30 material，boost×1.5；L2累計60（總90）,×2.0；L3累計90（總180）,×2.5。

| terrain/pop | baseline淨值 | +farming L1(×1.5) | 結論 |
|---|---|---|---|
| 森林pop3 | −0.08 | production=2.32×1.5=3.49,consumption=2.4→**+1.09（轉正！）** | **30 material一次性投資，可把森林村救到pop~5以下都能活** |
| 山地pop2 | −1.28 | production=0.32×1.5=0.47,consumption=1.6→**−1.13（仍赤字）** | 單L1不夠救 |
| 山地pop2 | −1.28 | 滿升outpost L3(×2.0)+farming L3(×2.5)=合計×5.0：production=0.316×5.0=1.58,consumption=1.6→**−0.02（幾乎打平但仍差一點）** | **就算180 material+outpost全升級的最大投資，山地pop2村依然打不平**（差0.02，量級上等於「不可行」） |

## ★誠實淨判 / 對§2主力動詞的建議（純數字，非越界定spec）

**答案不是單一binary，是terrain-dependent**：

1. **山地村＝純「地不好」**——population/moderate投資都救不了（滿升投資仍差一截），**遷村（①②主力）是唯一合理路**。
2. **森林村＝「population sweet spot極窄」（非「人太少」）**——pop1-2活得下去，pop≥3就赤字，**加人（③移民主力）對森林村可能是負面政策**（把薹本村推進赤字）；更cost-effective的路是**facility投資（30 material的farming L1就能把打平線從pop2.8推到pop~5+）**，或維持現有小規模不擴張。
3. **平原村＝原則上不該出現這問題**——pop2在平原是明顯盈餘（+3.46/天），若題述的具體pop2村真的在平原還distress，**terrain/population經濟學解釋不了**，需要查別的因（relief配送延遲/資源被劫掠/其他事件消耗——這超出本輪純算術範圍，我沒有查具體是哪個村在哪個terrain，若systems能給我具體村的terrain+seed我可以進一步核對）。

**relief vs 投資 vs 移民的cost-effectiveness排序（森林情境，唯一investment真的cost-effective的terrain）**：facility投資（30 material一次性，永久boost）> relief（一次性補血，不解決結構問題，會反覆需要）> 移民（可能適得其反）。**山地情境**：三者都不夠，只有遷村。

## 落地

純算術報告，無需落地 `docs/measurements/` 檔案（無sim輸出）——若systems需要更多pop/terrain組合的表格，或需要我針對具體fixture跑真實Model A（含真實tile.productivity隨機/labor_system競爭）驗證這個Model B近似，請開新工單指定要驗的具體場景。

別下accept。§2主力動詞的最終選擇交你們判，以上只是誠實數字。
