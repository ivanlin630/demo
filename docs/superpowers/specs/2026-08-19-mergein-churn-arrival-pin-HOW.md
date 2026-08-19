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

## §5 ★T2 精確化（T1 pin 後 systems 定案、2026-08-19）
**T1 根定案**：(iii) 移動 host + belief lag/失聯（控制床 6 場景決定性：場景 D=host 移動+belief 只在委派當下→20 日零到達卡 ghost tile；A/B/C/E/F 皆真到達=(i) movement 正常、(ii) 重委派單獨不致命）。**結構根**=`TASK_JOIN` 無完成/放棄契約。

**★systems 自驗（負斷言窮盡、no-head）**：`TASK_JOIN` 全樹 15 命中、含 release/timeout/clear/abort/expire **0**=確認無專屬出路。

**★但既有兩塊必須納入設計（避冗餘求解器/churn 換皮）**：
1. **既有 timeout 單源塊 `faction_ai:829-841`**（W2 TRADE：`task_start_tick` + `TRADE_TIMEOUT` + 殘距額度 `×TRADE_TIMEOUT_PER_HEX` + `Probe.bump` + `TaskArbiter.release`；A1a STATION_TASKS 同款）→ **JOIN timeout 必須寫進此塊**（`elif current_task == TASK_JOIN` 同 pattern、同 task_start_tick 單源），**非新 dispatch 站/新機制**=延伸統一。
2. **★crisis-override 已是泛化安全網 `faction_ai:389`**（`_famine_crisis` → release、註明涵蓋 5 種 stuck-task **含「併入-pending」**）——∴「JOIN 零出路」須精確化為「**無專屬**出路；crisis-override 只在**深餓未緩**才 fire（`CRISIS_FLOOR`+`CRISIS_DAYS`+food 沒回升），非普遍出路」。JOIN timeout 觸發面（到不了/撲空、與飢餓無關）**與 crisis-override 正交、合理共存非冗餘**；但**兩者 release 後處理須一致**（見 3）。

**★T2 定案（三件、按 systems 裁）**：
- **(1) JOIN timeout**（進既有單源塊 :829-841）：`JOIN_TIMEOUT + 殘距×PER_HEX` 未 resolve → Probe + `TaskArbiter.release`。TEST VALUE 常數鏡射 TRADE 款。
- **(2) 撲空 abort（感知鐵律 own-belief）**：committed JOIN + 已站上/已清 move_target + `BeliefSystem.belief_pos(self, social_target)==(-1,-1)`（自己的 belief 死=撲空語意、**非 god-view 查 host 真位**）→ release。
- **(3) ★★release 後別立刻重選同 host（防 churn 換皮、implementer 提案未列、systems 必要件）**：release 後下 cadence `併入` 仍會贏、`to_task` 讀 belief 一恢復就再派同 target → **churn 只是換個路徑重演**。**復用既有 rejection-learning**（`_resolve_join:1280` 已有 `write_memory(leader,"join_rejected",host_id,tick,0.5)` + cooldown、finder 於 cooldown 內不再選此 host、語意=「這 host 此刻不可行」）→ **arrival-fail 也寫同一 memory**（拒絕/到不了語意對稱）=**零新機制**。（or 鏡射 crisis-override 的 `crisis_released_task/until` 免疫款；擇一、勿雙做。）
- **(4) proximity-resolve 不加**（場景 E 證 belief lag 追擊仍能 resolve、非必需）=最小根修、不動 resolve 語意。

**gate 補**：churn 消須驗 **release 後不重演**（同對隊 SurvivalMergeIn 反覆數歸零、非只總數降）。
