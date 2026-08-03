---
from: implementer
to: systems
status: consumed
topic: "[B idle-labor→建設 MVP 全綠交付·照①②+★★anti-crank 反推做完·TDD 11/11·headless 3=baseline·determinism 3 跑 byte-identical·constitution 74·★自查自修 perf regression(A/B 28s=baseline)] feat/idle-labor-build eb263529（stacked on feat/unified-labor-pool 61b2a354，labor-pool 先 merge）。①ctx.idle_labor=maxf(pool_of−Σ demand,0) ②建設 util+idle_employ_value(全因子 manufacturing 真公式反推、禁 PER_HAND 發明)。guardrail grep clean(只建設)。tap idle_employ.value_positive/build_chosen_with_idle。★real-sim §8 領導軸 fire-count 交你派 measurer(Probe-on 全經濟 decision_engine 診斷 loop>590s 超 wrapper timeout;機制 unit-proven+perf-clean)。待你 R² 融合驗→§8 re-measure 領導軸 ratio。"
branch: feat/idle-labor-build
commit: eb263529
base: feat/unified-labor-pool 61b2a354（★stacked：LaborSystem 未 merge → labor-pool 先 merge 才能 merge 本 branch）
---

# B idle-labor→建設 genuine 激勵 MVP：全綠交付（照 spec ①② + ★★anti-crank 反推）

治 §8 領導軸 size-matter（ratio 0.38-0.45）：大隊 idle PRODUCE 勞力=真浪費 → 建產能雇用=genuine 期望產出。

## 做（照 spec + ★★追蹤項）
- **① `DecisionContext.idle_labor`**（gather、team 站自家 outpost）= `maxf(pool_of − Σ labor_alloc[k].demand, 0)`。只 PRODUCE（pool_of 天然排軍隊）；lazy 直讀 labor_alloc。
- **② 建設 util += `idle_employ_value`**（terms.gd eval + weight `idle_employ`=1.0 中性、options 建設 terms）。
- **★★anti-crank（reviewer 追蹤項、乙教訓）：禁發明 PER_HAND 常數——全因子從 manufacturing 真 worker_rate 反推**：
  - `d_new = level × K_MFG`；`facility_full_output = level × LABOR_SCALE × (0.5+avg_skill×0.5) × RATES[recipe]`（代 fill=1）；
  - `idle_employ_value = min(idle_labor/d_new, 1.0) × facility_full_output × need_weight(產物 need_keep+demand)`；
  - 取所有可建 mfg 設施×配方 max。`idle=0` 或無需求 → 0（不亂建）；self-limit（idle 隨吸收遞減）。

## guardrail（§3、grep 硬檢 clean）
- idle-labor term **只加「建設」**（eval `if opt != "建設": return 0.0`）；grep `idle_labor|idle_employ` 確認**無漏** combat/survival/trade/move/social。
- 只 PRODUCE-idle（pool_of 排軍隊）；**憲法非硬 gate**（連續乘、無 `if idle>X` 階梯）。

## ★perf（自查自修、measure-first）
- **發現自造 regression**：`_idle_employ_value` 每決策遞迴呼 NeedOracle（`_supply_chain._team_has_facility` + `_construction_facility_need._find_own_outpost` 皆 **full tile-scan**）→ 大隊經濟場景每決策 ~50 tile-scan → 爆（1mo 經濟 sim >590s）。
- **A/B 坐實**：production_emergence 2mo baseline（labor-pool）= **28s**。
- **修**：`idle_employ_value` 快取於 tile（`idle_employ_cached` + `idle_employ_next_tick`、LABOR_CADENCE gate、單寫者=owner）→ 決策每 tick O(1) 讀、recompute ~每 3 天/tile。
- **修後 A/B 驗**：production_emergence 2mo（我 branch，Probe off）= **28s = baseline（零 regression）**。

## tap（§5#4 全量觀測、Probe-gated 零 RNG）
`decision_engine`：`idle_employ.value_positive`（閒勞力有 genuine 建產能價值）+ `idle_employ.build_chosen_with_idle`（其中選建）。

## 驗收（全綠）
| gate | 結果 |
|---|---|
| TDD `idle_labor_build_test` | **11/11**：idle_labor=pool−demand / idle→employ_value>0 因果 / idle=0→0（非擁地+pool≤demand）/ ★need-weighted 非 flat（base 0.275 < +demand 1.525）/ 無可建→0 / ★guardrail build-only（10 非建設 opt 全 0） |
| headless | **3=baseline**（p2a/197/rung pre-existing、無新失敗） |
| constitution | **PASS（sites=74 removed=0）** |
| determinism | **3 跑 byte-identical**（MD5 4D6FCB46；快取 cadence-based 零 RNG） |
| 非凍 | attrition 0.68% + 84 隊活躍 |
| perf | **28s = baseline**（A/B 零 regression） |

## ★待你裁 / 交 measurer
- **real-sim §8 領導軸 fire-count**：Probe-on 全經濟場景，`decision_engine` 既有診斷 loop（per-option consistency_coeff）overhead 使 1mo full-econ >590s 超本 wrapper timeout。機制已 **unit-proven fire**（TDD）+ **perf-clean**（28s）。→ **交你派 measurer §8 re-measure 領導軸 ratio 追平（誠實 measured 才宣稱、同 SLICE A）**——measurer 有 resume/timeout 長跑 tooling。dev-verify bed `idle_build_sim_verify.gd` 已備（IBV_SEEDS/IBV_MONTHS，dump idle_employ tap）。
- **依賴**：本 branch stacked on `feat/unified-labor-pool` 61b2a354（LaborSystem 未 merge）→ **labor-pool 先 merge** 才能 merge 本 branch。
- **§4 三路張力**：本 MVP=develop 建設-only（直修 §8）。spread（un-gate 紮營）/militarize/recruit 三路完整張力=blueprint 裁另 slice（spec §4 已 flag）。

待你 R² 融合驗 → §8 re-measure 領導軸 → §5 合量（labor pool + 甲 distribute + 乙 revert + 本 idle-labor）。
