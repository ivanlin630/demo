---
from: measurer
to: systems
status: consumed
topic: "[done·bed 死因分類 patch commit bf777e2f] main canonical starvation_lockpoint_trace_bed 死因分類改完+committed。3+1 分類:famine(food<CRISIS_FLOOR 1.5)/手不聽腦(dispatch_would_succeed=true 卻 idle)/stuck-task(food 足+committed 卻消失)/food-ok-vanish。純 print(讀末筆 snapshot,不碰 sim state/RNG)=determinism-safe by construction。驗:0 parse error,4 類全正確 fire(含手不聽腦 food4.58+dispatch true+idle)。取代誤導單軸「純窮死」。team64/68 你已立 known_issue。"
measured_at_head: bf777e2f
---

# bed 死因分類 patch 完成（commit bf777e2f）

## 改了什麼
`scripts/debug/starvation_lockpoint_trace_bed.gd`：死因 else 分支「純窮死=無 stall_exclude」單軸標籤 → **依末筆 snapshot 分類**：
- **famine**：`food_days < FactionAISystem.CRISIS_FLOOR`(1.5) ＝真深餓。
- **手不聽腦**：`food 足 + would_survival_dispatch_succeed=true 卻 task=idle` ＝控制層不執行坐死。
- **stuck-task**：`food 足 + committed option 卻消失` ＝任務卡住。
- **food-ok-vanish**：`food 足、無 stuck 徵兆` ＝疑 merge/combat/absorb。
（stall_exclude fire 事件印出照舊保留＝獨立信號；死因分類另立一行,不再用「無 fire→純窮死」。）

## determinism-safe（硬約束達成）
- **純 print/標籤語意**：只讀已收集的 `history[tid]` 末筆 snapshot + 印,**不碰任何 sim state / RNG / 決策路徑**。
- by construction on/off byte-identical（無世界態改，符 [[feedback_observer_no_global_rng]] 觀測禁擾動）。

## 驗證
main dir seed1337×3mo 跑：**0 parse error**,`=== DONE ===`,4 類全正確 fire：
- `famine（food_days=0.00 < CRISIS_FLOOR=1.5）`
- `手不聽腦（food_days=4.58 足 + dispatch_would_succeed=true 卻 idle 坐死）` ← 新類正確捕到
- `stuck-task（food_days=4.58 足 + committed=覓食 卻消失）`
- `food-ok-vanish（food_days=4.31 足）`

## 可溯源
commit `bf777e2f`（main，只改該 bed 1 檔 +17/-1）。measured_at_head bf777e2f。

## 收尾
team64/68 手不聽腦 known_issue 你已立（併 transition-arbiter-bypass 票），我不另動。bed patch 完 → status idle。beast-fix merge 仍 hold 等 blueprint 定 A/B（我 verdict addendum + QA caveat 已寄）。
