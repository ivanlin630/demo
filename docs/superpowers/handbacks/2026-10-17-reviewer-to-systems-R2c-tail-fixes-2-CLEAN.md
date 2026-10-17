---
from: reviewer
to: systems
status: consumed
slice: 批尾小修二
topic: R²c VERDICT＝CLEAN（附 3 條派發前請併進 spec 的文字修補，不需再審）。靜態讀 code，沒跑測試。
---

# 一、N1–N3、T1–T4 收沒收（spec 15081f760 diff 全讀）
| 條 | 結果 | 依據 |
|---|---|---|
| N1 | ✓ | 對帳右邊補 `fate_killed ＋ fate_captured ＋ pursuit_killed`，保留獨立子句；A3 格要三種對照仗（你贏／NPC 贏有傷兵處置／NPC 贏有追擊）；`resolve_*` 另有扣人口的路由對照仗抓，不靠靜態讀。這正是我上輪要的 |
| N2 | ✓ 方向；見 C1 | 選 (a)：`_known_pos`／`:310` 原樣，NPC 喚醒不動；新基準只在 `:334` 玩家分支；親見判準用 `:336` 同一條；轉述照舊；D5 格加 NPC `_wake` 次數修前＝修後；world-fp 一條列入 D5 |
| N3 | ✓ | 清除點＝`_action_choose_heir` 清 `player_forced_event` 同處；進存檔不進 fp；B2 格加「死→選繼承人→再死兩次都停」 |
| T1 | ✓ | 條件寫字串名、由一支分派；重置點 `text_ui_main.gd:3975-3976` 一起改 |
| T2 | ✓ | 可達加格、不可達交件寫理由；獸戰後空結果不印空殼 |
| T3 | ✓ 方向；見 C2 | 兩個產生者收成 `EventSystem.story_end_reason` |
| T4 | ✓ | 只在死的是玩家本人時發，實作端交件寫結論 |

# 二、派發前請併進 spec 的文字修補（C1–C3）
- **C1 D5：寫明「不進玩家事件」的機制**
  - 玩家事件是在 `WorldEvents.emit(state, "intel_arrived", [obs_id], _wake, _iinfo)`（`belief_system.gd:340`）裡進佇列的，同一個呼叫也帶 `_wake`。新基準只能**抑制**（舊基準 `:310` 為真時才會走到 emit；新基準說「同位置」時要把玩家事件拿掉）。spec 只寫「決定進不進玩家事件」，沒說怎麼拿掉。
  - 請二擇一寫明：(a) `obs_id` 是玩家隊且新基準判相同時**不呼 emit**（那一支隊的 `_wake` 因此也不發——玩家隊是附身隊，AI 不接手，請在交件寫一句確認喚醒對附身隊無作用）；或 (b) emit 加一個「玩家可見」旗標，喚醒照發。選哪個都不影響 NPC 世界；玩家世界的 fp 可能變，已被 world-fp 那條涵蓋。
  - D5 格的「NPC `_wake` 次數修前＝修後」請同時印玩家隊的次數，兩個分開。
- **C2 T3：改字串，不是改句型；列受影響的讀者**
  - 故事結束那一行是 UI 直接顯示 `game_over_reason`（`text_ui_main.gd:1001-1002`），不是另有一支組句。所以 `story_end_reason` 回的就是畫面上那句。spec 寫的「故事結束：…」前綴請對照 view 現在印的前綴（`故事已結束：`之類）別重複。
  - `story_end_reason(state, team)` 的 team 在 `player_command_system.gd:2095-2100` 那支分支可能是 null（`dead_team == null` 才走 `:2098` 的 elif 與 `:2100` 的字串）。請寫 team 為 null 時回什麼。
  - 受影響的測試：`live_play_small_fixes_bed.gd:571-572` 列舉原因全集（含兩個舊字串）、`terminal_selfcheck_bed.gd:149` 寫死 `"玩家絕後（Team%d 無繼承人）"`。放進遷移表。
  - 好消息：`game_over_reason` 不在 `state_fingerprint.gd`（我 grep 無命中），改字串不動 world-fp。但 `a1_build_never_started.gd:175`、`observation_round_30day.gd:322`、`player_death_7day_specimen.gd:300` 等把它放進自家記錄陣列，比對基準若含字串會變，交件時看一眼。
- **C3 N1 對照仗的 fixture 母體**
  - 「NPC 贏且有追擊」需要 `can_pursue` 為真（`encounter_system.gd:1547-1553`）；請在床格寫它的構造條件，免得實作端造出沒有追擊的「追擊仗」，格就退化成第二個「你贏」。印出三場各自的 `fate_killed／fate_captured／pursuit_killed` 非 0 的那一項，當母體地板。

# 三、結論
- **CLEAN**。C1–C3 是 spec 文字補寫，併入後可直接派實作（開點目標交完後接），不需再回 R²。C1 最要緊（它決定 D5 的實作長相）。
- 交件時照 spec 末的清單，特別附：負對照 n1–n10 紅燈原文、三場對照仗的欄位值、`PLAYER 是否恆為領袖` 結論（T4）、T2 可達與否的理由、八個動作最終鍵。
