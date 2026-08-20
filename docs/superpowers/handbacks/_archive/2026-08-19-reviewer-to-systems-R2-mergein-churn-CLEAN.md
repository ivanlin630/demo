---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN] SurvivalMergeIn churn (b)arrival-never pin+根修investigation-slice HOW——①前提citation親讀interaction_system.gd:42-51+200-229確認:46 for arrived_id in arrived_ids:(到達處理迴圈)/:206 Probe.bump('join.dispatch')(JOIN到達診斷tap)/:226 (a.current_task==TASK_JOIN and a.social_target==id_b)(_social_arrive條件、resolve觸發判定的一部分)三處逐字精準命中,確認_resolve_join這條路徑本身結構完整、走到時正常運作,坐實『resolve機制沒壞、問題是joiner從沒抵達』這個因果框架;②investigation approach(T1三候選子因i移動不執行/ii cadence重評reset/iii host移動中追不上)——measure-first不預設子因,呼應這session已建立且驗證過的『症狀vs根因』方法論,跟own_granary null-caller pin那輪同款investigation-first紀律,三個候選子因彼此互斥可透過instrumentation清楚區分,設計嚴謹;③手不聽腦root非補丁:T2三種對應根修(i補movement執行/ii committed JOIN persist-to-arrival比照S2b corvee persist款/iii mobile-host proximity-resolve或host rendezvous)全部是真正解決『commit了卻沒真正發生』這個execution-break的架構級修法,非在resolve端疊補償邏輯繞過症狀,呼應project_hand_obeys_brain_arc已建立的家族診斷框架;④感知鐵律trace讀own-state(movement/target自己的)非god-view,禁耗global RNG的temp trace設計跟own_granary那輪同款紀律一致;⑤gate(churn消/team不暴增/perf回正/committed JOIN真resolve)量化具體、非空泛;判決=CLEAN→dispatch"
---

# R②判決：SurvivalMergeIn churn (b)arrival-never pin+根修 investigation-slice HOW — CLEAN

## ①前提 citation 親讀精準

親讀 `interaction_system.gd:42-51`+`200-229` 確認：`:46` `for arrived_id in arrived_ids:`（到達處理迴圈）/`:206` `Probe.bump("join.dispatch")`（JOIN 到達診斷 tap）/`:226` `(a.current_task==TASK_JOIN and a.social_target==id_b)`（`_social_arrive` 條件、resolve 觸發判定的一部分）——三處逐字精準命中。確認 `_resolve_join` 這條路徑本身結構完整、走到時正常運作，坐實「resolve 機制沒壞、問題是 joiner 從沒抵達」這個因果框架。

## ②investigation approach——measure-first、不預設子因

T1 三候選子因（i 移動不執行 / ii cadence 重評 reset / iii host 移動中追不上）——呼應這 session 已經建立且驗證過的「症狀 vs 根因」方法論，跟 `own_granary null-caller pin` 那輪同款 investigation-first 紀律。三個候選子因彼此互斥、可透過 instrumentation 清楚區分，設計嚴謹，不是先射箭再畫靶。

## ③手不聽腦 root 非補丁

T2 三種對應根修——(i) 補 movement 執行、(ii) committed JOIN persist-to-arrival（比照 S2b corvee persist 款，已在這 session 前幾輪確認過的成熟 pattern）、(iii) mobile-host proximity-resolve 或 host rendezvous——全部是真正解決「commit 了卻沒真正發生」這個 execution-break 的架構級修法，非在 resolve 端疊補償邏輯繞過症狀，呼應 `[[project_hand_obeys_brain_arc]]` 已建立的家族診斷框架。

## ④感知鐵律 + trace 紀律

trace 讀 own-state（movement/target 自己的）非 god-view；禁耗 global RNG 的 temp trace 設計跟 `own_granary` 那輪同款紀律一致。

## ⑤gate 量化具體
churn 消/team 不暴增/perf 回正/committed JOIN 真 resolve——四項皆有具體可測的量化標準，非空泛宣稱。

## 判決
**CLEAN → dispatch。**
