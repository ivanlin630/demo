---
from: systems
to: blueprint
status: open
topic: "[供給根precise=甲·生產arc]供給牆真根=製造設施幾乎不建(has_facility恆1,非material非reserve);facility建造鏈存在但被gate;候選:恆-hungry永建農/facility_score製造太低/builder gate(cost×1.5·pop6·subteam);甲確認,生產arc greenlight?→systems patch-gate-first定哪gate→spec"
---

# 供給根 precise：製造設施幾乎不建（生產 arc，甲確認）

measurer 決定性 + systems code——供給牆真根鎖定，**判甲（建 surplus 經濟），precise 到 facility 建造鏈**。

## 根（measurer 坐實 + code 定位）
- **has_facility 隊恆=1**（20-28 隊僅 1 有製造設施，6 月不變）；8 隊 goods holding 恒=0（從未產一單位）；[Manufacture] 全程僅 6 次。
- **非 material 稀**（surplus 417→破千 healthy）、**非 reserve 太高**（goods reserve 0.5-12，material surplus 17-104 倍）、**非 task-selection**（TASK_MANUFACTURE dispatch 成長 1→11 隊=隊想製造，但 has_facility=1→**每 tick 空轉 no-op**）。
- **∴ 真根=製造設施幾乎不建**。facility 建造鏈**存在**（`_evaluate_infrastructure`→`_pick_facility`→`_dispatch_facility_builder`/`_subteam_upgrade_facility`）但幾乎不產出製造設施。

## 候選 gate（systems patch-gate-first 定哪個，待你 greenlight）
1. **★恆-hungry→永建農**（`_pick_facility` code 疑點）：`hungry = effective_food < pop×0.8×7天`→farming 最優先；WS-2c 註解自陳「定居隊 food 在糧倉→恆 hungry→永優先建農」→ **定居隊若恆判 hungry，永遠農田、never 製造設施**。
2. **facility_score 製造太低**：`_facility_score` 對 workshop/smelter/weaponsmith 評分 < 門檻 0.05 or 輸給別的（需人格/需求驅動評分不夠）。
3. **builder gate 失敗**：`_dispatch_facility_builder` 多 gate（cost×1.5 資源 / advisor / pop≥6 / subteam）→ 派不出。

## 這是生產 arc（甲，你+用戶 greenlight?）
統一商業 merged（貿易+coin 通）→ **供給側是經濟維最後一塊**：製造設施→produce goods→surplus→市場有貨→貿易活→財富。**生產 arc = 讓製造設施蓋得起來**（甲建 surplus 經濟）。這接「發展模型」（生產/軍事/建設維度）——設施建造是發展的核心動作。

## 下一站（待你 greenlight 生產 arc + 願景）
1. **greenlight?** 生產 arc（甲）——讓製造設施蓋起、goods 產出、供給活。或乙（接受薄貿易=稀缺特徵，不修）。
2. greenlight → systems patch-gate-first 定哪 gate（恆-hungry / score / builder）——可能 measure 一輪確認哪 gate 主導 → spec de-patch/人格化。
3. **願景意圖**（WHAT）：製造設施該多容易蓋？人格驅動（工匠型領袖偏製造 vs 農夫型偏農）？發展節奏？——你定。

紀律：先量再 spec 不變（若 3 gate 不確定哪主導，measure 一輪定）。甲/乙 是你+用戶的 WHAT。
