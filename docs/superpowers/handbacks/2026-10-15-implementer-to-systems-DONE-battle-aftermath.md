---
from: implementer
to: systems
status: consumed
slice: 玩家可見批第 7 張：玩家遭遇戰戰後收尾（spec 2026-10-14-battle-aftermath-wounded-captives-pursuit-HOW）
topic: 請 merge feat/battle-aftermath 9eb616997（已併 main 152dfe5e4）｜全電池釘死 9eb616997：135／135 全綠 RC=0（run-id 272-20261015-223039）｜床 19／19 errors 0；12 個負對照全紅在該紅的格｜world-fp 換基準 4a8102d→34c2804，已證只是欄位（五區 40 點逐字相同、終局拿掉三欄 0 行不同）｜藍圖裁定＋你的 HOW 已照做｜U10b 那格綠
---

# DONE：戰後收尾

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `9eb616997`：135 支全部通過、✗ 0、BATTERY_RC=0、run-id `272-20261015-223039`；原始輸出 `docs/measurements/2026-10-15-battle-aftermath/battery-9eb616997-green.txt`（摘要 `docs/measurements/.battery/272-20261015-223039.txt`）。第一輪釘 1ed9f6b17 紅 6 支（原始輸出 `battery-1ed9f6b17-red.txt`），全修於 9eb616997；「本地多出 battle-aftermath」＝本支新註冊的床閘，尚未 push 到 origin
- ★第一輪（釘 `1ed9f6b17`，run-id `386-20261015-203018`，全文 `battery-1ed9f6b17-red.txt`）紅 6 支，全是「11 個新動作沒登進盤點」或「本分支碰到的檔」，已修（`9eb616997`）：
  - **headless**：動作 UI 覆蓋審計少 11 項 ⇒ 登 `interact-self`。
  - **ui-flow** 兩格：
    - 「last_encounter_result 已清」：我把收／棄戰利品改成只標 `loot_done`（同一份結果要留給傷兵／追擊／居民的 pending）。改成 `_mark_loot_done`：**沒有 pending ⇒ 照舊整份清掉**；有 pending 才只標。⇒ 舊行為在沒有 pending 的世界逐字不變。
    - P33「宣告 22／畫面 11」：戰後 11 項只在有 pending／有俘虜時列出 ⇒ 宣告側指名排除（同 `settle` 前例），沒有放寬計數。
  - **success-sentence** 三格：
    - 反向掃抓到 `_aftermath_pre()` 長得像前置檢查卻不在 `precheck_` 前綴下 ⇒ 改名 `precheck_aftermath_shared`。
    - `SPEC_REGISTRY_ACTIONS` 52→63（11 項）。
    - `SPEC_SUCCESS_RETURNS` 72→82：新增 10 條成功回傳，從床自己的輸出數的（`player_command_system.gd` 行 730 741 753 766 772 783 792 795 797 813）。幾支動作共用一支 helper，所以 10 不是 11。
  - **scripted-exploration**：`SPEC_ACTIONS_L2` 52→63。
  - **live-team-ratchet**：`encounter_system.gd` `_aftermath_emit` 的 `if tid >= 0 and state.teams.has(tid):` 被配到 @1597 的 `state.teams.get(tid)`，那是**另一個迴圈**的 tid 且已判 null ⇒ 偽陽，進 `teams-has-baseline.tsv`（owner implementer，on-touch，理由在列）。沒改成 `live_team()`：本行問的是「事件主詞」，被殲滅（待刪）的那一方要留在主詞裡；殲滅標待刪與本函式的先後我**沒驗**，所以不動。
  - **bed-kind**：`encounter_sim_test.gd`（不在註冊表，只改了一行註解）補 `@bed-kind: acceptance`＋slice。先宣告 diagnostic，閘說它有判決彙總行 ⇒ 改 acceptance。
  - 修完四支 Godot 閘在 aftermath worktree 重跑全綠（`fix2-*.txt`）——★那幾份跑在**未 commit 的工作樹**（[TREE] clean=NO），commit 後的版本由第二輪電池證。
- 兩輪都有探索床重寫 `docs/measurements/2026-09-30-scripted-exploration.txt`，已 checkout 還原。
- 原始輸出（main，隨本信同 commit）：`docs/measurements/2026-10-15-battle-aftermath/`

## commit（branch feat/battle-aftermath，first-parent）
| sha | 內容 |
|---|---|
| 0138fe589 | 普查床（diagnostic）：NPC 世界 3 seed × 30 天 |
| d538a3cbb | 2c 前半：`captive_room` 容量一支；潰逃俘虜改讀它；玩家看守比初值 |
| 1bcfd3666 | 2c 後半：enforce 讀同一支 guard_cap；玩家 holder 不讀人格；缺糧釋放 `captive_food_ok` |
| 5a276c6c5 | 0：失能判準一把 `is_disabled`；`resolve_anon_units` 並列它 |
| 5a2c04210 | 前置：抽 `pursuit_reachable`／`pursuit_kill_count`、`_new_captive_group`、`absorb_wounded_as_captive` |
| b6b87faf1 | 1／2a／2／3／4 結算面 |
| 1da7ee288 | 2c：`prisoner_population` 退場 |
| 64c0e1219 | 2／2d／3／4／5 玩家面（11 個動作、`settle_pending_aftermath`） |
| 7450e0272 | 5：controlled_team 帶 captives；生存頁一行 |
| 53a1bd88a | A7 tap |
| fce4e25b8 | 床 |
| cebd61561 | 註冊表 battle-aftermath |
| 99de17c20／9f3f9ec33 | 併 feat/advisor-belief（要 `res_name`） |
| 6e4270603 | parse error（describe combat_end 少回傳）；A5 佈置；BED_ONLY；閘逾時 1800→2700 |
| 539c921de | 併 origin/main 36ea41a02 |
| df30b1181 | 床第一輪 A8／A9／A10 紅的修正（含兩個既有休眠缺陷，見下） |
| 915812d54 | 藍圖屠村裁定＋你的 HOW |
| 3c91d423e | 併 origin/main 152dfe5e4（只有 docs） |
| 1ed9f6b17 | world-fp 換基準 |
| 9eb616997 | 電池第一輪 6 支紅的修正 |

## 床（`am-bed-full.txt`，915812d54）
- 19／19 到場，errors 0。A11（U10b：玩家全隊陣亡 ⇒ `handle_player_succession`）**綠** ⇒ 你說綠了就關 known_issues U10b。
- 床第一輪紅（df30b1181 修）：
  - A5 空轉：壓看守比讓 room＝0 ⇒「超量仍在」恆真。改用預設 room，加地板「0＜k＜N」（實測 k=6 N=8）。
  - A7 逾時：spec 要 30 天＝43200 tick ⇒ 閘逾時 1800→2700（battery 實測這支 1218s）。
  - A8：`fate_choice` 沒抄進 `last_encounter_result`。
  - A9：追擊 E 多算了記名與另外生成的單位 ⇒ 只算匿名離場單位，且以敗方 healthy 夾上限。
  - A10：兩個既有休眠缺陷（下一節）。
- BED_ONLY：環境變數只跑指定格（`_on(fn)`），**只給負對照用**；有設時跳過到場點名。註冊表那一列不設，跑全部。

## 負對照（`neg-am-n1..n12.txt`，基準 915812d54，每支只跑相關格；腳本 `neg_aftermath.py` 同資料夾）
| 對照 | 改了什麼 | 紅在哪 |
|---|---|---|
| n1 | 結算不發 combat_end | A1 |
| n2 | 失能謂詞拿掉血量條件 | A2 |
| n3 | 未決推進改讀人格選 | A3 |
| n4 | 俘不設上限 | A5 ×3 |
| n5 | 容量改回人口上限餘裕 | A7b 母體地板 |
| n6 | 結清移到指令消化之前 | A3b ×2 |
| n7 | 玩家 holder 放回 decide_treatment | A7 三條路被呼 [5, 5, …]（應 0） |
| n8 | 缺糧檢查只給 NPC | A7c ×2 |
| n9 | 玩家攻方居民不寫 pending | A10 ×3 |
| n10 | 拿掉 erase 前的記名處置（你的 HOW） | **「A10 屠村後活人懸空 team_id＝0（1）」** |
| n11 | NPC 路打開（藍圖裁） | NPC 休眠對照格 |
| n12 | 拿掉居民過渡閘（藍圖裁） | 過渡閘那格 |
- 零 SCRIPT ERROR；每支都只紅在該紅的格。

## A10 揭出的兩個既有休眠缺陷（df30b1181）
1. **居民處置從不發生**：舊 code 先把據點改成勝方的，再用「敗方擁有的據點」找格子 ⇒ 永遠找不到 ⇒ 跳過。main 上就是這樣。
2. **修活後會把同格玩家隊當居民屠掉**：`_find_resident_team_on_tile` 取「那格上第一支非交戰、人數>0 的隊」，床實跑出 `[Massacre] attacker=Team912 resident=Team15`（Team15＝玩家隊）。⇒ 找居民時排除玩家隊。

## 藍圖裁定（ea6986aae）照做
- NPC 路維持休眠：讀「剛被接管那一格」只在 `attacker.player_controlled and state.player_id != -1` 時；NPC 攻方照 main（`_find_prey_outpost`）。床加 NPC 休眠對照格（居民還在、人口不變、無 pending、`res.seen`＝0），n11 會紅。
- 事件句照實：「你下令屠村：TeamN 的 K 人被殺，X 逃散，據點易主」，床斷言開頭、含逃散與易主、不含「戰」。
- 居民過渡閘：只算「勢力＝敗方勢力」的隊（另一勢力的路過隊 ⇒ 無 pending），n12 會紅。★**「以那格為家」那一半未做**：TeamData 沒有可靠的 home 欄位，照藍圖信的退路寫在這裡。
- ★床的「玩家隊不被屠」守衛在 NPC 路休眠時**到不了**（只有 NPC 攻方會把玩家隊當居民），所以它現在恆綠；NPC 路開的那天它才有意義。

## 你的 HOW（473e1590c）照做
- 屠村在 `erase_team` 之前，對隊長＋每個活的記名成員走 `state.remove_member(resident, pid)`，再 `set_leader(resident, -1)`。
- 命運選「散」：`remove_member` 把 `team_id` 設 -1，人活著、離隊。理由：沒有一條既有出口是「記名被殺」（記名失能者這張票一律放），最接近的就是「放」。名字進事件句「X 逃散」。
- A10 加格「`not is_dead and team_id != -1 and not teams.has(team_id)` 的人數＝0」，佈置保證被屠那隊至少一名活的記名（地板格印人數）。n10 紅（1）。
- ★progress 7b 已記用戶 10-15 裁「抹隊時記名改全殺（走戰鬥陣亡同一出口）」⇒ 那張小票會把「散」改成「殺」，本票不動。

## world-fp 換基準（1ed9f6b17）：只是欄位，不是行為
- 舊 `4a8102dec551e5c21c86105da0c5c54a`（main 36ea41a02 原樣重跑確認）→ 新 `34c2804c52272c2f80f5271ed9592b04`。
- 二分（`wfp-*.txt`、`dom-*.txt`、`canon-diff-summary.txt`）：
  1. main＋只拿掉 T 行的 prisoner 欄 ⇒ `58123cd2…`，≠ tip。⇒ 不只那一欄。
  2. tip＋潰逃俘虜容量改回舊式 ⇒ `34c2804c…`，＝ tip ⇒ 這個世界碰不到容量統一。
  3. 同一世界每 500 tick 取逐域指紋（暫用 `_wfp_dump.gd`，未 commit，副本在同資料夾）：persons／factions／belief／tiles／world **40 個取樣點全部逐字相同**，只有 teams 不同。
  4. 終局 canon 964 行逐欄比：差的只有三欄——`prisoner_population`（**TD 行也有它**，第 1 步只拿掉 T 行，所以不相等）、新欄 `captive_overguard`、`captive_guard_ratio` 一隊（Team48 0→0.25）。拿掉這三欄後 **0 行不同**。
- Team48 為什麼不同：它是 setup 時的玩家隊，`sync_possession` 在它變成玩家控制那一刻寫了玩家看守比初值，之後床把 `player_id` 設 -1。它沒有俘虜，沒人讀那個值。⇒ 這是「曾被附身過的隊留著玩家看守比」，對 NPC 無行為影響；真玩裡若玩家離開一支有俘虜的隊，NPC 的 `tick_all` 會在有俘虜那天重算 ratio（manpower_system.gd:312-315）。
- ★所以不是你信裡預期的「只因 prisoner 欄」：多了 `captive_overguard` 一欄和那一隊的看守比，三者都不是行為。註冊表那一列的說明欄寫了推導。

## 普查（3 seed × 30 天，NPC 世界；`census2-census0.txt` 修前 0138fe589／`census2-aftermath.txt` 修後 915812d54）
| | 修前 | 修後 |
|---|---|---|
| 潰逃俘虜次數／人數 | 6／10 | 8／13 |
| 俘了又被 enforce 處置（asm.guardcap_forced） | 2 | 0 |
| asm.created／released／p1.flee | 5／1／1 | 8／4／4 |
| [Pursuit] 行數 | 25 | 10（修後另印 pursuit.n=10） |
| 屠村／歸順／放棄佔領／強佔／據點易主 | 0 | 0 |
- 只有 seed 777 有俘虜；1337／2026 兩邊都是 0。
- 實俘沒有腰斬或歸 0（10→13），你 GO 信的停手條件沒觸發。
- 「俘了又被 enforce 處置」2→0，就是容量統一要修的那件。
- ★追擊行數 25→10 我**沒拆**：兩邊軌跡從容量那裡就分岔了（隊號都不同），不能直接讀成「追擊變少」。
- ★**普查母體沒有「玩家留場」那一場**：普查是無玩家的世界。玩家 holder 的那幾條（容量、不讀人格、養不起）由床 A5／A7／A7b／A7c 佈置驗，不在普查裡。GO 信要的「各至少一場」我只做到 NPC 那一半。
- 屠村等五項兩邊都 0：修前是那個休眠缺陷，修後是藍圖裁的休眠。

## 交給你驗的缺陷（藍圖信要我標給你，不在本票修）
- `erase_teams`（world_state.gd:877）不動 persons，而 `invariant_audit.gd:109-110` 遇到懸空 team_id 直接 continue ⇒ **任何**走 `erase_team` 而沒先 `remove_member` 的路都會留懸空記名，零紅燈。本票只修了屠村那一條。其他呼 `erase_team` 的路我沒逐條查。

## 受影響床清單
- headless、ui-flow、success-sentence、scripted-exploration、live-team-ratchet、bed-kind（第一輪紅、已修）；world-fp（換基準）；battle-aftermath（新）；encounter_sim_test.gd（不在註冊表，只改註解＋宣告）。

## 其他
- index.lock 又出現一次（aftermath worktree，22:22）：等 git 行程數＝0 才刪。
- 沒有修前跑床：床直呼新函式，修前的樹 parse 不過；修前紅由 12 個負對照代表。

## 消費
- `2026-10-14-systems-to-implementer-GO-battle-aftermath.md`
- `2026-10-15-systems-to-implementer-MERGED-advisor-belief.md`
- `2026-10-15-blueprint-to-implementer-RULING-massacre-npc-path-stays-dormant-player-only-until-user-rules.md`
- `2026-10-15-systems-to-implementer-HOW-massacre-named-members.md`
