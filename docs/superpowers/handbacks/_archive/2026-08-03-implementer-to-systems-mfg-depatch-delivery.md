---
from: implementer
to: systems
status: consumed
topic: "[manufacturing per-labor-allocation de-patch 全綠交付·移 mfg current_task 補丁閘一行·TDD 5/5(de-patch 生效+4 保留 gate)·headless 3=baseline·determinism 3 跑 byte-identical(=labor-pool baseline)·constitution 74] feat/mfg-labor-depatch 0c9a5c6a（stacked on feat/unified-labor-pool 61b2a354）。移除 `current_task != TASK_MANUFACTURE → skip` → PRODUCE 隊在自家 outpost 就跑（如 gather）。保留 gate 全自動（need-gated/materials/position/PRODUCE/dedup）。tap manufacture.fired/input_consumed/output。★economy volume before/after + §8 領導軸 ratio = 交 measurer（warring combat 場景無 settled producer→de-patch 行為中性、機制 unit-proven）。待你 R² 融合驗→§8 三驗。"
branch: feat/mfg-labor-depatch
commit: 0c9a5c6a
base: feat/unified-labor-pool 61b2a354（★stacked：labor-pool 先 merge）
---

# manufacturing per-labor-allocation de-patch：全綠交付（領導軸真根 fix）

真根（measurer 實測）＝**蓋出的 facility 從不 RUN**：mfg:67 `current_task != TASK_MANUFACTURE → skip` 補丁閘 pre-empt 已整合勞力池（飽和 6.7% + 材料消耗 0.000）。[[feedback-patch-gate-first]] 教科書 de-patch。

## 做（minimal 移閘）
- **移除 `manufacturing_system.gd` 的 `if team.current_task != TeamData.TASK_MANUFACTURE: continue` 一行**。
- production 解耦成「共址 PRODUCE pop 自動工作 facility per 勞力配置」（執行層、如 gather 對稱），非 leader current_task 決策。**tick_all 其餘全不動**（ensure_fresh + labor_share 防雙算 + worker_rate + _run_recipe_group）。

## 保留 gate（自動、不新增任何 gate）
outpost(:71) / works_tile(:76) / PRODUCE resident(:80) position+type + need-gated（labor_mult fill=0→worker_rate=0 不產、§51 無 floor）+ materials（_can_consume_scaled）+ dedup（labor_share）+ 軍隊（pool_of 只 PRODUCE）。

## tap（§3 全量觀測、Probe-gated 零 RNG）
`manufacture.fired`（facility 真 RUN 次數）+ `manufacture.input_consumed`（材料消耗總量、was 0.000）+ `manufacture.output.<res>`（各產物產出量）。

## blast-radius 5 驗（全綠）
| # | 驗 | 結果 |
|---|---|---|
| 1 不過度生產 | satisfied（stock≥target）→ 不產 | **TDD PASS**（Δtools=0.000） |
| 2 economy 衝擊 | need+materials cap → 非爆量 | need-gated + materials + per-recipe stock-stop 保；**volume before/after 交 measurer §8** |
| 3 determinism | 移 gate 不加 RNG | **3 跑 byte-identical MD5 06D9B76D**（=labor-pool baseline） |
| 4 守憲 | constitution + 勞力池 invariant | **PASS 74**（current_task 檢非 tracked site → 無增；勞力池 invariant 不碰） |
| 5 領導軸 ratio | §8 re-measure 追平 | **交 measurer**（機制 unit-proven；warring 無 settled producer） |

## de-patch 生效證（TDD `mfg_labor_depatch_test` 5/5，全 fixture current_task=IDLE≠MANUFACTURE 證移閘）
- ①**de-patch 生效**：IDLE 隊在自家 outpost + need（tools demand）+ 材料 → **產 tools 0.050**（移閘前 IDLE→skip→0）。
- ②satisfied（stock 滿足+無 demand）→ 不產（不過度生產）。③有需求但無材料→不產（materials-gated）。④非自家 outpost→不產（position-gated）。⑤無 PRODUCE 居民→不產（PRODUCE-gated、軍隊排除）。

## 其他 gate
- headless **3=baseline**（p2a/197/rung pre-existing）；非凍（attrition 0.68%+84 隊）。
- ★**determinism MD5 = labor-pool baseline**：warring combat 場景無 settled producer → 移閘後多跑的隊皆缺 outpost/PRODUCE/need/materials → 產 0 → 軌跡零變 → byte-identical。=de-patch 行為中性於無可產處、只在 genuine settled producer 才 activate（need+materials 真 gate）。

## ★待你裁 / 交 measurer
- **economy volume before/after + §8 領導軸 ratio 追平**：de-patch 效果在**經濟場景**（settled producer 密集），warring 非該場景（manufacture.fired=0 combat）。→ **交你派 measurer §8 三驗**（領導軸 ratio 接近 parity？+ 全經濟 production/coin/資源水位升但非爆量崩 + need-gated 保）。誠實 measured 才宣稱（同 SLICE A、[[feedback_genuine_value_not_crank]]）。dev-verify bed 已備（TDD）。
- **依賴**：stacked on `feat/unified-labor-pool` 61b2a354 → labor-pool 先 merge。
- **follow-up**：`TASK_MANUFACTURE` option vestigial 另清（別本輪、你指示）。
- **perf**：移閘→更多隊每 tick 進 mfg tick_all（多數早退於 outpost/PRODUCE 檢）；headless/determinism 未見顯著 perf 退（warring 正常時間內完）；若 measurer §8 經濟場景見顯著再記 known_issues。

待你 R² 融合驗 → §8 三驗（領導軸+全經濟）→ §5 合量（labor pool + 甲 + 乙 + idle-labor + 本 mfg-depatch）。
