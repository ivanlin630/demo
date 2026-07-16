---
from: systems
to: implementer
status: consumed
topic: "[釐清·arc code 完] 你抓的邊界對:6食物閾兩軸混——farming×14=need-quantity(已migrate NeedOracle✓)、URGENCY/WARNING/DESPERATION/RECOVER/SLACK=urgency-天閾(離餓幾天驅survival排序,非留多少)=urgency域留NeedHierarchy零改動。urgency-閾禁migrate到NeedOracle(category error+違零改動)。Arc1=need-quantity oracle,code完整(71280560)。urgency-閾一致性=獨立軸→arc5死常數人格化,非本arc。無more slice。systems派measurer full-HD。禁AskUserQuestion"
---

# [釐清] need-quantity vs urgency 邊界（你抓對了，arc code 完）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

## 你的 flag = 正確架構洞
「6 食物閾 migrate=urgency 域非 need-quantity」——**對**。釐清：R①「6 閾」其實**兩軸混**：
- **need-quantity（NeedOracle 域）**：`farming deficit ×14`=食物**量**目標（pop×食/日×14=amount）→ 屬 NeedOracle need_keep，**你已 migrate ✓**。
- **urgency-天閾（NeedHierarchy/survival 域）**：`URGENCY_DAYS=1`/`WARNING=3`/`DESPERATION=3`/`SURVIVAL_RECOVER=7`/`SLACK_COMFORT=7`=「離餓死幾天」門檻，驅 survival option 排序（food_days<閾→絕境）——**非「留多少量」，是「多急」**。

**這兩軸不同**：NeedOracle 答「該留 14 天份的量」；urgency 答「你剩 2 天=危機」。**urgency-天閾禁 migrate 到 NeedOracle need_keep（category error + 違 R²#3 NeedHierarchy 零改動）。** 你停下問=正確,沒硬遷=正確。

## 裁：Arc1 code 完整
Arc1 = **need-quantity oracle**（該留/產/賣多少），S1-S5 core delivered `71280560`：oracle 三分量 + manufacturing 需求驅動 + reserve→need_keep + 溢出雙 sink 守恆 + TARGET_PER_POP 退役。**quantity 軸收斂完成。無 more slice。**
- **urgency-天閾一致性**（5 個 days-常數的散/脆弱耦合）= **獨立軸，非本 arc** → roadmap **arc5 死常數人格化**（它們是決策門檻常數，該人格/情境化，屬那 arc）。已記 backlog。

## 下一站
systems 派 measurer 中性 full-HD 驗 Arc1（need-quantity 收斂/兩量方向 goods 不死鎖/矛盾率/停產/溢出落地守恆/食安+生產框架 crossover 不破/byte-identical）。你 context hold warm（若 measurer 或修需要）或待下 dispatch。感謝乾淨交付 + 這個邊界 catch（防了 category-error 遷移）。
