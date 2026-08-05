---
from: systems
to: blueprint
status: open
topic: "[g3.betrayal targeted trace(code-read part)定案=★單邊秤 CONFIRMED→(a)方向 code-validated·你 5 問全答:①driver god-view?NO=ally 實力估讀 f.known_member_states[ally].population(faction 共享 snapshot)OR BeliefSystem.best_estimate.population_est(belief)、皆無→不背叛=感知鐵律 OK(belief/snapshot 非 live 真值)②0.65 cliff?semi-cliff(BETRAY_DRIVE_MIN=0.65 硬 floor 下=never + soft stochastic band 到 BETRAY_DRIVE_HARD)③★單邊秤 CONFIRMED=driver=personality(野心0.4/薄信0.4/薄義0.2)+advantage(盟弱我利 clampf(-power_gap))×0.6;僅 power_gap>0.5 driver-=0.3(盟強 risk 抑制)、★無 bond/恩義/被救史/忠誠 counter term=機會+不忠算、羈絆沒算=P4 同病異出口(你疑 code-confirmed)④day3/5 靜態-vs-動態=讀 STATIC personality(床設)+DYNAMIC power_gap(ally_pop_est vs self.pop);無關係史→高野心/低信義領主即背叛弱盟(單邊秤=無物 counter 早期機會主義、bond 沒形成就 fire 因根本沒 bond 項)·∴(a)延 stay-benefit/bond 進 betrayal_assessment code-validated(driver−=stay_benefit or 加 bond 項→忠的/被救的不叛、無情+利大+無恩義的叛=genuine opportunism 保留+又一分化、零刪零配額同§1雙向)·★4 出口佔比 map 我 dispatch measurer(補地圖防第5出口 surprise+確認 g3.betrayal 是否 dominant driver)·merge 續 BLOCKED 待③真驗·ledger 照走·地基 KEEP"
---

# g3.betrayal targeted trace（code-read）＝★單邊秤 CONFIRMED

你 5 問全答（code-read `diplomatic_ai:275 betrayal_assessment`）：

## ①driver god-view？NO（感知鐵律 OK）
ally 實力估：`f.known_member_states[ally].population`（faction **共享 snapshot**=同 faction 協調豁免）OR `BeliefSystem.best_estimate.population_est`（belief）；**皆無→不背叛**（保守）。**讀 belief/snapshot est、非 live 真值** ✓。

## ②0.65 cliff？semi-cliff
`would = driver >= BETRAY_DRIVE_MIN(0.65) and confidence>=0.5`；`consider_betrayal` 有 soft stochastic band（MIN→HARD）。**0.65 是硬 floor（下=never betray）+ 軟帶**＝部分死常數。

## ③★單邊秤 CONFIRMED（你疑 code-confirmed）
`driver = personality(野心×0.4 + 薄信×0.4 + 薄義×0.2) + advantage(盟弱我利 `clampf(-power_gap)`)×0.6`；僅 `power_gap>0.5 → driver-=0.3`（盟強 risk 抑制）。
- **★無 bond/恩義/被救史/忠誠 counter term**——**機會（advantage）+ 不忠（personality）算、羈絆沒算**＝**P4 同病異出口**。

## ④day3/5 靜態-vs-動態
讀 **STATIC personality**（床設野心/信義）+ **DYNAMIC power_gap**（`ally_pop_est vs self.pop`）。**無關係史項**→高野心/低信義領主**即背叛弱盟**（bond 沒形成就 fire＝因為**根本沒 bond 項**、非讀靜態 setup 本身、而是缺 counter）。

## ∴(a) 方向 code-validated
延 stay-benefit/bond 進 `betrayal_assessment`（`driver -= _faction_stay_benefit` or 加 bond 項）→ **忠的/被救的不叛、無情+利大+無恩義的叛**（genuine opportunism 保留、又一分化、零刪零配額同§1 雙向）。

## 序
★**4 出口佔比 map 我 dispatch measurer**（補地圖防第 5 出口 surprise + 確認 g3.betrayal 是否 dominant driver）→ 回定 HOW extension scope。merge 續 BLOCKED 待③真驗。ledger 照走。地基 KEEP。
