---
from: systems
to: blueprint
status: open
topic: "[promotion-initial-mood-loyalty MERGED(3390105a)→ready 推用戶·晉升→初始心情/忠誠(用戶問不同情況晉升怎處理)全鏈走完·★新 officer stress/fear/loyalty 從源團 state 湧現取代白紙 0/0(genuine 非死常數):忠誠=clampf(感激×義氣信義 pmod − unrest carryover − 急徵拖, floor0.2, 1.0)honest 3-signal、心情=stress(提拔滿足 base+unrest+desperate cap0.8)+fear(desperate+unrest cap0.7)·★HOOK 命門守(不改通用 generate 污染全體、_try_promote_advisor post-add_member hook)·感知鐵律全 own-state(unrest own+desperate context+officer 自 values)無 god-view·§4.5 bounded(怨團非0 floor0.2/絕境非崩潰 cap/和平非麻木 base0.1)·無新 randf determinism·★★merge-gate 抓到並修一缺陷(誠實報):首輪坐實 heard_rep 惰性(known_reputations team-id keyed 用 person-id 查恆 miss+own-team 拓撲無自 reputation)=偽 state-derived 違 genuine 命門→halt→fix A 移 rep 項(源團態度 unrest 已完整捕捉、你 spec §4 引 known_reputations 對 own-team 樂觀但拓撲無源=WHAT 對 HOW 一源換等效)→re-CLEAN·同族『wired 但不 work』(前 arc train-util 病)、merge-gate file:line 紀律接住·★驗收全鏈:blueprint spec R①+R²+systems merge-gate 兩輪+QA release CLEAN(親算三案 exact match happy0.5/resent floor0.2/高義氣0.7+cap 真攔+wiring CONFIRM LoyaltyBank→_avg_named_loyalty→_evaluate_uprising)·憲法 PASS75+promotion_mood+active_promotion+named_scarcity_ab ALL PASS+determinism byte-identical·★QA 精確度 note(parked、供你推用戶措辭參考非 defect):FLOOR0.2==_evaluate_uprising gate 閾值→單一怨團 officer 獨自(avg=自己 0.2)不跨 strict gate(avg<0.2 才觸發)、需集體 avg<0.2=其低忠誠拉低 team avg 真 liability(集體叛非獨自革命);spec §5『怨團拔個體日後真叛』精確講=集體 liability 非個體單獨保證叛·序:你推用戶(晉升初始心情/忠誠 genuine 從源團 state、不同情況真分化幸福 vs 怨團/和平 vs 絕境、感激買忠誠、怨團拔低忠誠真 liability)+next-phase 用戶裁(②軍民混編/③長期故事驗證/size-production/多疑下游內政忠誠 PARK 項)·地基 KEEP"
---

# promotion-initial-mood-loyalty MERGED（3390105a）→ ready 推用戶

晉升→初始心情/忠誠（用戶問不同情況晉升怎處理）全鏈走完。

## ★fix
新 officer stress/fear/loyalty 從源團 state 湧現取代白紙 0/0（genuine 非死常數）：
- 忠誠 = `clampf(感激×義氣信義 pmod − unrest carryover − 急徵拖, floor0.2, 1.0)` honest 3-signal。
- 心情 = stress（提拔滿足 base + unrest + desperate、cap0.8）+ fear（desperate + unrest、cap0.7）。
- HOOK 命門守（不改通用 `generate`、`_try_promote_advisor` post-add_member hook）。感知鐵律全 own-state 無 god-view。§4.5 bounded（怨團非0 / 絕境非崩潰 / 和平非麻木）。無新 randf。

## ★★merge-gate 抓到並修一缺陷（誠實報）
首輪坐實 **heard_rep 惰性**（known_reputations team-id keyed 用 person-id 查恆 miss + own-team 拓撲無自 reputation）= 偽 state-derived 違 genuine 命門 → halt → fix A 移 rep 項（源團態度 unrest 已完整捕捉；你 spec §4 引 known_reputations 對 own-team 樂觀、拓撲無源 = **WHAT 對、HOW 一源換等效**）→ re-CLEAN。同族「wired 但不 work」（前 arc train-util 病）、merge-gate file:line 紀律接住。

## ★驗收全鏈
blueprint spec R①+R² + systems merge-gate 兩輪 + QA release CLEAN（親算三案 exact match happy0.5/resent floor0.2/高義氣0.7 + cap 真攔 + wiring CONFIRM）。憲法 PASS75 + promotion_mood + active_promotion + named_scarcity_ab ALL PASS + determinism byte-identical。

## ★QA 精確度 note（parked、供你推用戶措辭參考、非 defect）
`FLOOR0.2 == _evaluate_uprising gate 閾值` → 單一怨團 officer 獨自（avg=自己 0.2）不跨 strict gate（avg<0.2 才觸發）、需**集體 avg<0.2** = 其低忠誠拉低 team avg 真 liability（**集體叛非獨自革命**）。spec §5「怨團拔個體日後真叛」精確講 = **集體 liability** 非個體單獨保證叛。

序：**你推用戶**（晉升初始心情/忠誠 genuine 從源團 state、不同情況真分化 幸福 vs 怨團 / 和平 vs 絕境、感激買忠誠、怨團拔低忠誠真 liability）+ next-phase 用戶裁（②軍民混編 / ③長期故事驗證 / size-production / **多疑下游內政忠誠 PARK 項**）。地基 KEEP。
