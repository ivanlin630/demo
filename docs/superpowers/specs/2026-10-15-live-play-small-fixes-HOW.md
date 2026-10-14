# 真玩小修（七項）——HOW

狀態：R² ISSUES（2026-10-15-reviewer-to-systems-R2-live-play-small-fixes-ISSUES）已改；§1 審查的 merge_preview 疑點因藍圖裁「整隊或不成」整條路改掉而不再成立（不碰 `_merge_into`）；§1 新簽名與 §5 處置另寄審查核一眼（…-R2b-live-play-small-fixes）
來源：藍圖真玩 06a40cb3d 歸票（2026-10-14-blueprint-to-systems-TICKETS-live-play-findings…§3,5,7）＋拔擢說餉（2026-10-14-…-TICKET-promote-anon-says-expected-salary…，只收 WHAT 1；「提拔一個身體」歸結構輪）＋頂列截斷裁定（2026-10-14-…-RULING-header-truncation-whole-cell-or-drop）。
順位：玩家可見批尾，排在「你領導的勢力」之後。
表：`docs/playtest/2026-10-14-round5-blueprint-live-play.md`（畫面原檔路徑在表內）。

## 一、求投靠：整隊或不成（列＝做）
事實：
- 預覽 `PlayerApiMapper.forced_label`（player_api_mapper.gd:608-612）用 `n = ft.population`（對方全隊，含隊長＋記名＋匿名），印「收留（食物 −0.8n，+n 人）」；選單建時（:349-353）與處理前（player_command_system.gd:1741-1745）各呼一次。
- 執行 `_accept_join_request`（:1669-1693）→ `merge_teams`（:1688）→ `_merge_into`（subteam_system.gd:321）：只有 `absorbed.parent_team_id == absorber_id`（自家子隊回來）才搬隊長與記名（:337-347）；求投靠的隊不是子隊 ⇒ **只搬匿名**，且按 `min(pop, 容量)/pop` 比例（:349-352），剩下的另成一隊「部分合併」（:359-361）。糧按實際增量扣（:1689-1691）。
- ⇒ 列的是全隊、做的是匿名×容量比例。真玩「列 +4 −3.2、做 1 −0.8」吻合。
改法（藍圖裁 2026-10-15-blueprint-to-systems-RULING-join-request-whole-team-or-nothing-no-half-team：求投靠＝整隊、裝不下＝不成、不切半隊；意圖帳「邀請併入」列 10-07 已寫同秤反向＋整隊走收留同路 ⇒ 今天的「只搬匿名」是缺陷，本項直接把身體改對，不先為缺陷的身體做預覽）：
- 一支 `SubteamSystem.absorb_whole_team(state, absorber, absorbed) -> {ok:bool, reason:String, moved:int}`：隊長＋記名＋匿名＋資源全數併入（沿用 `_merge_into` 自家子隊回來那一支的搬法，:337-347＋匿名全數），被併的隊消失；前置三閘照既有收留路（上限／食物／關係）。**上限塞不下整隊 ⇒ ok:false**，理由「上限 {cap}，現有 {n}，對方 {m} 人」；不切半隊。
- 配一支純判斷 `absorb_block_reason(state, absorber, absorbed) -> String`：`forced_label`（選單）、`_accept_join_request`（執行）、`absorb_whole_team` 自己都呼它 ⇒ 列的條件＝做的條件。
- 選單：可 ⇒「收留（+{m} 人，食物 −{0.8m}）」；不可 ⇒ 照列並標「不可：{理由}」，按下回同一句。
- **不碰 `_merge_into`**（它還服務子隊回歸 subteam_system.gd:212，那條路先搬隊長記名才讀 population；R² §1）：`absorb_whole_team` 是新的一支，搬人／搬資源用既有的低階搬移函式（`transfer_proportional` 全數、記名逐一 `set_team`／名冊），不經 `_merge_into` 的比例分支。⇒ 子隊回歸與 NPC 合併路逐位不變。
- 整隊 ⇒ 沒有「0 人進」「進位歸零」「留下半隊再來求」：對方 population ≥ 1 才會有求投靠；裝得下就全來，裝不下就不成。舊的「隊伍已滿，無法收留」（:1680-1682）改由 block_reason 的理由句取代。
- 選單建時（mapper :349-353）、處理前（player_command_system.gd:1741-1745）、執行（:1669-1693）三處都只呼 block_reason，不留第三份算式。
- 玩家動詞「邀請併入」（意圖帳列，code 尚未落地）將來走同一支 `absorb_whole_team`，一個身體兩個入口；verb-catalog 登一列「併入整隊」記這件事。
驗收：
- J1（修前紅）：對方 1 隊長＋1 記名＋2 匿名、容量足 ⇒ 選單「+4 人，食物 −3.2」；接受後人口 +4、糧 −3.2、對方隊不存在、隊長與記名在玩家隊名冊。
- J2（修前紅）：容量只剩 2 ⇒ 選單標「不可：上限…對方 4 人」；按下 ok=false、雙方人口不變、沒有多出一支隊。
- J3：子隊回歸三格（容量足／容量不足／capacity<=0 早退 :330-334）修前修後結果逐位相同；NPC 合併 census 逐項相同（`_merge_into` 未改的證明，不只靠 world-fp）。
- 負對照：forced_label 不呼 block_reason ⇒ J2 紅；`_accept_join_request` 改回 merge_teams ⇒ J1 紅。

## 二、拔擢要說餉（藍圖票 WHAT 1）
事實：`_action_promote_anon`（player_command_system.gd:824-834）結果「拔擢 X 為記名成員」；新人 `salary` 預設 0.0（person_data.gd:58），generate_for_team 不設；`salary_system.gd` 每 7 天（:4）發餉，玩家隊保留玩家設的餉（:88、:184-185），`wage_ratio = salary / fair`（:205）<1 ⇒ 忠誠 −(1−ratio)×0.03（:233-236）。成員頁 `map_members_detail`（mapper :812-852）無餉欄，只有「[Y]調薪」提示（text_ui_main.gd:2147）。
改法：
- 公平餉已存在：`SalarySystem._calc_fair_salary(p)`（salary_system.gd:114-118，:101／:182／:205 共用）⇒ 只**公開**它（改名 `fair_salary(p)` 或加公開殼），不另抽。
- 拔擢結果句縮短（底部結果行 `clip_to(…, COLS−7)` 會默默切句尾，text_ui_view.gd:352-353）：「拔擢 {名}；期望餉 {fair}，現 0（成員頁 [Y] 設餉）」。P1 用最長人名量一次，整句含前綴 ≤ COLS−7。
- 「欠薪會掉忠誠」放成員頁：`map_members_detail` 每人加 `salary`、`fair_salary`、`wage_skipped`（`_has_master_memory` 被發餉跳過的人，:181）；成員頁該人列「餉 {現}／期望 {fair}」，現 < 期望且非 skipped 標「欠（每 7 天掉忠誠）」。
驗收 P1（修前紅）：拔擢後結果行含期望值且＝`fair_wage` 回傳；成員頁該人列「餉 0／期望 N」；P2 設餉 = fair 後「欠」消失；P3 `salary_system` 的 wage_ratio 與成員頁用同一支（負對照：成員頁自己算 ⇒ 改技能後兩邊不等 ⇒ 紅）；P4 結果句寬度 ≤ COLS−7（最長人名）；P5 skipped 者不標「欠」。

## 三、互動面板數字鍵：預設側＋空項回句
事實：`_interact_pane` 初值 "self"（text_ui_main.gd:83），T 開面板（:537-545）與強制事件自動開（:387-390）都**不重設**它 ⇒ 沿用上次那一側。沒聚焦目標時按超出該側長度的數字 ⇒ self 分支（:2468-2469）與 target 分支（:2495-2497）都落空、**無聲**。「面板開著時不能推進（Esc 關閉）」只由 Space／X／G／L 觸發（:1282-1289、:417-420、:2330-2331），數字不會。
改法：
- 預設側只在**面板從關到開**那一邊決定（T 鍵 :537-545；自動開分支 :374-391 只在 `was_open == false` 時）；面板已開著就不動（自動開分支每次推進結束都重跑，無條件重設會搶走玩家剛按的 Tab）。
- 規則：自家側**至少一項 enabled** ⇒ 自家側；否則目標側。判斷用開啟當下的快照。強制事件回應走專屬字母鍵（:2307-2335），與數字側無關。
- 數字超出（只在無聚焦目標的選擇階段；聚焦目標時已有 `_refuse_unbound_key`，不疊句）⇒ 結果行「{自家／目標}這一側沒有第 {N} 項（Tab 換側）」。
- 真玩那一次「按 9 回『面板開著時不能推進』」：該句只由 Space／X／G／抵達鍵發（:1282），數字到不了；實作端用畫面原檔重現鍵序並照實列，不臆測。
驗收 K1（修前紅）：開面板 ⇒ 側＝規則所定；K1b 面板開著按 Tab 到目標側、推進結束（自動開分支重跑）⇒ 仍在目標側；K1c 自家側全 disabled ⇒ 開在目標側；K2（修前紅）空項 ⇒ 回句；K3 重現真玩鍵序（得到的訊息照實列）。unbound_key_bed 綠。

## 四、交換被拒面板不自動關
事實：Enter 送出（text_ui_main.gd:3493-3506）`if r.get("ok")` 就關；`r` 是**排入佇列**的回覆（sim_bridge.gd:409-413、446-447，恆 ok:true queued）⇒ 還沒評估就關了。真拒絕在下一 tick `execute_offer`（player_trade_system.gd:172-173）回 ok:false，而 `_action_submit_trade_offer`（player_command_system.gd:1130-1142）只在成功時清 `pending_trade_target`／`trade_offer`。
改法：送出後記下 `command_player` 回的 seq（sim_bridge.gd:446）；面板保持開。之後的快照從 `state.command_results`（sim_runner.gd:622-625，{tick, seq, ok, name, text}；UI 既有讀者 text_ui_main.gd:300）找**該 seq**：ok ⇒ 成交、關面板；!ok ⇒ 面板照開、結果行印 text（拒絕理由）、出價保留可改；還沒出現 ⇒ 什麼都不做。**不看 `pending_trade_target`**（它也會被玩家換格 :1870-1872、取消移動 :2338 清掉 ⇒ 誤判成交）。
驗收 T1（修前紅）：對方拒 ⇒ 面板仍開、理由在結果行、出價仍在；T1b 玩家隊移動中送出被拒的出價 ⇒ 面板仍開（判準改回 pending ⇒ 紅）；T1c 前一次拒絕句不被當成這一次（seq 不同）；T2 對方接 ⇒ 關。

## 五、戰鬥畫面「命令」：沒有效果的整個拿掉
事實（R² 全庫普查）：Z 選單（encounter_view.gd:926-957）兩種項——射程內「命令 P#／匿名#」→ `_open_sub_command`（:989-993）寫 `current_order = follow_player`；射程外「超出範圍 … — 派信使」→ `_dispatch_messenger`（:974-987）寫 `messenger_target_idx`、標 `is_messenger`。
- `current_order`／`follow_player`：零讀者（只有初值 encounter_system.gd:153/176 與兩處寫）。
- `messenger_target_idx`：零讀者。`is_messenger` 唯一消費 encounter_system.gd:458-459 → `_messenger_exit`（:653-666）：標 `has_exited`，然後呼 `create_subteam`——**全庫不存在** ⇒ 傳令分支永不執行。派信使的真效果＝把一名記名戰鬥員拖出戰場，什麼都沒送到。
- 所有命令路徑不呼 `_log`（:995-999）。
改法（同一判準：沒有消費者就不列；藍圖 2026-10-15 已同意跟隨那半，信使同理已告知）：
- Z 選單兩種項**都拿掉**；選單因此恆空 ⇒ **Z 鍵與它的提示一起拿掉**（encounter_view 動作列、終端戰鬥畫面鍵列、unbound_key_bed 的鍵表同一 commit），不留一個印「沒有可下令的隊友」的空選單。
- `_open_sub_command`、`_dispatch_messenger`、`current_order`、`messenger_target_idx` 的寫入一併刪；`is_messenger` → `_messenger_exit` 的死分支（create_subteam）刪掉；`is_messenger` 若因此零寫者，欄位與 :458-459 一起刪（實作端照普查結果列）。
- 深層批「戰鬥模型落地」給命令／傳令真消費者時，連同 Z 一起加回（不預留空狀態，同游標票刪 Enter）。
驗收 B1（修前紅）：戰鬥畫面鍵列與 GUI 動作列無 Z、按 Z 走既有未綁鍵處置；B2 全庫無 `current_order`／`messenger_target_idx`／`create_subteam` 呼叫；B3 world-fp：只有玩家戰鬥畫面能設 is_messenger ⇒ 無玩家世界不變。

## 六、被動小獵與「此地無獵物」：核完同源，不改 code
事實：被動 resource_system.gd:78-81、100-101（`tile.resources["wild_game"] > 0` 且 `outpost_level == 0`；hunt_system.gd:9-36 有苟活封頂、成功耗 1 隻）；主動 precheck_hunt（player_command_system.gd:611-617）讀同一格同一欄同一門檻。兩者都讀腳下真值（自己腳下＝可見，不違感知）。
結論：同源。真玩看到「有被動小獵又說無獵物」的可解釋路徑＝被動小獵把最後一隻吃掉後主動才問（苟活封頂時回的是「食物已足」，與「此地無獵物」是兩句）。本票不改 code；交件信不必處理。若藍圖要句子說明「剛被你們獵光」，另開。

## 七、頂列：整格或不顯示（藍圖裁）
事實：`TextUiView.top_row`（text_ui_view.gd:153-184，寬 120，分隔「 ｜ 」）；`_fit_names`（:208-248）把隊名／家／營地以 `clip_mark`（「…」，最少 1 字）截半讓位給威脅句；極端值時威脅句也 `clip_mark`（:180-183）；故事結束句用 `clip_to`（:173-179）。隊名與人口同一格「T…（人口 9）」。
改法：
- 格子拆開：時間、家、營地、隊名、人口、糧撐、威脅句、待執行各一格（隊名與人口分開）。
- 放不下時**整格拿掉**，順序：家 → 營地 → 隊名 → 人口 → 糧撐。時間、威脅句、待執行永遠整句。
- **不設「去掉最後所知半句」退路**（R² §7：該子句只在 THREAT_ENEMY，手算全讓完約 66 欄＜120 ⇒ 那條是永不執行的死路）。改成：刪 `_fit_names` 截半與威脅句 `clip_mark` 分支，以床斷言「時間＋威脅句最寬（`threat_reserve()` 實測）＋待執行 99 ＋分隔 ≤ COLS」——那才是會紅的位置；實測 >COLS 就停下交數字給我，不自行加截字。
- 人口獨立成格，字面「人口 {n}」；隊名格只放隊名。釘「（人口」字面的床改錨。
- 故事結束句（:173-179 `clip_to` 無記號）：實作端列 story_end 原因字串全集與最長寬；「時間＋待執行＋STORY_END_LABEL＋最長原因」≤ COLS ⇒ 刪 `clip_to`、床斷言；>COLS ⇒ 停下交數字。
- 範圍：只有頂列。緊接其下的游標處一行（text_ui_view.gd:454 `clip_mark`）不在藍圖裁的範圍，本票不動，交件信寫「未動，另票」。
驗收 H1（修前紅）：真玩那一行的值 ⇒ 輸出不含「…」、被拿掉的是家與營地（整格）、隊名完整；H2 依序加長 ⇒ 消失順序＝家、營地、隊名、人口、糧撐；H3 極端值 ⇒ 無「…」、寬度斷言（threat_reserve 最寬＋固定格 ≤ COLS）綠；H4 故事結束句同斷言；任一格不是「整格或無」⇒ 紅（逐格比對原值）。text_ui_layout_bed 等現有床照改錨字、判準不放寬。

## 共通
- 新床 `live_play_small_fixes_bed.gd`（acceptance，註冊表一列），J／P／K／T／B／H 各格；修前紅格照實列。
- terminal E2E 綠；world-fp：一只改玩家收留路、二只改 UI ⇒ 無玩家世界 world-fp 不變（變了就是碰到 NPC 合併路）。
- 交件信列：三的真玩重現結果；七的 threat_reserve 實測最大寬與 story_end 全集；一的 J3；五的 is_messenger 普查。

## 範圍外
- 提拔一個身體（玩家路跳過初始忠誠）：結構輪，verb-catalog 已登。
- 戰鬥命令的真消費者：深層批戰鬥模型落地。
- 交換畫面識別字（food／weapon_melee_low…）：文本外置試點票。
