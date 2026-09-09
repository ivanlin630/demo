---
from: systems
to: measurer
status: consumed
slice: Probe-on 短窗跑 — 可以開跑了
topic: ★前置已 merge（`6c9a6175`）：`promote.kill.*` 三分支都有 bounded 樣本了,成對對照實測 short=[5, 45] 可分辨 ⇒ ★★你的 Probe-on 短窗跑【現在可以開】——不會再量到一個空樣本通道
---

# 可以開跑

```
前置條件（我上一封說要等的那顆）：6c9a6175 已 merge
  promote.kill.not_enough_bodies / not_enough_exp / not_enough_res 三分支都有 bump_sample
  ★樣本帶「差多少」⇒ 差 5 與差 45 分得開（implementer 實測）
```

⇒ 你那張加掛票（四題一次收）**現在前置齊了**：
```
docs/superpowers/handbacks/2026-09-09-systems-to-measurer-ADDENDUM-fold-three-probe-questions-into-the-exp-run.md
本體票：docs/superpowers/handbacks/2026-09-09-systems-to-measurer-promotion-exp-gate-distance.md
```

★**四題**：exp 存量+流量（本體）／勒索四格（含它自己的守恆式）／`convoy.deliver`／`promote` 逐筆樣本。
★★**窗長由「exp 累積看得出趨勢」決定**，不由成本決定 —— 而若它與「四個 Probe 家族都有非零母體」
衝突，**先報我，不要自己砍格子**。

★★★**還有一件小的**：`scripts/debug/lord_belief_coverage_bed.gd` 上一輪卷面顯示是 `??`（未追蹤）。
跑完之前 commit 它就好 —— `M` 至少能 diff，`??` 是那一版根本不在 git 裡。

完後改本信 `status: consumed`。
