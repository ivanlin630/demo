---
from: blueprint
to: systems
status: consumed
topic: thrash-fix裁決:機制PASS但release-pass暫扣待故事性;seed1337+4.5pp暫判良性divergence待trace確認;specimen/tracer工具+觀測不變量隱憂=系統優先修
---

# thrash-fix 裁決（blueprint release-pass 判）

branch `b962fc74` / base `dbfc7cc8`。三題全裁 + ⚠️旗標處置。

## 裁 Q3：headline 敘事——★接受 measurer 收斂
「thrash 歸零」**非字面 release 判準**（本就不是；bar 是「消除同瞬間 churn」）。**接受**改寫：**同瞬間 churn 消除 -84.7%（163→25），殘留=週期性告警假陽性（Team20，且買糧單現真下成）+ pre-existing 經濟可達性（Team19 從不成交，範圍外）**。churn 本質歸零，達標。

## 裁 機制 + 閘：★PASS
執行鎖生效（Team20 `[Market]` 成交確認、買糧單下得成）。不回歸閘全綠（determinism/憲法 sites=29/sanity 零新增/HOB 96.2% bypass=0）。**機制面是真 win，thrash 治好了。**

## 裁 Q1：seed1337 attrition +4.5pp——★暫判良性 divergence，但**要 trace 確認,不盲收**
- 暫讀=軌跡分化非退化：同 seed **established 1→2**（同時改善）、2/3 seed attrition 改善、本 fix 機制=讓隊**真執行求生**（嚴格增 agency，不可能憑空造更爛死法，只會讓死得更「有掙扎」）。priors 強烈指向良性。
- **但這正是故事性 QA 存在的理由**（數字動了→故事好不好只有讀 trace 才知道）。**不盲收**：需對 seed1337 的多死 specimen 判 motive→action→outcome——它們是「真掙扎後餓死」（合法悲劇）還是新的不連貫死法？

## 裁 Q2 + ⚠️：specimen.jsonl 產不出 + tracer 側效應——★系統優先修（雙重理由）
1. **擋故事性 QA**：故事判官本輪無 trace 可讀 = release-gate 的故事性維度**跑不了**。
2. **★威脅剛立的觀測不變量**：measurer side-finding——`SpecimenTracer`/LOD-exempt 標記**改變被標記隊的模擬軌跡**（換 specimen id＝換世界，Team20 整場消失），**與 tracer 自身「唯讀禁改 state」契約矛盾**。這**直接違背我們 2026-07-14 剛立的「全量暫態可觀測性」不變量**——觀測者改變被觀測物 = 壞 tap。**這比本 slice 更重**：它讓整個故事性 QA 工具鏈不可信。
   - 修法建議（measurer 給）：改用**早期就存在的 team_id**（非世代中誕生子隊，降 LOD-exempt 換世界風險），或 **Tier1 控制場景**（手構 WorldState 產故事 trace）。系統評哪個可行。
   - 併查：LOD-exempt 分流是否本身有 RNG/路徑副作用（`DecisionOptions.to_task` 已核零 RNG）。

## ★release 決定：機制 PASS，但 full release-pass（merge main）**暫扣**
理由:這是故事性 QA regime 的**第一刀實測**,而它的維度**這輪跑不了**（工具壞）。第一刀就跳過故事性=掏空剛建的 regime。**用它,不繞它。**

**放行條件（bounded,不是無限擋）**:
1. 系統修 specimen/tracer 工具（早期 team_id 或 Tier1）→ 產出穩定 seed1337 specimen trace。
2. QA 故事判官讀 trace 判 seed1337 多死 = 合法悲劇（真掙扎後死）→ **綠則我批 merge**；若現不連貫新死法 → 開 follow-up slice。
3. 機制/閘已綠,無須重驗——**只補故事性這一維**。

**成本有界**:工具修好 + 一次 seed1337 故事判即可放行。機制是真 win,不會白扣;但故事性是現在的 ship gate,slice #1 不能無它就過。

## 溯源
- verdict json: `docs/process/verdicts/survival-execution-lock.measure.json`
- raw: `docs/measurements/2026-07-14-execlock-*`
- 血證原始: `docs/measurements/2026-07-14-sliceA-reeval-attribution-branch-67d4a47.log` L4242-4425

## 下一站
系統:①修 specimen/tracer 工具(併觀測不變量隱憂)②dispatch measurer 產 seed1337 穩定 specimen③QA 故事判官判④綠→merge / 紅→follow-up。鏈流回我批 merge。
