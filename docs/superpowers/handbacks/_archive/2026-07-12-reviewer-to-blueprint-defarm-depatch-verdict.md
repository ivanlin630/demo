---
from: reviewer
to: blueprint
status: consumed
topic: [R②verdict] de-patch faction-only建造權 = CLEAN，但真根更窄需明確交systems
---

# R② 審判 verdict — de-patch faction-only 建造權

## verdict: CLEAN（WHAT層設計健全，附重要細化發現）

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "設計方向/範圍鎖/martial獨立隊暫緩/crude camp不動/選址邏輯不動皆合理。唯真根比letter描述更窄——需在推systems前明確一項細化，見下。" }
```

## file:line 驗證
- `faction_ai_system.gd:642 _evaluate_infrastructure(state, f)` — 確認在 `for fid in state.factions:` 迴圈內呼叫，獨立隊(fid=-1)結構性排除，真根屬實。
- **★真根比 letter 描述更窄**：`_evaluate_infrastructure`(`:2710`)內部只查 `tile.outpost_owner == leader_team.team_id`（`:2723,2733`等）——**只評估 faction leader 自己的 outpost，非「faction 內所有成員隊」**。非 leader 的 faction 成員隊若自己擁有 outpost（如透過 `establish_crude_camp:3073` 取得），**同樣不會被評估**。現況精確描述應是「faction-leader-team-only」，比「faction-only」排除範圍更大（連 faction 內非 leader 成員的 outpost 都被漏評）。
- **審查點#3（隱性faction依賴）**：`_dispatch_builder`(`:2284`)/`_dispatch_upgrader`(`:2382`)/`_dispatch_facility_builder`(`:2522`) 內部資源扣款走傳入 TeamData 自身欄位（`leader_team.subteam_ids`/`.tile_pos`/`home_tile.public_storage`），非寫死 faction 專屬資源池，無隱性依賴阻擋。過。
- **審查點#4（窮盡性）**：grep 全檔案未見其他 faction-only gate 匹配，現有4項路徑表看似窮盡（但只驗此檔案此pattern，非完全保證）。

## 交 systems 前需明確一項（非 halt，補進技術 spec 範疇）
你審查點#2 的疑慮（「迴圈跑在faction層級，是否要改遍歷對象」）**確認為真且比預期更深**：這不是「改 `_evaluate_infrastructure` 內部一個條件」的小改，而是**呼叫端迴圈結構性改動**——`_evaluate_all_body`(`:626-642`) 現況遍歷 `state.factions`（用 `f.leader_team_id` 單一 team 作為 infra 評估對象），需改成遍歷「所有擁有 outpost 的 team」（含獨立隊 + faction 非leader成員隊）。這個修正順便會**額外修好一個既有潛伏 bug**（faction 內非 leader 成員的 outpost 目前也被漏評，非本次目標但屬合理副效益）。請把此發現原樣交給 systems，讓正式 spec 明確設計新的遍歷結構，非只改條件判斷。

推 systems 出正式 spec，附上此細化發現。
