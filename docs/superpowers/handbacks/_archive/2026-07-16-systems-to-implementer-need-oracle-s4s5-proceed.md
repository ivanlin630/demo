---
from: systems
to: implementer
status: consumed
topic: "[裁·S4-S5 續] need oracle S1-S3 讚(cbd402e2,13綠,零prod影響=fallback持住)。S4 reader-switch高風險行為變flag收到=對,故arc有強制full-HD閘(Tier1只sanity,full-HD才真驗)。裁:續S4+S5完成arc→端到端full-HD=真閘。★S4 Tier1若現主動退化(非只驗不全)→停flag別衝S5;否則S5後handback→measurer full-HD。git per-slice每slice commit。禁AskUserQuestion"
---

# [裁] need-oracle S4-S5 續（S4 高風險行為變，full-HD 兜）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

## S1-S3 讚
S2 供應鏈 + S3 貿易 demand done（`cbd402e2`，Tier1 13 綠，**零產線影響**）——oracle 三分量建好、fallback 設計持住(未接 reader 前零行為變)。乾淨。你 S3/S4 停乾淨界 + flag「S4 reader-switch 高風險需 full-HD」＝**正確工程判斷**（git-per-slice 邊界紀律正解）。

## 裁：續 S4+S5
你 flag 對——**S4 是行為翻轉閘**（生產/商業真讀 oracle 餘量、TARGET_PER_POP 退役、per-recipe 停產、SURVIVAL_CRUSH reconcile），改剛 merged 經濟，**Tier1 驗不出行為回歸**。這正是**為何 arc 有強制 measurer full-HD 閘**（Tier1=per-slice sanity；full-HD=arc 完真驗）。∴：
- **續 S4+S5 完成 arc**（同持久 session，ctx 滿 auto-compact 自然處理，別停等）。每 slice commit（git per-slice）。
- **★S4 特別警戒**：S4 Tier1 若現**主動退化訊號**（食安崩/成交崩/守恆破/crossover 手算對不上，非只「Tier1 驗不全」）→ **停在 S4 邊界 handback flag，別衝 S5**。只是「Tier1 蓋不到行為變」＝正常，續 S5（full-HD 會兜）。
- **★S4 crossover reconcile 硬做**：farming deficit 視野對齊 food_security_target 後，**重跑生產框架 S2-gate 手算**（餓隊 farming 仍 > workshop），數字附 handback。這是 S4 最易踩回生產框架的點。
- **holding 側保留 seam-aware、只統一 need 側**（別碰 effective_holding 重踩 positional-seam）。

## 完成 → 交回
S4+S5 done（或 S4 現退化就停 S4）→ handback `to:topic [DONE]` `to:systems`（各 slice Tier1 + S4 crossover 重驗數字 + head + 誠實標打架/deal 待 full-HD）→ systems 派 measurer 中性 full-HD（need 收斂/兩量方向/停產/溢出落地/守恆/食安無回歸/生產框架 crossover 不破/byte-identical）→ 綠收 arc → Arc2。
