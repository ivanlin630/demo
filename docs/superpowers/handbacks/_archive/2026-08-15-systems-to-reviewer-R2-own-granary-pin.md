---
from: systems
to: reviewer
status: consumed
topic: "[R² own-granary null-caller pin投機-slice HOW審(bug-fix investigation非新概念大框、R①免:前提day15 null-caller=measurer坐實+我窮盡grep全caller file:line)·spec=2026-08-15-own-granary-null-caller-pin-HOW.md·審點:①前提fact-check我負斷言『own_granary全caller傳state變數零literal-null』(grep own_granary_tile scripts/非test=decision_context:186/508、faction_ai:3418、resource_system:132/183/415/428、def:398)窮盡否?漏caller否?②pin-root非盲guard設計sound否(blueprint已裁、你sanity)③★風險:T2根修改caller state threading→若某caller本不該在null-state期跑、修其gating=改『何時跑』→行為/determinism變?flag④T3 outpost_owner permanent tap純記錄無RNG無mutation→byte-identical保持斷言對否·此slice待S1 merge後dispatch(base post-S1免stale-base)、R²平行S1 gate跑·CLEAN→我hold dispatch到S1綠·地基KEEP"
---

# R² own_granary_tile null-caller pin（investigation-slice HOW 審）

spec=`docs/superpowers/specs/2026-08-15-own-granary-null-caller-pin-HOW.md`。bug-fix investigation（非新概念大框）；R① 免（前提 day15 null-caller=measurer 坐實 known_issues:77 + 我窮盡 grep 全 caller file:line）。

## 審點
1. **★前提 fact-check（負斷言協議、你的活）**：我斷言「own_granary_tile **全 caller 傳 `state` 變數、零 literal-null caller**」（grep `own_granary_tile` scripts/ 非 test = decision_context:186/508、faction_ai:3418、resource_system:132/183/415/428、def:398）。**窮盡否？漏 caller 否？**（若漏=我負斷言破、pin 範圍不全）。
2. **設計 sound**：pin-root 非盲 guard（blueprint 已裁 closed-account 地基理由、你 sanity-check 方法：instrument get_stack()→定位→根修 threading）。
3. **★風險 flag**：T2 根修改 caller state threading——**若某 caller 本不該在 null-state 期跑**、修其 gating=改「何時跑」→**行為/determinism 變**？（vs 單純補傳 state 參數=無行為變）。要 reviewer 想這層。
4. **T3 tap**：outpost_owner permanent tap **純記錄無 RNG 無 mutation → byte-identical 保持**斷言對否。

## 時序
此 slice **待 S1 merge 後才 dispatch**（base=post-S1 main、免 stale-base [[feedback_worktree_stale_base]]）。R² **平行 S1 gate 跑**（省時）。CLEAN → 我 hold dispatch 到 S1 gate 綠+merge。

地基 KEEP。
