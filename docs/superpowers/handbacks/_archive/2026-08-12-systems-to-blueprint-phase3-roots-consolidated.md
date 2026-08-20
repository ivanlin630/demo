---
from: systems
to: blueprint
status: consumed
topic: "[③root-diagnose consolidated(systems code-read 加值坐實各根)+★新 observer-neutrality bug(measurer 揭、systems 坐實根)→餵你推用戶排 fix·★#0[NEW、observer-neutrality、measurer 判 HIGH、systems-owned invariant]SpecimenTracer re-query 耗 global RNG→觀測擾動世界:specimen 手動選不同 team_id→世界分岔(teams130 vs148、measurer isolation A/B 坐實 tap 中性但選 id 法非中性)·systems 坐實根=specimen_tracer:53『finder→estimate_catch_up→observe_velocity→randf=tracer 額外耗 global RNG』某路徑逃逸 suppress_observe_noise(:25)→不同 specimen 集 re-query 不同團耗不同 RNG=[[feedback_observer_no_global_rng]]第4 instance(LOD-exempt 已 sim_runner:506 移除、tracer re-query 殘留);fix=tracer re-query 全路徑 suppress randf(or 讀 cached 決策非 re-query)+加『specimen id-set 中性』regression(現只鎖 helper on/off 中性、選哪組 id 從沒驗)·★#3①[macro 最大根、structural confirm]立國 gate 霸主-tier 門檻 vs 凡人 leader:cmd≥0.4/野心≥0.6 三連 but leader-gen 凡人 統領∈[0.1,0.4](skill base 0-0.3+leader0.1)/野心∈[0.35,0.65](NORMAL_LO/HI)系統性低於 gate、『立國』goal 兩月零 emit、只霸主-archetype(hi_v 野心+hi_s 統領+SKILL_TAIL0.5-0.9)夠格→典型床無霸主 leader→established=0『世界不建國』=WHAT/balance 用戶裁(a 降門檻/b 確保霸主 leader spawn/c 接受立國罕見但 macro 扁平代價、連正統-arc)·★#3②[execution gap]merge 決定+order 成功但完成率 4.8%(consolidate_dispatch=168/set_ok=168 but mergein.complete=8)=碎不併真根在 post-order execution(travel/target-move/timeout?)非決策層·★#3③[precondition]recovery 評估即 100% fire(migrant/invest evaluated→dispatched 全轉)、瓶頸=評估機會稀(領主自身 pop 崩 1-6→CONVOY_MIN_PARENT_POP early-return 自保不派)非決策 under-fire;propagation vs precondition 未完全分(需另輪 tap)·★#4[known tier-up 根]promote 100% desperate=anon 全平民 tier structural(training never happens→無 tier-up→quality<0.3 normal 永不過)、同本 session tier-up-chain arc 根·★#5[NOT bug]intent=faction-level 設計(leader 驅動 shared、task=per-team)genuine 分層、T18 成員危機不改 faction intent 正確;bonus 耦合(領主 food-crisis→faction_ai:1033 return 凍 intent、minor 判斷)·★建議優先序(供你+用戶):#0 observer bug(HIGH、cheap-ish、un-taint 未來所有 measure、invariant)→#3① founding(最大 believability、WHAT 裁)→#3②/#3③ execution/precondition→#4 tier-up(大 arc known)·#5 close 非 bug·specimen 在 QA·序:你帶用戶排→逐個 fix arc·地基 KEEP"
---

# ③ root-diagnose consolidated（systems code-read 加值坐實各根）+ 新 observer-neutrality bug

measurer #3-#5 診斷 + systems code-read 坐實各根。★measurer 意外揭一新 observer-neutrality bug（判優先級可能 > #3-#5）。

## ★#0 [NEW、observer-neutrality、measurer 判 HIGH、systems-owned invariant] SpecimenTracer re-query 耗 global RNG → 觀測擾動世界
- 現象：specimen 手動選不同 team_id → 世界分岔（teams130 vs 148、measurer isolation A/B 坐實：9 tap 中性、但**選 id 法非中性**）。
- ★**systems 坐實根**：`specimen_tracer:53`「finder→estimate_catch_up→observe_velocity→**randf**＝tracer 額外耗 global RNG」某路徑逃逸 `suppress_observe_noise`（:25）→ 不同 specimen 集 re-query 不同團耗不同 RNG。= [[feedback_observer_no_global_rng]] **第 4 instance**（LOD-exempt 已 `sim_runner:506` 移除、tracer re-query 殘留）。
- fix = tracer re-query 全路徑 suppress randf（or 讀 cached 決策非 re-query）+ 加「specimen id-set 中性」regression（現只鎖 helper on/off 中性、選哪組 id 從沒驗）。

## ★#3① [macro 最大根、structural confirm] 立國 gate 霸主-tier 門檻 vs 凡人 leader
- cmd≥0.4 / 野心≥0.6 三連 but leader-gen 凡人 `統領∈[0.1,0.4]`（skill base 0-0.3+leader0.1）/ `野心∈[0.35,0.65]`（NORMAL_LO/HI）**系統性低於 gate**、「立國」goal 兩月零 emit、只**霸主-archetype**（hi_v 野心+hi_s 統領+SKILL_TAIL0.5-0.9）夠格 → 典型床無霸主 leader → established=0「**世界不建國**」。
- = WHAT/balance 用戶裁（a 降門檻 / b 確保霸主 leader spawn / c 接受立國罕見但 macro 扁平代價、連正統-arc）。

## ★#3② [execution gap] merge 決定+order 成功但完成率 4.8%
consolidate_dispatch=168 / set_ok=168（決策常選併+order 成功）but mergein.complete=8 → **碎不併真根在 post-order execution**（travel/target-move/timeout?）非決策層。

## ★#3③ [precondition] recovery 評估即 100% fire、瓶頸=評估機會稀
migrant/invest evaluated→dispatched 全轉（無 under-fire）。瓶頸 = 領主自身 pop 崩 1-6 → `CONVOY_MIN_PARENT_POP` early-return（自保不派）。propagation vs precondition 未完全分（需另輪 tap）。

## ★#4 [known tier-up 根] promote 100% desperate = anon 全平民
structural（training never happens→無 tier-up→quality<0.3 normal 永不過）、同本 session tier-up-chain arc 根。

## ★#5 [NOT bug] intent = faction-level 設計
genuine 分層（intent=leader 驅動 shared、task=per-team）、T18 成員危機不改 faction intent 正確。bonus 耦合：領主 food-crisis→`faction_ai:1033` return 凍 intent（minor 判斷）。

## ★建議優先序（供你+用戶）
**#0 observer bug**（HIGH、cheap-ish、un-taint 未來所有 measure、invariant）→ **#3① founding**（最大 believability、WHAT 裁）→ #3②/#3③ execution/precondition → #4 tier-up（大 arc known）。#5 close 非 bug。

specimen 在 QA。序：你帶用戶排 → 逐個 fix arc。地基 KEEP。
