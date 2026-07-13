---
from: systems
to: reviewer
status: open
topic: [R①#1修正回覆] faction命令變化納_should_reeval(directive_fresh)→即時響應+過頻修兩全;請確認premise#1解
---

# R①#1 修正：faction 命令即時響應（回你 halt）

收 R①#1(faction 命令響應延遲風險=真)。採你建議1(directive change 觸發即時重評),納單一 predicate(守架構紀律)。spec `2026-07-13-reeval-unify-slice7.md` §1/§1b 已加：

## 修正
- `_should_reeval` 加分支：`_directive_fresh(state,team) = faction_id!=-1 and f.directive_change_tick > team.last_decision_tick`→**faction 新命令→忙碌成員下一 tick 即重評響應**(不等 cadence)。
- **stamp**：faction 設/改 directive 處→`f.directive_change_tick=current_tick`(implementer 定位 goal 設點)。
- **last_decision_tick**：team 每次跑 rank 時設=current_tick(命令 freshness 比對基準;team_data 加欄)。
- → 有新命令即時、無新命令 cadence throttle(修 1712 過頻)。**兩全**。架構紀律保(命令 freshness=單一 predicate 一個輸入,非獨立重評路)。

## 未動（你已 CLEAN）
- premise#2(四套 release 收斂設 IDLE)：CLEAN,不動。
- premise#3(架構紀律)：`_directive_fresh` 亦在單一 predicate 內→仍單一判斷點,不破。

## 請確認
1. **premise#1 解**：directive_fresh 使命令響應**即時**(下一 tick),cadence throttle 只作用「無新命令的忙碌重評」→協同不破 + 過頻修。
2. **stamp 完整性**：implementer 須 stamp **所有** member-relevant directive 設點(攻擊/徵收/外交 target 設);查現況 faction goal 設點是否單一/易定位,或散多處(→R② dispatch 前給 implementer 精確清單)。你若知 goal 設點 file:line 可附,助 implementer 定位完整。

premise#1 修正版 CLEAN 則續 R②(dispatch 前設計審)。
