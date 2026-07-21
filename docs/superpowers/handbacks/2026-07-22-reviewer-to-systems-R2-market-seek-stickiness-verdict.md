---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·market-seek stickiness Gate A·CLEAN] 手不聽腦家族修做對:sticky 只 suppress 機會性經濟 cadence-divert,全逃逸閥保留。①crisis escape 坐實(sustained crisis→not in_crisis=false→落/4 cadence→survival divert,不餓死買路)②威脅經 _evaluate_threat 獨立路(TASK_TRADE∈PREEMPTIBLE)不受 sticky 阻③TRADE_TIMEOUT(817 距離估)兜 zombie+市場拆除抵達清 move_target 再 re-eval④resident 擺攤 move_target=-1 不受影響⑤無 RNG⑥measure sound。"
---

# R² verdict：market-seek stickiness（Gate A，手不聽腦家族）

**VERDICT: CLEAN** — 可 dispatch。`premise_contradiction: false`。手不聽腦家族修**做對**（sticky committed transit task，但全逃逸閥保留=不造新 latch）。factcheck 對 HEAD `fa10121d`。

## Root 坐實
- market-seek = unified `TASK_TRADE`（move_target=市場）走 `_decide_unified`（`_should_reeval` cadence gate）。
- `TASK_TRADE` **不在** `SURVIVAL_TASKS`（`:79`=RETURN_HOME/BEG/JOIN/FORAGE/CAMP，無 TRADE）→ 非 sticky；子隊 transit-exempt（`_evaluate_subteam:1710`）只保 subteam builder，unified market-seek 無保護 → cadence re-eval 機會性搶走 → 64% divert 到不了市場。坐實。

## ★安全分析（逃逸閥完整性=手不聽腦家族的關鍵）
fix 插 `_should_reeval`（`_directive_fresh` 後、cadence 1898 前）：`if TASK_TRADE and move_target != (-1,-1) and not in_crisis: return false`。`in_crisis`（`:1885`）在 scope。逐逃逸驗：

1. **★crisis escape → CLEAN**。`not in_crisis` = 關鍵閥。market-seeker 進 crisis：**edge**（`:1886-1888`）先 return true（逃）；**sustained crisis**（crisis_latched，落過 edge）→ fix 的 `not in_crisis`=**false**→ **不 sticky** → 落下方 cadence（crisis 排程 **/4** 快）→ survival 可 divert。∴ **餓/暴跌 market-seeker 頻繁 re-eval，不餓死買路**。手不聽腦教訓（別 trap 餓隊在非求生 committed task）正確套用。

2. **威脅 escape → CLEAN（獨立路，不受 sticky 阻）**。`TASK_TRADE ∈ PREEMPTIBLE_TASKS`（`:118-119`）→ `_evaluate_threat`（獨立 cadence 路，非 _should_reeval）可 preempt market-seeker → FLEE/DEFEND。sticky 只作用 `_decide_unified` 經濟重評路，**不阻威脅 preemption**（不同路）。flee/defend 逃逸保。

3. **IDLE/stuck/directive escape → CLEAN**。三者上方已 `return true`（`:1878/1881/1892`）→ 卡住/剛釋放/faction 新命令 全在 sticky 前逃。

4. **trade-timeout zombie 兜底 → CLEAN**。`TRADE_TIMEOUT`（`:817-822`）**距離估額度**（`+hex_dist × PER_HEX`）→ 追不到/市場消失 → timeout release（`trade.timeout` probe）。∴ sticky 不造永久 zombie。**市場拆除邊角**（Slice C demolish 清 known）：market-seeker 續往舊市集 → **抵達→move_target 清→sticky condition false→re-eval 發現無市集重選**，或 timeout 先 release。有界，非永卡。

5. **resident 擺攤 → CLEAN**。`move_target==(-1,-1)`（非在途）→ fix condition false → 正常 re-eval（不 sticky）。同 Slice C 擺攤語意（原地無 move_target）。

6. **無 RNG → CLEAN**。純 guard（task/move_target/in_crisis 布林）。

## 審點回覆
①crisis escape 正確（`not in_crisis`→sustained crisis 落/4 cadence 求生）②IDLE/stuck/crisis-edge/directive 上方 return true + 威脅 _evaluate_threat 獨立 preempt 全保 ③trade-timeout 距離估兜 zombie ④resident 擺攤 move_target=-1 不受影響 ⑤無 RNG ⑥measure=arrive%+deal+sticky-fire+doom-delta+**無 starve 回歸**（crisis escape 驗）sound。全 CLEAN。

## 回覆
CLEAN → dispatch。impl pre-merge R²：①guard 條件精確（TASK_TRADE + move_target!=-1 + not in_crisis）②插入點對（directive 後 cadence 前，in_crisis in scope）③無 RNG determinism ④measure 必含 **no-starve-regression**（crisis escape 硬驗——別餓死買路隊）+ arrive%（36%→?）。

——手不聽腦家族（committed task 執行到底）第 N 修：**這次做對**了——sticky committed transit **但每個逃逸閥（crisis/威脅/stuck/timeout/directive）都保留**。異於早期手不聽腦修的教訓（sticky 別變 trap）：此修的 `not in_crisis` + 威脅獨立路 + timeout 三重逃逸=不造新餓死/凍結 latch。範式健康。
