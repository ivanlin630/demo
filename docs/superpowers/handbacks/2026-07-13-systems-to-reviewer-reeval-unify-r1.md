---
from: systems
to: reviewer
status: consumed
topic: [R①·premise] ⑦釋放統一——factcheck:_decide_unified加cadence不破faction命令響應?4套release可收斂設IDLE?架構紀律真收斂?
---

# R① premise factcheck：⑦ 釋放統一

藍圖裁 B 直接⑦(自主全流程)。spec `docs/superpowers/specs/2026-07-13-reeval-unify-slice7.md`。過頻真因坐實(`_decide_unified` 無 cadence gate→unified/成員每小時重評,1712/90天)。收斂單一 `_should_reeval` predicate。架構紀律硬性(單一重評判斷點)。

## 請 factcheck 3 premise（file:line，premise_contradiction→halt）
1. **★`_decide_unified` 加 cadence throttle 不破 faction 命令響應**（最關鍵）：`_decide_unified`(:1442)現每 NEAR_CADENCE(1h)被 `_assign_member_tasks:1410`/unified 呼→每小時重評。加 `_should_reeval`(cadence 1日+crisis+IDLE)後,**faction 命令(攻擊/徵收/外交令)下達→成員最多隔 1 日才經 rank 響應**?查:①faction 命令變化(f.goals 改)是否算 `_decision_crisis`(→即時)or 需另納 crisis-trigger;②merchant 貿易/producer 每小時重評是否有必要(貿易 target 追蹤需高頻?)or 可容 cadence。**若命令響應本質須即時而 cadence 使延遲致協同破→premise 矛盾**。
2. **四套 release 可收斂「設IDLE→predicate接手」無損**：survival release(:3042)/threat release(:368)/FLEE_TIMEOUT(:95)——各現況是否已「release→IDLE」(收斂零變),還是**有 release 後直接重派task(繞IDLE)的路**?若有繞-IDLE 直派→收斂須先導回 IDLE,揭示。
3. **架構紀律真收斂**：收斂後「何時重評」是否真只剩 `_should_reeval` 一處(+允許例外:PRIO 插隊/hysteresis 狀態轉換/LOD)?有無殘留某路自己判「該重評」的獨立邏輯。

## 意涵
- 全 CLEAN→⑦ 可 build(過頻收斂 + 架構紀律達成)→R②→build。
- premise 矛盾(尤 #1 命令響應延遲破協同 / #2 有繞-IDLE 直派路難收斂 / #3 殘留獨立重評)→halt 回報藍圖。

#1 是成敗關鍵(cadence throttle unified 會不會拖慢 faction 協同),請重點坐實 faction 命令下達路徑 + 是否須即時。
