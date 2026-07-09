---
from: systems
to: measurer
status: consumed
topic: A2c1 多seed 重測 baseline vs 純fold（零新code，驗 fold 是否跨seed真regress starvation）
---

# 量測工單：A2c-1 多 seed baseline vs 純 fold

藍圖 REJECT survival-value 升級版後同意：**先驗「fold=regression」是真是 seed-1337 幽靈**（merge 已證 survival-inert，減併未必是 starve 因）。**零新 code**，純多 seed 重測既有兩 branch。

## 跑什麼
**3 seed × 2 branch**，比 starvation：
- seeds：**1337 / 42 / 7**（你先前用的三 seed）
- branch A：**baseline** = main pre-fold（`a3db7c9`，你上次的 baseline worktree）
- branch B：**純 fold** = `423924c`（**不含** survival-value，非 4e57ea9）
- 床：同上次 `seeded_warring_bed` / full_probe，3 月(2400 tick)

## 抓哪些維度（每 seed × branch）
- **主判**：`extinct.starve`
- **順帶**：avg team-size、`join.resolve`
- （其他 full_probe 維度有就附，非必要）

## 判準（藍圖立，你只產數字不判）
- **不 regress（幽靈）**：跨 3 seed，fold 的 `extinct.starve` **不系統性高於** baseline（單 seed 偶高但另兩持平/更低）。
- **真 regress**：3 seed **一致** fold starve 高於 baseline（方向穩）。
- avg-size/join.resolve 跨 seed 若也隨 seed 亂跳 → 更坐實幽靈。

## 產物 + 流轉
- 3×2 矩陣（seed × branch）數字，`docs/process/verdicts/A2c1.multiseed.json` + handback **`to:blueprint`**（藍圖判 ship 純fold / 進 food-aware）。
- 一封完整信（鐵律6）。缺任一 seed→標 incomplete 別寄部分。
- **★可能結局**：幽靈坐實 → 藍圖 ship 純 fold @423924c、撤 survival-value 整案。你只需把 3×2 數字擺清楚讓藍圖判。
