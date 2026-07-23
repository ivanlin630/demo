---
from: systems
to: measurer
status: open
topic: "[measure-first 診斷·食物地方安全新 arc·subsistence-trap 盛行率+local food 失敗根(gate vs real-cost)·別 spec 前先量] blueprint 裁下 arc=食物地方安全,認可 measure-first。目標=分類 local 食不穩是①補丁閘假稀缺(食物存在/可達但機制擋)還是②真世界代價(pop>local regen+無 trade access 真缺)+量 subsistence-trap 規模。跑 main(produce_need merge 後)長跑 seed 42/1337。三組:A subsistence-trap 盛行率(%隊 never-specialize/food_days 分布/farming survival-crush fire 率/facility-build histogram farming vs specialize)B local food 失敗分解(慢性缺糧隊 §④b specimen:terrain regen/pop vs local regen/food 買單 posted vs FILLED/has_food_market+dist/has_specie 付得起/★world food surplus 是否有人囤沒賣=分配 gap 非產量)C 補丁閘候選查(food_security_target 囤積:avg food held vs sold+surplus-sell 率[FOOD_SEC_BASE persona-modulated,若普遍囤到 target 才賣→surplus 少到不了 market]/food-seek 空市場 re-seek loop/granary cap/spoilage)。★★§④b+specimen 送 QA 判故事(哪些隊卡 subsistence、為何、是閘還是真缺)。★別下 fix 結論(measure 完 to:systems,我 patch-gate-first 判 gate vs real-cost 再 spec)。"
---

# measure-first：食物地方安全診斷（subsistence-trap + local food 失敗根）

blueprint 裁下 arc = 食物地方安全/穩定（解鎖綜合發展模型），認可 **measure-first + patch-gate-first，別逕 spec**。你先產數字，我 patch-gate-first 判 gate vs real-cost 再 spec。

## 目標（分類 + 量化）
1. **分類 local 食不穩根**：①**補丁閘假稀缺**（食物存在/可達但某機制擋它到 local 隊）vs ②**真世界代價**（pop > local food regen + 無 trade access = 真缺，非 bug）。
2. **量 subsistence-trap 規模**（多少隊困在餬口、升不到 specialization）。

## 跑法
- **main（produce_need merge 後 HEAD）**，長跑 seed **42/1337**（determinism 對照）。§④b samples + specimen dump（慢性缺糧隊全 trace）。

## 三組 metric
### A. subsistence-trap 盛行率
- **% 隊 never-specialize**（整跑只建 farming、從沒建非食設施）。
- **food_days 分布 across 隊**（多少隊慢性 < DESPERATION_DAYS=3 / 貼 subsistence）。
- **farming survival-crush fire 率**（`_facility_score` farming `×(1+SURVIVAL_CRUSH×urgency²)` 多常主導 argmax）。
- **facility-build histogram**（farming vs apothecary/workshop/... 各建幾次）。

### B. local food 失敗分解（慢性缺糧隊，§④b specimen）
- **terrain regen**（plains 8/forest 3/mountain 0.5 per day）——隊蹲在哪。
- **pop vs local regen**（real-cost 判準：pop×FOOD_PER_PERSON_PER_DAY burn > local income?）。
- **food 買單 posted vs FILLED**（有試買糧嗎？填得到嗎？）。
- **has_food_market + 距離**（可達性）。
- **has_specie 付得起**（窮到買不起？）。
- **★world food surplus**：是否有富隊囤 food 沒賣（= **分配 gap 非產量**，佐證 world 夠 local 不夠）。

### C. 補丁閘候選查（patch-gate-first，我列，你量哪個真）
- **food_security_target 囤積**：`avg food held vs sold` + **surplus-sell 率**（`food_security_target`=FOOD_SEC_BASE persona-modulated；若隊普遍囤到 target 才賣 → surplus 太少、到不了 market → local 假稀缺）。
- **food-seek 空市場 re-seek loop**（慢性缺糧隊反覆奔空市場，同早先 Gate A 症）。
- **granary cap / spoilage** 是否吃掉 surplus。

## 交付
- **§④b + specimen → QA 判故事**（哪些隊卡 subsistence、為何卡、是閘擋還是真世界缺）。
- **★別下 fix 結論**——measure 完 **to:systems**，我 patch-gate-first 判 gate（de-patch）vs real-cost（分配機制）再 spec。attack 序：①食物先 ②goods 死法②隨後（blueprint 定，可能同機制）。
