---
from: blueprint
to: systems
status: consumed
topic: [spec請求] de-patch faction-only建造權——R②CLEAN，真根更廣(faction-leader-team-only)+遍歷結構需改
---

# de-patch faction-only 建造權 —— 請出正式 spec（R②已CLEAN）

## 用戶裁定（WHAT，已點頭，不可變）
1. **全開**所有據點+設施建造權（outpost建造/升級/8設施，非只farm）——判準從「faction」改為「隊伍擁有outpost」。
2. 範圍鎖：只解**自己outpost**的建造權，非任何隊都能對任何outpost動工（占領邏輯不動）。
3. martial獨立隊（crude camp→military outpost→farming結構性永禁）**這輪不修**，留下輪視實測。
4. crude camp（免費/任何隊含獨立隊/既有）不動——零據點隊拿「第一個outpost」的既有入口。
5. 第二個以後outpost選址邏輯（`_evaluate_new_outpost_location:2568`，既有戰略選址）原封不動繼承，不重設計。

## reviewer R②驗證發現（CLEAN，附細化，需納入spec設計範疇）
- **真根比原描述更廣**：`_evaluate_infrastructure:2710` 內部只查 `tile.outpost_owner == leader_team.team_id`（:2723,2733等）——**只評估faction leader自己的outpost，非faction內所有成員隊**。現況精確描述 = 「faction-leader-team-only」，非單純「faction-only」。faction內非leader成員隊若自己有outpost（如透過`establish_crude_camp:3073`），現況同樣被漏評——**既有潛伏bug**，非本次目標但de-patch會順便修掉，屬合理副效益。
- **這不是條件改動，是呼叫端迴圈結構改動**：`_evaluate_all_body:626-642` 現況遍歷 `state.factions`（用`f.leader_team_id`單一team作評估對象）。需改成**遍歷「所有擁有outpost的team」**（含獨立隊 + faction非leader成員隊），而非在`_evaluate_infrastructure`內部加一個if判斷就了事。請正式spec明確設計新遍歷結構。
- 審查點#3（資源扣款隱性依賴）過：`_dispatch_builder/_dispatch_upgrader/_dispatch_facility_builder`內部扣款走傳入TeamData自身欄位，非faction專屬資源池，無阻擋。
- 審查點#4（窮盡性）：grep未見其他faction-only gate，4項路徑表已知窮盡（僅驗此pattern，非完全保證）。

## 不動範圍（重申）
成本/slot/地形/allowed_outpost型別限制（farming civilian-only不變）、crude camp免費機制與is_military判定、INFRA_INTERVAL(50h)觸發頻率、選址邏輯。

## 序
出正式spec（遍歷結構設計為重點）→ measurer平行corroborate（獨立隊farming_level恆0 vs faction隊>0×存活，+crude camp civ/mil比例）→ build → measurer驗（default.json 12mo能撐/建國）。
