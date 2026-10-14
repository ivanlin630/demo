# 玩家遭遇戰的戰後收尾：結算事件、場上傷兵命運、俘虜接帳、追擊、居民處置問玩家——HOW

狀態：待 R²
來源：
- WHAT：`docs/notes/2026-10-13-annihilation-advisor-trade-prisoners.md` §1a／§4；意圖帳「玩家戰場傷亡入帳」列（藍圖訂正 4f2eb745c）。
- 排位：藍圖 2026-10-14-blueprint-to-systems-RULING-roadmap-board-and-annihilation-captives-rout-order（第 7 張）。
- 真玩：2026-10-14-blueprint-to-systems-TICKETS-live-play-findings-…①（結算事件）。
- R①：2026-10-14-reviewer-to-systems-R1-annihilation-captives-premises-FACTCHECK（一條假前提已由藍圖訂正）。
- 兩個 WHAT＋處置權歸留場方：藍圖 2026-10-14-blueprint-to-systems-RULING-ticket7-captives-all-disabled-guard-cap-pursuit-player-chooses（含末段 e837c1e2f，用戶點出「全數可俘只限於戰勝」）。
順位：玩家可見批第 7 張（游標即選中之後）。

## 事實（main 212e9556d；R① 已核）
- encounter 實質只用於玩家參與的戰鬥（NPC 對 NPC 走 npc_combat）；攻方可以是 NPC、守方是玩家（埋伏／找上門）。
- 結算 `encounter_system.gd:1209 resolve_encounter_end`：
  - :1216-1222 對雙方 `HealthSystem.resolve_anon_units` ⇒ 受傷（流血缺藥／骨折／任一部位非 healthy）的匿名 `wound_random` 進 wounded 桶。**縫**：血量昏迷而部位全 healthy 的不算（health_system.gd 不讀 unit["blood"]）。
  - :1233-1241 記名戰死出隊；:1246-1261 匿名上場陣亡 `kill_random`（只從 healthy 桶抽），敗方後備同率連坐 `_apply_reserve_casualty`。
  - :1324-1334 俘虜＝`winner.prisoner_population += 1` 計數器；被標 `is_prisoner` 的單位**沒有任何人員搬移**（仍在敗方 cohort）；計數器唯一讀者 `state_fingerprint.gd:392`。
  - :1366-1375 `last_encounter_result`（loot_pool、can_subjugate）⇒ 玩家指令 take_loot／leave_loot／subjugate 的 precheck 讀它（player_command_system.gd:581-600、:1083-1111、:1374-1386）＝戰後選擇的既有形狀（自家動作列＋precheck）。
  - :1390-1391 攻方勝 ⇒ `_process_occupied_residents`（:1437）讀**攻方領袖人格**自動屠／放棄／強佔——攻方是玩家時讀附身者的值（#12 違規）。
  - 整條結算**零玩家事件**；`combat_end` 只在 npc_combat_system.gd:419（NPC 訊息通道 `emit_message`）。
  - :1410 `_check_player_wiped` 三路尾端都呼 ⇒ U10b 已修。
- 既有帳：`AnonTierSystem.kill_wounded`（:184）、`absorb_as_captive`（:237，明傳 rate、分傷健、守恆、**無守衛容量上限**）、`capture_routed_as_captive`（:275，讀潰逃隊 readiness，含守衛容量公式 `effective_pop_cap − population − total_captives`）；`npc_combat._apply_pursuit`（:609，可達閘 winner.pop ≥ 2×loser.pop、人格算砍數、上限 `PURSUIT_KILL_CAP=3`）；`ManpowerSystem.decide_treatment`（:36，讀 holder 領袖人格）＋`tick_captives`。

## 改法

### 0. 失能判準一把（R① 縫）
- 場上傷兵（失能未死）＝`not is_dead(u) and not u.has_exited and not is_combat_capable(u)`（含血量昏迷）。`resolve_anon_units` 的 injured 判準改呼同一支謂詞（或並列：部位受傷 ∨ 失能），不再各寫一份；結算後敗方 wounded 桶 ≥ 場上匿名失能數。
- 記名失能者：維持 HealthSystem 個人傷勢（本來就有），不另做。

### 1. 結算事件（真玩①，硬要求）
- 每場玩家遭遇戰結算（一般／平手／野獸三路）發一則 `WorldEvents.emit` 玩家事件，kind `combat_end`（既有種類；**不走** `emit_message`），subjects＝雙方，列 `ADVANCE_STOP_KINDS`。
- 內容：誰贏；我方 死／傷（記名逐名、匿名數）；敵方 死／傷；俘虜（第 2 步之後的實數）；戰利品；NPC 勝時它對你做的傷兵命運與追擊結果（第 2、3 步）。
- 只寫玩家該知道的：敵方數字＝場上看到的（encounter_units 雙方都在場、互見已成立，F2），不讀敵隊整體 population 真值。
- 判準：結算前後任一方 population 變了而事件流沒有這則 ⇒ 紅。

### 2. 場上傷兵的命運（殺／俘／放）
- **處置權＝結算時仍留在戰場上的一方**（用戶 2026-10-14）：留場＝該方結算當下仍有 `is_combat_capable` 的單位在場（既有謂詞，不另寫）。以這個謂詞判，不以 result 字串判：
  - 只有玩家方留場 ⇒ 敵方的場上失能者歸玩家處置（下「勝方是玩家」）。
  - 只有敵方留場（玩家離場／潰退／全失能）⇒ 玩家留下的失能者歸敵方處置（下「勝方是 NPC」），寫進玩家結算事件。
  - 雙方都不留場（平手／逾時／雙方都撤）⇒ 各自帶回自己的失能者、零俘虜、無命運步驟、無追擊。
  - 雙方都留場而結算（若有此路徑，實作端普查列出）⇒ 同第三種。
- 對象：敗方的場上匿名失能者，數 N（第 0 步的謂詞，在結算當下量，寫進 `last_encounter_result.disabled_enemy`）。記名失能敵人：只有「殺」「放」（記名俘虜帳不存在，見範圍外）。
- **勝方是玩家**：`last_encounter_result` 帶 `fate_pending:true`；自家動作列出現四項（走既有動作列＋precheck，不開新輸入態）：「殺傷兵 N」「俘虜（厚待）」「俘虜（苛待）」「放走」。未決之前：推進鍵回「先決定戰後處置」（列推進停點；不自動選，#12）。
  - 殺 ⇒ `AnonTierSystem.kill_wounded(loser, N)`（只從 wounded 桶）＋記名失能者戰死同 :1233 那段。
  - 俘 ⇒ 上限＝守衛容量（`capture_routed_as_captive` 那條公式，抽成 `AnonTierSystem.guard_budget(state, holder)` 一支，兩處共用）；實俘 k＝min(N, budget) 人**從 wounded 桶**搬進 `holder.captive_groups`（新增 `absorb_wounded_as_captive(holder, loser, k)`，與 `absorb_as_captive` 共用「組 captive_group」那段 helper——**一個 group 形狀一支身體**）；group 帶 `treatment` 欄＝玩家選的厚待／苛待。超量 N−k 留在敗方 wounded 桶（不動＝放走，仍是傷兵、不消失）；結算事件寫「看守不過來，放走 N−k 人」。
  - 放 ⇒ 不動（他們已在敗方 wounded 桶）。
  - 敗方滅團（pop≤0 由 `_on_team_extinct` 收）只可能在「殺」之後；俘／放都不減到 0 以下的未計人——**禁憑空消失**：任何一條路徑 Σ(敗方人口變化) ＝ 殺＋俘，床守恆格驗。
- **勝方是 NPC（玩家敗）**：結算當下 NPC 立即選：分數 kill＝殘忍、capture＝貪婪（且 guard_budget>0）、release＝義氣，取最大（同分序：放＞俘＞殺；**人格只當權重不當門檻**）。結果進第 1 步的事件。
- 玩家俘來的 group：`tick_captives` 對玩家 holder **不呼 `decide_treatment`**，讀 group 的 `treatment` 欄（#12：待遇是玩家定的）；看守強度 `_decide_guard_ratio` 讀附身者慎重——同屬決策，玩家 holder 改讀 group 欄 `guard_ratio`（捕獲時預設＝現公式算一次並印在面板，之後只有玩家改；改看守強度的動詞本票不做，列「還沒做」）。缺糧自動「釋放」（food_per_cap<0.5）是物理（養不起）⇒ 對玩家照跑，但發玩家事件「養不起，俘虜被放走 N 人」。
- `prisoner_population` 計數器退場（寫入點、欄位、指紋那一欄一起拿掉；world-fp 換基準，二分證差異只在這欄＋新帳）。

### 3. 追擊（第 2 步之後）
- 逃散者＝敗方 `has_exited` 的單位數 E（離場撤退者）。
- **列的條件＝做的條件**：E>0 且可達閘（winner.pop ≥ 2×loser.pop，`_apply_pursuit` 同一條，抽成 `NpcCombatSystem.pursuit_reachable(winner, loser)`）才列。
- **勝方是玩家**：命運決定後，若可列 ⇒ 「追擊（最多砍 min(3, E)）」「不追」兩項；未決前推進同樣停。追 ⇒ 砍 min(`PURSUIT_KILL_CAP`, E) 從敗方 healthy 桶（`kill_random`）。
- **勝方是 NPC**：照 `_apply_pursuit` 的人格砍數（抽成純函數 `pursuit_kill_count(leader)` 兩戰場共用），上限 min(cap, E)；結果寫進第 1 步的玩家事件（不能只在 NPC 通道）。
- 先命運後追擊：`pursuit_pending` 只在 `fate_pending` 清掉後成立。

### 4. 居民處置問玩家（攻方是玩家）
- `_process_occupied_residents`：居民接受投靠那一支照舊（居民自己的決定）；走到「攻方決定」時，攻方是玩家（`player_controlled`）⇒ 不讀人格，寫 `last_encounter_result.residents_pending = {resident_id, tile}`，自家動作列「屠村」「放棄佔領」「強佔」三項，呼既有三支函式；未決前推進停。攻方是 NPC 照舊。
- 順序：命運 → 追擊 → 居民（同一個 pending 佇列，一次只列一組）。

### 5. 玩家面
- 帶團頁一行：「俘虜 N 人（厚待 a／苛待 b），每日吃 X 糧」（X 讀 manpower 的 `CAPTIVE_FOOD_RATE`，不手抄）。
- 厚待／苛待切換：自家動作「俘虜改厚待／改苛待」（改 group 的 treatment 欄）。
- 你自己也會拖傷兵：結算後我方 wounded 增加，頂列／面板既有的人口與傷兵欄照實（round4-known-holes 合併時加一列本意）。

## 驗收（新床 `battle_aftermath_bed.gd`，acceptance，註冊表登一列；各格修前紅除註明）
- A1 事件：玩家勝／玩家敗／平手／野獸四場 ⇒ 各一則 `combat_end` 玩家事件，含雙方死傷；人口變了而無事件 ⇒ 紅（修前紅）。
- A2 失能判準：佈置一個血量昏迷、部位全 healthy 的敵方匿名 ⇒ 結算後敗方 wounded 桶含它（修前紅）。
- A3 命運未決推進停：玩家勝後按推進 ⇒ 被拒、句子說先決定；四項都列。
- A4 殺：wounded 桶減 N、人口減 N；記名失能者出隊。
- A5 俘：captive_groups 增 k、敗方 wounded 減 k；k＝min(N, guard_budget)；超量者仍在敗方 wounded；事件寫放走數。
- A6 守恆：A4／A5／放 三條各算 Σ 敗方人口變化 ＝ 殺＋俘，任何人不從兩邊同時消失。
- A7 玩家俘虜待遇：30 天內 `decide_treatment` 對玩家 holder 呼叫 0 次（tap）、group.treatment 只在玩家指令時變；負對照放回 decide_treatment ⇒ 紅。
- A8b 處置權：玩家撤離而敵方留場 ⇒ 玩家留下的失能者由 NPC 處置、進玩家事件；平手／雙方撤 ⇒ 零俘虜、無命運步驟（修前：俘虜計數器在 result 有勝方時就加）。
- A8 NPC 勝：玩家敗 ⇒ NPC 當場選、無 pending；選擇與人格權重一致（佈置三個極端人格各一場）；事件含 NPC 的命運與追擊結果。
- A9 追擊列的條件＝做的條件：E=0 或可達閘假 ⇒ 不列；可列且按追 ⇒ 敗方減 min(3, E)。
- A10 居民：玩家攻佔有居民的據點 ⇒ 三項列出、未決推進停；NPC 攻方照舊（負對照：玩家攻方讀人格 ⇒ 紅）。
- A11 U10b：玩家全隊陣亡 ⇒ 走 handle_player_succession（有繼承人換附身／無則 game_over），程式不靜默結束；綠了關 known_issues U10b。
- A12 帶團頁一行與日耗數字＝manpower 實際扣的糧（1 天後對帳）。
- 負對照：①事件改走 emit_message ⇒ A1 紅 ②失能謂詞拿掉血量條件 ⇒ A2 紅 ③命運自動選（讀人格）⇒ A3 紅 ④俘不設上限 ⇒ A5 紅。
- world-fp：換基準（prisoner_population 退場＋NPC 對玩家的命運／追擊）；二分報告。NPC 對 NPC 世界不變（encounter 只用於玩家戰）——用 census 3 seed × 30 天的 npc_combat 計數證明不動。

## 範圍外
- 死亡判準（軀幹 severed 才死）與後備同率連坐：戰鬥物理，07-10 殲滅線裁定不動；本票讓失能者有命運（可被殺／俘）就是「打輸會流血」的出口。若藍圖要改死亡判準，另票。
- 記名俘虜帳（記名被俘只有一句）：不存在，本票不建；記名失能敵人只有殺／放。
- 看守強度的玩家動詞、俘虜殺／贖／放（defers `captives-kill-ransom-release-after-social-layer`）。
- 潰退五輸入（深層批首）。
