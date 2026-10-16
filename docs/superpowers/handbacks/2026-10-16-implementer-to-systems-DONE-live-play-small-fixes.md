---
from: implementer
to: systems
status: open
slice: 真玩小修七項（spec 2026-10-15-live-play-small-fixes-HOW）
topic: 請 merge feat/live-play-small-fixes d08f90641（已併 main f4a192dfe）｜全電池釘 d08f90641：137／137 全綠 RC=0（run-id 2033-20261016-142738）｜床 24／24 errors 0；9 刀負對照全紅在該紅的格｜world-fp 不換｜六項改 code、第六項照 spec 不改
---

# 結論

- 分支 `feat/live-play-small-fixes` tip `d08f90641`，base origin/main 20865b78e，已併 f4a192dfe（7b；合併乾淨）。
- 全電池（`.worktrees/mm2neg` 釘 d08f90641）：137 支全部通過、BATTERY_RC=0、run-id `2033-20261016-142738`；跑前跑後樹 sha 都是 d08f90641、跑前 porcelain 0 行；`battery-final-d08f90641-green.txt`。「本地多出 live-play-small-fixes」＝本支新註冊的床閘。world-fp 綠、不換基準。
  - ★前一輪（釘 6baa1ae93，run-id `2148-20261016-121511`）RC=1 紅 2 支，原始輸出 `battery1-6baa1ae93-red.txt`，都修在 d08f90641：
    ①headless：失敗清單多一條「部分容量應只進 3」——`_test_join_request_cap_capped`（headless_test.gd:1770）的部分容量 case 斷言的正是被藍圖裁掉的半隊行為；改成「整隊或不成：0 人進、ok=false、糧不扣、對方原封不動」（改的是那個值，不是放寬）。
    ②value-key 第二段 lookup-key：床 J1 期望字面「收留（+4 人，食物 −3.2）」登 allow（同前例）。
- 床與負對照釘 6baa1ae93（`bed-full-6baa1ae93.txt` 24／24 errors 0）；之後到 tip 只多 d08f90641（headless 一條舊斷言＋lookup allow 一列），不碰床與產線。
- 新床 `scripts/debug/live_play_small_fixes_bed.gd`（acceptance，24 格點名），註冊表新列 `live-play-small-fixes`，expect `=== live_play_small_fixes DONE === 到場 24／24 errors: 0`。
- 原始輸出：`docs/measurements/2026-10-16-live-play-small-fixes/`。

# 逐項

## 一、求投靠：整隊或不成（4c400c3dc）

- `SubteamSystem.absorb_block_reason`（純判斷）：選單 `PlayerApiMapper.forced_label`、執行 `_accept_join_request`、`absorb_whole_team` 自己，三處都呼它，沒有第二份算式。
  - 三閘照**現行**收留路：同格、上限（整隊塞得下）、食物。
  - spec 寫「上限／食物／關係」，但現行收留路沒有關係閘（`_maybe_request_join_player` faction_ai_system.gd:7862 也只看同格與事件槽），所以沒加。
- `SubteamSystem.absorb_whole_team`：
  - 先把俘虜整組轉到 absorber 的 captive_groups（組上沒有 holder 欄，組就住在 holder 的陣列裡，所以「轉名下」＝搬陣列）。
  - 再呼 `merge_teams(…, [隊長]+記名, 匿名總數)` 長分支。
  - 不碰 `_merge_into`：`git diff 20865b78e..6baa1ae93 -- scripts/simulation/subteam_system.gd` 只有新增兩支函式，`_merge_into` 本體 0 行變動。
- 選單：
  - 可：「收留（+m 人，食物 −0.8m）」
  - 不可：「收留（不可：理由）」
- 按下「不可」：回「你選了「收留」，但{理由} ⇒ 沒有生效（請求還在，可改按婉拒）」，**強制事件保留**（比照 choose_heir）。
  - 句型沿用既有的「決定與結果分開講」（decision_vs_outcome 床守的那個形狀）。
  - 選項名取自同一支 label 去掉括號，沒有另立字表。
- 舊句「隊伍已滿，無法收留」由理由句「上限 {cap}，現有 {n}，對方 {m} 人」取代；兩支釘舊句的床改錨：terminal_e2e FR2、decision_vs_outcome P1。
- verb-catalog「併入整隊」那列目前寫「待建」，身體現在建好了（`SubteamSystem.absorb_whole_team`）。那份檔是你的，請改；我沒動。
- **J1b 去向**（實跑）：
  - 據點：`world_state.gd:1025`（erase_teams 3a `OutpostOwnerBank.set_owner(…, -1, "death_release")`），被併隊的據點 owner → -1。據點格上的公庫照舊留在格上。
  - 子隊：`world_state.gd:1000-1002`（erase_teams 對 `subteam_ids` 逐一 `parent_team_id = -1`），子隊留在世界上、成為獨立隊（實跑：Team931 parent -1、還在）。
  - 勢力身分：erase 既有的勢力名冊清理。
  - **沒有東西蒸發**：全世界人口、小孩、俘虜、coin、各資源、anon_treasury 前後相等；糧只少一餐 3.2；死亡數 0→0。據點與子隊該不該跟著來，照 spec 轉藍圖，本票不改。
- **J3**：子隊回歸三格實跑（`_merge_into` 本體未改）：
  - 容量 10：全併、子隊消失
  - 容量 1：+1、子隊留下
  - 容量 0：不併、子隊脫離母團獨立
- NPC 合併路逐位不變的證據：world-fp 綠（不換基準）＋上面的 diff。

## 二、拔擢說餉（0b51f9836）

- `SalarySystem.fair_salary`／`wage_skipped` 是公開殼，與發餉同一支，沒有另抽。
- 結果句實跑：「拔擢 韓靈；期望餉 4.1，現 0.0（成員頁 [Y] 設餉）」。
  - 最長人名（最長姓＋最長名＋撞名退路的 4 位數）連前綴「 結果：✓ 」量到 63／120。
- 成員頁速覽卡：「餉 0.0／期望 4.1  欠（每 7 天掉忠誠）」；設餉＝期望後「欠」消失。
- 隊長不在發餉迴圈（salary_system 只發 named_members），所以算 skipped，不標欠。

## 三、互動面板（44fce262c）

- 預設側只在關→開時決定：T 鍵那一支；強制事件自動開那一支只在原本關著時。
- 數字超出 ⇒「X這一側沒有第 N 項（Tab 換側）」。
- **真玩鍵序重現（K3）**：
  - 畫面原檔 `docs/measurements/2026-10-14-blueprint-live-play-06a40cb3d.txt` 沒有按鍵紀錄，但幀內容夠：:4606 起連續 15 幀，數字側標在「可互動目標 ◀ 數字鍵在這一側」、目標側只有 1 項，自家側第 9 項是「收編敗者」；結果行一直是「✗ 面板開著時不能推進（Esc 關閉）」。
  - ⇒ 按 9 落在目標側、超出 1 項 ⇒ 舊版**無聲**；畫面上那句是**更早一次**按推進鍵（X／Space）留下的，**不是 9 造成的**。
  - 床照這個鍵序（開面板、目標側、先 X 再 9）：X 回「面板開著時不能推進」，9 之後結果行換成「目標這一側沒有第 9 項（Tab 換側）」。
  - 新規則下這個情境會開在自家側（自家有可做的），玩家按 9 就是收編。

## 四、交換被拒面板不關（ac43fe234）
- 送出時記 `command_player` 回的 seq，面板不關。`_process` 排空 command_results 時找到該 seq：成交就關；被拒照開，理由走既有的失敗回句、出價保留。不看 pending_trade_target。
- 實跑：
  - 空出價 ⇒「被拒絕（出價為空）」、面板開。
  - 再送 coin 5 ⇒ seq 2「貿易成功」、面板關（seq 1 那筆拒絕沒有讓它關）。
  - 移動中送出被拒 ⇒ 面板開。

## 五、戰鬥命令整串拿掉（bf8cfb5dd）
- 照刪除清單：encounter_view 動作列兩份 Z、未綁鍵回句裡的 Z、終端選單三處、四支函式、SOUND_RANGE、is_messenger 黃點繪製；encounter_system 兩份單位初值的 is_messenger／current_order／messenger_target_idx、傳令決策分支、`_messenger_exit`、執行端 messenger_exit。主畫面 KEY_Z 不動。
- BATTLE⑦ 改成「戰鬥畫面按 Z ⇒ 未綁鍵處置（說出為什麼），鍵列上沒有 Z」。
- **is_messenger 普查**（`grep -rn is_messenger scripts tools`）：產線 0；只剩 `scripts/debug/headless_test.gd:3823`、`:3838` 兩個手造單位字典寫著 `"is_messenger": false`（佈置字典，沒有讀者）。`current_order`／`messenger_target_idx`／`create_subteam`／`follow_player`／`messenger_exit` 全庫 0（床 B2 掃 encounter_view／encounter_system 程式碼行＝0）。

## 六、被動小獵與「此地無獵物」
照 spec 不改 code。

## 七、頂列（07251a7c9）
- 八格：時間、隊名、人口、家、營地、糧撐、威脅句（或故事結束句）、待執行。
- 放不下就整格拿掉，順序 `TextUiView.TOP_DROP_ORDER`＝家 → 營地 → 隊名 → 人口 → 糧撐。
- 刪掉三條截字路徑：`_fit_names`（隊名／家／營地截成「…」）、威脅句 `clip_mark`、故事結束句 `clip_to`。
- **threat_reserve 實測最大寬＝30**。時間（999 天）＋「威脅：」＋30＋待執行 99＋兩個分隔＝**71／120**。
- **story_end 原因全集**（`game_over_reason` 寫者全庫兩處＋UI 退路一處）：
  - `event_system.gd:88`「玩家絕後（Team%d 無繼承人）」，Team99999 時 30 欄
  - `player_command_system.gd:2061`「玩家絕後（隊已滅,無繼承人）」
  - `text_ui_main.gd:1002`「（原因未記）」
  - 時間＋待執行＋「故事已結束：」＋最長原因＋分隔＝**77／120**。
  - ⇒ 兩條都 ≤ COLS，不用停下交數字。
- 床 H3／H4 是那兩條寬度斷言（會紅的位置）。
- 釘舊字面的床改錨：
  - `TextUiView.TOP_FIELDS` 第二欄：「（人口 」→「 ｜ 人口 」（人口格自己的字面），欄數仍 6。
  - text_ui_layout_bed 的說明字。
  - terminal_e2e 解析器樣本、terminal_selfcheck 反向對照樣本（合成字串改成新格式）。
  - terminal_input_prompts P3「長隊名用『…』截」→「無『…』、家整格拿掉」：舊斷言要求的正是被藍圖裁掉的行為。
- 頂列下方的游標處一行（`text_ui_view.gd` 的 clip_mark）：**未動，另票**。

# 負對照（釘 6baa1ae93，BED_ONLY 子集，跑完還原、porcelain 空）

| 刀 | 拔掉什麼 | 紅（原文節錄） |
|---|---|---|
| n1 | forced_label 不呼 block_reason | `J2 選單標「不可：上限…對方 4 人」…` |
| n2 | `_accept_join_request` 改回 `merge_teams`（舊路：只搬匿名×容量比例） | `J1 …人口 +4…`、`J2 …`、`J1b 守恆…（1.6）`、`J1b 俘虜組整組在玩家名下（0→0）` |
| n3 | 拿掉轉俘虜那一步 | `J1b 守恆…`、`J1b 俘虜組整組在玩家名下（0→0）` |
| n4 | 成員頁自己算期望餉（寫死 4.0） | `P1 …`、`P3 …（mapper 4.000＝SalarySystem.fair_salary 4.105）` |
| n5 | T 鍵不決定預設側 | `K1 開面板 ⇒ 自家側…`、`K1b …` |
| n6 | 空項不回句 | `K3 重現真玩鍵序…`、`K2 數字超出這一側…` |
| n7 | 看到排入佇列的 ok 就關（舊行為） | `T1 對方拒 ⇒ 面板仍開…`、`T1c …`、`T1b …` |
| n8 | 判準改回 pending_trade_target | `T1b 移動中送出被拒 ⇒ 面板仍開` |
| n9 | 頂列先拿隊名（順序錯） | `H1 真玩那一行…隊名完整…`、`H2 依序加長 ⇒ 消失順序＝家、營地、隊名、人口、糧撐…` |

- 每份 `neg-nX.txt` 開頭印樹 sha、`git diff --stat`（只動被拔的那一處）、末尾 porcelain 空。
- ★**第一輪（`neg-first-run/`，釘 0e53ff048）n8 沒紅、n9 只紅 H1**——兩格是床寫錯，改了床（6baa1ae93）後全部重跑（上表）：
  - T1b 原本只設 move_target，那一 tick 沒換格、pending 沒被清 ⇒ 舊判準也照開。改成照「換格會清 pending」的結果佈置（送出前清掉 pending、出價被拒）。
  - H2 原本拿 `TOP_DROP_ORDER` 常數當期望 ⇒ 改常數時兩邊一起變（同源恆真）。改寫 spec 的字面順序。
- B 格（戰鬥命令）是程式碼普查格，沒有拔刀；按 Z 的未綁鍵處置由 terminal_e2e BATTLE⑦ 在電池裡跑。

# 消費
GO-live-play-small-fixes、MERGED-aftermath-7b。

下一張：我的掛單與押貨（之後勢力目標票）。
