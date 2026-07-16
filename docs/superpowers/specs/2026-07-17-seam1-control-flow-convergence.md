# Spec：seam#1 控制流收斂（真統一 + 擴充，零殘留 stream①/stream②）

> 框架做好 stream① 軌1（控制流閘收斂）+ stream② seam#1（一舉兩得:真統一+擴充）。
> 用戶標準：真統一=每決策真只走一條（零手派 return-gate 路由、零散落入口）。北極星：一次遭遇→一 encounter eval。

## 根（結構已讀 + Arc2 R① 驗，premise 坐實）
`decision_engine.gd`：
- **`rank_scored`/`rank_scored_ctx`（`:15/23`）= 主統一 rank**：全 `DocisionOptions.applicable(ctx)` pool + util 秤 + argmax；**survival 已整合**（`:37` `food_days<SURVIVAL_BOOST_FLOOR` → SURVIVAL_OPTION_SET 等量加法破頂奪 argmax）。=canonical 一條路。
- **`rank_survival`（`:105` applicable∩SURVIVAL_OPTION_SET）/`rank_threat`（`:134` applicable∩THREAT_OPTION_SET[survival/備戰/迎戰/求和]）/`rank_ambient`（`:159` applicable∩AMBIENT_OPTION_SET）= filtered subset**：**非統一路 scaffolding**（loop3）按 context 手派選哪個 subset dispatch。
- **控制流閘（gate v2 baseline 未標）**：route×10（`_evaluate_survival/threat/solo/subteam/uprising/independent_strategy/all_body`/`_decide_subteam`/`_trigger_survival`/`options.applicable`）+ dispatch_entry（4 rank_* 散落入口 + `_evaluate_*`）= **手派 return-gate 路由**（`if uses_unified: return` 按隊型分流）。

## 目標：全隊一條路（rank_scored），退役 filtered-subset 非統一路
- **收斂**：所有隊決策**走 `rank_scored`（統一全 pool rank）**，退役 `rank_survival`/`rank_threat`/`rank_ambient` 作為**獨立 dispatch 入口** + 其手派路由。
- **語意保**：subset 的語意 rank_scored **已含**——survival（`:37` boost）、threat 選項（備戰/迎戰/求和 在 applicable + threat 權重）、ambient（訓練/貿易/生產… 在 applicable）。**收斂=非統一隊也走 rank_scored**（全 pool），非新造。
- **registry（擴充,stream② seam#1）**：`applicable()`+`to_task()` 的 per-option match → **REGISTRY 化**（option 為 data entry:{applicable_pred, term_weights, to_task}）。加 option = registry 1 entry，非碰多處 match/switch。收斂與 registry 一體（一條 rank over registry pool）。

## ★關鍵設計（語意合併，Arc2 R① flagged 的開放問題）
- **survival「軟」（主 rank boost）vs threat「硬」（rank_threat filtered）語意合併**：rank_scored 的 survival-boost 是軟整合（隨 food→0 線性破頂）；threat 目前非統一走 rank_threat filtered（硬子集）。**收斂 = threat 選項進全 pool、用 threat 權重競秤**（非 filtered 硬切）。**風險**：非統一隊 threat 行為可能變（filtered-hard→full-pool-weighted）。→ **measure 乾淨全量驗**：threat 反應（備戰/迎戰/求和/FLEE）率、preempt、survival 保序。
- **preempt scaffolding（序3.5 忙碌目標打斷）**：現活在 `_evaluate_threat`（非統一）——收斂後 preempt 語意（強威脅打斷非緊急 task）須保（走統一 rank 的 threat 權重仍能 preempt，或 preempt 是 world-mechanic scaffolding 保留）。impl 明確。

## 交付切片（TDD）
- **S1 registry 化 applicable+to_task**（stream② seam#1）：option→data entry，`applicable()`/`to_task()` 讀 registry（消兩平行 match）。加 option=registry entry 驗（擴充性 proof）。**byte-identical**（純重構,同 pool 同序）。
- **S2 收斂非統一 dispatch → rank_scored**：退役 `_evaluate_survival/threat` 等非統一 filtered dispatch + 手派路由，全隊走 rank_scored。preempt scaffolding 保。**行為變（非統一隊）→ 乾淨全量**。
- **S3 退役 rank_survival/threat/ambient 獨立入口 + baseline gate removed**：控制流閘（route/dispatch_entry）從 gate baseline removed（零殘留進度）。
- ★整 seam 完成才 measurer 乾淨全量（非拆一塊就量）。

## 非回歸
- **survival 保序**（絕境 FLEE/覓食/買糧 rank_scored boost 仍奪 argmax，不被發展選項蓋）。
- **threat 反應保**（備戰/迎戰/求和/preempt，收斂後全 pool 權重仍 fire）。
- **感知鐵律 / 守恆 / 觀測 byte-identical（S1 registry）**。
- **憲法閘**：控制流閘 removed（進度）、無新增、task-dispatch scaffolding 不誤傷。

## 閘
- **R② 必過**（大框結構重構,核心決策路徑）；**建議升異質框外審**（真統一北極星、blueprint/systems 對齊、redirect 核心）。
- premise 已坐實（結構讀 + Arc2 R①）→ R① 免（但語意合併風險標 measure）。
- **measurer 乾淨全量**：全隊一條路（gate 控制流閘 removed）、survival/threat/ambient 行為保、擴充性 proof（加 option=registry entry 動幾處）、無回歸、byte-identical(S1)。

## 溯源
Arc2 R① `arc2-r1-clean`（4 rank_* 同 pool filtered + 手派路由）；用戶真統一標準；encounter-north-star（invariants）；stream② seam#1（applicable+task→REGISTRY）；[[project_unification_matrix]] 憲法 arc unified/non-unified 雙路。
