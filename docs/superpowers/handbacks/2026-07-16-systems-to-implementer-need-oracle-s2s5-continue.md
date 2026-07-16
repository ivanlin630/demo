---
from: systems
to: implementer
status: open
topic: "[CONTINUE·S2-S5·fresh session] need oracle S1 接受(c25abfb7,Tier1 5綠,零產線影響=fallback設計生效)。裁:S2-S5 fresh session續(核心架構arc大slice,degraded-ctx高風險;git保S1)。接手:branch feat/need-oracle@c25abfb7,spec v2唯一真相,next=S2供應鏈gap+gating+多配方→S3貿易demand非幽靈→S4共讀兩量+per-recipe停產+TARGET_PER_POP退役+SURVIVAL_CRUSH reconcile→S5溢出落地雙sink+migrate。每slice Tier1。禁AskUserQuestion"
---

# [CONTINUE] need oracle S2-S5（fresh session 接手）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

## S1 接受（clean checkpoint）
S1 NeedOracle 骨架 + food 自用 done（`c25abfb7`，Tier1 5 綠，**零產線影響**）——正是 spec S1「fallback 舊常數防中間態盲飛」設計生效（未實作分量沒改行為）。乾淨，感謝。

## 裁：S2-S5 → fresh session 續（context 衛生）
你 ctx 深、S2-S5 是核心架構 arc 的大 slice build（供應鏈 walk/貿易 demand/共讀兩量/溢出落地）——**degraded-ctx 硬幹核心架構=高風險**（比一 session 硬撐更該分）。S1 已 commit（git 保），fresh session 從 branch 無縫續。**這是 worker ctx 衛生+品質，非中斷。**

## fresh session 接手指標
- **branch** `feat/need-oracle` @ `c25abfb7`（S1 in 內），worktree `.worktrees/need-oracle`。arm inbox-watch。
- **spec v2 唯一真相**：`docs/superpowers/specs/2026-07-16-arc1-unified-need-oracle.md`（S2-S5 全在 §交付切片；核心兩量 need_keep/demand 方向；R②#2-7 訂正已寫入各 §）。
- **原 dispatch**（完整非回歸/紀律）：`2026-07-16-systems-to-implementer-need-oracle-dispatch`。
- **next = S2** 供應鏈傳導（gap 非 raw + 設施 gating + 同 out 多配方）→ S3 貿易 demand（非幽靈視圖）→ S4 共讀兩量 + per-recipe 停產 + TARGET_PER_POP 正式退役 + **SURVIVAL_CRUSH reconcile（重驗生產框架 S2-gate crossover 手算）** → S5 溢出落地雙 sink + migrate 6 食物閾 reader。
- **每 slice 至少 Tier1**（防中間態盲飛，可歸因）。**holding 側保留 seam-aware、只統一 need 側**（別重踩 positional-seam）。誠實標打架/deal 待 measurer。

## 完成 → 交回
整 arc S2-S5 完成 → handback `to:systems`（各 slice Tier1 + S4 crossover 重驗 + 誠實標）→ systems 派 measurer full-HD → 綠收 → Arc2。
