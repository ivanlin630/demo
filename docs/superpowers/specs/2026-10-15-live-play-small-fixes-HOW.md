# 真玩小修（七項）——HOW

狀態：待 R²
來源：藍圖真玩 06a40cb3d 歸票（2026-10-14-blueprint-to-systems-TICKETS-live-play-findings…§3,5,7）＋拔擢說餉（2026-10-14-…-TICKET-promote-anon-says-expected-salary…，只收 WHAT 1；「提拔一個身體」歸結構輪）＋頂列截斷裁定（2026-10-14-…-RULING-header-truncation-whole-cell-or-drop）。
順位：玩家可見批尾，排在「你領導的勢力」之後。
表：`docs/playtest/2026-10-14-round5-blueprint-live-play.md`（畫面原檔路徑在表內）。

## 一、求投靠：列＝做
事實：
- 預覽 `PlayerApiMapper.forced_label`（player_api_mapper.gd:608-612）用 `n = ft.population`（對方全隊，含隊長＋記名＋匿名），印「收留（食物 −0.8n，+n 人）」；選單建時（:349-353）與處理前（player_command_system.gd:1741-1745）各呼一次。
- 執行 `_accept_join_request`（:1669-1693）→ `merge_teams`（:1688）→ `_merge_into`（subteam_system.gd:321）：只有 `absorbed.parent_team_id == absorber_id`（自家子隊回來）才搬隊長與記名（:337-347）；求投靠的隊不是子隊 ⇒ **只搬匿名**，且按 `min(pop, 容量)/pop` 比例（:349-352），剩下的另成一隊「部分合併」（:359-361）。糧按實際增量扣（:1689-1691）。
- ⇒ 列的是全隊、做的是匿名×容量比例。真玩「列 +4 −3.2、做 1 −0.8」吻合。
改法：
- 抽一支 `SubteamSystem.merge_preview(state, absorber, absorbed) -> {anon_moved:int, named_moved:Array, stays:int}`，與 `_merge_into` 用**同一段算式**（`_merge_into` 改成先呼它再照結果搬，不各算一份）。
- `forced_label` 與 `_accept_join_request` 的容量／糧檢查都讀它：「收留（+{anon_moved} 人，食物 −{0.8×anon_moved}；Team{X} 的隊長與記名成員不會加入{，留下 stays 人另成一隊}）」。
- **不改「誰會加入」的世界規則**（求投靠只來匿名＝既有 merge 規則）；它是不是本意，寫進交件信、我轉藍圖問（WHAT），本票只讓列＝做。
驗收 J1（修前紅）：佈置對方 1 隊長＋1 記名＋2 匿名、容量足 ⇒ 選單「+2 人，食物 −1.6」、接受後人口 +2、糧 −1.6；J2 容量只剩 1 ⇒ 選單 +1 並寫「留下 N 人另成一隊」、做後同。負對照：forced_label 改回讀 population ⇒ J1 紅。

## 二、拔擢要說餉（藍圖票 WHAT 1）
事實：`_action_promote_anon`（player_command_system.gd:824-834）結果「拔擢 X 為記名成員」；新人 `salary` 預設 0.0（person_data.gd:58），generate_for_team 不設；`salary_system.gd` 每 7 天（:4）發餉，玩家隊保留玩家設的餉（:88、:184-185），`wage_ratio = salary / fair`（:205）<1 ⇒ 忠誠 −(1−ratio)×0.03（:233-236）。成員頁 `map_members_detail`（mapper :812-852）無餉欄，只有「[Y]調薪」提示（text_ui_main.gd:2147）。
改法：
- `salary_system.gd` 把公平餉那段抽成 `SalarySystem.fair_wage(state, p) -> float`（:205 自己也改呼它，一支）。
- 拔擢結果句：「拔擢 {名} 為記名成員；他期望每期（7 天）餉 {fair}，現餉 0——到成員頁按 [Y] 設餉，欠薪每期會掉忠誠」。
- `map_members_detail` 每人加 `salary`、`fair_wage`；成員頁該人列「餉 {現}／期望 {fair}」，現 < 期望標「欠」。
驗收 P1（修前紅）：拔擢後結果行含期望值且＝`fair_wage` 回傳；成員頁該人列「餉 0／期望 N」；P2 設餉 = fair 後「欠」消失；P3 `salary_system` 的 wage_ratio 與成員頁用同一支（負對照：成員頁自己算 ⇒ 改技能後兩邊不等 ⇒ 紅）。

## 三、互動面板數字鍵：預設側＋空項回句
事實：`_interact_pane` 初值 "self"（text_ui_main.gd:83），T 開面板（:537-545）與強制事件自動開（:387-390）都**不重設**它 ⇒ 沿用上次那一側。沒聚焦目標時按超出該側長度的數字 ⇒ self 分支（:2468-2469）與 target 分支（:2495-2497）都落空、**無聲**。「面板開著時不能推進（Esc 關閉）」只由 Space／X／G／L 觸發（:1282-1289、:417-420、:2330-2331），數字不會。
改法：
- 開面板（兩個入口）時：自家側有可做的動作（列表非空）⇒ 自家側；否則目標側。不再沿用上次。
- 數字超出 ⇒ 結果行「{自家／目標}這一側沒有第 {N} 項（Tab 換側）」。
- 真玩那一次「按 9 回『面板開著時不能推進』」：實作端先用畫面原檔重現當時的鍵序；若重現出來是另一條路（不是數字），列出路徑再修那條，不臆測。
驗收 K1（修前紅）：開面板 ⇒ 側＝規則所定；K2（修前紅）空項 ⇒ 回句；K3 重現真玩鍵序（得到的訊息照實列）。unbound_key_bed 綠。

## 四、交換被拒面板不自動關
事實：Enter 送出（text_ui_main.gd:3493-3506）`if r.get("ok")` 就關；`r` 是**排入佇列**的回覆（sim_bridge.gd:409-413、446-447，恆 ok:true queued）⇒ 還沒評估就關了。真拒絕在下一 tick `execute_offer`（player_trade_system.gd:172-173）回 ok:false，而 `_action_submit_trade_offer`（player_command_system.gd:1130-1142）只在成功時清 `pending_trade_target`／`trade_offer`。
改法：送出後面板保持開；下一次快照：`pending_trade_target` 已清 ⇒ 成交、關面板；仍在且有該指令的失敗回句 ⇒ 面板照開、結果行印拒絕理由、出價保留可改。判準讀的是指令系統寫的那份狀態，不在 UI 另記一份。
驗收 T1（修前紅）：對方拒 ⇒ 面板仍開、理由在結果行、出價仍在；T2 對方接 ⇒ 關。

## 五、戰鬥畫面「命令」：沒有效果的不列，有效果的要回句
事實：Z 選單（encounter_view.gd:926-957）列「命令 P#／匿名#」；選了走 `_open_sub_command`（:989-993）寫 `current_order = follow_player` 只 print——**`current_order`／follow_player 模擬端零讀者**（只有 encounter_system.gd:153/176 設初值、encounter_view :983/:992 寫）⇒ 對記名、匿名都沒有任何效果。`_dispatch_messenger`（:974-987）跳過匿名（:980），沒信使只 print（:987）。所有命令路徑都不呼 `_log`（:995-999）⇒ 結果行不變。唯一模擬端讀的命令是 `is_messenger`（encounter_system.gd:458-459）。
改法：
- 「命令 P#／匿名#（跟隨）」**從選單拿掉**：它沒有消費者，回一句「已下令」＝說謊（與游標票刪 Enter 同一處理：等深層批「戰鬥模型落地」給命令消費者時連同它一起加回）。
- 「派信使」保留，三種結果都 `_log`：派出「{名} 出發去傳令」；選到匿名「匿名兵不能當信使」；沒人「沒有可派的記名信使」。
驗收 B1（修前紅）：選單不含跟隨命令；B2 派信使三種結果各一句進結果行。負對照：拿掉 _log ⇒ B2 紅。

## 六、被動小獵與「此地無獵物」：核完同源，不改 code
事實：被動 resource_system.gd:78-81、100-101（`tile.wild_game > 0` 且 `outpost_level == 0`；hunt_system.gd:9-36 有苟活封頂、成功耗 1 隻）；主動 precheck_hunt（player_command_system.gd:611-617）讀同一格同一欄同一門檻。兩者都讀腳下真值（自己腳下＝可見，不違感知）。
結論：同源。真玩看到「有被動小獵又說無獵物」的可解釋路徑＝被動小獵把最後一隻吃掉後主動才問。本票不改 code；交件信不必處理。若藍圖要句子說明「剛被你們獵光」，另開。

## 七、頂列：整格或不顯示（藍圖裁）
事實：`TextUiView.top_row`（text_ui_view.gd:153-184，寬 120，分隔「 ｜ 」）；`_fit_names`（:208-248）把隊名／家／營地以 `clip_mark`（「…」，最少 1 字）截半讓位給威脅句；極端值時威脅句也 `clip_mark`（:180-183）；故事結束句用 `clip_to`（:173-179）。隊名與人口同一格「T…（人口 9）」。
改法：
- 格子拆開：時間、家、營地、隊名、人口、糧撐、威脅句、待執行各一格（隊名與人口分開）。
- 放不下時**整格拿掉**，順序：家 → 營地 → 隊名 → 人口 → 糧撐。時間、威脅句、待執行永遠整句。
- 全讓完仍放不下 ⇒ 威脅句去掉「，最後所知 N 格」那半句（整個子句拿掉，不截字）。
- 刪 `_fit_names` 的截半與威脅句 `clip_mark` 分支。實作端用 `threat_reserve()`＋極端值（999 天／人口 9999／待執行 99）算出全讓完＋去半句後的最大寬：≤120 ⇒ 不留任何截字路徑；>120 ⇒ 交件信貼數字給我，不自行加截字。故事結束句同規則（整句或拿掉其他格）。
驗收 H1（修前紅）：真玩那一行的值 ⇒ 輸出不含「…」、被拿掉的是家與營地（整格）、隊名完整；H2 依序加長 ⇒ 消失順序＝家、營地、隊名、人口、糧撐；H3 極端值 ⇒ 無「…」；任一格不是「整格或無」⇒ 紅（逐格比對原值）。text_ui_layout_bed 等現有床照改錨字、判準不放寬。

## 共通
- 新床 `live_play_small_fixes_bed.gd`（acceptance，註冊表一列），J／P／K／T／B／H 各格；修前紅格照實列。
- terminal E2E 綠；world-fp：一、二只改 UI 與預覽（merge 算式抽出必須逐位相同 ⇒ world-fp 不變；變了就是抽壞了）。
- 交件信列：一的「求投靠只來匿名」是否本意（轉藍圖）；三的真玩重現結果；七的最大寬數字。

## 範圍外
- 提拔一個身體（玩家路跳過初始忠誠）：結構輪，verb-catalog 已登。
- 戰鬥命令的真消費者：深層批戰鬥模型落地。
- 交換畫面識別字（food／weapon_melee_low…）：文本外置試點票。
