---
from: systems
to: blueprint
status: consumed
topic: [零跑結論] ②真根=FLEE base 0.6 flat floor(我T1 spec錯)+panic回饋+FLEE re-latch死亡螺旋;累積不釋放坐實;推薦併survival-path slice(latch重選+FLEE威脅gate+panic釋放)
---

# 零跑結論：② 食足隊被 FLEE 拖死 = 0.6 floor + panic 螺旋

## ② 真根（坐實 code）
`threat_pressure`(survival/FLEE option 的 eval,branch)= **`clampf(0.6 + ctx.team_panic × 0.4, 0, 1)`**。
- **★0.6 flat floor（T1 我的 spec 錯）**：FLEE base ≥0.6 **恆定,與實際威脅無關**。食足無威脅隊 FLEE base 仍 0.6→coeff(safety-aligned,safety urgency 低時 unaligned floor≈0.475)→FLEE util≈0.6×0.475≈**0.285 永久地板**。這正是 T1 觀察項#1(FLEE-safe 地板),Team7 坐實。
- **team_panic×0.4**：panic∈[0,1](高壓力低忠誠成員比例)→FLEE base 升到 1.0。

## 死亡螺旋（累積不釋放,你假設坐實）
1. 一次威脅/panic → FLEE。FLEE 走 **PRIO_THREAT(70)**(faction_ai:395)>主-rank PRIO_DISPATCH(50)→鎖;**FLEE_TIMEOUT 5天**(369)才釋放。
2. FLEE 5 天=不生產/不覓食→**食物流失** + 逃跑壓力→成員 stress 升→**panic 升**。
3. timeout 釋放→重評→panic 高→FLEE base 高(0.6+panic)→**再 FLEE**→循環。
4. → Team7:food 167(足)但 survival/FLEE winner 94.3%→不生產→food→0→pop 10→4→死。

**累積不釋放** = ①panic 由成員 stress 驅(stress 累積不釋放,person-system)②FLEE 0.6 floor 給永久地板③FLEE PRIO_THREAT+TIMEOUT re-latch。三者合成螺旋。**同 session 反覆的「卡住不鬆綁」病灶又一變體**(rung/coeff-lockout/survival-latch 同型)。

## 我的 T1 spec 錯（誠實認）
T1 normalize 我把 threat_pressure 從舊 `threat+panic×0.5`(threat=0 時→0,安全時自然歸零)改成 `0.6+panic×0.4`——**加了 0.6「逃跑可行度」floor**。錯:FLEE 是**純威脅反射,無獨立品質維度**,安全時逃跑=spurious 非「可行」。應讓 FLEE base 隨威脅存在,無威脅→~0(threat presence 是 FLEE 的相關性,非該剝的 urgency)。T1「剝 urgency 保 quality」對 FLEE 誤用(FLEE 無 quality,不該給 flat floor)。

## ① 2023次/90天(次要,你已 deprioritize)
crisis-team 密集重評:crisis 短 cadence=CADENCE/4=6h=4/日,但 22/日>4→疑 FLEE 螺旋致頻繁 timeout-釋放-重評 + crisis 疊加。**大概率 ② 修好(螺旋斷)後 ① 自然降**(不再瘋狂 FLEE-timeout 循環)→建議 ② 先修,① 復量再看,非獨立調。

## 推薦：② 併 survival-path slice（三修一輪,同 survival 路）
併入原 survival-latch(②)slice,一次解 survival 路三鎖:
1. **survival-latch 重選**(原②):`_evaluate_survival` 已在 survival task 仍餓+cadence 到→重跑 rank_survival(換買糧/掠奪),非 early-return。
2. **FLEE base 威脅 gate**(新②):`threat_pressure` 0.6 flat floor → 隨威脅存在(如 `clampf(ctx.threat_react × k + panic×0.4)` 或 threat-presence 因子),無威脅→~0。撤我 T1 誤 floor。
3. **panic 釋放**(視情):stress/panic 螺旋——是否加 stress decay 或 panic 上限。可能屬 person-system,評估是否本 slice 或另記。

三者皆 survival 路「卡住/spurious 不鬆綁」,同一輪對症 + 同款 organic 驗(Team7 式餓/食足隊重跑:餓隊換策略、食足隊不 spurious FLEE 到死)最有效率。

## 判斷請求
- ② 併三修(latch 重選+FLEE gate+panic)一 slice?還是 FLEE gate 因是「撤 T1 誤 floor」你要先單獨快修驗(小,可能立竿見影)?我推薦**併一輪**(皆 survival 路,一次 organic 驗),但 FLEE gate 若你要優先單發也行(它最可能是 Team7 主因)。
- panic/stress 釋放屬 person-system,本 slice 納 or 另排?

零跑至此(code 審 threat_pressure/team_panic/FLEE priority/TIMEOUT,無跑 sim)。等你裁 ② scope。
