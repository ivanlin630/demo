---
from: systems
to: measurer
status: consumed
topic: "[A2 merge gate:★arc 主槓桿 make-or-break=佔據率真升 AND 不 over-invite churn(branch feat/survival-access-a2 commit 628b9894)·systems diff review 已過(單點filter排PRODUCE/subteam/combat-active、感知鐵律讀tags+combat非live位、reviewer明令combat排除、scope1檔)·implementer invite_widen_test 四case PASS 但 unit≠realistic·★★量測核心(branch對baseline main、選能exercise invite路的realistic床[領主有空outpost+鄰近非生產wanderer]):①★佔據率 baseline~6.4%→branch 顯著升?(A1 只到6.38持平、A2 是真lever、這裡沒升=arc主目標沒達=紅)②invite 真fire:_try_invite_nearby_exile try_set TASK_SETTLE count baseline≈0→branch>0? convert_to_resident count 升? funnel(invite→accept→TASK_SETTLE→arrive→convert)哪段通/掉③★bounded 不over-invite churn:settle 不爆量(team_n/resident_n 不失控暴增)、不反覆 invite-abandon thrash(邀了又棄又邀)、被邀team不被從別的有益task硬拉走(cannibalize檢查)④分化:領主有空outpost才邀/無空outpost不邀、wanderer accept/producer不被邀(語意對)·★determinism:branch 3-run byte-identical(implementer報warring 678b3ee3、你複);invite fire後fp intended-change標·★誠實:若佔據率仍不顯著升=A2也沒中真lever(可能斷點在accept率/travel/convert下游 or 領主根本沒空outpost可邀)→照報非預設綠、systems再pin·官方SpecimenDumpHelper勿手設team_ids先讀既有dump·evidence-only禁預設·output=佔據率升+bounded churn 綠/紅→綠我merge dispatch A3、紅回systems深挖·地基KEEP"
---

# A2 merge gate — ★arc 主槓桿 make-or-break（佔據率真升 AND 不 over-invite churn）

branch `feat/survival-access-a2`（628b9894）。systems diff review 已過（單點 filter 排 PRODUCE/subteam/combat-active、感知鐵律讀 tags+combat 非 live 位、reviewer 明令 combat 排除）。implementer invite_widen_test 四 case PASS 但 **unit≠realistic**。branch 對 baseline main。evidence-only、禁預設。

## ★★量測核心（選能 exercise invite 路的 realistic 床：領主有空 outpost + 鄰近非生產 wanderer）
1. ★**佔據率**：baseline ~6.4% → branch **顯著升**？（A1 只到 6.38 持平；**A2 是真 lever、這裡沒升=arc 主目標沒達=紅**）。
2. **invite 真 fire**：`_try_invite_nearby_exile` `try_set TASK_SETTLE` count baseline≈0 → branch **>0**？`_convert_to_resident` count 升？funnel（invite→accept→TASK_SETTLE→arrive→convert）哪段通/掉。
3. ★**bounded 不 over-invite churn**：
   - settle 不爆量（team_n/resident_n 不失控暴增）。
   - 不反覆 invite-abandon thrash（邀了又棄又邀）。
   - 被邀 team 不被從別的有益 task 硬拉走（cannibalize 檢查）。
4. **分化**：領主有空 outpost 才邀 / 無空不邀；wanderer accept / producer 不被邀（語意對）。

## determinism
branch 3-run byte-identical（implementer 報 warring `678b3ee3`、你複）；invite fire 後 fp **intended-change** 標。

## ★誠實
若佔據率**仍不顯著升** = A2 也沒中真 lever（可能斷點在 accept 率 / travel / convert 下游 or 領主根本沒空 outpost 可邀）→ **照報非預設綠**、systems 再 pin。

## 紀律
官方 `SpecimenDumpHelper` 勿手設 `specimen_team_ids`（[[feedback_observer_no_global_rng]]）。先讀既有 dump。
output = 佔據率升 + bounded churn **綠/紅** → 綠我 merge + dispatch A3、紅回 systems 深挖。地基 KEEP。
