# Hand Back: 設施改制 A 期（需求迴路 + Slot 制 + 專業化）

> 日期：2026-06-12
> Branch：`feat/facility-overhaul`
> Spec：`docs/superpowers/specs/2026-06-12-facility-overhaul-design.md`
> Plan：`docs/superpowers/plans/2026-06-12-facility-overhaul.md`

## 實作摘要（7 Task）

| Task | 檔案 | 內容 |
|---|---|---|
| 1 | `tile_data.gd` | 加 apothecary/smelter/weaponsmith/armorsmith_level 4 欄位 |
| 1 | `outpost_system.gd` | FACILITY_DEF v2（8 設施 + allowed_outpost + 三級成本）、FACILITY_SLOTS + slot_cap/slots_used、upgrade_cost(×1/×2/×3)、通用 `start_upgrade_facility` / `_begin_facility_construction`（取代 farming/manufacturing 專用路徑）、`demolish_facility` helper、廢 FARMING_CAP/MANUFACTURING_CAP/STABLE_CAP/cap_by_outpost/trigger_check/UPGRADE_COST |
| 1 | `player_command_system.gd` | `build_facility` 改通用入口（任一 FACILITY_DEF key；"manufacturing" 別名 → workshop） |
| 1 | `player_api_mapper.gd` | outpost panel 的 farming/mfg max 改 slot 制推導 |
| 2 | `outpost_system.gd` | BUILD_COST → OUTPOST_COST：civilian 純 mat（50/150/400）、military mat+tools（80/200/500 + 3/6/10），coin/weapon 成本移除 |
| 3 | `manufacturing_system.gd` | 固定優先序 `_run_recipes` 廢除 → RECIPE_GROUPS 4 組（工坊 goods/tools/arrows、冶煉、武器、護甲），組內缺口排序（stock/(target×pop) 最低先做），每設施每 tick 一條配方；生產權 = owner 或同 faction |
| 3 | `interaction_system.gd` / `player_trade_system.gd` | BASE_PRICE + TARGET_PER_POP 加 tools/arrows/armor_low/armor_high（軍民 tools 貿易線） |
| 3 | `faction_ai_system.gd` | `_can_manufacture` 改掃 4 個 level key + faction 生產權（military tile 可開工） |
| 4 | `faction_ai_system.gd` | `_evaluate_infrastructure` (2) 重寫：`_pick_facility` score = terrain_fit ×(1+deficit)× personality、飢餓 override（food<pop×2.4×7 → 農田最優先，slot 滿拆 score 最低設施改建）、軍用 outpost 開放（allowed_outpost gate 嚴格） |
| 5 | `faction_ai_system.gd` | `_try_dispatch_or_invite`：military tile 只 dispatch 子隊（無 invite fallback） |
| 5 | `outpost_system.gd` / `manufacturing_system.gd` | 生產人力 gate：mint/stable/製造需 tile 上有 PRODUCE 居民團 |
| 6 | `anon_tier_system.gd` | try_promote coin → team.anon_treasury（總量不變） |
| 6 | `player_command_system.gd` | 招募 anon/named coin → 目標 team |
| 6 | `encounter_system.gd` | audit 修復 2 個武器蒸發點（見守恆 audit 節） |
| 7 | `game_sim_multi.gd` | 加 CoinAudit（coin 等值總量 init/final/delta）+ FacilityStats（設施數/組合） |

## Task 7 整合期追加修復（驗收 debug 發現的 6 個前置 bug/缺口）

multi 跑出 baseline=0 的真正原因是一串執行層斷鏈，逐一修復後驗收才達標：

1. **建造資金斷鏈**（前置 bug，baseline 0 的根因之一）：`SubteamSystem.dispatch` 只按人口比例分資源（3/20 人 → 帶 15% 材料），子隊抵達後付不起建造費。修：`_fund_subteam_cost` — dispatch 後 owner 補足 cost 差額給子隊（純轉移守恆）。三個 dispatch 路徑（建造/升級/擴建）都接上。
2. **advisor 斷鏈**：NPC 團常無多餘 named member → `_pick_advisor` 永遠 -1 → dispatch 永不發生。修：`_pick_or_promote_advisor` — 仿 residency dispatch 既有機制，升一名 anon 為工頭（`PersonGenerator.generate_for_team`）。
3. **評估範圍缺口**：原 loop 只評 faction leader 自有 tile；NPC 子隊建的新據點 owner = 安頓後居民團 → 永不被評估。修：step (2) 擴大到 faction 內所有 outpost，以 **owner 團的 local 資料 + owner leader 個性**評估（比用 faction leader 全知資料更符合不變量）。
4. **執行層改就地施工**：faction leader 團多為 pop=1 空殼（人都派出去了），派 3 人子隊不可能。修：owner 在場 → 就地開工；否則 tile 上同 faction 居民團出工出料；最後才 fallback 派子隊。
5. **施工中斷永久卡死**（前置 bug）：survival（飢餓）劫持 建設 task 後 construction_team_id 卡住，無人復工 → tile 永久鎖。修兩處：
   - `_trigger_survival`：人已站在自己工地（`construction_team_id == team.team_id`）→ 不中斷（蓋農田即自救；return_home 回自己已在的家無意義）
   - `_try_resume_construction`（infra cadence 掃描）：在場居民/owner（idle/生產/製造/貿易/工地上的 return_home 殭屍態）強制復工；owner 在外 → 召回（transition 建設 + move_target=工地）
6. **工期單位校正**：spec 工期寫 world-ticks（農田 3 天=720t），但 `_tick_construction` 語意是 person-ticks（每 NEAR_CADENCE 扣 pop）。FACILITY_DEF ticks ÷10（farming 72 / workshop 168 / mid 336 / mint 720）→ pop=1 時恰為 spec 天數，人多更快。

## 與 spec 的差異

- `_facility_deficit` 各 threshold 為實作時自訂 TEST VALUE（spec 只給訊號方向）：藥坊 medicine<pop×0.2（×0.5 權重）、武器坊 0.6−armed_ratio、護甲 pop×0.3、冶煉 pop×0.75 steel、mint 公庫 ore>10、stable pop×0.5 mounts
- 「近期威脅」實作為：combat_target / prosperity_target_id 設定中，或 known_reputations 任一 < 0.3
- coin 守恆驗證採「**coin 等值總量**」（coin + ore_gold×20 + ore_silver×5，含 地面/公庫/人身/遺財）— mint 是合法轉換源，等值總量才恆定
- FACILITY_DEF ticks 為 person-ticks（plan 原文數值 ÷10，見追加修復 6）

## 守恆 audit 結果（Task 6 Step 3）

武器/護甲扣減點全列：
- `encounter_system._init_named_unit` / `_init_anon_unit` / `_assign_anon_weapons`：配發進戰場 pool — 正常結束由 `_sync_back_units`（存活+陣亡 anon）與 `_return_pool_equipment`（陣亡 named）歸還 ✅
- **修復 1**：`cleanup_encounter`（投降中止路徑）原不歸還存活單位 pool 裝備 → 蒸發。已加 `_sync_back_units`
- **修復 2**：`_spawn_team_units` spawn 位不足時已預扣的 anon 武器原不歸還 → 已加歸還迴圈
- anon 升等菁英 weapon 需求：check-only 不消耗 ✅；arrows 戰場消耗：可再生資源 ✅

## 行為變化（multi 90 天 ×4 config 實測）

- **NPC 設施建造：baseline 0 → 3 件完工**（merchant：workshop@(4,7)、farming@(4,7)、farming@(6,4)）
- **村莊設施組合差異：2 種**（`farming,workshop` ×1、`farming` ×1）
- **coin 等值總量 delta = 0.00**（全 4 config，含 mint 匯率折算）
- game_sim_test / tyrant / warzone 設施 0：NPC faction leader 只擁軍用據點（weaponsmith/smeltery 需 tools 3，開局無 tools，90 天內貿易鏈未成形）— **預期行為**（spec 軍民互賴：軍鎮需向民間買 tools）
- 軍屯派駐：military tile residency 只 dispatch 不 invite（warzone 實測 Team2 派子隊安頓軍堡）
- 生產人力 gate：無居民 outpost 的 mint/stable/製造停產

## 驗證

- headless_test：`=== DONE ===`、全 Facility Task1a–6b 通過、無 SCRIPT ERROR
- game_sim_test：`ALL INVARIANTS PASSED (violations=0)`
- game_sim_multi 4 config 跑完無崩潰；CoinAudit delta 0.00 ×4

## 連動風險

- **survival 行為變化**：站在自己工地的團不再被飢餓中斷建設（warning + urgent 都不中斷）— 影響範圍僅 `construction_team_id == 自己` 的 team；可能讓極端飢餓團蓋完農田才去乞食
- **復工召回**：`_try_resume_construction` 會以 transition 強制中斷 owner 的 貿易/製造/生產 任務 — 貿易夥伴等待方有 cooldown 自癒，但中斷頻率與 infra cadence（500 ticks）綁定
- `text_ui_main.gd` / `player_query_api.gd` 仍用 upgrade_farming/upgrade_manufacturing 指令名（wrapper 保留可用）；UI 無新 8 設施面板 — 玩家尚不能蓋藥坊/軍工設施
- construction_target 舊 action 字串（upgrade_farming 等）統一為 `upgrade_facility` + facility 欄位 — 讀 action 字串的 UI/外掛需注意
- `_check_food_shortage` 等舊 trigger helpers 成死碼（`_test_facility_def_registry` 仍引用，未刪）
- stable 產出 gate 在 `tick_all` 層；直接呼叫 `produce_stable_day` 不受 gate
- NPC 經濟長期飢餓（days_left 常駐 0–3）為前置狀態，本次只繞過不解決 — 見 known_issues 候選

## 待主 session 確認

- slot 數 / 地利係數 / 缺口門檻 / 三級成本 / score 門檻 0.05 / 復工 cadence 全 TEST VALUE tune
- 武器/護甲銷毀 audit 兩處修復是否合意（投降方裝備不被沒收，僅 30% food/coin/goods 轉移）
- 追加修復 3/4/5 的設計位階（evaluation 擴到 owner 團、就地施工、survival 建設豁免）— 實作時為達驗收所需，超出 plan 原文，請確認是否回寫 spec
- 軍用設施 90 天 0 建造（tools 鏈未成形）→ B 期觀察項或加 tools 種子？
- 玩家 build_facility UI 面板是否補 8 設施清單（player_api_mapper actions 目前僅 farming/manufacturing）
- B 期依賴：apothecary dormant 待 herb；stable terrain_fit 已含 wild_horses ×3
