# 接受同盟把勢力領袖搬進對方勢力——HOW

狀態：草稿，待 R²
來源：藍圖 2026-10-13-blueprint-to-systems-TICKET-accepting-alliance-moves-faction-leader-into-proposers-faction（第五輪用戶回饋 #7，會毀一局）
順位：Q 鍵、子隊輸入之後；地圖整寬之前。

## 事實（main 413ed41eb）
- `diplomatic_ai_system.gd:417-449 _form_alliance(team_a, team_b)`：註解「team_a＝收提案方、team_b＝發起方」；team_a 有勢力 ⇒ **team_b 被搬進 team_a 的勢力**；否則 team_b 有勢力 ⇒ team_a 被搬進去；兩獨立 ⇒ 建國（人多者為領袖）。**沒有任何一條檢查被搬的那隊是不是自己勢力的領袖隊。**
- 四個呼叫點：
  - `diplomatic_ai_system.gd:386`（NPC 收提案：`_form_alliance(self_team, sender_team)`，方向照註解）
  - `player_command_system.gd:876`（玩家發起、對方 accept 之後）——而 `handle_diplomacy_message` 在 :386 **已經結盟過一次**，:876 再呼一次（反方向）⇒ 重複呼叫、名聲 +0.2 兩次。
  - `player_command_system.gd:1865`（玩家接受 NPC 提案）：`_form_alliance(from_team, pt)` ＝ **發起方放在收提案方的位置** ⇒ 玩家（勢力 2 領袖）被搬進勢力 1。用戶撞到的就是這條。
  - `player_command_system.gd:1929`（另一條，實作端核語意）。
- 勢力失去領袖隊之後：`WorldState.set_team_faction`（world_state.gd:552-568）只改 member_team_ids，**不碰 `FactionData.leader_team_id`** ⇒ 勢力 2 的 leader_team_id 仍指向已在勢力 1 的玩家隊＝**無頭勢力、指標懸空**。誰讀 leader_team_id、懸空時各自怎麼壞，由實作端列（grep `leader_team_id`）。

## 改法
1. **規則收在 `_form_alliance` 本體一處**（四個呼叫點都經過它）：**勢力的領袖隊永不因結盟離開自己的勢力**。
   - 被搬的那一隊若是自己勢力的領袖隊（`factions[fid].leader_team_id == team.team_id`）⇒ 不搬。
   - 兩隊都在不同勢力、且被搬方是領袖 ⇒ **藍圖追加 WHAT（2026-10-13）：不得變成空動作**（只加名聲＝宣稱結盟而世界沒變）。
     - 現況（我查）：`FactionData.relations`（faction_data.gd:39-41，"neutral"／"ally"／"enemy"）欄位存在，但 scripts/simulation 內**找不到任何寫入或讀取**；威脅評估與攻擊資格都不讀它。實作端再以 grep 確認（含 `relations.get`、字串 "ally" 的比較）。
     - ⇒ **確認無讀者 ⇒ 拒絕這種結盟**：回句「兩個勢力之間的結盟還沒做」，名聲不動、勢力不動；NPC 端 `handle_diplomacy_message` 同樣不成立（回 refuse 或專屬理由，不寫 alliance）。留給回應提案框架票（深層批）。
     - 若 grep 找到真讀者（威脅評估或攻擊資格讀 ally）⇒ **停手、交件信列出**，由我改成「寫 ally 態」那條。
   - 「同盟≠併入」的完整語意（兩勢力的盟約關係）歸回應提案框架票（深層批）；本票只保證領袖不被搬。
2. **方向統一**：:1865 改成與 :386 一致（收提案方＝玩家＝team_a）。:876 的重複呼叫拿掉（:386 已做）；若 :876 存在是為了「玩家發起時要以玩家為主」，實作端說明，由我裁。:1929 核對後同樣對齊。
3. **結果句寫實際後果**（讀 `_form_alliance` 回傳的實際動作，不在呼叫端猜）：讓 `_form_alliance` 回 `{moved_team, to_faction, created_faction}`；玩家看到「Team8 加入你的勢力 2」／「你加入勢力 1（離開勢力 2）」／「兩個勢力之間的結盟還沒做」。**提案行**（強制事件面板上那一行）也寫實際後果的預告（同一個函式的試算版，不寫第二份規則）。
4. **懸空 leader 的守衛**：`set_team_faction` 對「把領袖隊移出其勢力」push_error＋Probe（`faction.leader_left`），不擋（擋會改其他路徑行為，例如叛離）。量：30 天世界的 `faction.leader_left` 次數，交件信寫；>0 ⇒ 列出來源路徑，我另開票。

## 先量（動 NPC 端前，藍圖 2026-10-13）
NPC 之間「兩勢力領袖結盟＝一方被搬進另一方」可能是現況勢力變大的主要管道；不能為修玩家 bug 少一條生長路。
- 在**修前**樹上跑觀測回合（30 天、seed 1337），用 Probe 數：`_form_alliance` 各分支 fire 次數（建國／搬入時被搬方是領袖／被搬方不是領袖），以及「被搬方是領袖」那一支佔全部勢力成員變動（`faction.join`）的比例；同時數那一支發生後原勢力剩幾隊、leader_team_id 是否懸空。
- **玩家端**（:1865、:876、:1929）照本 spec 改，不受量測結果影響。
- **NPC 端**：
  - 那一支 fire 0 次或很少 ⇒ 照本 spec 拒絕。
  - 是主要管道 ⇒ **停手、交件信附數字**，不自行決定。理由：現況那一支只搬領袖隊、留下原勢力其餘成員與懸空的領袖指標，「照舊合併」等於保留無頭勢力；真正的「併入」（整個勢力併過去）要設計，由我與藍圖定。

## 驗收
- L1（修前紅）：玩家是勢力 2 領袖，接受勢力 1 某隊（非領袖）的同盟 ⇒ 玩家仍在勢力 2；對方加入勢力 2；結果句「Team8 加入你的勢力 2」。
- L2（修前紅）：玩家是勢力 2 領袖，接受勢力 1 **領袖隊**的同盟 ⇒ 兩隊都不換勢力、名聲不變；結果句「兩個勢力之間的結盟還沒做」。
- L3（修前紅）：玩家（勢力 2 領袖）向勢力 1 某隊發起、對方接受 ⇒ 玩家不離開勢力 2。
- L4：玩家獨立，接受勢力 1 隊的同盟 ⇒「你加入勢力 1」，提案行事先寫明。
- L5：NPC↔NPC：兩勢力領袖之間的同盟提案 ⇒ 不成立（不換勢力、不加名聲）——**僅在量測判定不是主要管道時**；否則此格待裁。
- L6：名聲只 +0.2 一次（:876 重複呼叫拿掉）。
- L7：任一格結束時，每個勢力的 `leader_team_id` 都指向一個 `faction_id == 該勢力` 的隊。
- 負對照：拿掉領袖守衛 ⇒ L1／L2／L5 紅。
- world-fp：L5 會改 NPC 行為 ⇒ fp 可能變；先二分（只動 _form_alliance 那一處），證明是這一條的效果再換基準。
