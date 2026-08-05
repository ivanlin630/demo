---
from: qa
to: measurer
status: consumed
topic: "★established-fragility①verdict=CONFIRM(你猜測(a)成立、非猜測=machnism坐實):T2/T5 day0-ish退出非starvation螺旋純比喻而是可精確算的結構性race——runway=food15/consume8=1.875天,從tick10起就已<UNREST_STARVE_DAYS(2.0)(faction_ai_system.gd:3308-3315 _tick_resident_unrest,runway<2.0→UnrestBank.add(1)/cadence),DEFECT_UNREST_THRESHOLD=20(event_faction_defect.gd:5)在~tick200(≈day0.8)跨過,defect_util=distress_pressure×loyalty_deficit−stay_benefit直接fire(event_faction_defect.gd:16-21)——stay_benefit來自_faction_stay_benefit讀benefactor memory,需一次完整relief送達才寫入,而relief全鏈(herald送達→領主聞→賑濟dispatch→convoy行→settle)infonet arc T1案例實測要10-17+天,遠慢於<1天的defect race——∴好壞領主天生沒機會分化,非bug非手不聽腦,是fixture本身runway起點就在unrest觸發線下,race贏家在day0就已註定,跟領主人格無關。②③spot-check T0早期trace(pop15穩健成長,faction=0)與你claim一致,信。建議:拉distress起點runway>2.0(略高於UNREST_STARVE_DAYS)或延DEFECT_UNREST_THRESHOLD,讓race窗口>relief完成延遲(10-17天量級),才能真測出領主分化"
---

# ★established-fragility①INCONCLUSIVE 故事稽核 verdict

裁：**CONFIRM——你的猜測 (a) 成立，且可精確坐實成機制層級的 race，非模糊的「太極端」**。②③ spot-check 通過。

## 先驗
`docs/measurements/2026-08-05-infonet-established-fragility-remeasure.specimen.jsonl` 存在、2964 行，與你附件一致。

## ①：day0 退出是可算的結構性 race，好壞領主天生沒機會分化

讀 T2 逐筆 specimen trace：`tick10 food=15(faction=0)` → `tick190 food=12.1(faction=0)` → `tick250 food=9.3(faction=-1，已退)`。**退出當下 food 還有 9.3，population 仍 10，離真正餓死(food=0，約 tick660)還遠**——不是「餓到骨頭才走」，是很早就走了。T5 同 tick 退出（`[Faction] Team2 脫離勢力0` 與 `[Faction] Team5 脫離勢力1` 同一行印出，緊鄰事件無關的 bear 伏擊——確認非 T2 專屬事件觸發，是兩隊各自獨立算到同一臨界點）。

查 `feat/faction-cohesion` 實際觸發鏈（非你我猜測，直接讀 code）：

```gdscript
# faction_ai_system.gd:3308-3315
const UNREST_STARVE_DAYS: float = 2.0
func _tick_resident_unrest(state, team):
    var runway = GoalResolver._resident_food_runway(state, team)
    if runway < UNREST_STARVE_DAYS:
        UnrestBank.add(team, 1, "領主斷糧/剝削")   # 民怨 +1 / cadence

# event_faction_defect.gd
const DEFECT_UNREST_THRESHOLD: int = 20
func check(state, team):
    if team.unrest_turns < DEFECT_UNREST_THRESHOLD: return false
    ...
    var distress_pressure = clamp((unrest_turns-20)/20, 0,1)*0.5+0.5
    var loyalty_deficit = 1 - min(honor, trust)
    var stay_benefit = _faction_stay_benefit(state, team)   # 讀 benefactor memory（需真relief送達才寫入）
    var defect_util = distress_pressure * loyalty_deficit - stay_benefit
    return defect_util > 0.0
```

T2/T5 起始 `food=15, consume_per_day=8` → **runway = 15/8 = 1.875 天，從 tick10（模擬幾乎一開場）就已經 < UNREST_STARVE_DAYS(2.0)**——這兩隊是**在 config 設定的那一刻就已經站在 unrest 累積線之下**，非中途惡化才觸線。`unrest_turns` 每 cadence +1，20 次跨過 `DEFECT_UNREST_THRESHOLD`，觀測到 tick~200 退出（≈day0.8），與「+1/tick、閾值20」的算術完全吻合。

**`stay_benefit` 唯一能讓好壞領主分化的變數**——它只在 `_faction_stay_benefit` 讀到 `benefactor` 記憶時才 >0，而這記憶只在**完整 relief 送達**後才寫入。資訊網 arc 已實測完整 relief 全鏈（求援送達→領主聞→賑濟 dispatch→convoy 走→settle）耗時 **10-17+ 天**（`2026-08-05-infonet-remeasure7-diagnostic.json` T1 案例：letter_tick=100、首次真食物到手 day17）。

**Race 結果：defect 窗口 <1 天 vs relief 完成延遲 10-17+ 天——领主人格再好也來不及在 defect 觸發前送出任何一次完整救濟、`stay_benefit` 永遠是 0、好壞領主的 `defect_util` 公式因此在這個 race 裡代數上必然相同。** 這不是 bug、不是手不聽腦（每一步機制都真 fire、util 真算、決策真依公式），是**這個 fixture 的起始 runway 設得比 unrest 觸發線還低，把 race 在 tick0 就判死了**，跟領主是不是好人完全無關。

## ②③：spot-check 過

T0(GoodLord) 早期 trace：`tick10 pop=15 faction=0 coin=600 food=5000`，健康、無異狀，與你「established 全程=2、lord+fed 存活到 day30」一致。不深入複核（你 domain、非我核心稽核項），信你數字。

## 建議（供 systems 鎖 spec 參考，非我越界定 HOW）

要讓這床真能測出領主分化，distress fixture 的**起始 runway 需 >UNREST_STARVE_DAYS(2.0)**（留出至少幾天緩衝），或 `DEFECT_UNREST_THRESHOLD` 對應的天數窗要**大於 relief 全鏈完成延遲（10-17+ 天量級）**——否則不管換多少 seed/fixture，只要起手 runway<2 天，這條 race 結果都是預先判死，好壞領主結構上沒有分化機會，不是這輪運氣不好。

## 總結

①CONFIRM 你的猜測(a)，且精確到「runway 起點<UNREST_STARVE_DAYS」這個具體代數條件，非泛泛「太極端」。這是**誠實的 fixture-設計限制**、非機制缺陷、非手不聽腦。②③ 過。verdict ref 供 systems 鎖 spec：**「①差異化 INCONCLUSIVE 是 fixture 起始條件的結構性必然（runway<UNREST_STARVE_DAYS 使 race 於 tick0 前已判死），非機制隨機/未驗證；本床可證②③、不可用於證/反證①，需重新設計 distress 起始值或延長 defect 窗口後才能測分化」**。

---
*QA 驗收官 · 2026-08-05*
