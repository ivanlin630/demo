---
from: blueprint
to: reviewer
status: consumed
topic: [R②設計審] de-patch faction-only 建造權——獨立隊擁outpost即可走infra迴圈(outpost升級/正規outpost/8設施)；用戶點頭
---

# de-patch faction-only 建造權 —— 設計送審（R②）

## 背景（真根，systems已file:line坐實）
農場（食物基建）faction-only（`_evaluate_infrastructure` 只在faction迴圈跑，`faction_ai:642`）。獨立隊(fid=-1)結構性無食物基建路徑→雞生蛋死鎖餓死。完整建造條件表見 `2026-07-12-systems-to-blueprint-build-conditions-table.md`。

## 用戶裁定（已點頭）
1. **全開**所有據點+設施建造權（非只farm）——faction-only 改為「隊伍擁有outpost即可」。
2. 範圍鎖：**只解自己outpost的建造權**，非任何隊都能對任何outpost動工（占領邏輯不動）。
3. martial獨立隊（crude camp→military outpost→farming結構性永禁，`FACILITY_DEF farming allowed_outpost=["civilian"]`）**這輪不修**，留給下輪視實測結果再裁。
4. crude camp（免費、任何隊含獨立隊、既有）保持不動——是零據點隊拿到「第一個outpost」的既有入口，不用新設計。
5. 第二個以後outpost的選址邏輯（`_evaluate_new_outpost_location:2568`，戰略選址，faction現有機制）**原封不動繼承**，非隨機——de-patch只拆faction-only判斷本身，選址邏輯不動。

## 設計本體
`_evaluate_infrastructure`（faction_ai:642起）判斷準則從 `faction != null` 改為 `team 有 outpost`（owned_outpost非空/等價欄位）。三條建造路徑統一受此判準管：
- `_dispatch_builder:2284`（正規outpost，含第二個以後擴張，選址邏輯不動）
- `_dispatch_upgrader:2382`（outpost升級）
- `_pick_facility:2798`→`_dispatch_facility_builder:2522`（8設施，含farm）

不動：成本/slot/地形/allowed_outpost型別限制（farming civilian-only不變）、crude camp免費機制與is_military判定、INFRA_INTERVAL(50h)觸發頻率。

## 審查重點（factcheck/skeptical）
1. `team 有 outpost` 判準是否有現成欄位可查（owned_outpost/outpost_ids?），或是要新推導——影響HOW複雜度，systems spec前該先摸清。
2. `_evaluate_infrastructure` 迴圈目前跑在faction層級（可能疊代`faction.member_teams`），改判準後是否要改遍歷對象（改成遍歷所有team、非faction.member_teams）——結構性改動，非條件改動，systems需評估。
3. 獨立隊拿到outpost後，是否有其他隱性faction依賴（例如`leader_team.resources`扣款邏輯目前綁leader_team_id，獨立隊有無等價欄位？）——別漏看資源扣款路徑。
4. 有沒有遺漏的第三方faction-only判斷點（表列4項是否窮盡，或還有其他呼叫`_evaluate_infrastructure`外的faction-only檢查）。

CLEAN後直接推 systems 出正式spec。
