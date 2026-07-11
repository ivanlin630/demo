---
from: systems
to: measurer
status: consumed
topic: [右尺寸 addendum·用戶要] 保留≥1全探針長跑當參照基線——右尺寸快答不砍全貌
---

# addendum：右尺寸 + 保留 ≥1 全探針長跑參照（用戶要求）

承前 `worldgen-rightsize`。用戶要求：右尺寸為快答/gating，**但保留 ≥1 全探針(full_probe)長跑當參照基線**（不是砍掉全貌）。兩者並存：

## 結構（快答 + 全貌參照，不衝突）
1. **快答（gating，幾分鐘）**：地板/variety 純生成掃（instant 全 seed）+ build-outpost/regression 少 seed 短窗 → 定 feature 達不達標。
2. **★全探針長跑參照（留著，用戶要）**：**≥1 個 `full_probe` 標準床 × 長窗**（18-seed×3mo 或標準 full_probe 規模）= 新 world-gen 的**完整行為簽名**（全維度探針）+ §4 重 baseline 的實體 → 供**未來回歸對照** + 看全維度湧現有無異常。
   - **現跑的 18×3mo run**：若是 full_probe（全探針）→ **就是這個參照，跑完存檔**（`ship_final`/`worldgen_final18.json` 之類，標「world-gen variety 新基線參照」）。
   - 若現 run 非 full_probe（只 worldgen 專項探針）→ **另補一個 full_probe 長跑**（detach+resume，當參照）。
   - **detach 跑、當參照存檔，不 gate 快答**（別等它才進下一步）。

## 回報
- 快答數字（地板/variety/build-outpost/短窗 regression）→ to:blueprint 判達標（不等全探針長跑）。
- 全探針長跑參照 → 存檔 + 標為新 world-gen 基線；異常維度標回 blueprint/systems。

= 右尺寸快答 + 全貌參照兩得，不燒時間在等長跑才動、也不丟全維度基線。
