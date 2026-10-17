# 全員在場（隊上全部人都在戰場上）— HOW（定稿：R² M1–M5／S1–S8、R²b N1–N2／T1–T2、R²c CLEAN＋C1–C3）

- 審查：R² `docs/superpowers/handbacks/2026-10-18-reviewer-to-systems-R2-all-hands-on-field-ISSUES.md`。

- WHAT：藍圖票 `docs/superpowers/handbacks/2026-10-17-blueprint-to-systems-TICKET-tail-fixes-2-and-all-hands-on-field-pulled-forward.md` 票二（用戶裁 2026-10-14：上限 50／按比例／死了再補／先記名再高階匿名）；連帶 `2026-10-15-blueprint-to-systems-ADDENDUM-combat-model-spawn-band-units-silently-dropped-and-siege-layout.md`（出生帶、不准靜默掉人、預留圍城場型）。意圖帳 `docs/mechanism-intents.md:113`。
- 排序：跳窗報價之後（progress 板）。本張提前寫；file:line 在 main `ab0d31b55` 上讀，動工前重對（小修二會動 `encounter_view`、`encounter_system:1547` 附近）。
- 範圍：只動**戰術遭遇戰**（`EncounterSystem`，玩家參與的仗＋玩家被猛獸伏擊）。NPC 對 NPC 的抽象戰（`NpcCombatSystem`）不動——三軸戰力、坐騎、NPC 公式不乘武裝比，都留在深層批「戰鬥模型落地」原票。
- 呼叫者（全是有玩家的仗）：`player_command_system.gd:1022/1254/1780/1804`、`ambush_system.gd:62`（只在玩家隊時）。⇒ world-fp 預期不變（那一趟沒有玩家）。
  - 五處全傳 `"normal"`；**追擊戰分支（`combat_type == "pursuit"`，`:246`）沒有任何 production 呼叫者**（`npc_combat_system.gd:832` 只是 TODO）。本張對它的改動是 latent，以單元床直呼驗（M4，§三）。
- 遭遇戰不進 world-fp（`state_fingerprint.gd` 無 `encounter_*`，R² 已查）；存檔是否序列化 `encounter_units`：實作端 grep 存檔碼，交件信寫結論——若有，隊列一起進存檔（S8）。

---

## 一、現況（為什麼一個 7 人隊只上場幾個）

- 上場數＝隊長＋全部記名＋匿名 `min(int(人口 × max(armed_anon_ratio, 0.1)), 30)`（`encounter_system.gd:256-263`、`anon_spawn_count` `:1076-1079`）。⇒ 7 人、武裝比 0 的隊只上記名＋0 匿名。
  - `ARMED_RATIO_FLOOR`（`:6`）＝「堵 0 武裝免疫」的補丁門：它把「上場」與「有武器」綁成同一個比例。全員在場後兩件事分開，這道門在遭遇戰路徑上退場。
- 出生格：每方三條邊、半徑 8 那一圈（`_get_spawn_positions` `:202-209`），約 25 格／方；追擊戰守方只有中央 5 格（`:247-249`）。
- 位置用完就 `break`（`_spawn_team_units` `:1095`、`:1107`）：多的人不上場、不報、不算——ADDENDUM 說的靜默掉人。

## 二、名冊與分配

- **名冊**（每方）：隊長＋`named_members` 裡還活著的人，接著匿名 `AnonCohort.total(anon_cohorts)` 個。
  - 名冊數 ≠ `team.population` 時：`push_error` ＋ `Probe.bump("encounter.roster_mismatch")`，交件信印出差額與原因（俘虜、子隊等），**不改 population 的定義**。
  - 不依健康篩：今天匿名上場就不看傷，照舊（失能與否交給戰場上的 `is_combat_capable`）。
- **上限**：`FIELD_CAP = 50`（TEST VALUE，具名常數）＝雙方場上合計。
  - 雙方名冊合計 ≤ 50 ⇒ 全部上場。
  - 超過 ⇒ 一支 `field_allocation(R_atk, R_def, cap, floor) -> [n_atk, n_def]`（唯一產生者；用戶裁 2026-10-18 保底 10，`2026-10-18-blueprint-to-systems-RULING-all-hands-floor-10-then-proportional-remainder.md`）：
    - `FIELD_FLOOR = 10`（TEST VALUE，與 `FIELD_CAP` 一起調）。
    - `f_a = min(R_a, FLOOR)`、`f_b = min(R_b, FLOOR)`；剩餘格 `rem = CAP − f_a − f_b`；未上場 `l_a = R_a − f_a`、`l_b = R_b − f_b`。
    - `l_a + l_b ≤ rem` ⇒ 全上。否則先算 `l` 較大的那一方（下式以 a 代之；`l` 相等時兩方各 `floor(rem/2)`，`rem` 為奇數時多的一格給守方）：`x_a = min(roundi(rem × l_a ÷ (l_a + l_b)), l_a)`、`x_b = min(rem − x_a, l_b)`；`x_b` 被夾住時把差額還給 a：`x_a = min(l_a, rem − x_b)`。
    - `n_a = f_a + x_a`、`n_b = f_b + x_b`；總和恆 = `min(CAP, R_a + R_b)`（床斷言）。
    - 例：100 打 3 ⇒ 3／47；60 打 40 ⇒ 29／21；15 打 60 ⇒ 13／37；26 打 100 ⇒ 15／35；30 打 30 ⇒ 25／25。連續、不跳。
  - 分配一次定在開戰；之後只補不重分。
- **入場序**：**玩家本人**（`state.player_id` 若在這一方名冊）→ 隊長 → 記名（`named_members` 順序）→ 匿名。前 `n` 個上場，其餘進**場外隊列**（M3：比例分配可能讓 n 小於記名數，玩家不在場上就沒有玩家回合 `:846-850`）。
  - 玩家方的 n 下限＝1（玩家本人）。
- **猛獸**（M3）：猛獸方照 `_spawn_beast_units` 全部上場（`:1124-1142` 不動、不排隊），算進 50；玩家方 `n = clamp(50 − 猛獸數, 1, 名冊)`。
  - 有猛獸時**不走** `field_allocation`（只用這一條式子；R²b T2）。
  - 「高階匿名先」：今天匿名單位在場上**沒有各自的階**（`_create_anon_unit` 讀的是全隊平均戰鬥技能 `:168`，死亡由結算時 `kill_random` 依求生權重抽，`health_system.gd:181`），排序對結果沒有作用。單位帶自己的階屬深層批原票（意圖帳 :113「單位帶自己的階、死傷記在該階」）；本張照「記名先」，匿名之間不排。見誠實限。
- **武器**：上場與有武器分開。
  - 記名：照今天 `_init_named_unit`（個人裝備＋池）。
  - 匿名：這一方本場的武器額度＝`round(匿名總數 × armed_anon_ratio)`（`armed_anon_ratio` 已由 `EquipmentSystem` 依庫存算過，`equipment_system.gd:65`，不再另夾庫存；S2）。`_assign_anon_weapons` 對**入場的匿名**依序發，額度用完後面空手。⇒ 玩家的「武裝比例」（R 鍵）照舊表示「幾成的人拿武器」。
  - 額度是**本場累計發出數**，不是「目前持武的活人數」：戰中死去的人的武器要到戰後才歸還（`_return_pool_equipment`／`_sync_back_units`），補人時用累計數才不會超發（S2）。
  - 場外的人沒領武器；補進場那一刻才發（同一個額度、同一支函式）。
- `anon_spawn_count`（`:1076`）拆成兩支，讀者逐一改：
  - `field_roster(state, team) -> Array`：名冊（上一節）。
  - `anon_armed_count(team) -> int`：上面的武器額度。`armed_on_field`（`:1081`，顧問 `advisor_system.gd:101` 讀）改成「記名＋`anon_armed_count`」——它問的是武裝數，不是上場數。玩家面板的武裝數（`player_api_mapper.gd:228-232`）改呼叫同一支（S3）；`npc_combat_system.gd:242`、`faction_ai_system.gd:5243` 兩份不動（NPC 抽象戰，深層批），誠實限寫明。
  - `ARMED_RATIO_FLOOR` 在本檔刪除；`NpcCombatSystem:708` 那一份不動（深層批）。

## 三、出生區（一個場型給一組出生區）

- 新一支 `_spawn_zone(layout: String, side: int) -> Array[Vector2i]`，取代 `_get_spawn_positions` 與追擊戰那 5 格。
  - `"field"`：攻方＝上半三條邊（5,0,1）半徑 7、8、9 三圈的聯集；守方＝下半（2,3,4）同三圈。兩方都有的格（角）兩方都不給。
  - `"pursuit"`（**latent**：今天沒有入口，M4）：守方＝中央圓盤，半徑取**最小夠用**：`3r²+3r+1 ≥ n_def` 的最小 r，上限 4（r=2→19、3→37、4→61）——保住 ADDENDUM 2–3 的意圖，只在人多時放大；攻方＝`_get_pursuit_entry_edges` 那三條邊、半徑 7–9 三圈。以單元床直呼 `init_encounter(..., "pursuit")` 驗（H4）。
  - 預留 `"siege"`：本張**不實作**；`_spawn_zone` 的 `match` 寫一行 `"siege": push_error("圍城場型未實作")`，讓圍城那張只加一個分支。
- 容量斷言：`field` 每一方的格數 ≥ `FIELD_CAP`；`pursuit` 守方上限 61 ≥ 49（床格，不在執行時檢查）。
- 位置順序：出生區內 `shuffle()`（同今天，有玩家的世界才走到）。
- **不准靜默掉人**：`_spawn_team_units` 拿到的位置數 < 要上場數 ⇒ `push_error` ＋ `Probe.bump("encounter.spawn.short")`，**而且**沒上場的人進場外隊列（不消失）。`break` 那兩行刪掉。

## 四、場外隊列與補人

- `state.encounter_queue: Dictionary`（team_id → `{"named": [pid…], "anon": int}`）。`init_encounter` 建、`cleanup_encounter` 清。不存檔（遭遇戰本身不跨存檔——動工時驗一句；若跨，加進存檔）。
- **只補死人**（WHAT「死了從場外補」；M1）：每個遭遇 tick 結尾（`advance_encounter_tick`，在 `_check_prisoners`／`_check_rescues` 之後、勝負判定之前），每一方：
  - 缺額＝`n − 場上非死者數`。失能（活著但不能打）、撤出（`has_exited`）、被俘（`is_prisoner`）都**佔著名額、不補**；只有死的空出名額。
  - **沒有「整隊撤退就不補」這條**（R²b N1 選第三條路，改掉第二版那句）：
    - 今天 `_calc_team_incapable_ratio`（`:377-385`）的分子分母都含死者（`is_combat_capable` 對死者回 false），**不改它**（改了會動到所有遭遇戰的單位撤退）。
    - 補人在 tick 尾、下一 tick 的單位決策之前 ⇒ 補進的能戰者進分母，比例被稀釋。效果（R²c C1）：**死亡**由補人稀釋；**失能與累計傷亡不被稀釋**（失能者佔名額、不補；累計死亡約達 n 的 2.3 倍時 `d/(n+d)` 也會過 0.7），仍會觸發潰退，與隊列是否用完無關。
    - 個別單位撤出（`has_exited`）照今天，佔名額不補；整隊都撤出 ⇒ `_all_exited` 判負，隊列一起走。
    - 這是行為改變（有後備者較晚潰退），已告知藍圖。
  - 位置：自己出生區裡沒有被佔的格——佔位的定義同移動佔位（`:870-874`）：死的、已離場的不算佔位。依離己方出生區中心的距離排序取第一個（不耗 RNG）。沒有空格 ⇒ 本 tick 不補，`Probe.bump("encounter.reinforce.no_slot")`。
  - **只追加、不移除、不重排** `encounter_units`（`escort_target`、`pending_action.target_idx` 都是索引；S7）。死者留在表裡，照今天。
  - 戰報：**只對玩家方**寫「你方 N 人從場外補上」（同 tick 合併一句）。對方補進的人只會出現在地圖上（看得到的才畫，同 `:887-888` 的感知鐵律；M2）。
- **勝負判定**（`:904-911`）：`_has_active_units` 為假時，**只有這一 tick 真的補進了人**才不判負；沒補進（隊列空、撤退中、沒空格、或沒有死者空出名額）就照原判。⇒ 每個 tick 要嘛消耗隊列、要嘛照舊結算，隊列有限 ⇒ 必然終止。`_all_exited` 不看隊列（整隊撤＝隊列一起走）。
- **結算**（藍圖裁甲 `2026-10-18-blueprint-to-systems-RULING-all-hands-queue-reserve-not-liable-casualties-only-on-field.md`）：
  - **場外排隊、從沒上場的人不連坐**，死傷只算場上的。場外的人要死，得有人追到他們（追擊／潰退那條物理），不在結算時按比例抹掉。
  - ⇒ 「後備連坐」的理由（只有一部分人上場、後備就在旁邊）在全員在場後消失：`_apply_reserve_casualty`（`:1185`）與 `RESERVE_CASUALTY_MULT`（`:5`）在遭遇戰路徑刪除，呼叫點一起拿掉；實作端 grep 全部讀者列在交件信。
  - 小修二 A3 的「後備陣亡」欄之後恆 0：照 A3「只印非 0 欄」的規則它自然不出現；若 A3 印的是固定六欄，把那一欄拿掉，對帳式少一項。交件信寫走哪支（M5）。
  - 直呼被刪函式的床要改寫：`headless_test.gd:14619-14664`（「大隊 pop 遠超 ANON_UNIT_CAP ⇒ 後備連坐」）改成斷言「隊列的人不連坐」。

## 五、畫面

- 戰鬥畫面頂列**玩家方**加「場上 X｜場外 Y」（Y=0 不印）。讀 `encounter_queue` 與 `encounter_units`，產生者一支（`encounter_view`）。**對方不印場外數**——對方後面還有多少人是玩家看不到的（M2）；對方只顯示地圖上看得到的單位。
- 開戰那一句（`init_encounter` 的戰報）寫實際上場數：「你方 7 人全部上場」／「你方 30 人上場、12 人在場外」。

## 六、tap

`encounter.roster_mismatch`、`encounter.spawn.short`、`encounter.field.n.atk|def`（分配數）、`encounter.queue.size.atk|def`、`encounter.reinforce.n`、`encounter.reinforce.no_slot`、`encounter.unarmed_on_field`（空手上場的人數）。

---

## 驗收

- 新床 `scripts/debug/all_hands_on_field_bed.gd`，閘列 `all-hands-on-field`，expect `=== all_hands_on_field DONE === errors: 0`。

| 格 | 斷言 |
|---|---|
| H1 | 7 人隊（1 記名＋6 匿名、武裝比 0、無武器）對 9 人隊 ⇒ 場上 7＋9＝16 單位；我方 6 個匿名空手；`unarmed_on_field`=6 |
| H2 | 40 對 40（合計 80） ⇒ 場上 25／25、隊列 15／15；殺掉我方 3 人 ⇒ 下一 tick 補 3、隊列 12；補進的人位置在己方出生區 |
| H3 | `field_allocation` 單元格：100 打 3 ⇒ 3／47；60 打 40 ⇒ 29／21；15 打 60 ⇒ 13／37；26 打 100 ⇒ 15／35；30 打 30 ⇒ 25／25；5 打 5 ⇒ 5／5；總和＝min(50, 合計)；R_a 從 1 掃到 200、R_b 分別固定 60、10、11 時 n_a 單調不減（連續性）；對稱：`field_allocation(a,b)` 的 a 邊＝`field_allocation(b,a)` 的 b 邊（`l` 相等且 `rem` 奇數那一種除外）；每格印分配與名冊 |
| H4 | 單元床直呼 `init_encounter(..., "pursuit")`：守方 15 人 ⇒ 半徑 2 圓盤內；30 人 ⇒ 半徑 3；45 人 ⇒ 半徑 4；`spawn.short`=0 |
| H5 | 容量：`field` 每方格數 ≥ 50；`pursuit` 守方半徑 4 為 61 格；兩方出生區交集＝空 |
| H6 | 每場：上場名單數＝場上單位數（兩方各一次，含 50 滿額那場、含補人後）；`spawn.short`=0、`roster_mismatch`=0（或交件信列出差額來源） |
| H7 | 勝負：(a) 一方場上全死而隊列非空 ⇒ 不結束、補人；(b) 一方場上全失能（活著）、隊列非空 ⇒ 該 tick 不補、照原判，在有限 tick 內結束；(c) 個別單位撤出 ⇒ 隊列不減；(d) 被俘 ⇒ 隊列不減；(e) 全員撤出 ⇒ 判負、隊列不再補；(f) 全員被俘 ⇒ 結束（同 `_all_exited` 跳過俘虜，`:932`；T1）；(g) 前排死七成而隊列非空 ⇒ 補人後比例 < 0.7、不潰退；隊列用完後再死 ⇒ 比例 > 0.7、照今天潰退（印補人前後的比例）；(h) 前排**失能**七成（活著）且隊列滿 ⇒ 照今天潰退，印比例與隊列剩下數（已知後果，不是漏洞） |
| H8 | 武器：匿名 20、武裝比 0.5 ⇒ 額度 10；持武者戰死後補進的人，累計發出數不超過額度；戰後武器帳守恆（發出＝歸還＋陣亡損失） |
| H9 | 顧問估己方武裝（`armed_on_field`）＝記名＋`anon_armed_count`，不是上場數 |
| H10 | 猛獸伏擊玩家 ⇒ 猛獸照舊全上（`_spawn_beast_units` 不動）；玩家方 n＝clamp(50−猛獸數, 1, 名冊)，在上限內全員 |
| H10b | 名冊 100 對 20、玩家是排在後段的記名 ⇒ 玩家在場上、有玩家回合 |
| H11 | 畫面：玩家方頂列「場上 X｜場外 Y」與真值一致；開戰句寫實際數 |
| H11b | 感知：同一 fixture 只改敵方名冊（60 對 200）⇒ 玩家可見的頂列、戰報、事件字串逐字相同 |
| H12 | 母體地板：名冊合計 >50 且打完時玩家方隊列剩 ≥1（印剩幾人）；另三場各印自己非 0 的那一欄當地板（R²c C2）：你贏；NPC 贏且有傷兵處置（`fate_killed`／`fate_captured` ≥1，NPC 為留場方，同小修二 C3 的構造）；**玩家方輸、NPC 贏且有追擊**（`pursuit_killed` ≥1）。基準式：戰後匿名數＝戰前匿名數 − 場上死的匿名 − 場上被俘的匿名 − `fate_killed` − `fate_captured` − `pursuit_killed`（匿名部分；`_aftermath_captives_fate_pursuit` 在人口結算前扣人，R²b N2）。追擊殺的是全隊健康匿名、不分是否排過隊——那正是藍圖說的「場外的人要死，得有人追到他們」；`_apply_reserve_casualty` grep＝0 |

- 母體地板：H2 的補人格要先證「真的有人死」（我方死亡 ≥1），否則不算數。
- 負對照：
  - n1：出生區改回半徑 8 單圈 ⇒ H6 的 `spawn.short`>0（而且隊列收到那些人——證明不再靜默）
  - n2：拿掉補人 ⇒ H2 隊列不減、紅
  - n3：勝負判定不看隊列 ⇒ H7 紅
  - n4：拿掉保底（純比例）⇒ H3「100 打 3 ⇒ 3／47」紅；n4b：分配改成各 25 ⇒ H3「60 打 40」紅
  - n5：上場數改回乘武裝比 ⇒ H1 紅
  - n6：補人觸發式改回「活著的數＜n」⇒ H7(c) 紅
  - n6b：補人移到單位決策之後（比例不被稀釋）⇒ H7(g) 紅
  - n7：頂列讀敵方 `encounter_queue` ⇒ H11b 紅
  - n8：拿掉玩家優先入場 ⇒ H10b 紅
- world-fp：照常跑閘，預期不變（無玩家）；變了歸因第一個分歧 tick。
- 舊床遷移（交件信逐一列修前／修後）：依上場數斷言的戰鬥床、`aftermath`／小修二 A3 的床（我方六欄數字會變大）、顧問床（`armed_on_field`）；R² 點名的 `headless_test.gd:4073-4093`（`ANON_UNIT_CAP` 確認）、`:14619-14664`（連坐床）、`battle_aftermath_bed.gd:114/370`、`play_client_keys_bed.gd:99`、`terminal_e2e_bed.gd:2067/2294`。實作端再 grep `anon_spawn_count`／`ANON_UNIT_CAP`／`ARMED_RATIO_FLOOR`／`SPAWN_RADIUS`／`_get_spawn_positions`／`_apply_reserve_casualty` 補齊（S6）。
- 名冊對人口：除了 fixture，交件前用一場真世界的玩家仗（QA 第一局那場）印雙方名冊與 `population` 的差額分佈（S4）。
- 比例分配的小隊後果：交件信印一場 100 對 3（守方只 1 人在場）。已送藍圖問要不要「小隊先滿額」（S1）；裁定回來前照比例。
- 驗收後 QA 真玩：同一 seed 第一局那場仗，7 人全部站上場（WHAT 驗收）。

## 誠實限

- 匿名在場上沒有各自的階 ⇒「高階匿名先上」本張做不到有意義的排序；等深層批「單位帶自己的階」。
- 空手的人今天怎麼打照現行 `resolve_attack`（不改傷害）；「平民空手近零」屬深層批三軸。
- 50 人的仗戰術 tick 變慢，而且單位表只增不減（死者留著、補人追加），多處對全表掃描（`_nearest_visible_enemy_index`、移動佔位 `:870-874`、`_count_nearby_enemies`）。交件附 40 對 40 與最壞案例 200 對 200 打到隊列用完的每 tick 耗時（S5）；最壞案例若不可接受，回報再定單位表上限，不在本張自定。
- 武裝數今天有四份定義；本張把顧問與玩家面板併到 `anon_armed_count`，NPC 抽象戰那兩份（`npc_combat_system.gd:242`、`faction_ai_system.gd:5243`）不動，庫存不足時兩邊會不一致（深層批）。
- 追擊戰場型今天沒有入口（latent），只用單元床驗。
- 重傷後個別撤出、或失能留場的單位佔名額、不補 ⇒ 傷多於死的仗裡隊列會大量剩下；這是「只補死人」的後果，QA 看到「全員在場的仗隊列幾乎沒用」不是 bug（已告知藍圖：有後備者較晚潰退只對死亡成立）。
