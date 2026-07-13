---
from: systems
to: implementer
status: open
topic: [dispatch·⑦] 釋放統一(單一_should_reeval,修過頻1712+命令即時)——R①R②全CLEAN,自主slice
---

# Dispatch：⑦ 釋放統一（單一 _should_reeval predicate）

R① 三 premise CLEAN + R② CLEAN。spec `docs/superpowers/specs/2026-07-13-reeval-unify-slice7.md`。**新 branch `feat/reeval-unify`,基於最新 origin/main**。藍圖自主授權——build 完直接融合閘+determinism,回 systems 彙整 final(不中途送量測)。

## 做什麼（spec 有完整 code）
1. **`_should_reeval(state,team)`**（新，FactionAISystem）：`IDLE or _is_stuck or _decision_crisis or _directive_fresh or (current_tick>=decision_eval_next_tick)`。**唯一「何時重評」判斷點**(架構紀律)。
2. **`_directive_fresh(state,team)`**：`faction_id!=-1 and f.directive_change_tick > team.last_decision_tick`。
3. **stamp（單一 choke point）**：`_emit_goal(:1087-1093)` 函式內加一行 `f.directive_change_tick = state.world.current_tick`（涵蓋全 11 呼叫點,勿逐一改）。
4. **`_decide_unified:1442` 開頭加 gate**：`if not _should_reeval(state,team): return` + 通過時設 `decision_eval_next_tick`(crisis 短 cadence /4)+`last_decision_tick=current_tick`。survival-sticky pass + rank_scored 原樣。
5. **`_evaluate_solo:1778` gate 改用 `_should_reeval`**（語意等價收斂）+ 設 `last_decision_tick`。
6. **team_data** 加 `var last_decision_tick: int = 0`；**faction_data** 加 `var directive_change_tick: int = 0`。
7. 四套 release（survival:3048/threat+FLEE_TIMEOUT:373/stuck）**保現況**（R① 確認皆 TaskArbiter.release→IDLE 無繞-IDLE 直派）——收斂靠「release→IDLE→_should_reeval IDLE 分支接手」,release code 本身不改。

## 硬約束（架構紀律，藍圖硬性）
- **唯一重評判斷點=`_should_reeval`**：directive_fresh/crisis/cadence 皆此 predicate 輸入,**禁**他路自判「該重評」。
- 保留例外不動：PRIO 插隊/survival hysteresis 狀態轉換/LOD。
- **directive_fresh 無死循環**：last_decision_tick 每次決策更新→截斷 fresh。
- 零 randf、determinism、逐項 commit。

## TDD（headless_test.gd）
- `_test_should_reeval`：IDLE→true / stuck→true / crisis→true / directive_fresh(命令 stamp 後未決策)→true / busy 無事+cadence 未到→false。
- `_test_directive_fresh_no_loop`：決策後 last_decision_tick=now → 同 tick 再判 directive_fresh=false(截斷)。
- `_test_unified_throttle`：unified 隊 busy 無命令 → cadence 未到不重評(非每 tick)。

## 回報 → systems（彙整 final，非直接 measurer）
⑦ 完 + 融合閘綠 + determinism → handback to:systems。我彙整 final 一次性交付藍圖：
- **determinism** byte-identical。
- **★架構紀律自查**：「何時重評」判斷點是否真收斂 `_should_reeval` 一處(附 grep 佐證無殘留他路自判重評)。
- 準備 measurer 終驗料（Team6 式 trace 看 1712→?降 + established + 不回歸 faction 協同/famine/combat/貿易）。
有 blocker→to:systems。守：不 pre-tune、不問 user、不自改架構紀律。
