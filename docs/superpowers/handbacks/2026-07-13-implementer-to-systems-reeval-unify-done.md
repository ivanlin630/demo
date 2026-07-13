---
from: implementer
to: systems
status: consumed
topic: ⑦ 釋放統一交付 — 單一_should_reeval;融合閘綠+determinism;架構紀律自查(附grep);待你彙整final交藍圖
---
# Hand Back: ⑦ 釋放統一（單一 _should_reeval predicate）

branch `feat/reeval-unify`（已 push，疊 origin/main）。spec `2026-07-13-reeval-unify-slice7.md`。**回你彙整 final（非直接 measurer）**。

## 實作摘要（7 項）
1. `_should_reeval(state,team)`：`IDLE or _is_stuck or _decision_crisis or _directive_fresh or (current_tick>=decision_eval_next_tick)`。唯一「何時重評」判斷點。
2. `_directive_fresh(state,team)`：`faction_id!=-1 and f.directive_change_tick > team.last_decision_tick`。
3. **stamp 單一 choke point**：`_emit_goal` 內 `f.directive_change_tick = state.world.current_tick`（涵蓋全 11 呼叫點，未逐一改）。
4. `_decide_unified` 開頭加 gate（現無→加，修每小時過頻）+ 通過設 `decision_eval_next_tick`(crisis /4)+`last_decision_tick`。
5. `_evaluate_solo` gate 收斂用 `_should_reeval` + 設 `last_decision_tick`。
6. `team_data +last_decision_tick`；`faction_data +directive_change_tick`。
7. 四套 release 保現況（release→IDLE→_should_reeval IDLE 分支接手，release code 不改）。
- TDD：`_test_should_reeval`（IDLE/stuck/crisis/directive_fresh/busy-throttle）+ `_test_directive_fresh_no_loop`（決策後截斷）+ `_test_unified_throttle`（busy 無命令 cadence 未到不重評）皆 PASS。

## 融合閘（全綠）
- headless **0 新增 SCRIPT ERROR**（3 pre-existing p2a/beg_join/strategic 同 baseline）；3 ⑦ test PASS。
- **constitution PASS**（sites=29）；**determinism byte-identical**（1337×1mo cmp）；**multi sanity 0 SCRIPT ERROR**。

## ★架構紀律自查（附 grep 佐證）
`grep decision_eval_next_tick`（讀「該重評?」的點）：
- `:1786` — **在 `_should_reeval` 內**（唯一 predicate 的 cadence 分支）✓
- `:1449`/`:1801` — 寫（gate 通過後排下次），非判斷 ✓
- **`:3075` — `_evaluate_survival` survival-latch relatch（survival-path slice）**：inline `current_tick>=decision_eval_next_tick or _decision_crisis`。**這是唯一 `_should_reeval` 外仍 inline 判 cadence+crisis 的點**。
  - **性質**：包在 survival hysteresis gate 內（`days_left<WARNING_DAYS and not proactive_camp`）= spec §3「survival hysteresis 狀態轉換保留例外」的一部分——判的是「何時 re-trigger survival 選擇」（survival 機械內），非主 rank 重評。技術上非違反「主重評收斂」，但**確實 inline 複用 cadence+crisis 輸入**（未走 _should_reeval）。
  - **誠實呈報**：若你要 100% 收斂（survival relatch 也走 _should_reeval），需重構 relatch 條件（拆 survival-gate 與 reeval-gate）——非本 slice 範圍，且 spec §3 明列 survival hysteresis 保留。**建議留現況 + 記為架構債（survival 機械 vs 統一 reeval 的邊界）**，你裁是否納後續。
- 其餘：主 rank 兩入口（_decide_unified/_evaluate_solo）**已收斂 _should_reeval 一處**✓。無其他他路自判主重評。

## measurer 終驗料（你彙整後派）
- Team6 式 trace：1712 次/? → 降（cadence throttle 生效）+ established + 不回歸 faction 協同（命令即時響應驗 directive_fresh）/famine/combat/貿易。
- 命令即時：忙碌成員收 faction 攻擊/徵收令 → 下一 tick 響應（非隔 1 日）。

## 註
- 純節流+命令即時，行為改動（決策頻率降+命令即時）非 regression；baseline 位移。
- 承接餓隊鎖死鏈（cadence/survival-path/same-need-fallthrough）+ 本 slice 統一 reeval predicate。
