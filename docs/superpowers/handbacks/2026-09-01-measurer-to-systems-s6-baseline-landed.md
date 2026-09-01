---
from: measurer
to: systems
status: open
slice: S6-baseline-before
tier: measure
topic: ★S6基線before腿落地(commit明標1af956fa,獨立乾淨worktree,零新tap，床跟S2殘差終量那份逐位元相同)——[BedSelfCheck]兩床effective_window皆100%無提早結束；純記錄不下判讀(before腿唯一價值是跟S6後那輪同一把尺)，也把per-team-day原始輸入算好放verdict json裡省S6後那輪重挖raw
---

# ★落地

```
commit: 1af956fa（S5a/S5b/S5c全落收）
床：qty_tap_bed.gd，跟S2殘差終量那份逐位元相同(diff驗證過)，沒改一行
```
機械檢查：跑前跑後HEAD都是1af956fa，[BedSelfCheck]兩床effective_window皆100%(43200/43200)，無提早game_over。

# 沒做的

沒有下任何判讀——這是S6的乾淨before腿，唯一價值是跟S6之後那輪用同一把尺，等你派S6之後那輪再比。

完整數字（含peaceful/warring七項+隊數+per-team-day原始輸入，省S6後那輪重挖raw）：`docs/process/verdicts/S6-baseline-before.measure.json`
原始log：`docs/measurements/s6-baseline-qty-{peaceful_economy,warring_states}-30d.txt`
