# 全員在場（隊上全部人都在戰場上）— HOW

- WHAT：藍圖票 `docs/superpowers/handbacks/2026-10-17-blueprint-to-systems-TICKET-tail-fixes-2-and-all-hands-on-field-pulled-forward.md` 票二（用戶裁 2026-10-14：上限 50／按比例／死了再補／先記名再高階匿名）；連帶 `2026-10-15-blueprint-to-systems-ADDENDUM-combat-model-spawn-band-units-silently-dropped-and-siege-layout.md`（出生帶、不准靜默掉人、預留圍城場型）。意圖帳 `docs/mechanism-intents.md:113`。
- 排序：跳窗報價之後（progress 板）。本張提前寫；file:line 在 main `ab0d31b55` 上讀，動工前重對（小修二會動 `encounter_view`、`encounter_system:1547` 附近）。
- 範圍：只動**戰術遭遇戰**（`EncounterSystem`，玩家參與的仗＋玩家被猛獸伏擊）。NPC 對 NPC 的抽象戰（`NpcCombatSystem`）不動——三軸戰力、坐騎、NPC 公式不乘武裝比，都留在深層批「戰鬥模型落地」原票。
- 呼叫者（全是有玩家的仗）：`player_command_system.gd:1022/1254/1780/1804`、`ambush_system.gd:62`（只在玩家隊時）。⇒ world-fp 預期不變（那一趟沒有玩家）。

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
  - 超過 ⇒ 按名冊數比例分：`n_atk = round(50 × 攻名冊 ÷ 合計)`，夾在 [1, 攻名冊]，`n_def = 50 − n_atk` 再夾在 [1, 守名冊]；夾掉的餘額回給另一方（仍不超過名冊）。
  - 分配一次定在開戰；之後只補不重分。
- **入場序**：隊長 → 記名（`named_members` 順序）→ 匿名。前 `n` 個上場，其餘進**場外隊列**。
  - 「高階匿名先」：今天匿名單位在場上**沒有各自的階**（`_create_anon_unit` 讀的是全隊平均戰鬥技能 `:168`，死亡由結算時 `kill_random` 依求生權重抽，`health_system.gd:181`），排序對結果沒有作用。單位帶自己的階屬深層批原票（意圖帳 :113「單位帶自己的階、死傷記在該階」）；本張照「記名先」，匿名之間不排。見誠實限。
- **武器**：上場與有武器分開。
  - 記名：照今天 `_init_named_unit`（個人裝備＋池）。
  - 匿名：這一方本場可發的武器數＝`min(round(匿名總數 × armed_anon_ratio), 庫存)`；`_assign_anon_weapons` 對**入場的匿名**依序發，發完的後面空手。⇒ 玩家的「武裝比例」（R 鍵）照舊表示「幾成的人拿武器」。
  - 場外的人沒領武器；補進場那一刻才發（同一個額度、同一支函式），歸還走今天的 `_sync_back_units`／`_return_pool_equipment`。
- `anon_spawn_count`（`:1076`）拆成兩支，讀者逐一改：
  - `field_roster(state, team) -> Array`：名冊（上一節）。
  - `anon_armed_count(team) -> int`：上面的武器數。`armed_on_field`（`:1081`，顧問 `advisor_system.gd:101` 讀）改成「記名＋`anon_armed_count`」——它問的是武裝數，不是上場數。
  - `ARMED_RATIO_FLOOR` 在本檔刪除；`NpcCombatSystem:708` 那一份不動（深層批）。

## 三、出生區（一個場型給一組出生區）

- 新一支 `_spawn_zone(layout: String, side: int) -> Array[Vector2i]`，取代 `_get_spawn_positions` 與追擊戰那 5 格。
  - `"field"`：攻方＝上半三條邊（5,0,1）半徑 7、8、9 三圈的聯集；守方＝下半（2,3,4）同三圈。兩方都有的格（角）兩方都不給。
  - `"pursuit"`：守方＝中央半徑 ≤ 4 的圓盤（61 格）；攻方＝`_get_pursuit_entry_edges` 那三條邊、半徑 7–9 三圈。
    - ADDENDUM 寫 2–3（19–37 格）；但比例分配下守方最多可到 49 人，37 格會再掉人 ⇒ 取 4。這是容量算術，不是設計改動。
  - 預留 `"siege"`：本張**不實作**；`_spawn_zone` 的 `match` 寫一行 `"siege": push_error("圍城場型未實作")`，讓圍城那張只加一個分支。
- 容量斷言：每個場型每一方的格數 ≥ `FIELD_CAP`（床格，不在執行時檢查）。
- 位置順序：出生區內 `shuffle()`（同今天，有玩家的世界才走到）。
- **不准靜默掉人**：`_spawn_team_units` 拿到的位置數 < 要上場數 ⇒ `push_error` ＋ `Probe.bump("encounter.spawn.short")`，**而且**沒上場的人進場外隊列（不消失）。`break` 那兩行刪掉。

## 四、場外隊列與補人

- `state.encounter_queue: Dictionary`（team_id → `{"named": [pid…], "anon": int}`）。`init_encounter` 建、`cleanup_encounter` 清。不存檔（遭遇戰本身不跨存檔——動工時驗一句；若跨，加進存檔）。
- **只補死人**（WHAT「死了從場外補」）：每個遭遇 tick 結尾（`advance_encounter_tick`，在 `_check_prisoners`／`_check_rescues` 之後、勝負判定之前），每一方：
  - 場上活著（`not is_dead`、未 `has_exited`、非俘虜）的數 < 開戰時分到的 n，且隊列非空 ⇒ 補到 n，先記名後匿名。
  - 位置：自己出生區裡沒人站的格，依離己方出生區中心的距離排序取第一個（不耗 RNG）。沒有空格 ⇒ 本 tick 不補，`Probe.bump("encounter.reinforce.no_slot")`。
  - 撤退中不補：這一方已觸發整隊撤退（`_should_retreat` 那條）⇒ 不補，隊列跟著撤。
  - 每補一人發一句戰報：「Team X 的 N 人從場外補上」（同 tick 合併一句）。
- **勝負判定**（`:904-911`）：`_has_active_units` 為假但隊列非空 ⇒ 不算沒人；先補，補不進（沒空格）才照原判。`_all_exited` 不看隊列（整隊撤＝隊列一起走）。
- **結算**（藍圖裁甲 `2026-10-18-blueprint-to-systems-RULING-all-hands-queue-reserve-not-liable-casualties-only-on-field.md`）：
  - **場外排隊、從沒上場的人不連坐**，死傷只算場上的。場外的人要死，得有人追到他們（追擊／潰退那條物理），不在結算時按比例抹掉。
  - ⇒ 「後備連坐」的理由（只有一部分人上場、後備就在旁邊）在全員在場後消失：`_apply_reserve_casualty`（`:1185`）與 `RESERVE_CASUALTY_MULT`（`:5`）在遭遇戰路徑刪除，呼叫點一起拿掉；實作端 grep 全部讀者列在交件信。
  - 小修二 A3 的「後備陣亡」欄之後恆 0：照 A3「只印非 0 欄」的規則它自然不出現；若 A3 印的是固定六欄，把那一欄拿掉，對帳式少一項（交件信寫走哪支）。

## 五、畫面

- 戰鬥畫面頂列每一方加「場上 X｜場外 Y」（Y=0 不印）。讀 `encounter_queue` 與 `encounter_units`，產生者一支（`encounter_view`）。
- 開戰那一句（`init_encounter` 的戰報）寫實際上場數：「你方 7 人全部上場」／「你方 30 人上場、12 人在場外」。

## 六、tap

`encounter.roster_mismatch`、`encounter.spawn.short`、`encounter.field.n.atk|def`（分配數）、`encounter.queue.size.atk|def`、`encounter.reinforce.n`、`encounter.reinforce.no_slot`、`encounter.unarmed_on_field`（空手上場的人數）。

---

## 驗收

- 新床 `scripts/debug/all_hands_on_field_bed.gd`，閘列 `all-hands-on-field`，expect `=== all_hands_on_field DONE === errors: 0`。

| 格 | 斷言 |
|---|---|
| H1 | 7 人隊（1 記名＋6 匿名、武裝比 0、無武器）對 9 人隊 ⇒ 場上 7＋9＝16 單位；我方 6 個匿名空手；`unarmed_on_field`=6 |
| H2 | 40 對 40 ⇒ 場上 25／25、隊列 15／15；殺掉我方 3 人 ⇒ 下一 tick 補 3、隊列 12；補進的人位置在己方出生區 |
| H3 | 45 對 5 ⇒ 45／5（比例）；60 對 20 ⇒ 38／12（四捨五入＋夾）；每格印分配與名冊 |
| H4 | 追擊戰守方 30 人 ⇒ 30 全在中央圓盤內；`spawn.short`=0 |
| H5 | 容量：`field`／`pursuit` 每方格數 ≥ 50；兩方出生區交集＝空 |
| H6 | 每場：上場名單數＝場上單位數（兩方各一次，含 50 滿額那場、含補人後）；`spawn.short`=0、`roster_mismatch`=0（或交件信列出差額來源） |
| H7 | 勝負：一方場上全倒而隊列非空 ⇒ 不結束、補人；整隊撤退 ⇒ 不補、照撤退結算 |
| H8 | 武器：匿名 20、武裝比 0.5、庫存 6 ⇒ 6 人有武器；庫存 30 ⇒ 10 人；場外補進的人在額度內才有武器；戰後武器帳守恆（發出＝歸還＋陣亡損失） |
| H9 | 顧問估己方武裝（`armed_on_field`）＝記名＋`anon_armed_count`，不是上場數 |
| H10 | 猛獸伏擊玩家 ⇒ 猛獸照舊（`_spawn_beast_units` 不動）、玩家方全員上場 |
| H12 | 超過 50 的仗打完、隊列還有人 ⇒ 隊列的人一個不少（不連坐）；`_apply_reserve_casualty` grep＝0 |
| H11 | 畫面：頂列「場上 X｜場外 Y」與真值一致；開戰句寫實際數 |

- 母體地板：H2 的補人格要先證「真的有人死」（我方死亡 ≥1），否則不算數。
- 負對照：
  - n1：出生區改回半徑 8 單圈 ⇒ H6 的 `spawn.short`>0（而且隊列收到那些人——證明不再靜默）
  - n2：拿掉補人 ⇒ H2 隊列不減、紅
  - n3：勝負判定不看隊列 ⇒ H7 紅
  - n4：分配改成各 25 ⇒ H3 紅
  - n5：上場數改回乘武裝比 ⇒ H1 紅
- world-fp：照常跑閘，預期不變（無玩家）；變了歸因第一個分歧 tick。
- 舊床遷移（交件信逐一列修前／修後）：會被改變的有——依上場數斷言的戰鬥床、`aftermath`／小修二 A3 的床（我方六欄數字會變大）、顧問床（`armed_on_field`）。實作端先 grep `anon_spawn_count`／`ARMED_RATIO_FLOOR`／`SPAWN_RADIUS`／`_get_spawn_positions` 的全部讀者列表。
- 驗收後 QA 真玩：同一 seed 第一局那場仗，7 人全部站上場（WHAT 驗收）。

## 誠實限

- 匿名在場上沒有各自的階 ⇒「高階匿名先上」本張做不到有意義的排序；等深層批「單位帶自己的階」。
- 空手的人今天怎麼打照現行 `resolve_attack`（不改傷害）；「平民空手近零」屬深層批三軸。
- 50 人的仗戰術 tick 變慢：交件附 40 對 40 一場的每 tick 耗時（修前 30 人上限那場對照）。
