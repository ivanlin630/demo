---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] g3.betrayal延伸HOW(第四出口bond counter-term)——Seam親驗坐實:diplomatic_ai_system.gd:299-300確認driver=personality+advantage×BETRAY_ADVANTAGE_GAIN、power_gap>0.5抑制0.3,零bond/relief counter=單邊秤claim精準;:296-297 ally_pop_est來源親讀確認是faction snapshot(known_member_states)或belief(best_estimate),非live god-view,驅動輸入乾淨;:314-319 consider_betrayal的randf soft-band只在BETRAY_DRIVE_MIN~HARD窄margin內生效,新counter-term在driver計算上游插入純算術減項不會碰到這段RNG邏輯,determinism/既有stochastic tie-break結構皆不受影響;:324-333 _execute_betrayal的clear_team_faction親讀確認完全未被觸及,零刪claim坐實;★共享helper要求親驗架構上零風險:_faction_stay_benefit已是FactionAISystem的無self-state純函式(只讀state/team參數),diplomatic_ai_system.gd呼叫FactionAISystem.new()._faction_stay_benefit(...)是這整個codebase一路都在用的既有跨class呼叫慣例(本session已見過數十次precedent如FactionAISystem.new()._merchant_trade_target等),不需要改成static才能安全共用同一個函式本體,正是我上輪要求的『一套非兩套』能直接達成非要等大重構;§1防crank五點逐一對上實際code(零刪/禁boost因counter=已驗證genuine helper的減項/零god-view繼承既有性質/genuine opportunism因counter=0時driver不變仍可能過門檻/determinism因純算術插入不動既有RNG段);0.65 semi-cliff正確defer避免scope creep;CLEAN→dispatch implementer續feat/faction-cohesion→re-measure③下游解鎖真驗"
---

# R②判決：g3.betrayal延伸HOW（勢力凝聚力第四出口）— CLEAN

## grounding——上輪必查項的自然延續，非新problem
上輪我在faction-cohesion build merge-gate那輪確認了三決策點(defect/uprising/`_trigger_defection_evaluation`)統一到`_faction_stay_benefit`。這次measurer量測揭露③(rep床不再秒崩)這個下游解鎖指標仍FAILED，真根不是前三個出口沒修好，是**第四個獨立出口**（`diplomatic_ai`的g3.betrayal機制）本來就完全沒被這次arc碰過、仍是單邊秤——這是良性的「量測揭露漏了一個同病灶的出口」而非前面工作有瑕疵，spec自己定性「同病異出口」精準。

## Seam——親驗坐實
親讀`diplomatic_ai_system.gd:296-300`：

```
var power_gap: float = (ally_pop_est - float(self_team.population)) / maxf(float(self_team.population), 1.0)
var advantage: float = clampf(-power_gap, 0.0, 1.0)
var driver: float = personality + advantage * BETRAY_ADVANTAGE_GAIN
if power_gap > 0.5: driver -= 0.3   # 盟強 → 抑制
```

`driver`公式確認只有`personality`（機會/不忠人格）+`advantage`（盟友弱勢程度）兩項相加，`power_gap`大於門檻時扣0.3——**完全沒有任何跟「這個member欠這個盟友/勢力什麼恩情」相關的項**，單邊秤claim精準坐實。`:285-293`親讀`ally_pop_est`的來源——`f.known_member_states`（同faction共享snapshot）或`BeliefSystem.best_estimate(...).population_est`（belief）——確認驅動輸入本身已經是belief/snapshot，非live god-view，這條線的感知鐵律地基本來就乾淨。

## ★共享helper——親驗架構零風險，直接滿足「一套非兩套」要求
這輪最重要的查核是「共享`_faction_stay_benefit`會不會變成第五套精度」。親確認`_faction_stay_benefit`（上輪已審過）是`FactionAISystem`上一個**無instance-state依賴的純函式**——只讀傳入的`state`/`team`參數，不碰`self`任何欄位。`diplomatic_ai_system.gd`要呼叫它，走`FactionAISystem.new()._faction_stay_benefit(state, self_team)`這個模式——這正是本session整路反覆見過幾十次的既有跨class呼叫慣例（例：`decision_context.gd`呼`FactionAISystem.new()._merchant_trade_target(...)`、`OrderSystem.new().best_arbitrage_order(...)`到處被其他class呼叫）。這代表「兩個系統呼叫同一個函式本體」**不需要**先把函式改成static或搬去共享utility class才能安全做到——現有寫法直接呼叫就是真的呼叫同一份程式碼、非另抄一份。上輪我抓到的「兩套精度」風險，這次用最小改動（一個跨class呼叫）就徹底避免，沒有製造新的架構負擔。

## §1防crank五點——逐一對上實際code
**零刪**：親讀`_execute_betrayal`（`:324-333`）完整函式，`state.clear_team_faction(self_team)`一行原封不動、沒有出現任何新的condition包住它——背叛執行端完全沒被這次改動碰。**禁boost逼留**：counter-term是`driver -= _faction_stay_benefit(...)`，減去的是上輪已經驗證過genuine（讀真benefactor memory+belief reputation）的值，非發明一個「忠誠獎勵」常數往上加。**零god-view**：counter繼承`_faction_stay_benefit`既有性質，driver本身的`ally_pop_est`也已確認是belief/snapshot。**genuine opportunism保留**：`stay_benefit≈0`時`driver`幾乎不變，一個真的無情+真的有利可圖+真的沒受過恩惠的member，減掉接近0的值後driver依然可能超過`BETRAY_DRIVE_MIN`——沒有被焊死成「凡是member都不會背叛」。**determinism**：counter是driver計算上游插入的一行純算術減法，`consider_betrayal`(`:309-322`)裡`randf()`那段soft-band tie-break邏輯（親讀確認只在`BETRAY_DRIVE_MIN`~`BETRAY_DRIVE_HARD`窄margin內才擲骰）完全沒被觸碰，只是它讀到的`driver`輸入值現在多了一項，既有RNG段落結構不受影響。

## 0.65 semi-cliff——defer範圍判斷合理
spec自己標「本延主刀=bond counter-term、0.65連續化可選defer、若動→另過R②」——這個範圍切分我認可：這輪的核心命門是「driver有沒有counter項」，0.65這個門檻本身連不連續是次要的照妖鏡polish，硬要這輪一起做只會增加變動面、稀釋「這次到底改了什麼」的可驗證性，正確地留給之後單獨審。

## 判決
**CLEAN → 回systems → dispatch implementer續build（`feat/faction-cohesion`）→ re-measure（★③下游解鎖真驗：rep床不再秒崩+4出口佔比map）→ QA → merge。** Seam/counter-term數學/共享helper可行性/§1五點皆親讀code逐條核對，非信spec文字宣稱；「共享helper=既有跨class呼叫慣例、非要重構」這個判斷是這輪最重要的架構確認，讓上輪我提的要求以最小成本被滿足。
