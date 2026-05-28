# Hand Back: 遭遇戰系統 (encounter-system)

## 實作摘要

- `scripts/data/world_state.gd` — 加入 5 個遭遇戰臨時欄位（encounter_active、encounter_units、encounter_attacker_id、encounter_defender_id、pursuit_edge_offset）
- `scripts/simulation/encounter_system.gd` — 新建完整遭遇戰系統（600+ 行）：base helpers、單位初始化、六角進場位置、裝備分配、箭矢系統、戰術 AI 行動決策、advance_round 戰鬥解算、俘虜判定、傳令兵退出、resolve_encounter_end 結算
- `scripts/simulation/interaction_system.gd` — `_try_interact` 開頭加玩家遭遇戰觸發：player_id != -1 且雙方之一為玩家隊 → 設 encounter_active=true 並 return，跳過大地圖快速結算
- `scripts/simulation/sim_runner.gd` — `advance_tick` 開頭加 encounter 暫停分支：encounter_active 時呼叫 advance_round + resolve_encounter_end，推 tick 後 return
- `scripts/debug/headless_test.gd` — 加 6 段遭遇戰驗證（base helpers、匿名 unit、init_encounter、decide_action、advance_round 50 輪、完整流程含 resolve_end）

與 spec 的差異：
- `_decide_action` 等函數內所有 `state.encounter_units[i]` 取值均改為 `var x: Dictionary = ...`（GDScript 4 無法從 Array 存取推斷型別，`:=` 會 parse error）

## 連動風險

- `InteractionSystem._try_interact`：玩家觸發後所有互動邏輯（外交、貿易、徵收、同陣營合併）對玩家隊均被跳過。若設計上玩家應能進行外交/貿易，需要在觸發條件加更細緻的判斷（目前任何涉及玩家隊的 `_try_interact` 都觸發遭遇戰）。
- `SimRunner.advance_tick`：遭遇戰進行中整個大地圖（資源、移動、反應）全部暫停，僅 tick 推進。若遭遇戰持續很多輪（units 大且膠著），糧食/薪資長期不結算。
- `EncounterSystem._spawn_team_units`：population 較大時每 advance_round 遍歷 O(N²)，正式地圖大規模團隊可能有效能問題。

## 待主 session 確認

- **設計決策**：玩家觸發條件目前是「任何 _try_interact 涉及玩家隊就觸發」。玩家與同陣營隊伍相遇是否也觸發遭遇戰？目前會觸發，可能不符設計意圖。
- **設計決策**：`_messenger_exit` 呼叫 `SubteamSystem.create_subteam`，但 SubteamSystem 無此方法（has_method 保護），傳令兵功能暫為空殼。需決定是否補實作或移除。
- **建議後續 task**：spawn 數量上限（效能）；玩家同陣營互動例外；傳令兵 SubteamSystem 接口。
