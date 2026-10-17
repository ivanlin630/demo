---
from: reviewer
to: systems
status: consumed
slice: 全員在場
topic: R² VERDICT＝ISSUES（5 條 must-fix：M1–M5；小項 S1–S8）。靜態讀 code（main ab0d31b55 一帶），沒跑測試。
---

# 一、你問的七點，先答

| 點 | 答 | 依據 |
|---|---|---|
| 1 呼叫者 | 五處成立，但**追擊戰的分支沒有任何 production 呼叫者**（M4） | `init_encounter(` 非 debug 呼叫：`player_command_system.gd:1022/1254/1780/1804`、`ambush_system.gd:62`；全部傳 `"normal"`。字串 `"pursuit"` 在非 debug 只出現在 `encounter_system.gd:246`（分支本身）、`:1549`、`player_command_system.gd:700/780`（那兩個是戰後追擊命運，不是 combat_type）、`npc_combat_system.gd:832`（TODO 註解「接入後設 combat_type = pursuit」）。1780/1804 來自 `player_pre_encounter`（只由玩家分支寫），`ambush_system:62` 有 `leader.id == player_id` 守衛 ⇒ world-fp 不變的前提成立 |
| 2 名冊對 `population` | 結構上可能不等，只報不改可以；見 S4 | `team_data.gd:120-122`：`population`＝(`leader_id != -1`) ＋ `named_members.size()` ＋ `AnonCohort.total`。名冊的「活著的記名」＝`_spawn_team_units` 跳過 `persons.get(pid)==null`（`:1096-1097`）的那批 ⇒ 兩者差在「`named_members` 裡 person 不存在／已死」或「領袖 id 在 named 裡重複」。靜態讀不出母體有幾個，所以 H6 要在真世界走查印分佈，別只在 fixture 斷言 0 |
| 3 武裝數讀者 | 沒有別的讀者讀 `anon_spawn_count`（只有 `:1086`、`:1104`）；但「武裝數」有四份定義，見 S3 | grep `armed_anon_ratio`／`armed_on_field` |
| 4 追擊守方半徑 4 | 容量算術對（37 格＜49），但整條路沒人走（M4）；若要留，用「最小夠用的半徑」 | `3r²+3r+1`：r=3→37、r=4→61 |
| 5 會不會永不結束 | **會**，一個構造：場上全部活著但失能、隊列非空（M1） | `:904-912`、`:918-925` |
| 6 連坐 | 已被藍圖裁甲取代（刪除，spec 97d059175）；我針對舊公式的發現撤回，新的要求見 M5 | `:1185-1196`、`:1243-1256` |
| 7 n1–n5 | n1–n5 各自能紅；缺的刀見 M1／M2／M3 | 見下 |

# 二、must-fix

## M1 補人觸發與勝負判定：會補到撤退的人、也會卡死
- **公式與敘述矛盾**：§四寫「只補死人、撤退不補」，但觸發式是「場上活著（`not is_dead`、未 `has_exited`、非俘虜）的數 < n」。個別單位撤退走的是 `has_exited = true`（`:880-885`，`_should_retreat` 在重傷或隊失能比例時是**單位級**判斷，`:348-357`），俘虜走 `is_prisoner`。⇒ 照式子，撤出去的、被俘的都算「不在場上」而被補，與「撤退不補」相反。
- **「整隊撤退」沒有旗標**：`_should_retreat` 每次行動重算（`team_incapable_ratio > RETREAT_TEAM_RATIO`，`:350`），沒有隊級狀態可讀。spec 的「這一方已觸發整隊撤退 ⇒ 不補」要指定一個謂詞（例如 tick 尾算 `_calc_team_incapable_ratio > RETREAT_TEAM_RATIO`）。注意該比例的分母只有場上單位（`:377-385`），補人會稀釋比例、失能的人留在場上（死的不會被移除）會墊高比例，兩者都會讓比例跳。
- **卡死構造（回答你的第 5 點）**：勝負式 `:909-911` 在 `_has_active_units` 為假時判負。`_has_active_units` 要 `is_combat_capable`（`:918-925`），失能（重傷未死）不算。spec 新規「`_has_active_units` 為假但隊列非空 ⇒ 不算沒人、先補，補不進才照原判」：若一方場上全是**活著但失能**的人，沒有死人 ⇒ 觸發式不補（人數沒少）⇒ 又因隊列非空而不判負；對方若也同狀態（或打不到），整場永遠 `ongoing`。補人本身不會無限（隊列有限），卡的是「不補也不判」。
- 要求：
  1. 觸發改成明確的集合：缺額＝`n − (場上單位中非死者)`，只補「死」；寫明失能、撤出、被俘各自算不算（我建議：撤出與被俘不補、失能不補）。
  2. 「隊列非空 ⇒ 不判負」限定為**這一 tick 實際補進了人**；沒補進就照原判（保證每個 tick 要嘛消耗隊列、要嘛照舊結算，終止性可論證）。寫成一句話放在 spec。
  3. 整隊撤退用明確謂詞；寫比例分母的取法（場上全部、含失能者）。
  4. 驗收 H7 加格：(a) 場上全失能（活著）、隊列非空 ⇒ 該場在有限 tick 內結束；(b) 個別單位撤出 ⇒ 隊列不減；(c) 被俘 ⇒ 隊列不減。負對照 n6：觸發式改回「活著的數＜n」⇒ (b) 紅。
  5. 補人的位置「沒人站的格」要與移動佔位同一個定義：死的、已離場的不算佔位（`:870-874`）。寫明。

## M2 感知鐵律：敵方的「場外」人數與補人戰報會洩漏對方後備
- §五：頂列「每一方加『場上 X｜場外 Y』」；§四：「每補一人發一句戰報：『Team X 的 N 人從場外補上』」，「每一方」。對方的隊列大小是玩家看不到的資訊（對方有多少人在後面）；現行戰報刻意只記我方：`advance_encounter_tick` 的 `:887-888` 註解寫「敵方的移動看得到的已畫在地圖上，看不到的不能寫進戰報（感知鐵律）」。
- 要求：場外數與補人句**只對玩家方**；敵方只顯示場上可見的單位（已畫在地圖上的）。開戰句已寫「你方」沒問題。驗收 H11 加格：同一 fixture 只改敵方隊列大小（例如敵方名冊 60 vs 200）⇒ 玩家可見的頂列、戰報、事件字串逐字相同。負對照 n7：頂列讀敵方 `encounter_queue` ⇒ 該格紅。

## M3 玩家單位一定要在場上；H10 與上限相衝
- 入場序「隊長 → 記名（`named_members` 順序）→ 匿名」，前 n 個上場。n 由比例分配決定，可以小於記名數（例：名冊 100 對 20 ⇒ 守方 8，若守方有 12 個記名，4 個記名在隊列）。玩家的 `person_id`（`state.player_id`）若不是領袖、排在 `named_members` 後段，會被留在場外；`advance_encounter_tick` 的玩家回合（`:846-850`）找不到該單位 ⇒ 玩家沒有回合，整場自動跑。今天因為記名全上（位置不足才掉），這個洞不存在。
- 要求：入場序最前面放「玩家本人（若在名冊）」，再隊長，再記名；n 的下限＝玩家方 `max(1, 含玩家)`。驗收加格：名冊 100 對 20 且玩家為排在後段的記名 ⇒ 玩家在場上。負對照 n8：拿掉玩家優先 ⇒ 該格紅。
- H10：「猛獸伏擊玩家 ⇒ 玩家方全員上場」。若玩家方名冊＞ 50 − 獸數，與 `FIELD_CAP` 相衝。請寫明猛獸算不算進 50（`_spawn_beast_units` 不動，`:1124-1142`，獸數是 `team.population`，與名冊無關），以及玩家方上限怎麼算；H10 的「全員」改成「在上限內全員」。

## M4 追擊戰分支沒有 production 呼叫者
- `combat_type == "pursuit"` 只在 `encounter_system.gd:246`；五個 production 呼叫者全傳 `"normal"`；`npc_combat_system.gd:832` 的 TODO 寫「接入 `_try_interact`，返回 true 時設 combat_type = pursuit」，還沒接。⇒ §三的追擊出生區、H4、半徑 4 vs ADDENDUM 的 2–3，都是為一條走不到的路寫的。
- 要求（二擇一，HOW 內）：(a) 明寫「追擊戰場型目前無入口，本張以單元床直呼 `init_encounter(..., "pursuit")` 驗證，標 latent」，H4 的 fixture 就是這個直呼；半徑改成「最小夠用的半徑」（`3r²+3r+1 ≥ n_def` 的最小 r，上限 4），保住 ADDENDUM 的 2–3 意圖，不是固定 4；(b) 本張不動追擊分支，只在 §三留 `"pursuit"` 的 `match` 一行 push_error 與註解。不論哪個，第 1 點「呼叫者全是有玩家的仗」那一句要改成附上「追擊分支無呼叫者」的 grep 結論。
- 注意：ADDENDUM 是藍圖的文，半徑 2–3 與 4 的差異即使在無入口的分支，也請在交件信告知藍圖。

## M5 （依 spec 97d059175 更新）刪除後備連坐：H12 與舊床要寫穩
- 我原本的 M5（`reserve` 公式少算 `dead_anon`）已被藍圖裁甲取代：`_apply_reserve_casualty` 與 `RESERVE_CASUALTY_MULT` 在遭遇戰路徑刪除（spec §四），我原先針對現行公式的發現不再適用，撤回。留作記錄：被刪的公式少算 `dead_anon`（`:1253` 先於 `:1256`），不必修。
- 新的要求：
  - **H12 的斷言要有基準**：「隊列的人一個不少」請寫成可算的式子：戰後 `AnonCohort.total` ＝ 戰前 ＋ 0 − 場上匿名死亡 − 戰後命運（`fate_killed`／`pursuit_killed`）欄；並要求該場是「> 50 且打完隊列仍有人」（母體地板：隊列剩下 ≥1，否則 H12 只在沒有東西可連坐的場上綠）。負對照 n9：把 `_apply_reserve_casualty` 呼叫放回 ⇒ H12 紅。
  - **唯一讀者**：非 debug 的 `_apply_reserve_casualty` 呼叫只有 `:1256`；`combat_reserve` 這個 kill reason 在 scripts 只被它自己寫、沒有讀者；`headless_test.gd:14619-14627` 的床直接呼叫 `_apply_reserve_casualty`（斷言連坐有發生）——那是在驗被刪的行為，必須改寫成 H12 同型的反向斷言或刪除，列入遷移表（原 S6）。
  - **A3 的關係**：小修二 A3 還沒進 code（`reserve_dead` 目前只在 spec）。排序是小修二先、全員在場後，兩者落地後 A3 的「後備陣亡」恆 0。spec 已寫「只印非 0 欄」或拿掉一項，請交件信明寫走哪支，並在 A3 對帳式的床補一格「全員在場後對帳式仍成立」。

# 三、小項（不擋，併同輪）
- **S1 比例分配的後果請告知藍圖**：總名冊＞50 時比例分配會讓小隊也不全員上場。例：100 對 3 ⇒ 攻 `round(50×100/103)=49`、守 `50−49=1`（夾到 [1,3]）⇒ 3 人的小隊只有 1 人在場上、2 人在隊列，而場上只有 50 個位置。這是用戶裁定「按比例」的直接後果，不是 bug；請交件信印這種場並問藍圖要不要「小隊先滿額」。
- **S2 武器額度定義**：§二「`min(round(匿名總數×ratio), 庫存)`」。`armed_anon_ratio` 本來就是 `EquipmentSystem` 依庫存算的（`equipment_system.gd:65`），再取庫存是重複。更要緊：額度是「累計發出數」還是「目前持武的活人數」？戰中死去的持武者的武器要到戰後才歸還（`_return_pool_equipment`／`_sync_back_units`），所以補人時應用累計數，否則會超發。請寫明，H8 加「死後補進者不得超額」。
- **S3 武裝數四份定義**：`player_api_mapper.gd:228-232`、`npc_combat_system.gd:242`、`faction_ai_system.gd:5243` 都是「記名＋round(匿名×ratio)」（無庫存夾、無下限）；新的 `armed_on_field` 又一份（含庫存夾）。顧問讀的是新的，玩家面板讀 mapper 那份，兩者會在庫存不足時不一致。請 `anon_armed_count` 與 mapper 共用一支，或誠實限寫明差異。
- **S4 名冊與人口**：H6 的 `roster_mismatch=0` 在 fixture 容易達成；請在交件前用真世界一場玩家仗（QA 那局）印分佈，不要只信 fixture。
- **S5 效能最壞案例**：場上單位只增不減（死的留在 `encounter_units`，補人只追加），而 `_nearest_visible_enemy_index`、移動佔位（`:870-874`）、`_count_nearby_enemies` 都是對全表掃描。200 對 200 打到隊列用完，表長可到數百。誠實限只寫了 40 對 40；請交件附一個最壞案例的每 tick 耗時，或給單位表一個上限。
- **S6 舊床遷移**：除了 spec 列的，`headless_test.gd:4073-4093`（印 `ANON_UNIT_CAP` 的確認）、`:14619-14664`（「大隊 pop 遠超 ANON_UNIT_CAP → 多數 anon 未上場」的 reserve 連坐床，語意會變）、`battle_aftermath_bed.gd:114/370`、`play_client_keys_bed.gd:99`、`terminal_e2e_bed.gd:2067/2294`（用 `init_encounter` 的）。`ANON_UNIT_CAP` 本身退場時這些要跟著改。
- **S7 補人是否改索引**：`escort_target`、`pending_action.target_idx` 都是 `encounter_units` 的索引。補人只追加不重排，索引不失效——這點是對的，請在 spec 寫一句「只追加、不移除、不重排」當約束，免得實作端為了效能清死者。
- **S8 存檔**：「動工時驗一句」請落成：grep 存檔序列化是否含 `encounter_units`；`state_fingerprint.gd` 無 `encounter_*` 命中（我已查），所以隊列不進 fp 成立。

# 四、結論與下一站
- 判定：**ISSUES**。M1–M5 都在 HOW 內，無需藍圖裁決（S1、M4 的半徑差異是「告知」）。
- 修完回 R²b，只審 M1–M5 對應段＋S1–S8 有沒有收。
- 實作排在跳窗報價之後，不急。
- 沒重審：A3 與小修二已 CLEAN 的段。
