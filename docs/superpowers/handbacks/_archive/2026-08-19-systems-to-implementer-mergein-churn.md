---
from: systems
to: implementer
status: consumed
topic: "[dispatch SurvivalMergeIn churn (b)arrival-never pin+根修·base main b223a862·spec=2026-08-19-mergein-churn-arrival-pin-HOW.md R²-CLEAN(reviewer親讀resolve路結構完整、investigation measure-first三候選互斥、T2手不聽腦架構級根修非補丁)·★(b)arrival-never定案(probe:join.resolve~10 vs commit 698=1.4%=joiner從沒抵達host、每cadence重commit反覆)=hand-obeys-brain家族(project_hand_obeys_brain_arc、12mo大考#4/S2b corvee cousin)·★T1 runtime-trace pin sub-cause(禁耗global RNG的temp trace、同own_granary款):instrument JOIN-committed隊追(i)movement不執行(try_set TASK_JOIN後MovementSystem有無真朝join_pos移動、move_target設否path推進否)(ii)cadence重評reset(survival re-eval每cadence是否重commit JOIN reset task_start/move在到達前=persist太弱S2b corvee款、_should_reeval cadence頻率vs移動到達時間)(iii)移動host chase(join_pos追移動中host每commit更新host現位joiner永不及)·seeded短局跑捕churn(day51左右密集)→pin i/ii/iii→★T1 handback附caller/機制+我確認根再T2(或鏈清直接T2)·★T2根修依T1:(i)→補movement執行(JOIN task驅move到join_pos)(ii)→JOIN survival persist-to-arrival(committed JOIN在途不被cadence重評reset/蓋、比照S2b corvee persist款、到達或timeout才釋放)(iii)→mobile-host proximity-resolve(不強求精確co-locate)or host rendezvous·移T1 trace·★手不聽腦root非補丁(別在resolve端疊繞過)·感知鐵律讀own-state(movement/target自己)·gate:churn消(join.resolve/commit比例回正非1.4%)+team不暴增(49→242病消)+perf回正(40-70×消)+committed JOIN真resolve+determinism+constitution+不破既有JOIN/survival+fp intended·worktree feat/mergein-churn-fix·完→handback附measurer·地基KEEP"
---

# dispatch SurvivalMergeIn churn (b)arrival-never pin + 根修

spec=`docs/superpowers/specs/2026-08-19-mergein-churn-arrival-pin-HOW.md`（**R²-CLEAN**）。base=main `b223a862`。與農業b re-measure/labor-v2 **平行**。

## ★(b)arrival-never 定案
probe：`join.resolve` ~10 vs commit 698=**1.4%**=joiner 從沒抵達 host、每 cadence 重 commit 反覆=hand-obeys-brain 家族（12mo 大考#4 / S2b corvee cousin）。

## ★T1 runtime-trace pin sub-cause（禁耗 global RNG、同 own_granary 款）
instrument JOIN-committed 隊追：
- **(i) movement 不執行**：try_set TASK_JOIN 後 MovementSystem 有無真朝 join_pos 移動（move_target 設否/path 推進否）。
- **(ii) cadence 重評 reset**：survival re-eval 每 cadence 是否重 commit JOIN（reset task_start/move）在到達前=persist 太弱（S2b corvee 款、`_should_reeval` cadence 頻率 vs 移動到達時間）。
- **(iii) 移動 host chase**：join_pos 追移動中 host（每 commit 更新 host 現位、joiner 永不及）。
- seeded 短局跑捕 churn（day51 左右密集）→ pin i/ii/iii → **T1 handback 附 caller/機制 + 我確認根再 T2**（或鏈清直接 T2）。

## ★T2 根修（依 T1、手不聽腦 root 非補丁）
- **(i)→** 補 movement 執行（JOIN task 驅 move 到 join_pos）。
- **(ii)→** JOIN survival persist-to-arrival（committed JOIN 在途不被 cadence 重評 reset/蓋、**比照 S2b corvee persist 款**、到達或 timeout 才釋放）。
- **(iii)→** mobile-host proximity-resolve（不強求精確 co-locate）or host rendezvous。
- 移 T1 trace。★別在 resolve 端疊繞過補丁。感知鐵律讀 own-state。

## gate（measurer bounded）
churn 消（join.resolve/commit 比例回正非 1.4%）+ team 不暴增（49→242 病消）+ perf 回正（40-70× 消）+ committed JOIN 真 resolve + determinism + constitution + 不破既有 JOIN/survival + fp intended。

worktree `feat/mergein-churn-fix`。完 → handback 附 measurer。地基 KEEP。
