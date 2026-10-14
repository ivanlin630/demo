# 動詞目錄（動詞 → 身體 → 呼叫者）

> systems owner。用戶 2026-10-14：「做模組後各自調用」要一張查表。**從票裡長**：每張深層批 HOW 的驗收多一格「這個動詞有沒有第二條同功能的路？有就併，併不了寫原因」，併完在這裡登一列。不派獨立稽核、不預先列全庫。
> 一列＝一個玩家／NPC 都會做的世界動作。「身體」＝唯一實作它的函式（含成本表／可行性判斷）；「呼叫者」＝所有入口。同一個動詞出現第二支身體＝違規（S6 禁令同形：不准保留第二支「然後讓它等於第一支」）。

| 動詞 | 身體（唯一） | 呼叫者 | 狀態 | 票 |
|---|---|---|---|---|
| 建點（L0→L1／新據點開工、採段、築段、完工） | 未併（現況三支：`start_settle_construction`、`_dispatch_builder`→`start_build`、玩家 `start_build`；兩個價） | 紮根（NPC／玩家）、派子隊、玩家建設 | 待併（結構輪探針一；L1 材料票本體併入） | 藍圖 2026-10-14-blueprint-to-systems-TICKET-L1-needs-material-gathered-on-site-and-three-entries-merge-into-one-verb |
| 子隊到場執行（到了做什麼：採／觀察／落腳／移居／開工） | 未併（現況兩支：NPC `_tick_subteam` 腦內段、玩家 `_tick_player_subteam` 殼） | NPC 子隊、玩家子隊 | 待併（結構輪探針二；腦只決定留／回，玩家子隊沒腦） | 藍圖 2026-10-14-blueprint-to-systems-RULING-structure-round-before-deep-batch-one-verb-one-body-events-carry-source |
