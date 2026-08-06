# 框架收尾「兩硬綠」program — 零殘留閘 + 可擴充（WHAT / vision）

status: DRAFT（據 grounding 真數字、pending R② → 鎖 → slice 切）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-07
溯源：用戶定 2026-08-06「兩個都完成」（行為統一 + 結構模組化）+ 排序 A（復甦收後整段轉）；grounding audit `2026-08-06-framework-grounding-audit.md`（systems，file:line re-verified）。完成標準 = 用戶早定兩硬綠（game-design §大戰略校準）。連 [[project_unification_matrix]]（行為線）+ [[project_framework_seams]]（結構線）。

## §0 grounding 定案（省盲改，據真數字）
- **① 行為零殘留 = largely machine-proven**：`constitution_gate` v2 已抓全 9 閘型（taskarbiter + 值閘[threshold/override/rng] + god-view[gv_teamstate/gv_mapscan] + 控制流[route/dispatch/early_return]）、**75 sites baselined 過閘 removed=0**。§殲滅清單 A 前 6 條全 stale/已修（含 systems 差點又犯 oracle over-count、re-verify 抓住）。
- **② 可擴充 = 主戰場**：faction_ai 5018 行 = 209 func / ~8 行為域。

## §1 兩硬綠 = 完成標準（用戶定、據 grounding 具體化）
- **★硬綠①：零殘留非框架閘（機器證，非人肉）**。達成 = 75 baselined threshold/gate 型 sites **逐一 triaged 分類完畢**（physical-viability[留] vs death-constant[人格化]）、death-constant 全人格化、`constitution_gate` 綠且**無 un-triaged site** + diplomatic:325 補 gate-ok 標。
- **★硬綠②：可擴充（結構乾淨）**。達成 = **無單一 god-object**（faction_ai 拆成有邊界模組、每模組單一行為域）+ **加新行為域/決策 = 動一個有邊界模組 + 引擎註冊、不編輯 orchestration 核或別的模組**（擴充性稽核證得出）+ 每模組有明確 owned state/責任。

## §2 ★守則（防 crank / 防 regression / 防 scope creep）
1. **① 分類判準 = genuine（§5 照妖鏡精神）**：threshold 代表「**與人格無關的物理/世界真實**」（大群不能覓食＝空間物理）→ **留**；代表「**該由人格秤的行為決策**」（DESPERATION 天閾等）→ **人格化**（util 讀人格/記憶/現況、非死值）。**人格化 = genuine 真值 modulate、非 crank**（乙教訓）。留的也要標 legit（machine-gate 認）。
2. **★② 純結構重構 = 行為保持（determinism byte-identical = 硬證/安全網）**：切模組/搬 code **不得夾帶行為變更**——每次抽取/切割後 **determinism 三跑逐位元同**＝證「只搬位置沒改行為」。行為變更（①人格化）與結構搬移（②）**分 slice、不混**（混＝byte-identical 失效、debug 地獄）。
3. **序＝先行為(A)後結構(B)**（grounding 定）：先抽 faction_ai 的 decision chunks 進引擎（自然瘦）→ 再切剩下的 lifecycle/dispatch 模組。反序＝白工（切完又因統一再拆一次）。
4. **每 slice 有界 + gate 驗**：constitution 75+ 過閘、headless 無新錯、determinism、R②。**禁大爆炸一次重寫 5018 行**（切小、每片可 merge、可 revert）。
5. **★scope 邊界（本 program 不做）**：**WorldState 共享狀態的根本 re-architecture 不在本批**——62/64 系統共讀 WorldState 是更底層結構選擇，全解＝近乎重寫、風險/報酬不成比例。本 program 攻 **god-object 消滅 + 有邊界模組所有權**（用戶真痛「加東西大改」的高槓桿處），WorldState-as-shared-state re-architecture＝**documented 未來獨立問**（記 backlog、非本批）。

## §3 track 結構（高層、systems 切 HOW slice）
- **Track ①（行為零殘留、bounded）**：75 baselined threshold sites 死常數審 → physical-viability 留 / death-constant §5 人格化。+ diplomatic:325 gate-ok 標。= 硬綠① genuine 剩工。
- **Track ②（結構可擴充、主戰場、序 A→B）**：
  - **(A) 先行為抽引擎**：faction_ai decision chunks（統一戰略 scorer/意圖/目標評估 895-1311、剩餘散 scorer）→ DecisionEngine util term，faction_ai 自然瘦。
  - **(B) 後結構切模組**：剩下 lifecycle/dispatch 切 5 有邊界模組（基建/設施 lifecycle ~1200 行、side-dispatch 家族 ~480、公庫徵用 ~220、outpost 居民派駐 ~280、envoy 外交 ~350）；`evaluate_all` 主循環 + tag 權限留 faction_ai 核。
- **平行（clean-extractable、低風險先動）**：marginal/message/labor（2-3 ref）seam 明確化/文檔化。

## §4 slice 序（高層、systems HOW 定確切切法）
1. **F1**：Track ① 死常數審 + 人格化（bounded、推硬綠①收）+ diplomatic:325 標。
2. **F2**：Track ②(A) faction_ai decision chunks 抽引擎（behavior-first 瘦身；byte-identical 除非同時 §5 人格化的部分另 slice）。
3. **F3+**：Track ②(B) 逐模組切（一模組一 slice、每片 byte-identical、可 revert）。
4. **平行**：clean-extractable seam 文檔化。

## §5 量測（硬綠驗收）
- **硬綠①**：`constitution_gate` 綠 + 75 sites 全 triaged（無 un-triaged）+ death-constant 人格化後**行為分化可觀測**（同 §5 照妖鏡：死常數 → 人格產不同傾向）+ determinism。
- **硬綠②**：**擴充性稽核**證得出（加一個 mock 新行為域/決策 = 只動一有邊界模組 + 引擎註冊、不碰核/別模組）+ 無 god-object（行數/耦合度稽核：無單檔 209-func 巨物）+ 每純結構 slice **byte-identical determinism**（證無夾帶行為變更）。
- **無 regression**：全程 headless 1000+ tick 無崩、既有 arc 行為不破（recovery/cohesion/info-net 回歸綠）。
