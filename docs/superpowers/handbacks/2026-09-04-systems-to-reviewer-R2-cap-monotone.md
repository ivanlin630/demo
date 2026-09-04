---
from: systems
to: reviewer
status: open
slice: goal-util-cap-monotone（★新票，R² 審設計）
topic: ★問題不是「上限太低」而是【clamp 把序也壓掉了】(gu2.clamped 0/523 → 167/333,五個 option 全 = 1.5000 = 上限本身);★★形狀=單調壓縮 u = CAP·x/(1+x) ⇒ 保序且永遠不到 CAP ⇒ GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX 那條【不必改】;★★★而本票唯一的設計題是 UNIT 從哪來——我提「該隊一天生計的價值」(pop × FOOD_PER_PERSON_PER_DAY × BASE_PRICE[food]),兩個因子都既有,但我自己標了三個疑點請你打
---

# 審什麼
`docs/superpowers/specs/2026-09-04-goal-util-cap-monotone-HOW.md`

# ★請優先打 §3 的三個疑點（★我自己標的，不自己放行）
```
①★用「食物」當所有 goal 的計價基準 = 把食物特殊化了嗎?
   （我的反面論證:食物是唯一【每天都必須消費】的東西 ⇒ 天生是一個「時間×價值」的自然單位）
②★★x 對 pop 敏感 ⇒ 大隊的【同一個絕對缺口】換算成較少天 ⇒ u 較低
   —— 這是【對的】(大隊本來就更容易補)還是【新的規模偏誤】?
③★★★UNIT 隨 pop 逐 tick 變 ⇒ u 不是跨 tick 可比
   （我的反面論證:argmax 只在【同一 tick 同一池】內比 ⇒ 跨 tick 可比性不是需求）
```
★**②我最沒把握** —— **它可能正是「規模經濟 absent」那個舊 arc 的反面：我可能在無意間讓大隊變得【更不積極】。**

# ★★而驗收我加了一條【機械斷言】而不是宣稱
```
#4:印 `max(u) < GOAL_UTIL_CAP` 的【反例計數 = 0】
⇒ ★因為本票的整個賣點是「保證仍成立」,而那句話【必須可被打臉】
⇒ ★★不是寫「數學上不會超過」就算 —— 那是推論不是量測
```

# ③附：payoff 導出那票的具名回訪【已答】
```
★段級 PHASE_TIMING（EXCLUSIVE=yes）:wall_clock 146.5 → 139.2（−5.0%）｜rank −9.8%
⇒ ★★我 merge 時明寫的「merge 後才發現的成本」風險【沒有實現】
⇒ ★★★而方向要講準:【不是導出比較便宜】,是【導出改變了世界,而那個世界要秤的東西比較少】
   —— 不得引用成「導出更快」,那會在下一個池子沒變小的情境下騙人
```
