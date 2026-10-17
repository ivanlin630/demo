# 動詞目錄（動詞 → 身體 → 呼叫者）

> systems owner。用戶 2026-10-14：「做模組後各自調用」要一張查表。**從票裡長**：每張深層批 HOW 的驗收多一格「這個動詞有沒有第二條同功能的路？有就併，併不了寫原因」，併完在這裡登一列。不派獨立稽核、不預先列全庫。
> 一列＝一個玩家／NPC 都會做的世界動作。「身體」＝唯一實作它的函式（含成本表／可行性判斷）；「呼叫者」＝所有入口。同一個動詞出現第二支身體＝違規（S6 禁令同形：不准保留第二支「然後讓它等於第一支」）。

| 動詞 | 身體（唯一） | 呼叫者 | 狀態 | 票 |
|---|---|---|---|---|
| 建點（L0→L1／新據點開工、採段、築段、完工） | `OutpostSystem.start_build`（開工：帶來的料先抵、缺的進 `gather_left`）＋`_tick_construction`（採段→築段→完工一支 `"build"`）；成本表只有 `OUTPOST_COST`；估算器 `build_eta_total_days` 同源 | 紮根（NPC `_commit_settle_site`／玩家 `_action_settle`）、派子隊 `_dispatch_builder`、玩家建設、子隊抵達 | ✅ 已併（merge aa82c866d 2026-10-17；`start_settle_construction` 刪、`crude_camp` 退場；床 `build_verb_one_body_bed.gd`） | 藍圖 2026-10-14-blueprint-to-systems-TICKET-L1-needs-material-gathered-on-site-and-three-entries-merge-into-one-verb |
| 子隊到場執行（到了做什麼：採／觀察／落腳／移居／開工） | `SubteamSystem.on_arrival(state, sub)` | NPC 子隊（腦只決定留／回）、玩家子隊（沒腦） | ✅ 已併（merge aa82c866d 2026-10-17；床同上 S 開頭） | 藍圖 2026-10-14-blueprint-to-systems-RULING-structure-round-before-deep-batch-one-verb-one-body-events-carry-source |
| 提拔（匿名→記名：生成＋加入＋初始忠誠／壓力） | 未併（現況兩支：玩家 `player_command_system.gd:824` 跳過初始忠誠、NPC `faction_ai_system.gd:2760`→`_apply_promotion_initial_state`:2812） | 玩家拔擢、NPC 盟主提拔 | 待併（結構輪；差別只留誰觸發＋NPC 需求秤） | 藍圖 2026-10-14-blueprint-to-systems-TICKET-promote-anon-says-expected-salary-and-one-body-with-npc-promotion |
| 併入整隊（隊長＋記名＋匿名＋資源；裝不下＝不成，不切半隊） | `SubteamSystem.absorb_whole_team`（判斷 `SubteamSystem.absorb_block_reason`：同格／上限／食物；選單、執行、身體三處同呼） | 玩家收留求投靠（`_accept_join_request`）；玩家「邀請併入」（code 未落地） | 已建（6281ce878；床 `live_play_small_fixes_bed.gd` J 系列）；NPC 之間的併隊路本票沒盤點；邀請併入落地時必呼同一支 | 藍圖 2026-10-15-blueprint-to-systems-RULING-join-request-whole-team-or-nothing-no-half-team |
| 戰鬥解算（重量＝Σ人均戰力(階×武裝×坐騎)×意志；死傷按階） | 未併（兩支：遭遇戰 `encounter_system`（匿名單位用隊平均階 :167）、NPC `npc_combat_system`（:700 同）） | 玩家遭遇戰、NPC 對 NPC 戰 | 待併（深層批首：戰鬥模型落地票；驗收含兩個身體勝率一致） | 藍圖 2026-10-14-blueprint-to-systems-TICKET-combat-model-landing-tier-arms-mount-all-present-rout-scale |
