# Hand Back: Q7-4 玩家 anon→named 拔擢 command

Branch: `feat/q7-4`（基於 origin/main `68a97e9`，已 push，**未** merge）

## 實作摘要
- `scripts/simulation/player_command_system.gd`：registry 加 `promote_anon` + 新 `_action_promote_anon`。復用既有 NPC 拔擢路徑 `PersonGenerator.generate_for_team`（已含「從 anon 桶移除 1 + treasury×3 bonus + 加 state.persons」），command 只 `pt.named_members.append(p.id)`。population getter 自動守恆（anon-1/named+1，總 pop 不變）。leader 不變，新增 named 成員。
- `scripts/simulation/player_query_api.gd`：`_build_available_actions` 加 `promote_anon` self-action（mirror `train`，同條件 `AnonTierSystem.total_pop(pt) > 0`，allowed_kinds=none）；`_action_label` 加「拔擢匿名→記名」。
- `scripts/debug/headless_test.gd`：`_test_action_ui_coverage` coverage dict 加 `"promote_anon": "interact-self"`。

UI 自動接線：`text_ui_main.gd` 的 `_interact_action_split()` 依 `allowed_kinds` 自動把 none-kind action 歸入 self-actions 並在目標選擇階段顯示、`_handle_interact_input` 自動 dispatch。故無需改 `text_ui_main.gd`（與 train/camp 同機制）。

## 與 plan 的差異
- plan Task 2 寫「改 text_ui_main.gd」，實際 self-action 顯示由 query_api 的 `available_actions` DTO 驅動，UI 端通用機制已自動處理（train/camp/hunt 皆如此）。故改點落在 `player_query_api.gd`（DTO 來源）而非 `text_ui_main.gd`。符合「UI 只經 player API / DTO 是 UI 契約」不變量。
- plan 程式碼片段 `AnonTierSystem.total_pop(pt) <= 0` guard 照用；註：`generate_for_team` 內部 `anon_pop = population - named_count`，與 `total_pop` 等價，雙重保險（command guard + 函數 null 回傳）。

## 端到端驗證（臨時 probe，已刪）
全 anon 隊（pop=6, anon=5, named=0）：
- 拔擢前 `dispatch_candidates`=0（全 anon 隊永遠卡，無法派子隊）。
- `promote_anon` → ok，named 出現（pop=6, anon=4, named=1，**總 pop 守恆**）。
- 拔擢後 `dispatch_candidates`=1 → `dispatch_subteam` 成功派出 Team1。
這正是 Q7-4 核心目的：解全 anon 隊無法派子隊/任命的死結，補對稱性（NPC 缺 named 自動拔擢，玩家原無對應）。

## 全回歸結果
- `headless_test.gd`：`=== DONE ===`，UI 覆蓋審計 OK（51 actions 全有路徑，含 promote_anon），無 SCRIPT ERROR。
- `ui_flow_test.gd`：`errors: 0`。
- `game_sim_multi.gd`：4 scenario 全 coin_eq delta=0、invariant 違反=0、無 SCRIPT ERROR。
- `ui_logic_test.gd` 的 2 個 vision-dist FAIL 為 pre-existing baseline，與本 batch 無關（未理會）。

## 連動風險
- `SubteamSystem.dispatch` / 子隊系統：promote_anon 後新 named 可被選為子隊 leader → 已端到端驗證可派遣，無新風險。
- `PersonGenerator.generate_for_team`：本 command 與 `faction_ai_system.gd:389` NPC 用例共用同函數；NPC caller 設 leader_id、玩家 caller append named_members，兩者皆「caller 負責設 named」契約。函數本身未改。
- 守恆：拔擢不鑄幣、treasury bonus 在函數內由 anon_treasury 轉到 person.coin（守恆路由），coin_eq 不破——game_sim_multi 已證 delta=0。

## 待主 session 確認
- 無 spec 外決策。promote_anon 無 coin 成本（純拔擢，不同於 train 的 -coin 訓練）——依 plan「command 只 append named_members」，treasury bonus 走既有 generate_for_team 內建邏輯，未另加成本。若設計上要對玩家拔擢收費需另議（plan 未要求）。
