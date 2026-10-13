# 接受同盟把勢力領袖搬進對方勢力——HOW

狀態：收 R²（…-R2-alliance-leader-ISSUES §1–§6，覆蓋面補完不需再審）
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
   - **謂詞（R² §6②）**：`_form_alliance` 被搬的只有發起方（team_b），且只在收提案方有勢力時 ⇒ 被拒集合＝「**發起方是其勢力領袖 ∧ 收提案方在另一勢力**」（收提案方不必是領袖）。反向（領袖收提案、成員發起）⇒ 成員照搬入，保持。抽成純函式 `plan_alliance(a, b) -> {action, reason}`，`_form_alliance` 與選項層都呼叫它。
   - 上述集合 ⇒ **藍圖追加 WHAT（2026-10-13）：不得變成空動作**（只加名聲＝宣稱結盟而世界沒變）。
     - 現況（我查）：`FactionData.relations`（faction_data.gd:39-41，"neutral"／"ally"／"enemy"）欄位存在，但 scripts/simulation 內**找不到任何寫入或讀取**；威脅評估與攻擊資格都不讀它。實作端再以 grep 確認（含 `relations.get`、字串 "ally" 的比較）。
     - ⇒ **確認無讀者（R² 已獨立驗證：只有 state_fingerprint 讀、欄位恆空）⇒ 拒絕這種結盟**：回句「兩個勢力之間的結盟還沒做」，名聲不動、勢力不動。留給回應提案框架票（深層批）。
     - **NPC 端在提案選項層排除**（R² §6③）：`try_proactive_diplomacy` 現在對同格異勢力隊 score>0.6 就送 propose_alliance 並 return ⇒ 領袖會每個冷卻週期重送必被拒的提案、擠掉同輪 trade／tribute。⇒ 選項生成處呼 `plan_alliance` 跳過無動作者；`handle_diplomacy_message`（:384-388 現為先 `_form_alliance` 再回 accept）改成先 plan、無動作回 reject 並帶可映射原因碼給玩家端。
     - 若 grep 找到真讀者（威脅評估或攻擊資格讀 ally）⇒ **停手、交件信列出**，由我改成「寫 ally 態」那條。
   - 「同盟≠併入」的完整語意（兩勢力的盟約關係）歸回應提案框架票（深層批）；本票只保證領袖不被搬。
2. **方向統一**：:1865 改成與 :386 一致（收提案方＝玩家＝team_a）。:876 的重複呼叫拿掉（:386 已做）；若 :876 存在是為了「玩家發起時要以玩家為主」，實作端說明，由我裁。:1929 核對後同樣對齊。
3. **結果句寫實際後果**（讀 `_form_alliance` 回傳的實際動作，不在呼叫端猜）：讓 `_form_alliance` 回 `{moved_team, to_faction, created_faction}`；玩家看到「Team8 加入你的勢力 2」／「你加入勢力 1（離開勢力 2）」／「兩個勢力之間的結盟還沒做」。**提案行**（強制事件面板上那一行）也寫實際後果的預告（同一個函式的試算版，不寫第二份規則）。
4. **完整性收在 `set_team_faction` 咽喉（R² 擋點）**：政策（同盟不搬領袖）在 `_form_alliance`，**但搬領袖的路徑不只結盟**——`_try_subjugate`（npc_combat_system.gd:828-851）、投降強鄰（faction_ai_system.gd:8058）、整併（interaction_system.gd:1719）都能搬；`leader_team_id` 全站只 3 處寫，沒有一處處理「領袖隊被搬走」。
   - `set_team_faction`：erase 舊名冊之後，若舊勢力 `leader_team_id == 這隊` 且 reason ≠ `LEAVE_FACTION_DISSOLVED` ⇒ 呼既有 `succeed_or_disband_faction`（world_state.gd:482，現有 3 個領袖死亡呼叫端在用）。**不擋任何路徑**，只讓勢力不再無頭。
   - join 也加 reason 常數（現在只有離開有），各呼叫端帶上；Probe `faction.join.<reason>`，來源才歸因得到。
   - L7 掛進 `InvariantAudit`（每個勢力的 leader_team_id 指向 faction_id 相符的隊），不只是床的斷言。

## 先量（動 NPC 端前，藍圖 2026-10-13）
NPC 之間「兩勢力領袖結盟＝一方被搬進另一方」可能是現況勢力變大的主要管道；不能為修玩家 bug 少一條生長路。
- 在**修前**樹上跑觀測回合（30 天，**至少 3 個 seed**，含 1337），用 Probe 數：發起方角色×收提案方角色（領袖／成員／獨立）3×3 的 `_form_alliance` 次數；各 JOIN 路徑**絕對次數**（不用 `faction.join` 總數當分母——它含子隊繼承 subteam_system:110/148/175，會把比例壓低）；那一支發生後原勢力剩幾隊、leader_team_id 是否懸空。
- **陽性對照**：佈置同格「領袖發起、異勢力收」的提案，證明修前那一支確實會 fire（否則「fire 0 次」是母體太小的負斷言）。
- **門檻（事前定）**：「主要管道」＝任一 seed 中，該支造成的頂層入勢力（不含子隊繼承）≥ 20%，或使 ≥ 2 個勢力的頂層成員數增加。
- **玩家端**（:1865、:876、:1929）照本 spec 改，不受量測結果影響。
- **NPC 端**：
  - 那一支 fire 0 次或很少 ⇒ 照本 spec 拒絕。
  - 是主要管道 ⇒ **停手、交件信附數字**，不自行決定。理由：現況那一支只搬領袖隊、留下原勢力其餘成員與懸空的領袖指標，「照舊合併」等於保留無頭勢力；真正的「併入」（整個勢力併過去）要設計，由我與藍圖定。

## 驗收
- L1（修前紅）：玩家是勢力 2 領袖，接受勢力 1 某隊（非領袖）的同盟 ⇒ 玩家仍在勢力 2；對方加入勢力 2；結果句「Team8 加入你的勢力 2」。
- L2（修前紅）：玩家是勢力 2 領袖，接受勢力 1 **領袖隊**的同盟 ⇒ 兩隊都不換勢力、名聲不變；結果句「兩個勢力之間的結盟還沒做」。
- L2b：勢力 1 領袖隊向勢力 2 的**非領袖成員**提案 ⇒ 同樣拒絕（收提案方不必是領袖）。
- L2c：勢力 2 成員向勢力 1 領袖提案、領袖接受 ⇒ 成員照搬入勢力 1（反向保持）。
- L3（修前紅）：玩家（勢力 2 領袖）向勢力 1 某隊發起、對方接受 ⇒ 玩家不離開勢力 2。
- L4：玩家獨立，接受勢力 1 隊的同盟 ⇒「你加入勢力 1」，提案行事先寫明。
- L5：NPC↔NPC：兩勢力領袖之間的同盟提案 ⇒ 不成立（不換勢力、不加名聲）——**僅在量測判定不是主要管道時**；否則此格待裁。
- L6：名聲只 +0.2 一次（:876 重複呼叫拿掉）。
- L7：`InvariantAudit` 新條：每個勢力的 `leader_team_id` 指向 `faction_id == 該勢力` 的隊；30 天世界零違反。
- L8：`_try_subjugate` 把領袖村搬走（佈置）⇒ 原勢力繼位或解散，不懸空。
- L9：NPC 領袖不會對異勢力隊送 propose_alliance（選項層排除）；同輪 trade／tribute 照常可選。
- 負對照：拿掉領袖守衛 ⇒ L1／L2／L5 紅。
- world-fp：L5 會改 NPC 行為 ⇒ fp 可能變；先二分（只動 _form_alliance 那一處），證明是這一條的效果再換基準。
