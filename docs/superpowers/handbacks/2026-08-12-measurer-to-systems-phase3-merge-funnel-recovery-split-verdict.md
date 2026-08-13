---
from: measurer
to: systems
status: consumed
topic: "[#3②merge funnel真塌點比預期更早+#3③migrant/invest真塌點=找不到可用holding非precondition非decision]①你點名的併入funnel(pair_seen/try_entered/accept)全程0/0/0/0/0——168次consolidate_dispatch/set_ok後execution從未engage一次,8次真完成(mergein.dissolve+subteam)另有源頭=_resolve_mergein第二呼叫點(accept.join_accept弱方join路,interaction_system.gd:1287,跟你點名的強拉路徑:511完全不同機制)②migrant/invest三段funnel:reached_entry→precond_block只擋61%/26%,真正瓶頸在precondition過關後找holding這段(migrant147/148、invest277/282過關後找不到可用target,連evaluated都到不了)——偏propagation/target-availability而非decision-under-fire,但無法100%排除genuine self-preservation"
---

# #3② merge funnel 塌點 + #3③ recovery precondition-split —— 兩題都比假設更早塌

## #3② merge 執行 funnel —— 你點名的鏈路全程 0，真塌點在更早一步

你結構列舉的鏈路（`consolidate_dispatch→set_ok→[travel]→pair_seen→try_entered→{guard_fail|accept_reject|accept_accept}`）我逐段讀 counter：

```
merge.consolidate_dispatch  168
merge.set_ok                168
merge.pair_seen               0
merge.try_entered             0
merge.guard_fail_ordertgt     0
accept.merge_reject           0
accept.merge_accept           0
```

**決策層+order-set 都很活躍（168次），但 `pair_seen`（co-location 有無發生過）整個 2 個月連 1 次都沒有。** 這代表塌點不是你假設的「travel 到了但沒踫到面」或「踫到面但 target 已搬走」或「genuine feed_ok 拒收」——這些全部要先過 `pair_seen` 才有機會發生，而 `pair_seen` 本身是 0，比整條假設鏈更早就塌了。

但 `mergein.dissolve`=4、`mergein.subteam`=4（總計 8 次真完成）不是 0——查 code(`interaction_system.gd:1292` `_resolve_mergein`)發現這個函式有**兩個呼叫點**：
- `:511`（你點名的這條：強方吸弱，`accept.merge_accept` 後呼叫——這條 0 次）
- `:1287`（另一條：**弱方 push／`_resolve_join`→`accept.join_accept`→`_resolve_mergein`**——完全不同的觸發機制，跟「併入」決策/`consolidate_dispatch` 無關）

★合理推論（非 100% 追蹤到每一筆，但 accept.merge_accept=0 已排除強拉路徑）：**這 8 次完成很可能全部來自「弱方主動 join」，跟「併入」決策 168 次下的 order 一次都沒有真正走完**。也就是說「併入」這個決策選項，從決策→下 order 都正常，但**下完 order 之後這個 team 好像從沒有真的走到跟 target 碰面過一次**——是 travel/movement 沒發生，還是 order 設好了但沒人真的去執行移動，這輪數字看不出來（要分辨需要再加一個「TASK_MERGE 隊有無 move_target」或「TASK_MERGE 隊有無實際位移」的 tap，這輪沒做）。

## #3③ migrant/invest —— 精確三段 funnel，塌點在「找不到可用 holding」而非 precondition 或 decision

```
migrant:  reached_eval_entry=384 → precond_block_pop=236 → util_evaluated=1
invest:   reached_eval_entry=384 → precond_block_pop=101, precond_block_food=1 → roi_evaluated=5
```

換算：migrant 過了 precondition 的還有 384-236=**148** 次，但只有 **1** 次走到 util 計算——**147/148（99.3%）在「掃 holding 找正邊際 target」這段silently drop**。invest 過了 precondition 的還有 384-101-1=**282** 次，只有 **5** 次走到 roi 計算——**277/282（98.2%）同樣在這段drop**。

這是**很乾淨、兩個機制一致的訊號**：precondition（領主自身 pop/food 崩潰自保）確實有擋（migrant 擋 61.5%、invest 擋 26.3%），但**不是主要瓶頸**——真正吃掉幾乎所有殘餘機會的是 precondition 過關之後、util/roi 計算之前那段（掃 `dispatch_ledger` 的 holding 條目 + `_village_est` belief 查詢）。這比較支持 **propagation/target-availability 這支**（找不到可用 target，不是不划算才不做），跟 decision-under-fire（評估了但覺得不划算）完全不符——decision-under-fire 這支上一輪已經被 100% 轉換率排除，這輪進一步確認瓶頸更早，在「連評估都到不了」這一步。

★誠實限制：我沒辦法從現有 tap 分清楚這 147/277 筆是「`dispatch_ledger` 裡根本沒有 holding 條目」（領主連自己村都沒登記，更基礎的問題）還是「有 holding 條目但 `_village_est` 每次都回 null」（真正的 belief-propagation 缺口，對應 ticket 假說的 info-net :79 共位路徑）——這兩者都會落在同一個「silently drop」桶。若要精確分開需要再加一層 tap（分別數 holding 條目數 vs est-null 次數），這輪沒做，交你判斷值不值得再開一輪。

## Determinism

第三次確認：這輪換了新 tap 集合重跑（同 seed1337、官方 `SpecimenDumpHelper` 選法），`specimen.jsonl` 逐位元跟前兩輪（`868e7a8b`/`10b273dc`）完全一致，聚合數字（promote/migrant/invest/relocate/pop/teams）也全部吻合——這條 bed 現在穩定中性，可放心繼續疊 tap 用。

## 落地檔案（已 commit `3f562a55`）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.json`（補 merge funnel + migrant/invest 三段 funnel 欄位）
- `docs/measurements/2026-08-13-phase3-funnel-evidence.txt`（跑完終態 raw tail，佐證上面數字）
- 5 個 precondition temp tap + 沿用既有 merge funnel tap，皆已 revert（`git status` 確認乾淨）

specimen 沿用已送 QA 的批次（這輪結論全部是聚合 counter 直讀，非新 behavior-causal specimen claim）。

routing：#3②「決策一直下 order 但 execution 從沒engage過一次」這個訊號本身可能比原本猜的任一分支都更值得優先看；#3③兩機制一致指向 propagation/target-availability，建議跟 blueprint 的 fix 優先序一起看要不要先補那層 tap 精確分清，還是先接受目前這個 evidence 等級往下走。
