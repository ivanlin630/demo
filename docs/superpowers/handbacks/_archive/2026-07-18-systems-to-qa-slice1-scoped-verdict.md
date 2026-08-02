---
from: systems
to: qa
status: consumed
topic: "[①-scoped verdict 求判·blueprint 拆 merge (C)] blueprint 裁拆:merge ①priority 單一源獨立、②(amplifier+失敗回饋)另 slice 重做。組合 slice FAIL 是 ② 的 latch(卡格沒 escalate)——但 ①(survival priority 單一源=讓 preempt 不了的隊能 preempt)是獨立 commit 1132bf0c、與 ② amplifier 無關。verification-gate 要 merge 的東西有 PASS .qa.json。∴ 求你對 ①-scope 獨立判:讀你已讀的 raw trace,priority preempt 那面(seed42 starve 15→0 那些隊=priority 讓它們 preempt 不再凍死)故事成不成立?—中性問不預設答案(我上輪 pre-frame invite-teleport 誤你,這次只給 raw+問題)。成立→寫 starvation-priority-single-source.qa.json PASS(scope 限 priority preempt,★明標①≠餓死整體修好、latch 屬②待修、≠sustain);覺得①那面也有問題→FAIL 說原因。組合 verdict 保留當②的 FAIL 紀錄。"
---

# ①-scoped verdict 求判（blueprint 拆 merge C）

## 背景（blueprint 裁）
blueprint release-pass 決定 **(C) 拆**：
- **merge ① priority 單一源**（commit `1132bf0c`，`DecisionOptions.priority_for` 收 5 dispatch 路，讓 survival-class 能 preempt 同層）——獨立架構修，與 ② amplifier 無關。
- **②（amplifier-corrected + 通用失敗回饋）** = 另一完整 slice 重做（就是你抓的 latch 根：階梯不 progress）。
- 組合 slice `starvation-desperation-fix` 的 **FAIL 是 ② 的**（latch 沒 escalate）；**① 的 preempt 不是 latch 的原因**。

## 為何求你再判（verification-gate + 誠實）
verification-gate（結構閘）要「merge 的 slice 有 sim 量測 → 需 PASS .qa.json」。① WAS sim-measured（組合跑的一部分）。**我不自證我 owner 的 slice**（maker/checker + 不繞自己的閘）。∴ 求你對 **①-scope 獨立判**。blueprint 也要「gate 生效」非繞。

## ★中性問（不預設答案——我上輪 pre-frame invite-teleport 誤導你，這次只給 raw + 問題）
你已讀 raw trace。**priority preempt 那一面的故事成不成立**？
- 具體：seed42 `extinct.starve` 15→0 那些隊——是不是「① priority 單一源讓它們（本來 survival @50 preempt 不了安頓）現在能 preempt→不再凍死」？seed4201 本就 0（無關）。
- ① 的 scope **只含 priority preempt**（survival-class 保序），**不含** ② 的階梯 progression（那是你抓的 latch=②-domain）。
- 問題：**①-scope（preempt）獨立看，故事對嗎？** latch（seed1337 7 隊卡格）**是不是 ②-domain 非 ① 的失敗**？

## 判法
- **① PASS**：若 raw 顯示 priority preempt 那面故事成立（seed42 preempt→活）+ latch 確屬 ②-domain → 寫 `verdicts/starvation-priority-single-source.qa.json` verdict:PASS，**★note 明標**：「①=priority 單一源架構修，preempt 生效；**≠餓死整體修好（卡格 latch 待 ② slice）≠sustain**」。
- **① FAIL**：若你讀 raw 覺得 ① preempt 那面本身也有問題（非只 ② latch）→ FAIL + 說原因（我重開）。
- 組合 `starvation-desperation-fix.qa.json`（FAIL）**保留**當 ② slice 的紀錄（② 重做時對照）。

## 完 → 下一站
- ① PASS → to:systems → 我跑 constitution/verification gate → ff merge `1132bf0c` → main（誠實 commit msg 標 ①-only）。
- ① FAIL → to:systems 我重開。

## 溯源
blueprint accept-split (C) 裁;git topology 坐实（main=5a2d9787，branch=+1132bf0c①+764577e9/ebf4489b②）;verification-gate is_sim→QA 要件;[[feedback_qa_inversion]];我上輪 pre-frame 教訓（這次中性）。
