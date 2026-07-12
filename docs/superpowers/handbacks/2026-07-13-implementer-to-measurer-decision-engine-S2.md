---
from: implementer
to: measurer
status: consumed
topic: 決策引擎重構 S2 交付 — coeff架構原子切換+plan_phase退役;branch feat/decision-needs-hierarchy已push,待organic全23覆蓋/行為連貫
---
# Hand Back: 決策引擎重構 S2（架構原子切換）

branch `feat/decision-needs-hierarchy`（已 push，含 S1+S2 全 commit）。plan `docs/superpowers/plans/2026-07-13-decision-engine-needs-hierarchy.md` Slice 2 + 增補 spec `2026-07-13-need-raw-readiness-increment.md`（S2.0）。

## 實作摘要（逐 task commit）
- **S2.0**（裁 B 就緒度）：`compute_raw` L_ESTEEM/L_ACTUAL 改就緒度語意——esteem=`food_ready×safe_ready×ambition_gap`；actual=`ff_ready×pop_ready×faction_ready×gap`（solo→0）。低層(生存/安全/歸屬)不動。守 §2 獨立（只讀世界訊號）。
- **S2.1**：`AFFINITY` const 表 23×5（行和≈1）+ `affinity_of`（未列→均勻）。純 lookup 零分支。
- **S2.2**：`consistency_coeff = clampf(1-steepness·(1-alignment), FLOOR=0.15, 1)`，alignment=Σaff·urgency，steepness 人格陡度(慎重↑/野心↓)。軟降權不歸零。
- **S2.3**：`rank_scored_ctx` util `×= coeff`（全 23 統一，乘 COMMITMENT_BONUS 前）。
- **S2.4**：`narrative_label`(argmax 層→求生/警戒/歸附/立業/立國) → gather 尾寫 `team.plan_phase`（GUI 來源改接，讀點不變）。
- **S2.5**：`plan_phase` **完整退役**——terms(eval+weight)/options(6 REGISTRY row)/decision_context(PHASE 常數+plan_phase_drive_map+derive_plan_phase+_phase_option_bias+gather 三行)。sim code 零殘引用（grep 驗）。team.plan_phase 欄保留純顯示。
- **S2.6**：probe `decision.coeff_applied_n`(全 23 覆蓋)+`decision.coeff_lowhalf`(遠層壓比例)。

## ★放寬的 unit 測（裁 A，明列不靜默）
逐測加 `coeff-era(裁A)` 註解：
1. `_test_tc7_divergence`：`uniq==3` → **`uniq>=2`**（全隊同需求態可收斂個性，同 plan-layer S2 先例；保留 print 三隊 option 供 organic cross-ref）。
2. `_test_govern_warmonger_roams`：`!="治理"` → **`!=TASK_IDLE`**（產出 actionable；solo 低就緒→需求驅動落點 organic 驗）。
3. `_test_govern_enough_stops`：同上 `!=TASK_IDLE`。
- **硬 invariant 未動**（survival/安全/determinism/資源守恆嚴格擋）。跑全 headless 無其他 coeff 破測（僅上 3 放寬）。

## 我方自驗（融合閘全綠）
- **headless**：全新 test PASS（affinity/coeff/readiness/narrative_label/rank_coeff/plan_phase_retired）；**0 新增 SCRIPT ERROR**（3 pre-existing p2a/beg_join/strategic_reads 同 main baseline）。
- **constitution PASS**（sites=29）；**multi sanity 0 SCRIPT ERROR**；**determinism byte-identical**（1337×1mo cmp）。

## 待驗收（spec §驗收）
1. **全面覆蓋**：刻意製造某層急迫 → 原本無 bias 的 12 option（生產/建設/駐守/囤貨/徵收/歸建/備戰/迎戰/求和/吸納/乞食/佔村）分數隨之變（`decision.coeff_applied_n` 涵蓋全 option）。
2. **行為連貫性**：同隊不在同時段於不相關行動間搖擺（organic multi-seed）。
3. **determinism** byte-identical（我已初驗）。
4. **軟降權不死鎖**：無 option structurally 永遠選不到（baseline 觀察，S3 補鬆綁前）。

## ★measurer 校準項（systems 附，我不改，記此供你）
- **駐守 affinity 標 actual-heavy(0.5) 語意待校**：駐守=定居知足≠nation-striving，organic 若顯 settle 型被壓則校此。
- **coeff needs-vs-人格 平衡點**（TC7 collapse 揭）：organic full_probe 看跨 seed 人格是否真 collapse → collapse=帶數據 tune 平衡點的真 finding（非 unit 硬湊）。

## 連動風險 / 註
- coeff 系統性位移 argmax baseline（行為改動非 regression，baseline 位移標記）。unit close-call 測已放寬 3 個（上列），organic 為真閘。
- 序：S2 merge 後 systems dispatch S3（卡住自動鬆綁 anti-deadlock）。
