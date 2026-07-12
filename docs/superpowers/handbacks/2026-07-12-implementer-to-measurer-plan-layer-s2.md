---
from: implementer
to: measurer
status: consumed
topic: 計畫層 S2 實作交付 — phase導出+plan_phase_drive偏置term(裁決B移貿易);branch feat/plan-layer-s2已push,待驗收
---
# Hand Back: 計畫層 S2（phase 導出 + 偏置 term）

branch `feat/plan-layer-s2`（已 push，疊 main d67a7a7 含 S1）。plan `docs/superpowers/plans/2026-07-12-midlong-term-plan-layer.md` **Task 2**（含 systems 裁決 B）。

## 實作摘要
- `scripts/data/team_data.gd`：+`plan_phase: String`（gather 導出持久，供 S4 GUI/hysteresis）。
- `scripts/simulation/decision/decision_context.gd`：
  - const `PHASE_NONE/SEEK_FOOD/GROW/GATHER/ESTABLISH` + `PLAN_PHASE_DRIVE_MAG=0.4`；欄 `plan_phase`/`plan_phase_drive_map`。
  - `derive_plan_phase(state, team)`：缺口偵測（低階優先 糧>人>勢>立國；子隊→NONE），純機械+人格複用 AmbitionLadder 門檻，零 randf。
  - `_phase_option_bias(phase)`：SEEK_FOOD→{覓食,買糧}／GROW→{返家補給,紮營}／GATHER→{外交,併入}。
  - gather：填 `c.plan_phase`/`c.plan_phase_drive_map` + 持久 `team.plan_phase`。
- `scripts/simulation/decision/terms.gd`：+`plan_phase_drive` term（回 `ctx.plan_phase_drive_map.get(opt,0)`）+ weight `plan_phase_drive`=1.0（比照 intent_fit）。
- `scripts/simulation/decision/options.gd`：6 option +`["plan_phase_drive","plan_phase_drive"]` REGISTRY tuple（覓食/買糧/返家補給/紮營/外交/併入）。
- `scripts/debug/headless_test.gd`：+`_test_plan_phase_derive`（缺糧→求糧/糧足人少→成長/子隊→NONE）+`_test_plan_phase_bias`（求糧偏覓食不偏攻擊 + term eval 生效），皆 PASS。

## ★裁決 B（systems，卡點解）
- **SEEK_FOOD map 移除「貿易」**：貿易=致富 intent 主表達（intent_fit 致富→貿易 已驅）；設計原則=phase map 只含 phase 內在選項，排除他 intent 主表達。
- **成效**：`_test_tc7_divergence` 硬 bar 自動 PASS（霸主→建設/商人→貿易走 intent_fit/隱士→駐守，3 distinct）；reviewer 貿易雙偏置 watch **徹底歸零**（貿易只 intent_fit 驅，phase 零觸），非只壓低。

## 我方自驗（非驗收，供參）
- headless `=== DONE ===`，2 phase 測 [OK] + `TC7 divergence OK`。
- **0 新增 SCRIPT ERROR**：3 = pre-existing（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`，S1 已對照 main baseline 同集）。TC7 修後淨新增=0。
- **determinism byte-identical**：`WARRING_SEEDS=1337 WARRING_MONTHS=1` 兩跑 `cmp` 相同（phase 導出純算術零 randf）。
- constitution_gate PASS（sites=29，removed=0）。
- **冗餘 lens 自查**：plan_phase_drive（中長期 phase 承諾偏置）vs intent_fit（短期意圖）vs ambient_train（練兵 base）語意分層；貿易雙偏置 = 0（裁決 B 移除）。

## 待驗收（plan §驗收 + 裁決附帶 watch）
1. **phase 分布**：不同個性/隊形 **≥2 種明顯 phase 序列模式**（誠實非「全不同」）。
2. **偏置生效**：求糧隊真偏覓食/買糧；聚勢隊偏外交/併入。
3. **★GROW「紮營」watch（裁決附帶）**：GROW 隊有無 collapse 定居 vs 非定居分歧（紮營近定居主表達）——若實測破同原則→下輪移除。本 slice 不預先動 GROW（TC7 未撞它）。
4. **★貿易 util 量級（reviewer watch）**：確認貿易無異常疊加（現應純 intent_fit，phase 零觸）。
5. **determinism** byte-identical（我初驗 1seed×1mo；你擴）。
6. **融合閘**：constitution（我綠）/coin/framework/sanity 綠。baseline 位移（phase 偏置改行為）標記。

## 連動風險
- plan_phase_drive 偏置 6 option → 相關 phase 隊 option 選擇位移（baseline 位移非 regression）。
- GROW/紮營 潛在 collapse（見 watch#3）。
- 序列：S2 merge 後 systems 才 dispatch S3。本 slice 讀 rung 不碰 rung。
