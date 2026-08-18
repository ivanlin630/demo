# SurvivalMergeIn churn (b)arrival-never pin + 根修（HOW / systems）

status: DRAFT→R²（2026-08-19）
owner: systems（HOW）← measurer probe-pin (b)arrival-never CONFIRMED + blueprint churn-first ruling
溯源：農業b interim 揪 698× SurvivalMergeIn churn（team 暴增 49→242、perf 40-70×）→ probe-pin：`join.resolve` ~10 vs commit 698=**1.4%**=**(b)arrival-never**（joiner commit JOIN 但從沒移動抵達 host、每 cadence 重 commit 反覆）。=hand-obeys-brain / committed-but-never-resolves 家族（[[project_hand_obeys_brain_arc]]、12mo 大考#4 前科、S2b corvee cousin）。

## §0 命門
- **★手不聽腦 root 非 sticky 補丁**：committed JOIN 必真 resolve（到達 host co-locate 觸發 `_resolve_join`）；別加繞過補丁。
- **感知鐵律 self-knowledge**：讀自己 movement/target（own-state）、非 god-view。
- **★fp NOTE**：churn 疑 pre-existing（非農業b、農業b 弱隊放大現形）；修=行為變（churn 消→team 不暴增）、fp intended-change。
- determinism（零新 RNG）。

## §1 現況（grounded）
- JOIN commit：survival 路 `try_set TASK_JOIN + social_target + join_pos`（faction_ai survival dispatch）+ `_stamp_survival_commit`。
- resolve：joiner 移動抵達 host tile → co-locate → interaction `arrived_ids→_try_interact→_resolve_join`（interaction:46/206/226）=**運作正常（走到時）**。
- **落差**：commit 698 vs resolve ~10=joiner 從沒抵達。
- probe：`accept.join_reject`=11 同量級=(c) host 拒非主因；`mergein.subteam`=6/dissolve=1（resolve 後分流、非 churn 成因）。

## §2 Task（TDD）
### T1：runtime-trace pin sub-cause（i/ii/iii）
- instrument JOIN-committed 隊的 movement/re-eval（temp trace、禁耗 global RNG）追：
  - **(i) movement 不執行**：try_set TASK_JOIN 後 MovementSystem 有無真朝 join_pos 移動（move_target 設否、path 推進否）。
  - **(ii) cadence 重評 reset**：survival re-eval 每 cadence 是否重 commit JOIN（reset task_start/move）在到達前=persist 太弱（S2b corvee 款、`_should_reeval` cadence 頻率 vs 移動到達時間）。
  - **(iii) 移動 host chase**：join_pos 是否追移動中 host（每 commit 更新 host 現位、joiner 追移動目標永不及）。
- seeded 短局跑捕 churn（day51 左右密集）→ pin i/ii/iii → **T1 handback 附 caller/機制 + systems 確認根再 T2**（或鏈清直接 T2）。
### T2：根修（依 T1）
- **(i)→** 補 movement 執行（JOIN task 驅 move 到 join_pos）。
- **(ii)→** JOIN survival persist-to-arrival（committed JOIN 在途不被 cadence 重評 reset/蓋、同 S2b corvee persist 款；到達或 timeout 才釋放）。
- **(iii)→** mobile-host 處理：join_pos 追 host 現位 or proximity-resolve（不強求精確 co-locate）or host rendezvous——R² 議最小根修。
- 移 T1 trace。驗 churn 消（join.resolve/commit 比例回正、team 不暴增、perf 回正）。

## §3 gate（measurer bounded）
1. **churn 消**：join.resolve/SurvivalMergeIn commit 比例回正（非 1.4%）、`SurvivalMergeIn` 同對隊反覆消。
2. **team 不暴增**（49→242 病消、最終存活隊數回合理）。
3. **perf 回正**（per-tick 回正常量級、40-70× 消）。
4. committed JOIN 真 resolve（到達 host co-locate）。
5. determinism、constitution、不破既有 JOIN/survival、fp intended 標。

## §4 界外
- 農業b pop-cap floor 校準=churn 修+re-measure 後定（blueprint deferred）。
- resolve 後分流（subteam vs dissolve）=既有、非本 slice。

序：R² 審此 HOW（(b) 前提+trace pin approach+手不聽腦 root 非補丁）→ CLEAN → dispatch implementer（base 現 main）→ pin→根修→gate→merge。地基 KEEP。
