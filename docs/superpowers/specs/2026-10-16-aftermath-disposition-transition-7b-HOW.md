# 7b 戰後處置過渡 — HOW

> systems 2026-10-16。
> WHAT：藍圖信 2026-10-15-blueprint-to-systems-RULING-massacre-disposition-form-siege-assault-map-enlarge §一「第 7 張過渡」＋藍圖 2026-10-16 確認（過渡期記名同尺＝殺，走戰鬥陣亡同一出口；2.5 再變逐列可選）。
> 狀態：R² ISSUES（2026-10-16-reviewer-to-systems-R2-aftermath-disposition-transition-7b-ISSUES）M1–M4＋排序已補；審查註明補完不需再審 ⇒ GO。
> 位置：玩家可見批，第 7 張（b35535bfa）正後面、你領導的勢力之前。
> 關 known_issues「刪隊時隊上記名的人不會被處理，稽核也看不到」（條件見 §驗收 B4）。

## 現況（main b35535bfa，file:line 本輪已讀）
- 屠村 `encounter_system.gd:1693 _massacre_residents`：易主 → 隊長＋活記名逐人 `remove_member`（命運＝散，team_id＝-1）→ 公庫與資源轉攻方 → 仇 → `erase_team`。回 `{killed: 匿名數, scattered: [名字], team_id}`。
- 強佔 `:1723 _force_occupy`：易主 → `kill_random(resident, 兩成, "occupy")`。兩成沒有來源（藍圖）。
- 戰鬥記名陣亡出口：`resolve_encounter_end` 內 `:1254-1262` 三行 inline——`dp.is_dead = true`、`state.remove_member(t, pid, false)`（team_id 留，同 famine 留屍）、是隊長則 `t.leader_id = -1`。**不是函式**。
- 玩家句：`player_command_system.gd:789-795`「你下令屠村：Team%d 的 %d 人被殺，X 逃散，據點易主」；強佔回「強佔」。
- NPC 攻方：`_process_occupied_residents`（:1640）NPC 那條走 `_find_prey_outpost`，第 7 張沒改 ⇒ 仍休眠（床 A10 有休眠對照格）。屠村／強佔函式是兩條路共用的 static。
- 稽核：`invariant_audit.gd:103-112` 反向檢查遇 `state.teams.get(p.team_id) == null` 直接 `continue`（註解「由 remove_member 語意保證不生」）。headless 與 scripted_exploration 都會跑 InvariantAudit。
- `erase_team`／`erase_teams` 的非床呼叫點（本輪 grep）：屠村（encounter_system.gd:1716）、獸隊清除（beast_system.gd:56）、滅團批次（faction_ai_system.gd:5247 `cleanup_extinct_teams`）、子隊併回（subteam_system.gd:233）。後三條是否都先處理了記名，**沒逐條驗**——交給 §四 的稽核去照。

## 改法

### 一、記名陣亡一個出口
- 把 `:1254-1263` 的動作抽成 `EncounterSystem.kill_named(state, t, pid) -> String`（R² M4，讓「行為逐字不變」為真）：
  - dp 存在且未死 ⇒ `dp.is_dead = true`、`remove_member(t, pid, false)`、是隊長則 `t.leader_id = -1`，回名字。
  - **dp == null ⇒ 仍 `remove_member`（清名冊裡的懸空 pid，同現況 :1262），不標死，回空字串。**
  - **不碰 am**：`dead_named` 記帳（:1261）留在 `resolve_encounter_end` 呼叫端，條件照舊「dp != null and am["sides"].has(tid)」，用回傳的名字記。屠村沒有 am，不寫。
  - 呼叫端的守衛三行（person_id == -1、not is_dead(u)、t 存在）留在呼叫端。
- 不另寫第二份；屠村呼同一支。
- 屠村的 `if resident.leader_id != -1: set_leader(-1)`（:1705-1706）因 kill_named 已清而冗餘，可刪（Bug10／feud 兩格的 resident 無記名，不受影響）。

### 二、屠村：記名全殺
- `_massacre_residents` 的逐人迴圈改呼 `kill_named`（取代 `remove_member` 散）。對象＝隊長＋活的記名成員。
- 回傳改 `{killed_anon, killed_named: [名字], team_id}`；拿掉 `scattered`、`killed`。
  - ★呼叫端 `player_command_system.gd:788-791` 同 commit 改讀新 key（R² M1）：舊 key 用 `get(key, 0)` 讀會靜默變 0／空，句子悄悄說「0 人被殺」而不報錯——B1 句子格（人數＝匿名＋記名、含每個名字）咬的就是這個。
- 隊長也死 ⇒ 不走繼位（隊緊接著被 erase）。
- 死者 `team_id` 留著指向已刪的隊＝留屍（同戰死、饑荒）；稽核反向檢查跳過 `is_dead`，不受 §四 影響。
- 順序不變：殺記名 → 轉資產 → 仇 → erase。

### 三、強佔：改「易主＋居民留」
- `_force_occupy` 拿掉 `kill_random` 那兩行，只留易主。print 改「據點易主，居民留下」。
- 選項名不改（「強佔」照舊，動作 id `residents_seize` 不變，盤點常數不動）。
- ★同 commit 改舊床：`headless_test.gd:9816-9826` `_test_occupy_force`（Task6d）斷言「pop 10→8」與標題「強佔 pop-20%」改成「人口不變（10）」——它直呼 NPC 分支，所以一定會紅；改的是被藍圖裁掉的那個值，不是放寬。

### 四、稽核：懸空 team_id 的活人算違規
- `invariant_audit.gd` 反向檢查：`t == null` 時改 append 違規「懸空 P%d team_id=%d 隊已不存在（活人）」，不再 `continue`。註解改寫成現在的事實（保證是靠這一格，不是靠 remove_member 的語意）。
- 這是改既有守衛的判準，不是新閘。
- ★**排序（R² 第 1 問）**：這一刀**單獨先 commit、先跑一輪電池**，再落一、二、三、五。紅＝存量（之前被 continue 吞掉），與 7b 無關；綠之後再落其餘，之後若紅才是 7b 造的。兩輪電池的 run-id 都寫交件信。
- ★電池若因此在別的路紅（滅團批次、子隊併回、獸隊）：**不在本票修、不放寬**。交件信列出哪支床、哪個 P、隊是怎麼沒的，我判。

### 五、玩家句照實
- 屠村：「你下令屠村：Team{N} 的 {a} 人被殺（含 {名字、名字}），據點易主」。沒有記名 ⇒ 不印括號。
  - {a}＝匿名＋記名合計。
- 強佔：「據點易主，Team{N} 的 {p} 人留在原地」。

## 驗收（加進 battle_aftermath 床；註冊表那一列不動）
- B1 屠村記名全死：佈置被屠隊有隊長＋≥2 名活記名（地板格印人數）⇒ 每人 `is_dead`；`state.persons` 中活人懸空 team_id＝0；句子含每個記名名字、人數＝匿名＋記名。
  - A10 既有「活人懸空＝0」格（:778）保留（它現在由殺達成，不是散）。
  - ★同 commit 改 A10 句子格 `battle_aftermath_bed.gd:779-780`（R² M1）：「含逃散」換成「含被殺＋（有記名時）每個記名名字」；保留「開頭你下令屠村」「含據點易主」「不含戰」。改的是被藍圖裁掉的那個值（散→殺），不是放寬。
  - 佈置要 ≥2 名活記名：確認 `_resident_setup` 生得出，不行就 B1 另佈置；地板格印實際人數。
- B2 強佔不殺：記錄居民隊 `population` 前後相等、隊仍在、據點屬主＝玩家；句子含「留在原地」。
- B3 記名出口同一支：戰鬥陣亡的既有格照綠（A 系列不改斷言）。
- B4 稽核會紅：床內造一個活人、team_id 指向不存在的隊 ⇒ `InvariantAudit` 回的違規含「懸空」（陽性對照）；刪掉那個人 ⇒ 0。
  - known_issues 該條的結案條件＝本票電池全綠 **且四條 erase 路在電池世界裡都真的走過**（R² M2；綠也可能是路沒走到）。交件信印各路進場次數，只讀既有計數、不加 Probe 鍵：
    - 滅團＝`extinct.team.*` 各鍵；批次＝`erase.batches`／`erase.teams_erased`；子隊併回＝「[Merge] 完全合併」行數；獸隊＝`[BeastHunt]` 行數。
    - 任一條為 0 ⇒ 該條不算審過，known_issues 條目改寫成只剩那幾條，不結案。若有紅，同樣改寫成紅的那幾條。
- B5 NPC 仍休眠：A10 休眠對照格照綠；world-fp **不換基準**（NPC 路沒開、強佔與屠村只在玩家路被走到）。若 world-fp 變了 ⇒ 停下回報，不換。
  - ★fp 不變也可能只是「路沒走到」（R² M3）：交件信印電池各世界 `res.seen`、`res.npc_massacre`、`res.npc_force` 總和（既有鍵，encounter_system.gd:1652／1681／1687）。全 0 ⇒「fp 不變」才等於休眠；>0 ⇒ fp 照理會變（兩成沒了），停下回報。
  - 靜態直呼點只有 headless 合成 state（Task6a-d、Bug10、feud 整合；R² 第 2 問已 grep），不進 world-fp。

### 負對照
| 對照 | 該紅 |
|---|---|
| n1 屠村迴圈改回 `remove_member`（散） | B1 `is_dead` 格、句子格 |
| n2 `_force_occupy` 放回兩成 `kill_random` | B2 人口格 |
| n3 稽核改回 `continue` | B4 |
| n4 `resolve_encounter_end` 不呼 `kill_named`、改成只 `remove_member` | B3（A 系列記名戰死格）——★先確認 A 系列真有斷言 `is_dead`／`dead_named`；沒有就補一格，否則 n4 是預期綠的對照 |

## 範圍外
- 戰後處置單逐列可選（殺／俘／放）：2.5。
- 居民＝「以此為家」：圍城那張加 home 欄位；過渡閘照第 7 張。
- 屠村消息走傳播、隊內反應：社交層。
- NPC 路開路（過決策引擎）：等用戶定，known_issues S3 歸那裡。

## 交件信要列
- `kill_named` 的位置與兩個呼叫點。
- B1 實跑句子逐字。
- B4 電池結果：四條 erase 路有沒有產生懸空活人（有就列）。
- world-fp 新舊值（應相同）＋B5 三個 res.* 總和。
- 稽核先落那一輪與全量那一輪的電池 run-id；四條 erase 路進場次數。
- 屠村前後 `len(state.persons)`（留屍累積可見；health_system.gd:210 對留屍每 tick 仍跑血量迴圈，既有成本，不在本票）。
- n1–n4 紅燈原文。
