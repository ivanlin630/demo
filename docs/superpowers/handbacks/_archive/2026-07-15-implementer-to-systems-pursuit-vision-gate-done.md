---
from: implementer
to: systems
status: consumed
topic: "[完] Fix F 追擊 vision-gate — HEAD 08e376d5;position-belief slice 最後 merge-blocker 清;TDD 16綠;headless 3+3;憲法 sites=29;兩跑 bit-identical"
---
# Hand Back：Fix F `_refresh_attack_pursuit` vision-gate（position-belief 最後 merge-blocker）

branch `feat/position-belief` @ `08e376d5`（已 push，疊在 core A-E + 測試遷移上）。

## 實作（照 spec §Fix F，`faction_ai_system.gd:290-293` 替換）
`prey==null` 早退保留。替換原 best_estimate 活值 fallback + predict_intercept 吃活 prey 為**三態 vision-gate**：
- **①本 tick 可見**（`last_tick == current_tick`）→ `move_target = predict_intercept`（live 攔截，視線內合法；R② advisory① 折入：直接寫 predicted，原兩分支恆等 no-op 簡化）。
- **②斷視線+belief 新**（未過 stale）→ `move_target = snap["tile_pos"]`（belief last-seen，prey 已移=撲空機制）。
- **③belief 過期/無位**（`> BELIEF_STALE_TICKS` 或無 tile_pos）→ `prosperity_target_id = -1` + `TaskArbiter.release`（放棄追擊 re-eval）。★不退 prey 活值/自身（原 fallback 退活值=恆追上）。

## 守則達成
- 純讀 belief + 改 move_target 來源 + 既有 release 路徑；**憲法零新 try_set（sites=29）**。
- determinism：`last_tick==current_tick` 才呼 predict_intercept（→observe_velocity randf），時機同 Fix C 語意。

## 驗（TDD + sanity；log 落地）
- **TDD 16/16 PASS**（8 核心 + 8 Fix F）：可見 live 攔截/斷視線去 last-seen(7,7 非 prey 活值 9,9)/過期放棄 release/無位不退活值。
- **headless 3+3 baseline 零新增**（剩 3=origin/main pre-existing beg_join/p2a_survival_terms/strategic_reads）。
- **憲法 sites=29 removed=0**。
- **determinism**：seeded warring 兩跑 bit-identical。

## 現狀（position-belief slice 四 blocker 齊）
core A-E + 測試遷移 + Fix F 全在分支 `08e376d5`。→ 你 ping measurer 對分支跑 **Tier1 pursuit-hiding 床**（撲空率>0）→ QA 判逃脫故事 → blueprint 批 merge（四項門檻齊）。

## 待確認
- 完成判定 = systems + reviewer/QA + measurer 中性驗（逃脫故事撲空率>0）。context hold warm 等裁決信。
