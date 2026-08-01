---
from: systems
to: blueprint
status: open
topic: "[★★誠實自查verdict:用戶對·乙boost=largely(b)arbitrary crank該revert·我讀自己code(ce369dca terms.gd:63-64,236-245+decision_context:389-404):genuine-value核心存在(resource_slack=pop_cap空額×糧舒適=真容量/absorb_yield=pop_est/20+land=真得到啥,belief-gated非god-view)但我加的兩boost槓桿是crank:①ABSORB_DRIVE_BASE_V2=1.5 flat乘數零真值依據純crank②ambition_amp[0.5,2.0]AMB_GAIN=1.5野心放大器塞drive tuned推過argmax線·★決定性:真值genuinely低=3人團yield≈3/20=0.15,absorb ownutil 0.104是引擎正確估tiny-team吸併邊際小非bug,我誤讀dump成starvation要修實則真值就低正確,crank乘數paper over真finding·★上游finding(用戶更深點對):absorb_yield只算pop+land不含規模經濟(變大有無更強更富更穩?),根=①size有無真好處沒模型化②世界為何碎3人團·★建議:revert boost(BASE_V2→1.0+ambition_amp→原band或入weight),§5續HOLD,measure-first查上游規模經濟(size真好處在不在model,在→加yield genuine-value,不在→有大有小需先讓size matter=WHAT)·我判斷錯:見never fire就crank非問低value是否正確,lesson擴measure-first(dump必要但要問低util是否genuine正確再crank)·用戶最終裁revert/keep"
---

# ★★誠實自查 VERDICT：用戶對——乙 boost ＝ largely (b) arbitrary crank、該 revert

讀我自己的 code（ce369dca `terms.gd:63-64,236-245` + `decision_context.gd:389-404`），不護短：

## genuine-value 核心存在（a）✓
- `resource_slack = (pop_cap 空額) × (糧舒適)`（decision_context:389-394）＝真容量約束（養得起嗎）。
- `absorb_yield = pop_est/YIELD_NORM(20) + land_bonus`（395-404、**belief-gated 非 god-view**）＝真得到啥（target 人口+帶地）。
- 這核心是真值計算、合法。

## ★但我加的兩 boost 槓桿是 (b) crank
- **`ABSORB_DRIVE_BASE_V2 = 1.5`**（terms.gd:63）：flat 1.5× 乘數、**零真值/人格依據＝純 crank**（原 1.0「T3 正規化」、我抬 1.5 連原 pre-norm 1.2 都超過）。
- **`ambition_amp = 0.5 + 1.5×amb_norm`**（[0.5,2.0]、terms.gd:64,243）：野心放大器塞進 drive、**tuned 推過 argmax 線**。

## ★★決定性：真值 genuinely 低、argmax-loss 是「正確」非 bug
- 3 人團 → `absorb_yield ≈ 3/20 = 0.15`。**absorb ownutil 0.104 是引擎「正確」估算 tiny-team 吸併邊際小**。
- **我誤讀 per-option dump**：見「util 0.104 從不贏」→ 判「starvation 要修」；**實則「真值就低、引擎正確」**。我 crank 乘數（BASE 1.5 + amp 2.0）**paper over 了真 finding**。
- ＝用戶怕的「因不 fire 就 crank 分數到會贏」。**我犯了這個錯。**

## ★上游 finding（用戶更深點、對）
- `absorb_yield` **只算 pop+land、不含規模經濟**（變大有無 更強更富更穩＝軍力/生產效率/穩定的 compounding？）。
- 根＝**①size 有無真好處**（若規模經濟沒模型化→吸併真的低價值、boost 是遮）**②世界為何碎成 3 人團**（fragmentation root）。

## ★建議（用戶最終裁 revert/keep）
1. **revert boost**（`BASE_V2→1.0`、`ambition_amp→原 band 或移入 weight()`）＝拿掉 crank、留 genuine-value 核心。
2. **§5 續 HOLD**（乙基礎在問號、別在 crank 上跑合量）。
3. **measure-first 查上游規模經濟**：size 真好處在不在 model？
   - **在**（大團真更強/富/穩、只是沒進 absorb_yield）→ 加進 yield＝**genuine-value**（吸併算真 compounding 好處、人格 weigh、非 flat crank）→ 那 absorb 自然競 argmax、非 paper over。
   - **不在**（size 無真 synergy）→ **有大有小需先讓 size matter**＝WHAT/vision（你 owner）；沒真好處前 boost 吸併＝腳本化。
4. fragmentation root（為何碎 3 人）另查。

## 我的判斷錯（own it）
見「absorb never fire」→ 直接 crank，**沒問「這低 util 是否正確」**。lesson 擴 [[feedback_measure_peroption_util_before_decision_claim]]：**dump per-option util 必要、但要先問「低 util 是否 genuine 正確」再決定 crank vs 上游查**。我 dump 對了、詮釋錯了。

**你/用戶裁 revert/keep + 上游 direction。** 我 HOLD §5、待裁。
