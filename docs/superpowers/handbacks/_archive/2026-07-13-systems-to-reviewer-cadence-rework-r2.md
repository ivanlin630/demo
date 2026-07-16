---
from: systems
to: reviewer
status: consumed
topic: [R②·cadence] 重評cadence重構設計審——churn/survival-latch/成員互搏/perf 壓測;dispatch前
---

# R② 設計審：重評 cadence 重構

## 前置
- R① premise CLEAN(`cadence-rework-r1-verdict`,五項坐實+無隱藏重評路)。spec `docs/superpowers/specs/2026-07-13-reeval-cadence-rework.md`。藍圖裁 pivot B + 觸發模型。

## 內容
拿掉非-unified `_evaluate_solo:1764` IDLE-lock，改三閘 OR：週期(`DECISION_CADENCE` 1日)+IDLE 立即+`_decision_crisis`(複用 crash-bypass 事件提前)。COMMITMENT_BONUS(既有)防抖不疊 IDLE-gate。4 task：T-cad1 核心週期/T-cad2 crisis/T-cad3 成員收斂(債縫#3,高風險)/T-cad4 unified 收斂(可選)。

## 請 R② 重點壓測
1. **churn（最高風險）**：拿掉 IDLE-lock→非-unified 每 DECISION_CADENCE(1日)重評。COMMITMENT_BONUS(0.3) 是否**夠防每 cadence 亂跳**？——查現行 COMMITMENT_BONUS 量級 vs term util 差（0.3 相對 base~1 的 option 間差，翻不翻得動）；1 日 cadence 是否太頻繁（抖）或合理。這是「認知 vs 蟑螂/雜訊」平衡的技術面。
2. **survival-latch 保**：週期重評打斷絕境覓食？——survival_pressure(食0→12... 註:normalize 後覓食 base=1.0×coeff,survival urgency 高時 coeff~1)+COMMITMENT 應保餓隊續覓食。查週期重評時 survival 態隊會不會被非-survival option 搶（TC2/survival-dominance latch 不回歸）。normalize 後 survival base 已剝為 [0,1]→靠 coeff 撐,查重評頻繁下 survival 仍 sticky。
3. **T-cad3 成員互搏（判是否該拆）**：成員從無重評→進主 rank(faction_duty term 載服從)。與 `_assign_tasks` 派工雙寫風險（688 註警「避大面積互搏」）。查：讓成員進主 rank 是否與 faction 派工衝突（雙路徑寫 current_task）;還是該拆 T-cad3 為後續 slice、T-cad1/2 先解主根。**我傾向若你判互搏風險高→拆**。
4. **crisis 不推 next_tick**：`_decision_crisis` true 時允許連續反射（不推 cadence 到未來）——會不會 crisis 持續時每 tick 重評爆量/churn？是否該給 crisis 短 cadence 而非全放。
5. **perf**：週期重評 O(23×term)×隊×(1/cadence)。查是否 LOD 已限評估隊數（premise 提 _evaluate_solo 走 LOD near-set）→ cadence×LOD 是否可控;還是需 perf 量測 gate。
6. determinism（decision_eval_next_tick 純整數推進,crisis 純讀,零 randf）。

## 註
- 全 TEST VALUE（DECISION_CADENCE/crisis 門檻/COMMITMENT 若需調）,measurer 校。
- CLEAN 則 dispatch（T-cad1/2 核心先,T-cad3 依你判拆否,T-cad4 defer）。churn/survival-latch/成員互搏任一你判過險→回 verdict 收窄。
