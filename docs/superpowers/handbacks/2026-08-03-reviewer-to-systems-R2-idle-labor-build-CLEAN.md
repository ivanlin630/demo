---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+1追蹤項] idle-labor→建設 genuine激勵HOW——親讀options.gd:40-46(建設applicable恆true)+terms.gd:116,193(settle_fit常數0.4/ambition_drive只吃ambition_gap)確認Q1「labor-blind」premise精準；idle_employ_value公式每個因子皆有真grounding(非乙那種arbitrary amp)，結構上非crank；追蹤：PER_HAND_OUTPUT這個新常數implementer訂值時應該從manufacturing真實worker_rate/labor_mult公式反推而非獨立發明，否則risk變成一個縮小版的乙"
---

# R②判決：idle-labor→建設 genuine 激勵 HOW — CLEAN + 1 追蹤項

## Q1/Q2 premise——親讀確認精準
`options.gd:40-46`「建設」：`applicable=func(_ctx):return true`——**無條件**適用，不吃任何ctx欄位（含未來的idle_labor），確認「labor-blind」完全成立。`terms.gd:193` `settle_fit`對「生產」「建設」回傳**固定常數0.4**（comment原文「不動(另含ambition_drive)」）；`terms.gd:116` `ambition_drive=clampf(ambition_gap×0.3,0,1)`只吃`ambition_gap`——兩個term合起來，建設util目前**完全不依賴團隊規模/人口/閒置勞力**，大隊小隊同等野心值算出的建設分數一模一樣。這正是這個修正要打的洞，premise坐實非空談。

`options.gd:168-176`「紮營」：`applicable`要求`food_days<DESPERATION_DAYS and has_farmable_tile and not has_own_outpost`——確認「有outpost就不能紮營找第二據點」，§4把spread這條標成需要un-gate的另一個更大範圍改動、MVP先不碰，這個範圍切分合理誠實，不是為了省事迴避。

## idle_employ_value公式——結構上非crank
`min(idle_labor, D_NEW_WORKSTATION) × PER_HAND_OUTPUT × need_weight(candidate facility產物)`——三個因子逐一檢查：
- `idle_labor`：直接複用我上輪已經親讀驗證過的`labor_system.gd`真實資料結構(`pool_of`+`Σlabor_alloc[k].demand`)，非新造的假數字。
- `D_NEW_WORKSTATION`：`level×K_MFG`，沿用勞力池既有常數，同一套語彙。
- `need_weight`：走`need_oracle`真實need_keep+demand，無需求的產物this term=0——不會誘導蓋沒人要的設施。

跟乙那次的`ambition_amp=0.5+AMB_GAIN×gap`比較：乙的問題是那個放大倍率沒有對應到任何「真實產出」，純粹是「讓util數字變大」的旋鈕；這次的`idle_employ_value`每一項都指向「真的雇用了多少手、這些手真的能產出多少、這些產出真的有沒有人要」——是一個期望值計算，不是一個為了讓選項fire而調的乘數。self-limit(閒勞力隨設施吸收遞減)也confirm了這不是無限鼓勵蓋房子，蓋到閒勞力被吸收完就沒有額外誘因了。

## ★追蹤項——`PER_HAND_OUTPUT`這個新常數的取值方式
spec沒有給這個常數的具體數值(留給implementer/tuning，符合這個codebase的慣例)。但我想指出：如果這個「每隻手的產出價值」是**獨立發明**的一個數字(非從manufacturing現有的`worker_rate=level×labor_mult×(0.5+skill×0.5)`這類真實公式反推)，就有可能在「結構是genuine」的外殼下，藏一個「這個常數剛好調到讓建設看起來划算」的縮小版crank——結構對不代表每個具體數字都自動誠實。

**要求**：implementer訂`PER_HAND_OUTPUT`時，應該從manufacturing真實的產出公式（例如某個代表性設施在標準skill/rate下，一隻手實際貢獻多少產出）反推校準，而非憑空取一個「看起來讓建設有感」的數字。dev-verify §5-2(genuine非crank)測「idle=0或無需求→term=0」是必要條件但不是充分條件——常數本身的**來源**也要交代清楚，這條我沒看到spec明講，要求implementer補這個校準依據。

## 判決
**CLEAN → dispatch隔離`feat/idle-labor-build`。** premise/formula結構/guardrail/gap-deferral皆核到位。追蹤項(PER_HAND_OUTPUT取值依據)非blocking，implementer落地時請附上校準推導，dev-verify/§8 re-measure照spec既定計畫走。
