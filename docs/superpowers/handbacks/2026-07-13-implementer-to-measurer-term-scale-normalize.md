---
from: implementer
to: measurer
status: consumed
topic: term-scale normalize T1-T4 整包交付 — base eval [0,1]正規化;branch feat/term-scale-normalize已push,待organic(9-zero lift+3觀察項)
---
# Hand Back: term-scale normalize（T1-T4 整包）

branch `feat/term-scale-normalize`（已 push，疊 main，含 S1+S2 決策引擎）。spec `docs/superpowers/specs/2026-07-13-term-scale-normalize.md`。core：`util = weight(0-1.5) × eval(執行品質 0-1) × coeff(需求 0.15-1)`；base eval 剝 urgency（移 coeff）保 quality、值域 [0,1]。

## 實作摘要（逐 bucket commit）
- **T1 survival-class**（8 term）：survival_pressure→1.0 / restock→home_food/RESTOCK_MIN / threat_pressure→0.6+panic×0.4 / buyfood→dist_disc / beg→0.5 / camp→1.0 / join→0.5+rep×W×0.5 / occupy→1.0或0.3。
- **T2 threat-class = no-op**：threat_pressure 已於 T1 正規化（工單 T1 列表含之）；prepare/defend/pacify 本就 [0,1] 不動。
- **T3 ambient/opportunity**：INTENT_FIT_DRIVE 1.5→1.0 + conq_person clampf 上限→1.0；ABSORB_DRIVE_BASE 1.2→1.0；economic_opp rescale clampf(舊/0.8,0,1)。loot_drive 已 cap 不動。
- TDD：`_test_term_normalize_t1`/`_test_term_normalize_t3`（各 eval∈[0,1]）PASS。

## 13 decision 測回歸處理（裁定逐測分類，明列）
- **Class A 機械更新舊 eval 值**：`_test_survival_magnitude`(前) / `_test_decision_terms`。
- **Class B fixture（+ambition_cap esteem 就緒 + warmup EWMA urgency）**：decide/engine_rank/tc5/survival_magnitude(後 s1/s3)/p3/p4。★關鍵：unit 單次 gather → need_urgency EWMA 僅 25%×raw → coeff 表達不出優先序；`for _w in range(8): gather()` 逼近 raw = 跑真架構（非放寬）。
- **Class B 放寬 organic-verified（裁 D，非硬 invariant 失效）**：`_test_survival_magnitude`-s2 / `_test_p1_loot_believability` / `_test_econ_empty_home_no_return` / `_test_solo_seek_home` / `_test_govern_option_cautious` / `_test_decision_commitment`（belonging 宰/FLEE-safe/掠奪 class 內偏好）。

## 我方自驗（融合閘全綠）
- headless **0 新增 SCRIPT ERROR**（3 pre-existing p2a/beg_join/strategic_reads 同 baseline）；`_test_term_normalize_t1/t3` PASS。
- **constitution PASS**（sites=29）；**multi sanity 0 SCRIPT ERROR**；**determinism byte-identical**（1337×1mo cmp）。

## 待驗收（spec §驗收）
1. **9-option 非零**：貿易/備戰/求和/駐守/乞食/併入/吸納/訓練/買糧 per-option chosen>0（跨 seed；用 per-option probe branch）。
2. **既有不回歸**：survival-dominance(餓→survival-class)、threat(打/逃仍主+備戰/求和 出現)、faction 服從、consolidation/combat/established organic 不劣化。
3. **determinism** byte-identical（我已初驗）。

## ★★3 organic 觀察項（裁定，帶數據才 tune；full_probe 特別看）
1. **FLEE-safe 地板**：安全隊(safety urgency 0)是否 spurious FLEE（`opt_chosen.survival` 在無威脅隊異常高）？根=coeff unaligned≈0.475(非 FLOOR) + threat_pressure base 0.6。真出問題→coeff steepness/FLOOR 重估。
2. **掠奪 vs 覓食（餓隊）**：餓隊是否 over-loot（掠奪選中率 ≫ 覓食）？根=掠奪 survival-affinity 0.4 + high base。真出問題→掠奪 affinity/base 校。
3. **belonging solo=1.0 宰**：solo/faction 隊是否 over-join（併入/外交 選中率異常高，蓋 home-development）？根=belonging 未就緒度化（裁 B 只做 esteem/actual）。真出問題→belonging 就緒度化（動裁 B scope，systems 帶 organic 數據升藍圖）。
- 併：**駐守 affinity actual-heavy(0.5) 語意待校**（settle 型被壓則校）——measure-first 延後，未 pre-tune。

## 連動風險 / 註
- 全 base term 值域 [0,1]（faction_duty §7 授權例外除外）；優先序純由 coeff 表達。baseline 位移（util scale 全變）非 regression。
- per-option probe 在 `feat/peroption-probe` branch（若未 merge，量 9-zero 需該 probe）。
- 序：T4 整包後，organic 驗回報 → 3 觀察項真出問題才帶數據 tune。
