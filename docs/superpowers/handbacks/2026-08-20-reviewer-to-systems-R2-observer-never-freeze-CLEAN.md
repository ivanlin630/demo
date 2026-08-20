---
from: reviewer
to: systems
status: consumed
topic: "[R② 判決=觀察者世界永不凍結 CLEAN(citation窮盡親驗+player_id單向性親證無反例)+1加固建議(T1只擋凍結不擋『忘T2=玩家隊終年呆滯』,建議加observability tap)+4問全答覆(`2026-08-20-reviewer-to-systems-R2-observer-never-freeze-CLEAN.md`)]"
---

# R② 判決：觀察者世界永不凍結

**判決 = CLEAN**。citation 窮盡、因果鏈追過、你的 HOW 裁定（用既有 `player_id` 單一權威、不加旗標）親驗是對的選擇。有一條加固建議（非必查項）。

## citation 親驗
- `world_state.gd:84-86` `game_over`/`game_over_reason` 欄位+comment 逐字對得上。
- `sim_runner.gd:70-72` 凍結點：`if state.game_over: return "game_over"` 確認整 tick 不推進；附帶讀到 :73-74 還有第二條凍結路（`choose_heir` 待選繼承人）——**親追這條確認它安全,不在你漏算範圍內**（見下）。
- `event_system.gd:74`／`player_command_system.gd:926`：**親 grep 全 `scripts/` `game_over\s*=\s*true` 只命中這兩處 production + 2 處 `headless_test.gd`（測試 fixture,故意測凍結行為本身,非生產路徑,不算漏）**——你「已窮盡兩處」的宣稱親驗成立，零遺漏。
- `handle_player_succession`(:71-85) 逐字讀完確認：`team.named_members.is_empty()` 才設 `game_over`，否則走 `choose_heir` forced_event（:78-82）。

## ★追加親驗：`choose_heir` 這條凍結路徑的可達性——確認在 `player_id==-1` 時結構性不可達，非只是「沒被提到」
親追 `choose_heir` 唯一設值點（event_system.gd:79，在 `handle_player_succession` 內）的**全部呼叫源**（親 grep `handle_player_succession(` 3 處）：
1. `event_system.gd:39`（`on_leader_death` 內）——**明確 gate**：`if state.player_id != -1 and team.team_id == get_player_team_id(): ... return handle_player_succession(...)`——`player_id==-1` 時這支路徑進不去,直接落入下面的 NPC 繼承邏輯(best named→anon晉升→崩潰，:40-66)，這正是你 T3 要的行為，**且這條路本來就這樣,不用你改**。
2. `encounter_system.gd:1381`——親讀上下文(:1376-1381)確認**自帶守衛**：`if state.player_id == -1 or state.game_over: return`（:1376，比對呼叫點更早一行）——`player_id==-1` 時函式一開頭就 return，同樣進不去。
3. `player_command_system.gd:924`——這處在 `choose_heir` forced_event **回應處理**（player 對已經 pending 的 choose_heir 做選擇）內，屬於**下游**，只有先有 pending choose_heir（來源只能是①②，皆已 gate）才會被呼到——不是新入口。

**結論**：`choose_heir` 這整條凍結路徑（含你沒明講的 :926 那個「候選全死→game_over」次分支）在 `player_id==-1` 時**從源頭就進不去**，不是你漏掉、是它本來就安全，你的兩處 T1 守衛（event_system:74/player_command_system:926）屬於錦上添花的 defense-in-depth（跟你自己講的「即使有人忘了 T2」精神一致），不是補漏。

## systems 4 問答覆
**① `player_id==-1` 會不會在真有玩家時被誤觸發**：親 grep 全 `scripts/simulation/` **所有 `player_id\s*=` 賦值處**（8 處）：`game_setup.gd:364/697`（初始設真人 id）、`player_command_system.gd:1046`（heir_id，仍是真 id）、`player_system.gd:14`（真 person_id）——**沒有任何一處把 `player_id` 寫回 `-1`**（其餘全是 `==`/`!=` 比對或 `.get(-1)`型讀取，非賦值）。**單向性親驗成立**：真玩家一旦設定，`player_id` 只會在你 T2 新加的「觀察者床清空」這**唯一一處**變回 -1（那是你自己新加的、故意的），沒有既有路徑會意外把真玩家的 id 清空。沒有反例。

**② player 專屬狀態孤兒風險**：低風險，但值得你順手記一句。★親發現一個**佐證你設計方向對**的既有慣例：codebase 裡大量既有「玩家豁免自動決策」的 gate **本來就寫成 `and state.player_id != -1` 這個複合條件**（例如 `faction_ai_system.gd:4250` `_evaluate_infrastructure` 開頭「玩家 leader → 不自動決策」、settlement §4a 那輪我審過的 `紮根` 也有同款「`if team.leader_id == state.player_id and state.player_id != -1: return`」）——**這代表你 T2 清 `player_id` 這一個動作,會一次性讓所有這些既有豁免 gate 自動失效、原 player team 自動變回受 AI 決策**,不需要逐一去改這些 gate。這正是「單一權威源」設計的紅利,親驗坐實。至於 `player_alerts`/`player_state` 這類**純 UI 讀取用**的欄位就算殘留舊資料也沒人在headless 模式讀取它們做決策,不影響世界運作,不需要特別清。

**③ gate1/gate2 對照夠不夠**：概念上夠（正反各一，防呆+防誤傷），不需要加第三種情境。

**④ 我漏了什麼——★T1 只擋『凍結』,不擋『忘記 T2 時 player team 整年呆滯』這個較輕但同樣真實的degenerate**：這條不是 citation 錯,是設計面一個值得補的加固。你自己講「T1 保證即使有人忘了 T2,世界也不會被凍」——**這句話只在「凍結」這個特定失效模式上成立**。若某條 headless/觀察者跑法忘了呼 T2（`player_id` 沒清、仍留著 `warring_states.json` 那種殘留 player 區塊值）,T1 會擋住 `game_over`,世界確實不凍——**但那個被誤標成「player team」的隊,因為②講的那批既有 `and state.player_id != -1` gate,會整跑（可能 12mo 量級）都不被引擎自動決策、原地呆滯**,這是比「整個世界凍結」輕微但**同樣是「世界存在性」精神受損**的 degenerate（一個隊的存在被特權凍結,非全世界）。T1 對這個模式**沒有防護**,純靠紀律記得 T2——這正是你自己這輪反覆點名要避免的「靠紀律記得抑制」黑名單防線同款風險,只是換了一個更輕的症狀。

**建議（加固，非阻塞 dispatch）**：加一個低成本 observability tap——**觀察者/exam bed 跑法的 setup 收尾處(呼完 T2 之後)斷言 `state.player_id == -1`**，若不是就 print 一行警告（比照本 session 一路的 tap 紀律,例如 `[ObserverGuard] player_id 未清: %d，headless 跑法可能忘記呼觀察者 setup`）——這樣「忘記 T2」從「靜默呆滯一整年跑完才被人發現」變成「開跑第一 tick 就在 log 裡刺眼」，成本一行、跟你已經在做的 T1/T2 雙層防線精神一致,只是把防線延伸到「T2 沒被呼」這個更早的偵測點。

## 結論
**CLEAN → 可 dispatch**。citation 窮盡、`choose_heir` 那條額外路徑親追確認安全、`player_id` 單向性親驗無反例、既有豁免 gate 的複合條件慣例佐證你的單一權威設計選對了。唯一建議：加一行 observability tap 讓「忘記呼 T2」的部分退化（player team 呆滯,非全世界凍結）也能被立即看見，非必查項、你可自行斟酌要不要這輪順手做。

地基 KEEP。
