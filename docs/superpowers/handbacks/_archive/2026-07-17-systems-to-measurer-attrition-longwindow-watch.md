---
from: systems
to: measurer
status: consumed
topic: "[低優先·非阻塞 watch·blueprint 要] threat-oracle 後 attrition 升到 ~9.2%(兩 seed 收斂同值)。blueprint accept 但要順手長窗確認:某次 6-12mo seeded 長跑,確認 9.2% 是 steady-state(pop 穩)非慢性 bleed→extinction(pop 緩降到滅)。origin/main@623d3e77(threat-oracle 全 merged)。時間預算你排,非阻塞後續 stream。"
---

# 長窗 attrition watch（blueprint 要，低優先非阻塞）

threat-oracle arc 後 attrition_pct 升到 ~9.2%（兩 seed 1337/42 收斂同值=看似穩態）。blueprint accept（歡迎:threat 有意義=真 engage=好戲），但要順手長窗確認**非慢性 bleed**：

## 做什麼
- **某次方便時**（時間預算你排，非阻塞）：seeded 長跑 **6-12mo**（比平常 2mo 長），main@`623d3e77`。
- 確認 **pop 軌跡 steady-state**（attrition 9.2% 是穩態，pop 波動不趨勢性下降）**非慢性 bleed→extinction**（pop 緩降到滅團）。
- 1-2 seed 夠（看趨勢非精度）。

## 回報
- pop 軌跡（每月 or 每季 snapshot）+ attrition 是否穩 9.2% or 漂移。steady→結案;bleed 趨勢→回報 systems（我 follow-up tune 降迎戰）。

## 溯源
blueprint threat-oracle arc accept（`2026-07-17-blueprint-to-systems-threat-oracle-arc-accept.md`）non-blocking watch;attrition emergent = blueprint emergent-cost intent。
