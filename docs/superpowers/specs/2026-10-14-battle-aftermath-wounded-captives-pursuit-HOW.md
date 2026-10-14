# 玩家遭遇戰的戰後收尾：結算事件、場上傷兵命運、俘虜接帳、追擊、居民處置問玩家——HOW

狀態：R² ISSUES（2026-10-14-reviewer-to-systems-R2-battle-aftermath-ISSUES）兩擋已改（2c 容量一支、2d 推進＝不處置不擋推進）；重送審查核；記名失能者雙向一律放（藍圖裁 2026-10-14-…-RULING-ticket7-named-disabled-release-both-ways-until-named-captive-ledger）
來源：
- WHAT：`docs/notes/2026-10-13-annihilation-advisor-trade-prisoners.md` §1a／§4；意圖帳「玩家戰場傷亡入帳」列（藍圖訂正 4f2eb745c）。
- 排位：藍圖 2026-10-14-blueprint-to-systems-RULING-roadmap-board-and-annihilation-captives-rout-order（第 7 張）。
- 真玩：2026-10-14-blueprint-to-systems-TICKETS-live-play-findings-…①（結算事件）。
- R①：2026-10-14-reviewer-to-systems-R1-annihilation-captives-premises-FACTCHECK（一條假前提已由藍圖訂正）。
- 兩個 WHAT＋處置權歸留場方：藍圖 2026-10-14-blueprint-to-systems-RULING-ticket7-captives-all-disabled-guard-cap-pursuit-player-chooses（含末段 e837c1e2f「全數可俘只限於戰勝」、再追加 27e53db65「接上既有戰中俘虜」）。
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
- manpower 讀 holder 領袖人格的**三處**（R²）：`decide_treatment`（:36 野心／殘忍，內含缺糧自動釋放 :42-46）、`_decide_guard_ratio`（:63 慎重）、`_enforce_guard_cap`（:233-262 殘忍：超過 `total_pop × captive_guard_ratio × GUARD_CAP_MULT(3.0)` 的超額，殘忍≥0.5 殺一部分、否則放成流民）；`tick_all`（:279）每日先設 ratio、再 enforce、再逐 group decide。
- 遭遇收場（R²）：`advance_encounter_tick` 末段（:930-932）雙方同時無人可戰時回 "attacker_win"；"draw" 只在 def_id==-1 可達（實質只被 observer_bridge.gd:32 強制呼叫）；全檔無回合上限／逾時 ⇒ **result 字串不可當處置權依據**；:1295 draw 分支對玩家流程是死碼，不掛新邏輯。
- 推進（R²）：`SimBridge.request_advance`（sim_bridge.gd:44）只設 `_ticks_remaining`、無閘；強制事件是「停點＋逾時自動拒絕」（sim_runner.gd:746），不擋推進。
- 既有帳：`AnonTierSystem.kill_wounded`（:184）、`absorb_as_captive`（:237，明傳 rate、分傷健、守恆、**無守衛容量上限**）、`capture_routed_as_captive`（:275，讀潰逃隊 readiness，含守衛容量公式 `effective_pop_cap − population − total_captives`）；`npc_combat._apply_pursuit`（:609，可達閘 winner.pop ≥ 2×loser.pop、人格算砍數、上限 `PURSUIT_KILL_CAP=3`）；`ManpowerSystem.decide_treatment`（:36，讀 holder 領袖人格）＋`tick_captives`。

## 改法

### 0. 失能判準一把（R① 縫）
- 場上傷兵（失能未死）＝`not is_dead(u) and not u.has_exited and not is_combat_capable(u)`（含血量昏迷）。`resolve_anon_units` 的 injured 判準改呼同一支謂詞（或並列：部位受傷 ∨ 失能），不再各寫一份；結算後敗方 wounded 桶 ≥ 場上匿名失能數。
- 記名失能者：維持 HealthSystem 個人傷勢（本來就有），不另做。

### 1. 結算事件（真玩①，硬要求）
- 每場玩家遭遇戰結算（一般／平手／野獸三路）發一則 `WorldEvents.emit` 玩家事件，kind `combat_end`（既有種類；**不走** `emit_message`），subjects＝雙方，列 `ADVANCE_STOP_KINDS`。
- 內容：誰贏；我方 死／傷（記名逐名、匿名數）；敵方 死／傷；俘虜（第 2 步之後的實數）；戰利品；NPC 勝時它對你做的傷兵命運與追擊結果（第 2、3 步）。
- 只寫玩家該知道的：敵方數字＝場上看到的（encounter_units 雙方都在場、互見已成立，F2），不讀敵隊整體 population 真值。
- 判準（per-encounter：`resolve_encounter_end` 前後，不是 per-tick——同 tick 其他系統也動人口）：結算前後任一方 population 變了而事件流沒有這則 ⇒ 紅。戰後玩家指令（subjugate／take_loot／命運）各有自己的結果句，不屬此判準。
- 句子由 `WorldEvents.describe` 單一產生者組（world_events.gd:98 現只有簡稱「戰鬥結束」），encounter_system 不手寫字串；玩家面零英文識別字。

### 2a. 戰中已被押住的（既有 `_check_prisoners` :596／`_check_rescues` :625，用戶 2026-10-14）
- 戰中：失能未離場且身旁有敵人 ⇒ 就地 `is_prisoner`（押方＝對方隊）；隊友貼身且無敵看守 ⇒ 救回。這兩支不改。
- 結算（**兩個方向都算**，現況只數敗方＝漏一邊）：對每個 `is_prisoner` 單位，若押方結算時仍有 `is_combat_capable` 單位在場 ⇒ 被帶走歸押方，**不看誰留場**：
  - 匿名 ⇒ 押方 `captive_groups`（`absorb_wounded_as_captive`，受同一個 `guard_budget` 上限；押方是玩家時 group 的 treatment＝玩家下一步選，見 2 的「俘虜（厚待／苛待）」；押方是 NPC 時照 manpower 既有）。超過上限的回原隊 wounded 桶、進事件。
  - 記名 ⇒ 記名俘虜帳不存在（範圍外）⇒ 放回原隊並在結算事件寫「X 被俘後放回（記名俘虜還沒做）」——不憑空消失、不假裝帶走。
- 押方自己全倒或全離場 ⇒ 被押者等於無人看守 ⇒ 回到下一步（失能者看留場）。
- 玩家這側每一筆（我方被押走幾人、我方押住幾人、放回幾人）都進 `combat_end` 玩家事件。
- 這一步先於下一步；下一步的 N 不含已被押走的。

### 2. 場上傷兵的命運（殺／俘／放）
- **處置權＝結算時仍留在戰場上的一方**（用戶 2026-10-14）：留場＝該方結算當下仍有 `is_combat_capable` 的單位在場（既有謂詞，不另寫）。以這個謂詞判，不以 result 字串判：
  - 只有玩家方留場 ⇒ 敵方的場上失能者歸玩家處置（下「勝方是玩家」）。
  - 只有敵方留場（玩家離場／潰退／全失能）⇒ 玩家留下的失能者歸敵方處置（下「勝方是 NPC」），寫進玩家結算事件。
  - 雙方都不留場（雙方同 tick 全失能／一方全撤另一方同 tick 全失能）⇒ 各自帶回自己的失能者、零俘虜、無命運步驟、無追擊——★此時 result 字串是 "attacker_win"（R²），所以必須用留場謂詞。
  - 雙方都留場而結算：不存在（迴圈到一方無 active 才結束）。
  - **野獸遭遇**：沒有命運／追擊／居民步驟（野獸不抓俘虜，:604-607）；結算事件寫「獵得 …」。
- 對象：沒被押走（2a 之後）的場上匿名失能者，數 N（第 0 步的謂詞，在結算當下量，寫進 `last_encounter_result.disabled_enemy`）。**記名失能者（雙方、含玩家本人）一律放**：留在原隊當傷兵、走既有恢復；結算事件寫「X 倒在戰場上，對方沒有處置（記名俘虜還沒做）」。殺／俘記名要有處決窗，歸深層批俘虜殺／贖／放那張（藍圖裁，07-10 對稱）。
- **勝方是玩家**：`last_encounter_result` 帶 `fate_pending:true`；自家動作列出現四項（走既有動作列＋precheck，不開新輸入態）：「殺傷兵 N」「俘虜（厚待）」「俘虜（苛待）」「放走」。未決時推進見 2d。
  - 殺 ⇒ `AnonTierSystem.kill_wounded(loser, N)`（只從 wounded 桶；只限匿名）。
  - 俘 ⇒ 上限＝`ManpowerSystem.captive_room(state, holder)`（見 2c 容量一支）；實俘 k＝min(N, room) 人**從 wounded 桶**搬進 `holder.captive_groups`（`absorb_wounded_as_captive(holder, loser, k)` 為 `_capture_from_health`（anon_tier_system.gd:323）的薄包裝；組 group 抽 `_new_captive_group(captured, origin_faction, entry)`，**`absorb_as_captive`（:259-265）與 `capture_routed_as_captive`（:312-318）兩份舊組裝一併改呼它**）；group 帶 `treatment` 欄＝玩家選的厚待／苛待。超量 N−k 留在敗方 wounded 桶（不動＝放走，仍是傷兵、不消失）；結算事件寫「看守不過來，放走 N−k 人」。
  - 放 ⇒ 不動（他們已在敗方 wounded 桶）。
  - 敗方滅團（pop≤0 由 `_on_team_extinct` 收）只可能在「殺」之後；俘／放都不減到 0 以下的未計人——**禁憑空消失**：任何一條路徑 Σ(敗方人口變化) ＝ 殺＋俘，床守恆格驗。
- **勝方是 NPC（玩家敗）**：結算當下 NPC 立即選，三分數取最大（同分序：放＞俘＞殺；取最大不是門檻梯）。域專判斷器穿人格＋記憶＋現況：
  - kill＝殘忍＋對敗方領袖的 feud 邊強度（`DiplomaticAiSystem._edge_intensity_to`）；
  - capture＝貪婪 ×（`captive_room>0` 且 `captive_food_ok`，否則 0）；
  - release＝義氣＋對敗方領袖的 gratitude 邊強度。
  - 尺度說明：命運是三選一的相對比較（原值互比）；追擊是砍數（`round(殘忍×2+貪婪×0.8)` 夾 [0,3]），用途不同、不共尺。
  - 三分數只作用於匿名；記名照上「一律放」。
  - 結果進第 1 步的事件。
- 玩家俘來的 group 怎麼養、怎麼看守：見 2c。

### 2c. 容量一支、manpower 三個人格讀者（R² 擋①）
- **容量一支**：`ManpowerSystem.captive_room(state, holder) = max(0, floor(total_pop × ratio × GUARD_CAP_MULT) − total_captives)`，ratio＝holder 的看守比（NPC：`_decide_guard_ratio(state, holder)` 當下值；玩家：`holder.captive_guard_ratio`）。**捕獲（第 2 步）、2a 押走、`capture_routed_as_captive`（取代 :299-301 內聯的 pop_cap 公式）、`_enforce_guard_cap` 四處同一支**——捕獲時就不會超過下一次 enforce 的上限（NPC 的 ratio 隨持有量上升，cap 只會更大）。
  - ★這改了 NPC 對 NPC 潰逃俘虜的上限（舊：人口上限餘裕；新：看守容量）⇒ census 3 seed × 30 天量 `capture_routed` 實俘數修前修後；跌到 0 或腰斬 ⇒ 停手回 systems。理由：兩套公式本來就互相打架，NPC 世界今天就有「俘了、下一個 cadence 被 enforce 殺掉／放掉」的折騰。
- **玩家 holder**（判定用 `player_controlled`，不用 leader_id==player_id）：
  - 看守比只在 holder 層一欄 `captive_guard_ratio`（不另造 group 欄）；玩家 holder 不呼 `_decide_guard_ratio`，初值＝具名常數 `PLAYER_GUARD_RATIO_DEFAULT = GUARD_RATIO_MAX / 2`（不讀附身者人格），面板印出；改看守比的動詞本票不做（列「還沒做」）。
  - 不呼 `decide_treatment`，讀 group 的 `treatment` 欄（玩家選）。
  - `_enforce_guard_cap` 遇玩家 holder 超額 ⇒ **不處置**，發玩家事件「看守不足：俘虜 N 人、可看守 M 人」＋Probe `asm.guardcap_player_excess`（因容量一支，正常為 0；它是守衛）。
  - 缺糧釋放（:42-46）搬出成獨立物理檢查 `captive_food_ok(state, holder)`，對所有 holder 在 decide 之前跑；玩家 holder 養不起 ⇒ 照放，發玩家事件「養不起，俘虜被放走 N 人」（與 NPC 對稱）。
- `prisoner_population` 計數器退場（2a 取代它）（寫入點、欄位、指紋那一欄一起拿掉；world-fp 換基準，二分證差異只在這欄＋新帳）。

### 2d. 未決時推進＝不處置（R² 擋②；不擋推進）
- 不新增硬模態。戰後處置跟強制事件同一個形狀：**停點＋推進即取被動選項**。`combat_end` 是推進停點，玩家停在結算那一屏、看到選項；若直接推進 ⇒ 在推進的第一個 tick 之前，把每個 pending 以**被動選項**結清：命運＝放走、追擊＝不追、居民＝放棄佔領；結果行寫「你沒有處置：傷兵被放走（N 人）」等。
  - 被動選項＝不作為，不是 AI 替玩家選（#12 成立：沒有讀任何人格）。
  - 結清點：`SimBridge.request_advance` 咽喉（X／空白／G／L／PlayerRepl 等待迴圈／腳本全經這裡）；一支 `PlayerCommandSystem.settle_pending_aftermath(state)`，冪等。
  - 不陳舊：結清在世界前進之前 ⇒ N、E、居民狀態都是結算當下的值。
  - 無軟鎖：沒有任何狀態會擋推進；precheck 全假時被動選項仍成立。
  - 與 choose_heir／game_over：玩家領袖戰死 ⇒ choose_heir 強制事件與 pending 同時成立時，pending 照常列在動作列（新附身者決定）；game_over ⇒ `settle_pending_aftermath` 以被動選項結清，不擋結束畫面。
  - 無玩家世界／observer_bridge.gd:32 強制 draw 路：pending 只在 `player_id≠-1` 且玩家為留場方／攻佔方時成立，不受影響。
- 受影響床（實作端照實列在交件信）：`terminal_e2e_bed` BATTLE 系列（戰後繼續推進——推進會先結清，斷言句子可能多一行）、`ui_flow_test` 戰後流程、任何戰後還推進的床。

### 3. 追擊（第 2 步之後）
- 逃散者＝敗方 `has_exited` 的單位數 E（離場撤退者）。
- **列的條件＝做的條件**：E>0 且可達閘（winner.pop ≥ 2×loser.pop，`_apply_pursuit` 同一條，抽成 `NpcCombatSystem.pursuit_reachable(winner, loser)`）才列。
- **勝方是玩家**：命運決定後，若可列 ⇒ 「追擊（最多砍 min(3, E)）」「不追」兩項；未決時推進＝不追（2d）。追 ⇒ 砍 min(`PURSUIT_KILL_CAP`, E) 從敗方 healthy 桶（`kill_random`）。
- **勝方是 NPC**：照 `_apply_pursuit` 的人格砍數（抽成純函數 `pursuit_kill_count(leader)` 兩戰場共用），上限 min(cap, E)；結果寫進第 1 步的玩家事件（不能只在 NPC 通道）。
- 先命運後追擊：`pursuit_pending` 只在 `fate_pending` 清掉後成立。

### 4. 居民處置問玩家（攻方是玩家）
- `_process_occupied_residents`：居民接受投靠那一支照舊（居民自己的決定）；走到「攻方決定」時，攻方是玩家（`player_controlled`）⇒ 不讀人格，寫 `last_encounter_result.residents_pending = {resident_id, tile}`，自家動作列「屠村」「放棄佔領」「強佔」三項，呼既有三支函式；未決時推進＝放棄佔領（2d）。攻方是 NPC 照舊。
- 順序：命運 → 追擊 → 居民（同一個 pending 佇列，一次只列一組）。

### 5. 玩家面
- 帶團頁一行：「俘虜 N 人（厚待 a／苛待 b），每日吃 X 糧」（X 讀 manpower 的 `CAPTIVE_FOOD_RATE`，不手抄）。
- 厚待／苛待切換：自家動作「俘虜改厚待／改苛待」（改 group 的 treatment 欄）。
- 你自己也會拖傷兵：結算後我方 wounded 增加，頂列／面板既有的人口與傷兵欄照實（round4-known-holes 合併時加一列本意）。

## 驗收（新床 `battle_aftermath_bed.gd`，acceptance，註冊表登一列；各格修前紅除註明）
- A1 事件：玩家勝／玩家敗／雙方同 tick 全失能（result=attacker_win、零俘虜）／野獸 四場 ⇒ 各一則 `combat_end` 玩家事件，含雙方死傷（per-encounter 比較）；反向格：observer_bridge 強制 draw 路（無玩家）⇒ 不發玩家事件（修前紅）。
- A2 失能判準：佈置一個血量昏迷、部位全 healthy 的敵方匿名 ⇒ 結算後敗方 wounded 桶含它（修前紅）。
- A3 未決推進＝不處置：玩家勝後四項都列；不選直接推進 ⇒ 第一個 tick 前結清為放走（N 人留在敗方 wounded）、結果行說明；X／空白／G／L／PlayerRepl 五條推進入口各一格都走同一結清；推進不被拒（無軟鎖）。
- A4 殺：wounded 桶減 N、人口減 N；記名失能者出隊。
- A5 俘：captive_groups 增 k、敗方 wounded 減 k；k＝min(N, guard_budget)；超量者仍在敗方 wounded；事件寫放走數。
- A6 守恆：A4／A5／放 三條各算 Σ 敗方人口變化 ＝ 殺＋俘，任何人不從兩邊同時消失。
- A7 玩家俘虜待遇：30 天內 manpower 三條讀人格路徑（decide_treatment／_decide_guard_ratio／_enforce_guard_cap 的人格分支）對玩家 holder 呼叫 0 次（各一個 tap）；group.treatment 只在玩家指令時變；負對照放回 decide_treatment ⇒ 紅。
- A7b 容量一支：玩家俘 k 人（k＝captive_room，接近上限）後推 3 個 captive cadence ⇒ captive 總數不變（除缺糧物理）、無「苛用」「GuardCap」輸出、無 breakaway 隊、`asm.guardcap_player_excess`＝0；負對照：捕獲改回 pop_cap 公式 ⇒ A7b 紅。
- A7c 缺糧物理對稱：玩家 holder 糧不足 ⇒ 俘虜被放走並發玩家事件（負對照：缺糧檢查留在 decide_treatment 內 ⇒ 玩家 holder 永遠不放 ⇒ 紅）。
- A8c 戰中俘虜：玩家押住敵方匿名 2 人、敵方押住我方 1 人，押方都留場 ⇒ 結算後各自進對方 captive_groups（兩個方向）、事件三筆都有；押方全倒 ⇒ 被押者回留場規則；記名被押 ⇒ 放回、事件寫明（修前：只數敗方、只加計數器、無人員搬移）。
- A8b 處置權：玩家撤離而敵方留場 ⇒ 玩家留下的失能者由 NPC 處置、進玩家事件；雙方同 tick 全失能 ⇒ 斷言 result=="attacker_win" 且零俘虜、無命運步驟（修前：計數器照加）；押方在結算前同 tick 才倒 ⇒ 被押者回留場規則。
- A8 NPC 勝：玩家敗 ⇒ NPC 當場選、無 pending；三個極端人格各一場＋一場「有 feud 邊」＋一場「養不起」（capture 分數歸 0）；雙方記名失能者（含玩家本人）都不被殺、留原隊、事件寫明；事件含 NPC 的命運與追擊結果。
- A9 追擊列的條件＝做的條件：E=0 或可達閘假 ⇒ 不列；可列且按追 ⇒ 敗方減 min(3, E)。
- A10 居民：玩家攻佔有居民的據點 ⇒ 三項列出、未決推進＝放棄佔領；NPC 攻方照舊（負對照：玩家攻方讀人格 ⇒ 紅）。
- A11 U10b：玩家全隊陣亡 ⇒ 走 handle_player_succession（有繼承人換附身／無則 game_over），程式不靜默結束；綠了關 known_issues U10b。
- A12 帶團頁一行與日耗數字＝manpower 實際扣的糧（1 天後對帳）。
- 負對照：①事件改走 emit_message ⇒ A1 紅 ②失能謂詞拿掉血量條件 ⇒ A2 紅 ③被動結清改成讀人格選 ⇒ A3 紅 ④俘不設上限 ⇒ A5 紅 ⑤容量改回兩套 ⇒ A7b 紅。
- world-fp：換基準（prisoner_population 退場＋NPC 對玩家的命運／追擊）；二分報告。NPC 對 NPC 世界不變（encounter 只用於玩家戰）——用 census 3 seed × 30 天的 npc_combat 計數證明——★例外是 2c 的容量統一會動 NPC 潰逃俘虜數，census 單列修前修後；census 母體要含「玩家為留場方」「NPC 為留場方」各至少一場（佈置），免得母體沒碰到。

## 範圍外
- 死亡判準（軀幹 severed 才死）與後備同率連坐：戰鬥物理，07-10 殲滅線裁定不動；本票讓失能者有命運（可被殺／俘）就是「打輸會流血」的出口。若藍圖要改死亡判準，另票。
- 記名俘虜帳與殺記名的處決窗：不存在，本票不建；記名失能者雙向一律放。
- 記名一律上場＋匿名只上武裝比×人口（encounter_system:1102）⇒ 拔擢＝讓沒武器的人上場：藍圖記著，歸「戰前編成由隊長定」軍民比／動員那條，本票不動。
- 看守強度的玩家動詞、俘虜殺／贖／放、記名俘虜帳（defers `captives-kill-ransom-release-after-social-layer`）。
- 潰退五輸入（深層批首）。
