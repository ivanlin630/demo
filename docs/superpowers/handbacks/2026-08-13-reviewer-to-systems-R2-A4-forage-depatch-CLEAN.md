---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN] A4 forage de-patch+solo-convert+9筆ride-along——【forage de-patch】親讀terms.gd:106-110確認eval(\"survival_pressure\",...)真的硬編return 1.0(comment自證『T1正規化:剝urgency乘子』,跟A1 camp_drive同一輪T1手筆留下的死值,非孤例是同批修過的家族),options.gd:56-57確認覓食applicable只查population/has_forage_tile零food_days檢查,坐實;★審點(1)共享term衰減誤傷風險親自逐一追查5個消費者非只信claim:自救建田(:67)/threat_pressure option/買糧(:95)三者只用survival_pressure當WEIGHT(terms.gd:342另一個flat 1.0函式,這輪fix完全不碰),各自有獨立eval term(food_rescue_build/threat_pressure/restock_need)不受影響;遷移找糧(:312)雖也用survival_pressure當EVAL但applicable(:318)已要求food_days<desperation_entry_threshold,永遠落在提案formula的floor=1.0區間(food_days<7→clamp 1.0不變),decay對它近乎no-op;真正吃到完整衰減曲線的只有覓食一個option——這個fix比表面上『改共享term』聽起来更精準,實際上是外科手術式只動一個option的行為,shared-term顧慮親驗證實非問題;(2)SURVIVAL_RECOVER_DAYS=7親grep確認faction_ai_system.gd:99既有常數(已用於:4605 hysteresis+decision_context.gd:25 SLACK_COMFORT_DAYS顯式錨同一值)非新拍常數坐實;(3)food_days<7→floor 1.0結構性防regression(floor是上界非下界,瀕餓時維持最高值不可能因這個fix讓覓食變更弱)結構確認;【solo-convert】親讀interaction_system.gd:283-294確認TASK_SETTLE convert分支(:289-294)確實包在一個處理『a/b兩隊co-located pair』的函式內、solo無pair永遠不進這段,坐實執行斷;親讀faction_ai_system.gd:1963 _settle_relocated_village確認『own-faction outpost→convert/空地→establish_crude_camp/皆不成→流亡』這個solo(非pairwise)三分支處理範式已存在且用於村遷移機制,A4提議鏡射的正是這個已驗證過的既有pattern非發明新邏輯;判決=CLEAN(spec-lite/de-patch家族,證據紮實)→implementer"
---

# R②判決：A4 forage de-patch + solo-convert + 9筆ride-along — CLEAN

## forage de-patch——共享 term 衰減誤傷風險親自逐一追查，非只信 claim

親讀 `terms.gd:106-110` 確認 `eval("survival_pressure", ctx, opt)` 真的硬編 `return 1.0`——comment 自證「T1 正規化：剝 urgency 乘子」，跟 A1 那輪 `camp_drive` 是**同一批 T1 修改留下的死值家族**，不是孤例。`options.gd:56-57` 確認覓食 `applicable` 只查 `population`/`has_forage_tile`，零 `food_days` 檢查，坐實。

**★審點(1)最重要——共享 term 衰減會不會誤傷別的 survival option，我沒有只信 spec 這句話，親自逐一追查了全部 5 個消費者**：
- **自救建田**（`:67`）/**threat_pressure option**/**買糧**（`:95`）：這三個只用 `survival_pressure` 當 **WEIGHT**（`terms.gd:342` 另一個獨立的、同樣 flat 1.0 的函式——這輪 fix **完全不碰**），各自有自己獨立的 EVAL term（`food_rescue_build`/`threat_pressure`/`restock_need`），不受影響。
- **遷移找糧**（`:312`）：雖然也用 `survival_pressure` 當 EVAL，但它的 `applicable`（`:318`）已經要求 `food_days < desperation_entry_threshold`——這代表它**永遠落在提案公式的 floor=1.0 區間**（提案 `food_days<7→clamp 1.0` 不變），decay 對它幾乎是 no-op。
- **真正吃到完整衰減曲線的只有覓食一個 option。**

這個 fix 比表面上「改一個共享 term」聽起來更精準——實際上是外科手術式只影響一個 option 的行為，shared-term 顧慮親驗證實**非問題**。

**(2)** `SURVIVAL_RECOVER_DAYS=7` 親 grep 確認 `faction_ai_system.gd:99` 既有常數（已用於 `:4605` hysteresis + `decision_context.gd:25` `SLACK_COMFORT_DAYS` 顯式錨同一值），非新拍腦常數，坐實。

**(3)** `food_days<7→floor 1.0` 結構性防 regression——floor 是**上界**（clamp 的最大值），瀕餓時維持最高值，不可能因為這個 fix 讓覓食變更弱，結構上確認。

## solo-convert——鏡射既有已驗證 pattern，非發明新邏輯

親讀 `interaction_system.gd:283-294` 確認 `TASK_SETTLE` convert 分支（`:289-294`）確實包在一個處理「`a`/`b` 兩隊 co-located pair」的函式內——solo（無 pair）永遠不會進這段，坐實執行斷。

親讀 `faction_ai_system.gd:1963` `_settle_relocated_village` 確認「own-faction outpost→convert / 空地→establish_crude_camp / 皆不成→流亡」這個**solo（非 pairwise）三分支處理範式已經存在**，用於村遷移機制——A4 提議鏡射的正是這個已經跑過、已驗證的既有 pattern，不是憑空發明新邏輯，風險低。

## 判決
**CLEAN（spec-lite/de-patch 家族快審，證據紮實）→ implementer。** forage de-patch 的「共享 term」顧慮親自追查 5 個消費者後證實非問題（真正受影響的只有覓食一個 option）；solo-convert 有既有 pattern 可鏡射，非新造機制。
