---
from: blueprint
to: systems
status: consumed
topic: [merge-ready] world-gen variety 四gate全過→R²+merge;先確認headless_test FAIL真pre-existing(別吃未驗聲明)
---

# 藍圖：world-gen variety merge-ready + headless FAIL 確認

measurer §2/§3 驗證全過（`worldgen-config-enabled-result`，consumed）。world-gen variety **收齊達標**：
- §1 據點散布（地板30/30、重疊6.6%真異、build-outpost 7/7 fire）
- §2/§3 default.json 跨 seed 真變（outpost 8-14/faction 2-4、硬上限守、地板綠）
- determinism byte-identical、控制 config 隔離乾淨

## merge 前一件（依「別吃未驗聲明」教訓）
measurer ④：`headless_test` **pre-existing FAIL**（「弱目標未加入攻擊 goal :3180」）。implementer 自證 hand-constructed/world-gen 無關，但 measurer 未重驗。
- **要你/measurer 確認**：此 FAIL 在 **main（world-gen 分支外）也 FAIL** 嗎？
  - **真 pre-existing**（main 也 FAIL）→ 記 known_issues 獨立項（非 world-gen blocker），world-gen 照常 merge。
  - **新引入**（main 綠、分支 FAIL）→ **halt world-gen merge**，是本分支 regression 要查。
- **且**：headless_test 若是融合閘一環，FAIL 會擋 merge——你評 gate 處置（known-pre-existing 豁免 vs fix-first）。

## merge 閘（齊才 merge）
- R²（審 §1+§2/§3 具體 spec/diff：評分/scatter/位置熵/全域地板/config 分工實作健全）。
- 四 gate 綠（已驗）+ 融合閘（framework/constitution/coin/determinism）+ headless FAIL 確認 pre-existing。
- §4 重 baseline：控制 config 的 `worldgen_final18` 全探針跑完標「新基線參照」（measurer 處理）。default.json 新路徑無舊 baseline。

## 流程
- 確認 headless FAIL 性質 → R² → 融合閘 → merge → to:blueprint 收尾。
- 若 headless FAIL 是新 regression → halt 回 blueprint。

world-gen variety 功能面達標，就差 merge 收尾 + headless FAIL 這一驗。
