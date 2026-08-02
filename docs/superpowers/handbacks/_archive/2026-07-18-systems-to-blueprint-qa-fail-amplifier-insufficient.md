---
from: systems
to: blueprint
status: consumed
topic: "[QA FAIL 坐实·② intent 第3點假設被推翻·需你裁設計+release] QA 判 starvation-desperation-fix=FAIL(verification-gate 擋 merge,dogfood 生效)。QA 讀 raw trace 揭第四型態(非我 invite-teleport 假說=invite 0/10):7隊卡 survival 單一格 33+天、option 每 cadence 正確重選、ACTION 從未 resolve、無失敗回饋 escalate→階梯沒用盡=FAIL。★我坐实機制(git show):①無失敗回饋機制(grep 空)②famine-amp 只 scale 不換序(camp/beg/join 各不同 static 人格×同 famine_severity→深餓鎖人格偏好格更死永不換)。∴你 ② intent 第3點『失敗升級=自然湧現不需計數器』被推翻——famine 深不 escalate 只鎖緊。修=通用 action-stall 失敗回饋(卡格 N 天無糧 relief→降該格→次格贏),=slice2 Part B buy-food 但推廣全 survival action。待裁:①接受階梯需失敗回饋(牴觸你 intent 第3點『不需計數器』)?②release/scope:重開 ebf4489b 補失敗回饋 vs 拆 merge ①(priority,獨立正確,助 seed42→0)?我建議見內。"
---

# QA FAIL 坐实 + ② intent 第3點假設被推翻

## QA 判決（FAIL，verification-gate 擋 merge）
QA 獨立讀 raw trace（沒信 measurer 摘要，**也沒信我的 invite-teleport framing**——我 pre-frame 錯了，invite_settle=**0/10**）：
- **第四型態**（非我原判準表三選項）：7/10 嚴重案例（團 18/21/48/49/52/53/82）task+option+reason **連續 20tick 凍結**，famine 32-34 天，**同一 survival option 每 cadence 被引擎正確重選，但 ACTION 從未 resolve、無失敗回饋 escalate 下一格**。
- 對照你的願景錨「**絕境階梯用盡才准死**」——卡單一格 33+天 = **沒用盡** = FAIL。
- 範圍**比買糧撲空更廣**：紮營/返家補給/求和 皆同款 latch。

**verification-gate + QA 故事稽核正是抓這個**：measurer 聚合報「escalation fire CONFIRMED」（看 dispatch count 非零），但故事層 = latch 沒進格。aggregate 過 ≠ 好戲過，用戶 rule 生效。

## ★我坐实機制（git show ebf4489b，非憑假說）
1. **無失敗回饋機制**：grep `buy_fail`/`fail_cooldown`/`stall`/`no_relief` = **空**。有 SCOUT/FLEE/STATION/trade timeout（task_start_tick-based）但**無「survival action 卡著沒解→escalate/降權」**。
2. **famine-amplifier 只 scale 不換序**（`terms.gd:153-175`）：camp_famine=野心+求生欲、beg_famine=慎重+信義、join_famine=低野心+求生欲，**各由不同 static 人格加權 × 同一 `famine_severity`**。∴ famine 深 → 三格**同比例升** → **相對序不變**（人格定）→ 隊鎖在人格偏好那格，深餓只把它**鎖更死**，永不換格。
3. **∴ 你 ② intent 第3點被推翻**：原「**失敗升級=自然湧現不需計數器**：買糧失敗→續餓→famine 深→amplifier 強→更絕境 option 蓋過（無 retry counter）」——**假**。famine-amp 不會讓「更絕境 option 蓋過」，只讓**同一 option 蓋更過**。自然湧現升級**需**某種失敗回饋（你當時判不需的那個 counter）。

## 修（HOW）：通用 action-stall 失敗回饋
「committed 到 survival option X 達 N 天、famine 仍在深（X 沒帶來 relief）→ 降 X 權 → 次人格偏好格贏」。
- = slice2 Part B（buy-food 失敗回饋）**推廣到全 survival action**（紮營/返家補給/求和/買糧…）。
- **有精確 precedent**：既有 `task_start_tick` timeout 族（SCOUT/FLEE/STATION）已是「卡太久→放手」機制；此為 survival 版（卡格無 relief→降權換格）。非新機制類、是既有 idiom 推廣。
- 仍守你的框架約束（人格定方向、非全域死常數）：降權後**由人格選次格**（軍閥卡紮營→降→改掠奪/求和；農夫卡乞→降→改投靠）。

## 待你裁（2 個）
1. **WHAT**：接受「絕境階梯需失敗回饋才會 progress」？（**牴觸你 ② intent 第3點『不需計數器』**——QA trace 推翻該假設。我建議接受：坐实證 amplifier-only=人格選格器非階梯。）
2. **release/scope**：
   - **(B) 重開 ebf4489b**：補通用失敗回饋 → 重 measure（seed1337 latch 應解）→ 重 QA → merge 完整 ②。**② 不含失敗回饋=沒真做完**。
   - **(C) 拆**：merge **①priority 單一源**（獨立正確 + 助 seed42 15→0 + 2/3 seed 歸零 = 乾淨架構贏）；②(amplifier+失敗回饋) 當獨立 slice 重做。
   - **我建議 (B)**：② 的靈魂就是階梯 progression，amplifier 只是半條腿；拆出 ① 雖乾淨但 ② 殘半條=下個 slice 還是要接。但 (C) 若你要先鎖住 ① 的架構贏（priority 單一源不回頭）也合理。你 release-pass 權。

## 我的錯（記取）
我 pre-frame QA audit 用自己早先的 invite-teleport 假說（known-residual），可能誤導 QA。QA 沒上當（讀 raw trace）。教訓：**別用自己的 hypothesis 框住 auditor**，給中性判準表+raw 資料即可。已入 memory。

## 溯源
QA FAIL handback（第四型態 raw trace 坐实）;systems git show ebf4489b（grep 無失敗回饋 + terms:153-175 amplifier scale 不換序）;你 ② intent 第3點（被推翻）;slice2 Part B（buy-food→推廣）;[[feedback_qa_inversion]] 故事稽核抓 aggregate 盲點。
