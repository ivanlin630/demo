# 佔村 option（雙引擎複利咬合點）— Design

> 藍圖裁定 `dual-engine-horses` 裁1。用戶戳破:弱村=最小據點,T36 月 raid 43 次**搶了就走從不佔**=荒謬。
> 雙引擎複利:人力引擎（raid→俘→同化→壯兵,已通）×糧引擎（據點+生產→盈餘,T32 和平版已通）——**佔村=兩引擎咬合**:
> `raid 活命抓人→同化壯兵→奪據點→據點產糧養兵→打更大→立國`。

## 系統偵察（先讀,measure 依此設計）

- `OutpostSystem.capture`（outpost:598）:只在**戰鬥落點 tile `outpost_level>0`** 時翻所有權（`_end_combat:272` 決勝 + `_force_retreat:319` rout 皆呼）。
- survival-loot 路（interaction:299）:`_should_pay_tribute` → 勒索（**無戰鬥→無 capture**）;否則 `_should_attack` → 戰。
- **翻旗 ≠ 佔住**:capture 只改 `outpost_owner`;狼不 settle、不駐守、產出歸屬與收取鏈是否真到狼手上待驗。
- **「佔住不走」option 不存在**:raid 弧無「奪據點+搬進去」選項。

## Task 1 — Measure（藍圖明示先量:機制斷 vs 權重斷）

探針（Probe guard）+ longwindow/seeded 量 T36 型狼的 raid 解剖:
1. raid 解決分佈:`raid.extort / raid.combat / raid.combat_at_outpost / raid.combat_open_field`（勒索 vs 戰;戰鬥落點有無 outpost）。
2. `capture 翻旗數` + **翻旗後**:狼是否收到產出（owner 收取鏈:granary/tax 到 owner?）/ 是否回訪 / 旗又被翻回?
3. 弱村 prey 組成:believed prey 是 resident 村隊（PRODUCE,固定 outpost tile）vs 流浪隊 佔比——**追擊撞點多在開闊地=capture 永 no-op** 假說驗證。
→ 定「機制斷」（戰不落村格/翻旗無收益鏈）vs「權重斷」（有 option 永輸）佔比,Task 2 修對應根。

## Task 2 — 「佔村」= means-end option（按 Task 1 數據,方向如下）

- **與「搶了就走」並列秤**（零新判斷器,連續 util）:
  - 搶了就走 util ← 守不住信號:離家遠（hex_dist 自家 outpost）/ 強敵環伺（threat 既有）/ 人少分不出駐軍（pop vs 駐軍需求）。
  - 佔住不走 util ← 守得住+要根據地:無自家 outpost（流浪狼最需要）/ pop 夠分駐 / 目標村產出（belief richness）/ 征服/建國 intent 加權（means-end driver）。
- **佔住動作=複用既有**:capture 翻旗（既有）+ 派駐/settle（`TASK_SETTLE`/residency 既有 pattern）+ 村民=受控人力（capture 俘虜鏈既有）+ 產出歸 owner（outpost tick 既有,驗收取鏈通）。**不新造據點系統**。
- 戰不落村格問題（若 Task 1 證主因）:攻 resident 村的戰鬥自然在村格（村隊不動）——追流浪隊才開闊地。修向可能=prey 選擇對「有據點的弱村」加權（要據點的狼優先打村非打流浪,means-end 自然導向）。

## 硬約束
- 零新判斷器;佔/走=同 menu 兩 option util 秤;身分不切路徑;新 latch（settle 派駐若 latch）必配 timeout。
- 守恆:村民→受控人力走 AnonTierSystem;產出歸屬走既有 bank。

## 驗收
1. measure 報告（Task 1 分佈數字進 handback）。
2. 長窗:狼「佔村」事件 >0（翻旗+settle+產出真到手）;佔村狼 food_flow 轉正（糧引擎點火）;搶了就走仍存在（離家遠/守不住者)。
3. 雙引擎弧一段可見:某狼 raid→俘→佔村→flow 轉正（specimen/per-wolf 曲線）。
4. 回歸:headless+framework+coin_eq+InvariantAudit 全綠;不 over-war。

## 檔案 scope（平行紀律:勿碰 diplomatic_ai/world_generator——他軌）
`npc_combat_system.gd`（探針）、`faction_ai_system.gd`（option/prey 加權,勿碰 envoy/結盟函數）、`outpost_system.gd`（收取鏈驗/佔住 wiring）、`decision/options.gd`（如 option 走 engine）、`headless_test.gd`、`longwindow_bed.gd`（佔村探針）。
