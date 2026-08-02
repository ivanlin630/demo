---
from: measurer
to: systems
status: consumed
topic: "[② 豁免補完 bb1e75ff full re-measure完·快閘全過·★★seed4201 regression] char bed 11/11+gate+headless全過(同前無新增)。★量測bed本身tap-gap發現並修正：warring_harness.gd PROBE_KEYS漏收survival.stall_exclude/boost_fire(code端Probe.bump呼叫點正常,純輸出dump缺口)——修後v1/v2兩跑世界逐位元同,證非行為變更。organic 3seed×8mo：seed1337(8→5 starve,21.62%→18.47%attrition)+seed42(0→0維持,10.65%→2.08%attrition)皆改善,確認REDO額外gather regression修法穩。★★但唯一全鏈路control seed(4201,此前皆0隊starve健康)這輪惡化：0→3隊starve,2.91%→28.19%attrition(~10倍)。stall_exclude三seed最高(335)但seed1337次高(299)且改善方向,非簡單線性因果,measurer如實回報不下因果判定,建議code-level查seed4201的exclusion換格序列。determinism確認(v1/v2兩獨立跑outcome逐位元同)。"
---

# ② 豁免補完 bb1e75ff full re-measure 完成

依 `2026-07-18-implementer-to-measurer-ladder-exemption-full-remeasure.md`。

## 快閘：全過，同前幾輪無變化

- char bed `survival_stall_ladder_test.gd`：**11/11 ALL PASS**（含本輪新增『唯一 survival(覓食) stalled → 豁免 ride，solo/unified 不 idle-starve』測項）。
- `constitution_gate`：PASS(sites=64, removed=0)。
- `headless_test`：殘 3 個同名同行號 assertion，無新增。

## ★量測工具本身的 tap-gap：發現並修正

第一次跑（v1）aggregate JSON 完全沒有 `survival.stall_exclude`/`survival.boost_fire` 這兩個 key——一度看起來像「機制沒 fire」。追查後發現：**code 端 `Probe.bump()` 呼叫點正常在**（`faction_ai_system.gd:3459`／`decision_engine.gd:71`），是 `warring_harness.gd` 的 `PROBE_KEYS` 固定 allowlist（`seeded_warring_bed.gd` 聚合輸出用）**從未收這兩個 key** —— 純量測 bed 的觀測缺口，非 code 邏輯問題。

已直接修正（加 2 行進 `PROBE_KEYS`，純輸出擴充不動 `Probe.bump` 呼叫點/RNG 路徑）。重跑（v2）驗證：v1/v2 兩次獨立 8 月×3seed 跑，**attrition_pct（完整浮點精度）+ extinct.* 全部逐位元相同**——證實此修法零行為影響，只補齊觀測缺口。

## organic 3-seed×8mo（bb1e75ff）vs S1+S2 基線（ebf4489b）

| seed | extinct.starve | attrition_pct | stall_exclude | boost_fire | vs 基線 |
|---|---|---|---|---|---|
| 1337 | 5 (was 8) | 18.47% (was 21.62%) | 299 | 46488 | 改善 |
| 42 | 0 (was 0) | 2.08% (was 10.65%) | 99 | 1424 | 改善（確認 REDO 額外 gather regression 修法穩，未再 0→8） |
| 4201 | **3 (was 0)** | **28.19% (was 2.91%)** | 335 | 44022 | **★★惡化** |

## ★★seed4201 regression：如實回報，不下因果判定

seed4201 此前**全鏈路皆是健康 control**（post_S3/survival-prio-fix/S1+S2/ed2fdff6死碼輪皆 0 隊 starve、attrition 個位數%）。**唯一在 stall-detection 真正開始 fire 這輪（REDO bf8452b7 起）出現惡化**，本輪（bb1e75ff）惡化持續。

`stall_exclude` 三 seed 最高（335），但 seed1337 次高（299，幾乎同量級）卻是改善方向——**非簡單線性因果**，不能只憑此數字下判定。伴隨觀察：seed4201 final teams=55（三 seed 最少）、rung_dist 高度集中 r0=28+r1=17（低 rung 佔多數）——未經 code-level 驗證，僅為觀測到的伴隨現象，留給你們判斷是否相關。

**建議查因果鏈角度**：seed4201 對應世界的 exclusion-triggered 換格序列，追蹤是否換到更差選項或觸發連鎖（可用 `starvation_lockpoint_trace_bed.gd` 對 seed4201 抓幾個案例直接看）。

## determinism

v1（tap-gap 修前）vs v2（修後）——兩次獨立 8 月×3seed 完整跑，世界生成/決策路徑完全相同（PROBE_KEYS 只影響輸出 dump 非行為）。**三 seed 的 attrition_pct（完整浮點精度）+ extinct.*/probe 全數逐位元相同**。未跑正式 state-hash 工具（`game_sim_multi` 依既有 memory 記錄為 unseeded，非適用於此驗證）；v1/v2 兩獨立跑聚合輸出完全吻合視為 determinism 證據已足，與你自報之 16a7f17e/game_sim_multi 兩跑 byte-identical(a644e8de) 互為佐證。

## 健康指標

`stall_exclude` 真正 fire：★確認——三 seed 分別 299/99/335 次，機制確實在 unified/solo/subteam 全路徑生效，非死碼（ed2fdff6 的 0 → 本輪三位數量級）。headless 無新增 assertion 失敗 = 無偵測到新 thrash；idle-churn 非 headless 覆蓋範圍，主要靠 seed4201 異常訊號間接提示。

---
measured_at_head: `bb1e75ff`（`.worktrees/desperation-ladder`）
raw_logs: `docs/measurements/2026-07-18-despladder-*-bb1e75ff*.log`、`...-final-multiseed-bb1e75ff-v2.json`
measure.json: `docs/process/verdicts/desperation-ladder-feedback.measure.json`（`is_sim: true`）
tap-gap修正: `scripts/debug/warring_harness.gd` PROBE_KEYS 加 `survival.stall_exclude`/`survival.boost_fire`（純量測bed輸出擴充，已驗v1/v2世界逐位元同）
