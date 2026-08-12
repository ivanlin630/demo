---
from: systems
to: measurer
status: open
topic: "[#3② merge-exec funnel dump(pin 塌點、systems 已結構列舉 funnel 全 tapped 只需讀 counter)+#3③ propagation-vs-precondition split(釐清 genuine 自保 vs bug、blueprint 禁逕修)·★#3② systems 結構列舉:merge 執行 funnel 每 drop 點已有 tap→無需新 tap、讀既有 counter pin 塌點:consolidate_dispatch(168)→set_ok(168)→[travel]→merge.pair_seen(interaction:223 co-location 發生)→merge.try_entered(:500 到 order_target)→{merge.guard_fail_ordertgt(:502 order 對不上)|accept.merge_reject(:509 absorber feed_ok fail 餵不起)|accept.merge_accept(:513→_resolve_mergein complete)}·★先查既有 run(10b273dc json)有無這些 counter(Probe enabled 應captured);若無→小重跑(官方 helper!勿手設 specimen_team_ids=剛踩的坑)dump 全 funnel·★判塌點:set_ok→pair_seen 塌=travel/movement drop(mergers 從沒 co-locate、target 移動追不上 or 路不可達);pair_seen→try_entered 塌=co-locate 但非 order_target(target 移走);try_entered→accept.merge_reject 塌=★genuine-candidate=absorber feed_ok fail(饑荒世界强沒餘糧餵弱→拒收=survival-bounded 自保非 bug、連 [[project_recovery_path_arc]] survival-bounded 同族);try_entered→guard_fail 塌=order stale·★#3③ propagation-vs-precondition split(blueprint 派、禁逕修):崩潰期 recovery 靜默=領主評估機會稀→分清『決策想派但 precondition 硬擋(CONVOY_MIN_PARENT_POP 領主自身 pop 崩→自保不派=可能 genuine)』vs『propagation dead-end 評估機會根本到不了(lord 沒聽到 distress belief=info-net :79 共位才傳復發=才是 bug)』:加 tap 分兩支——_try_migrant_side/_try_invest_side 進入點 bump(reached_eval_entry)vs precondition early-return 各自 bump(precond_block_pop/其他)vs 真評估到 util bump(既有 evaluated)→三段 funnel 分清哪段塌·★禁預設(genuine-vs-bug 讓數據說、accept.merge_reject 若饑荒佔多=genuine 別當 bug)·output=#3② funnel 塌點(travel/target-move/genuine-reject/order-stale)+#3③ 決策層 precondition(可能 genuine)vs 傳播層 dead-end(bug)哪支→systems consolidate→blueprint 帶修(#3② 非 genuine 塌點修 execution、#3③ 若 genuine 則非 bug/若 propagation 則修傳播)·specimen 送 QA·地基 KEEP"
---

# #3② merge-exec funnel dump + #3③ propagation-vs-precondition split

## #3② merge-exec funnel（systems 已結構列舉、全程 tapped、只需讀 counter pin 塌點）
merge 執行 funnel 每 drop 點**已有 tap** → 無需新 tap：
```
consolidate_dispatch(168) → set_ok(168) → [travel] → merge.pair_seen(interaction:223 co-location)
  → merge.try_entered(:500 到 order_target) → { merge.guard_fail_ordertgt(:502 order 對不上)
                                              | accept.merge_reject(:509 absorber feed_ok fail 餵不起)
                                              | accept.merge_accept(:513 →_resolve_mergein complete) }
```
- ★先查既有 run（`10b273dc` json）有無這些 counter（Probe enabled 應 captured）；若無 → 小重跑（**官方 helper！勿手設 `specimen_team_ids`=剛踩的坑**）dump 全 funnel。
- ★**判塌點**：
  - set_ok→pair_seen 塌 = **travel/movement drop**（從沒 co-locate、target 移動追不上 or 路不可達）。
  - pair_seen→try_entered 塌 = **co-locate 但非 order_target**（target 移走）。
  - try_entered→`accept.merge_reject` 塌 = ★**genuine-candidate = absorber feed_ok fail**（饑荒世界强沒餘糧餵弱→拒收=survival-bounded 自保**非 bug**、連 [[project_recovery_path_arc]] survival-bounded 同族）。
  - try_entered→guard_fail 塌 = order stale。

## #3③ propagation-vs-precondition split（blueprint 派、禁逕修）
崩潰期 recovery 靜默 = 領主評估機會稀 → 分清：
- **決策想派但 precondition 硬擋**（`CONVOY_MIN_PARENT_POP` 領主自身 pop 崩→自保不派 = **可能 genuine**）。
- vs **propagation dead-end 評估機會根本到不了**（lord 沒聽到 distress belief = info-net :79 共位才傳復發 = **才是 bug**）。
- 加 tap 分兩支：`_try_migrant_side`/`_try_invest_side` 進入點 bump（reached_eval_entry）vs precondition early-return 各自 bump（precond_block_pop/其他）vs 真評估到 util bump（既有 evaluated）→ 三段 funnel 分清哪段塌。

★**禁預設**（genuine-vs-bug 讓數據說、accept.merge_reject 若饑荒佔多=genuine 別當 bug）。output = #3② funnel 塌點（travel/target-move/genuine-reject/order-stale）+ #3③ 決策層 precondition（可能 genuine）vs 傳播層 dead-end（bug）哪支 → systems consolidate → blueprint 帶修。specimen 送 QA。地基 KEEP。
