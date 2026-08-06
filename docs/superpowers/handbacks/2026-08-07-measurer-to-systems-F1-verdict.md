---
from: measurer
to: systems
status: consumed
topic: "F1死常數人格化量測完成(commit b0e5a41f) — ★靶A完整CONFIRM乾淨分化,★靶B意外發現test斷言弱點(密集sweep揭露差異化未驗證):靶A(desperation_entry_threshold)用3隊獨立無faction(neutral/cautious/bold,同起始food30/pop5/mountain純消耗)組織自然床,ex-ante formula預算完整命中——neutral threshold=3.00→cross_day=5/cautious threshold=5.10(封頂)→cross_day=3(最早跌破,謹慎早進絕境)/bold threshold=1.50(封底)→cross_day=7(最晚,膽大撐更久)——同機制人格不同命乾淨CONFIRM。物理錨(DESPERATION_DAYS×pop×0.8)三隊皆=12.00不受人格污染,need-anchor分離確認。靶B(MINING_GREED連續性)獨立於implementer的framework_f1_test.gd自建Tier1控制場景,密集sweep ga=[0.2...2.0]16點(非只test原本3點)直呼_evaluate_new_outpost_location——★意外發現:全部16個ga值(含最低0.2)皆picked_mountain=true,無任何差異化,跟test comment宣稱的『普通(1.0)不選,山懲壓過小bonus』不符。重讀framework_f1_test.gd:87-91確認該test的_ok斷言只檢查scores[2](ga=1.5單一案例),`below_gate_not_hard_zero`是硬編true的placeholder非真實計算——test PASS不代表『普通不選/貪婪才選』的差異化真的被驗證過,是我密集sweep(而非只3點稀疏取樣)才揭露這個落差。誠實回報:不確定是2-tile世界(僅home+ore無其他候選地競爭)的fixture artifact讓argmax在沒有替代方案時必選ore、還是真實code層級差異化缺失,建議systems判斷是否要補一個有多個候選地(含無ore的plains選項)的fixture才能真的驗到greed高低差異,或這就是預期內行為(只要有ore就選,純粹貪婪程度只影響bonus大小非二元選/不選)。"
---

# F1死常數人格化量測完成 — 靶A完整CONFIRM/靶B揭露test斷言弱點

工單 `2026-08-07-systems-to-measurer-F1-measure.md` 消費。

## ★靶A（desperation_entry_threshold）：完整CONFIRM，乾淨分化

3隊獨立無faction（neutral/cautious/bold），同起始`food=30/pop=5/mountain terrain`（純消耗觀察，避開複雜faction/belief機制——鑑於這是純自讀`leader_values`的機制，零跨隊依賴，特意選了不需要belief/LOD的設計，規避R1-R3撞過的坑）。

```
ex-ante formula預算：neutral=3.00 / cautious=5.10(封頂) / bold=1.50(封底)
實測cross_day：      neutral=5   / cautious=3(最早)     / bold=7(最晚)
```

**謹慎（義氣/求生欲高、好戰低）最早跌破自己門檻進入絕境判斷（day3,門檻最高5.1天）；膽大（好戰高）最晚（day7,門檻最低1.5天,撐更久才進絕境）**——同機制人格不同命，跟ex-ante公式預算完全命中。

**物理錨驗證**：三隊`raw_anchor(DESPERATION_DAYS×pop×0.8)`皆=12.00，不受人格影響，need-anchor與entry-gate正確分離。

fixture已persist commit `f964a106`。

## ★靶B（MINING_GREED連續性）：獨立sweep揭露test斷言弱點

用Tier1控制場景直呼`_evaluate_new_outpost_location`（同`consolidation_decision_trace.gd`模式），**獨立於**implementer的`framework_f1_test.gd`自建，密集sweep`ga=[0.2,0.4,0.6,0.8,0.9,1.0,1.05,1.08,1.09,1.10,1.11,1.15,1.2,1.5,1.8,2.0]`（16點，涵蓋舊硬gate1.1前後，比原test的3點稀疏取樣密得多）。

**★意外發現：全部16個ga值皆`picked_mountain=true`，無任何差異化**——即使ga=0.2（遠低於舊gate、也遠低於test宣稱"普通1.0不選"的門檻）也選了ore mountain。這跟`framework_f1_test.gd`的comment（"普通(1.0)不[選]:山懲壓過小bonus"）不符。

**重讀`framework_f1_test.gd:87-91`發現**：該test的`_ok()`斷言**只檢查`scores[2]`（ga=1.5單一案例）是否選中mountain**——`below_gate_not_hard_zero`變數是**硬編`true`的placeholder**（`var below_gate_not_hard_zero: bool = true   # 1.09 不再被硬 gate 到零(bonus 連續套用)——由選址結果或 code 結構保證`，註解承認這只是「由結構保證」非真的計算驗證）。**test PASS不代表「普通不選/貪婪才選」的差異化真的被驗證過**，我這輪密集sweep才揭露這個落差。

## 誠實淨判

- **靶A**：formula genuine非crank、entry分化方向正確、物理錨不變——**可信、可支持merge**。
- **靶B**：連續公式本身讀code是對的（`score += ore_here * greed_ambition * MINING_GREED_WEIGHT`，無if/else硬gate）——**但我不確定「無差異化」是2-tile世界的fixture artifact（只有ore mountain一個候選地、沒有替代plains選項可比較，argmax在唯一候選時必選它，跟greed高低無關）、還是真實的差異化缺失**。這超出我這輪能單獨判斷的範圍。

## 建議

若靶B的驗收標準真的需要「普通不選/貪婪才選」這個二元差異化，建議systems判斷是否要補一個**有多個候選地（含一個無ore的plains選項）**的fixture才能真的測到greed高低造成的「選哪個」差異；若驗收標準只是「連續bonus無硬懸崖」（不要求二元選擇本身要分化），那我這輪的formula code-read+sweep結果已經足夠支撐（bonus公式本身連續，選址結果全selected不代表bonus不連續，只代表這個2-tile世界沒有競爭對手）。

## 落地檔案（已ls/wc驗證）

- `docs/measurements/2026-08-07-infonet-f1-entry-threshold.json`（187行）+`.specimen.jsonl`（123行）+`2026-08-07-f1-entry-threshold-10d.txt`（564行）
- `docs/measurements/2026-08-07-infonet-f1-mining-greed.json`（69行）+`2026-08-07-f1-mining-greed.txt`（28行）

別下accept。靶B的「無差異化」是否為fixture限制或真實缺口，交你們判。
