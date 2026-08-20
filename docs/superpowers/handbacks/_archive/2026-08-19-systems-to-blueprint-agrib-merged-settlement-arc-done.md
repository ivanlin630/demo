---
from: systems
to: blueprint
status: consumed
topic: "[★報:農業b MERGED 3ef619fd=settlement arc 全 slice 落地(S1/crash/S2a/S2b/農業a/農業b+churn-fix+labor-v2)·下一站=§4 戰略蓋點(等你 WHAT spec、含 de-scaffold 77→75 硬 gate)·★農業b gate:①organic 無 floor 需求(cap<5 隊 mint_level>0=0.0% vs cap>=5 也 0.0%、farming 4.0% vs 5.5% 效果量小=無結構性發展封頂強證據;g1a 礦村未鑄幣=fixture artifact[helper 缺 leader 統領→effective≈2 開局 overflow]已修 test-only)→★你先前 concern『cap=2<常識地板』organic 不成立、不加 floor(免 artificial tuning)②pop-cap 複核 PASS(cap<5=4.6%、★pop>100=0 且 cap>150=0 雙向零 runaway、overflow_fire=2)=⑥乘法放大器在 90 天/152 隊規模驗證通過③churn 高壓覆蓋:★team 暴增 PASS(49→152 vs 原 49→242、day50 後趨平)=churn-fix 在原始高壓場景真壓住(你要的 churn 缺口覆蓋達成)·★★我裁的一條(pair 指標):measurer 報『同對隊反覆 1647 行/max81× vs 原 698/54×=方向相反』→我 code-read 定性【pair-print 非有效 churn 指標】:print 在 survival 路每次選併入都印、committed JOIN 在途每 cadence re-set 同 target 又印一次=把在途重申與跨 episode 重演混算;join_rejected cooldown(480tick=2日)只在事後寫、擋不到在途重申(設計如此);且 698 是 day65 partial vs 1647 是 day90 full+原輪 full stdout 被 wrapper race 吃掉=無有效對照→∴不阻 merge、有效證據改用 team 暴增-37%+出路真 fire(abort21/timeout1/reject33)+控制床構造斷根·★兩條 follow-up 已記 known_issues(非 blocker、排 §4 後):(a)在途重申燒 CPU→候選修『重申抑制』(hand-obeys-brain 家族、順帶讓 pair-print 恢復可信)(b)★per-team tick 成本+34%(670.6ms/152隊 vs 793ms/242隊;O(N²)下隊少該降卻升→疑三 slice 疊加真開銷、但無 phase breakdown=粗量測非定罪)→符合你 perf re-open 條件的 candidate、需先一輪 phase profile 才算『明確熱點』、你裁要不要開·序:等你 §4 WHAT spec→我接 HOW(含 de-scaffold 拆 2 站回 77→75 硬 gate)→繼承-lite→12mo 大考二回·地基KEEP"
---

# ★農業b MERGED（`3ef619fd`）=settlement arc 全 slice 落地

S1 / crash(own_granary) / S2a / S2b / 農業a / 農業b + churn-fix + labor-v2 **全在 main**。下一站=**§4 戰略蓋點**（等你 WHAT spec、含 **de-scaffold 77→75 硬 gate**）。

## ★農業b gate
1. **①organic 無 floor 需求**：cap<5 隊 `mint_level>0`=**0.0%** vs cap≥5 也 **0.0%**、farming 4.0% vs 5.5%（效果量小）=**無結構性發展封頂的強證據**；`[g1a]` 礦村未鑄幣=**fixture artifact**（helper 缺 leader `統領`→effective≈2→開局 overflow），已修 test-only。
   → **★你先前 concern「cap=2<常識地板」organic 不成立、不加 floor**（免 artificial tuning）。
2. **②pop-cap 複核 PASS**：cap<5=4.6%、**★pop>100=0 且 cap>150=0（雙向零 runaway）**、overflow_fire=2 → ⑥乘法放大器在 **90 天/152 隊**規模驗證通過。
3. **③churn 高壓覆蓋**：**★team 暴增 PASS（49→152 vs 原 49→242、day50 後趨平）**=churn-fix 在**原始高壓場景**真壓住（你要的 churn 缺口覆蓋達成）。

## ★★我裁的一條（pair 指標）
measurer 報「同對隊反覆 **1647 行/max 81×** vs 原 698/54×=**方向相反**」→ 我 code-read 定性=**pair-print 非有效 churn 指標**：print 在 survival 路每次選「併入」都印；**committed JOIN 在途每 cadence re-set 同 target 又印一次** → 把**在途重申**與**跨 episode 重演**混算。`join_rejected` cooldown（480 tick=2 日）**只在事後寫**、擋不到在途重申（設計如此）。且 **698=day65 partial vs 1647=day90 full**、原輪 full stdout 被 wrapper race 吃掉=**無有效對照**。
→ ∴ **不阻 merge**；有效證據改用 **team 暴增 -37% + 出路真 fire（abort 21/timeout 1/reject 33）+ 控制床構造斷根**。

## ★兩條 follow-up（已記 known_issues、非 blocker、排 §4 後）
- (a) **在途重申燒 CPU** → 候選修「**重申抑制**」（hand-obeys-brain 家族、順帶讓 pair-print 恢復可信）。
- (b) **★per-team tick 成本 +34%**（670.6ms/152 隊 vs 793ms/242 隊；**O(N²) 下隊數變少 per-team 該降卻升** → 疑三 slice 疊加真開銷；但無 phase breakdown=**粗量測非定罪**）→ 符合你 **perf re-open 條件**的 candidate、**需先一輪 phase profile 才算「明確熱點」**、**你裁要不要開**。

序：等你 **§4 WHAT spec** → 我接 HOW（含 de-scaffold 拆 2 站回 **77→75** 硬 gate）→ 繼承-lite → 12mo 大考二回。地基 KEEP。
