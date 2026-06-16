# Known Issues

> 最後更新：2026-06-16 | **本檔只列開放項**。已修項（✅）移 `docs/archive/resolved_issues.md`（保留根因/修法/教訓,可搜尋）。
> 來源：動態測試 + code review + QA harness 遍歷。
> **仍有效真 backlog**：Bug2(salary floor 後果)、Bug5(休眠)、W4(promote/train + leader 駐留)、W3(dist tune)、P5 C-1~C-6(玩家自隊 task 對稱)。
> **圖形 Main.tscn 項 moot**：`run/main_scene = TextUI.tscn` → S5/U5/U6/U7/U8/U9 等 graphical 項凍結,復活圖形 UI 才解。


## 🔴 高優先（影響基本可玩性）

### P4 玩測批（2026-06-16 玩測抓,主 session harness 驗修中）
- **U16 地圖視野不以玩家為中心** ✅ 真修(viewport,見下 U16)。
- **P4-1 demand_tribute forced event「未知提案類型」** ✅ 修(`_accept_diplomacy` 加 "demand_tribute" case + framing「要求納貢」)。
- **P4-2 打獵選項混在 team 互動選單中** ✅ 修:`_interact_action_split()` 分離 self/原地動作 vs team-target;self-actions 在目標選擇階段直接可選,team-focus 只顯 team-kind。ui_flow 驗。
- **P4-3 跟其他 team 互動缺乞討等生存選項(選項不全)** ⚠ 開→roadmap:玩家無「乞討/投靠」等主動生存動作(對稱性缺——NPC 會,玩家不能)。**非「已有功能 UI 落差」,是缺玩家 command(新 feature)** → 對稱性,需設計 spec。
- **P4-4 遭遇戰到邊界不會停** ✅ 修:encounter_view 移動 target + attack_select 游標加 `_is_in_map` clamp。GUI clamp 邏輯確,視覺待玩測。
- **動作 UI 覆蓋保證**:新增 `_test_action_ui_coverage`,47 registry actions 全驗有 UI 路徑(防未來新增漏接)。
- **「等很多」**:玩測尚有未列出問題,待用戶補。
- **狀態**:U16/P4-1/P4-2/P4-4 已修 + harness 驗;P4-3=對稱性 feature→roadmap;覆蓋測保證已有功能全可達。

### P5 QA批（2026-06-16 QA session harness 系統遍歷，stage2 驗收抓）
> ui_flow 31/31 全綠但漏抓——測試只驗「能呼叫/字串含關鍵字」，不驗端到端守恆與主場景路徑。
- **B-1 收留撞 pop_cap：扣糧成功但 0 人併入 + msg 謊報**（高，守恆紅線）。`_accept_join_request`（player_command_system.gd:757/760/763）先用意圖值 `from_team.population` 算 cost/joined，再呼 `merge_teams`→`_merge_into`（capacity<=0 時 transfer=0 啥都不轉但仍 return）→ 食物已先扣（憑空蒸發）+ msg 謊報人數。修向：cost/joined 改 merge 後量測 delta；或 merge 前驗 capacity，0 容量直接拒。
- **A-1 記名招募在主場景 TextUI 死路**（高，stage2 核心迴路斷）。`recruit` 回 payload menu(has_willing_named/anon_available)，但 `text_ui_main.gd` team-target handler（916-977）不消費此 menu，只 `_log_event` 後清 target。`recruit_named` 唯一路徑 `execute_action_with_target`（member-kind）text UI 從不呼 → 記名招募完全不可達。功能寫在停用的圖形 `main.gd`（show_recruit_panel:115-142）。`recruit_named` 不在 registry → `_test_action_ui_coverage` 抓不到。修向：把 recruit menu 消費搬進 text_ui_main。
- **C-1 玩家無設自隊 task command**（高，對稱性，keystone）。registry 無 `set_task`/寫 `pt.current_task` 的 command；NPC 自動設 TASK_FORAGE/TASK_CAMP/TASK_TRAIN。連鎖鎖死 C-2/3/4。→ roadmap（需 spec，同 P4-3 對稱性 feature 模式）。
- **C-2 紮營 establish_crude_camp**（中）/ **C-3 覓食 forage**（中）/ **C-4 anon 升 tier train/promote**（中）：NPC 會、玩家 registry 無對應；皆 task-shaped，C-1 的 task menu 一併解 → roadmap。
- **C-5 安撫村莊 pacify**（低）/ **C-6 主動定居 resident**（低）：對稱缺口 → roadmap。
- **狀態**：B-1/A-1 → 立修（feat/qa-p5-fixes）；C-1~C-6 → 對稱性 roadmap，待 spec。

### W4. Faction leader 行為性貧窮 — 建造解鎖極慢 ⚠ 部分修（2026-06-13 economy-bootstrap）
- **症狀**：2 年 multi 派建造子隊 = 0；失敗原因 log（本批新增）顯示全是 material < cost×1.5（leader material +0.2/day 涓滴，門檻 75 要爬數年）
- **根因**：leader team 常駐外面（迎戰/乞食/逃跑），不在 outpost tile → collect 收入 0；material 只靠稅/貿易涓滴
- **修（部分）**：faction leader 補「治理」回家路徑（公庫<75 + 不在家 + idle → 回家攢公庫）；自給階梯讓無 tools faction 先蓋民村→工坊→產 tools→後期軍鎮
- **驗證**：2 年設施完工 2→4（merchant 自然長出 workshop）；但限**常駐型 leader**（merchant）有效
- **遺留**：遊牧軍閥 leader（tyrant/warzone 好戰高）永遠在外迎戰，從不 idle 在家 → 治理觸發不到、建造仍 0。需 leader 駐留行為 spec（強制週期回防/或建造資金走 faction 共同出資）才能根治

### Bug2. salary 拖 coin 無下限
- **症狀**：integration test merchant min_coin=-49 / warzone min_coin=-42（90 天）
- **根因**：salary 系統發薪前不檢查 coin >= 0；新團 `[Split]` 出來特別易負
- **影響**：經濟守恆破，新生團體永久赤字
- **發現**：2026-06-09 integration test
- **驗證（2026-06-15）**：**floor 已修**——`salary_system:65/75` 已 `maxf(coin−paid, 0.0)` → coin 不再為負。剩「欠薪後果」(發不出薪 → loyalty/離隊/anon 補充停)= 設計 spec,未做。
- **狀態**：負 coin 缺陷 ✅；欠薪後果 → 路線圖 spec

---

## 🟠 中優先（影響遊戲合理性）

### S4. 人口分裂太快
- **症狀**：main.gd 開局 3 team，tick 10 開始自動分裂，tick 30 已有 10+ team
- **根因**：PopMgmt 分裂條件觸發太容易；10 人就能分裂出子隊
- **位置**：`scripts/simulation/population_system.gd`
- **勘誤（2026-06-15）**：描述過時。現 population_system 無「pop10 分裂」,改 **overflow-based**(`check_overflow`/`_create_overflow_team`,超 cap 才溢出建團)。且症狀指 graphical `main.gd` 開局 = **moot**(TextUI 為 `main_scene`)。如仍嫌溢出太快屬另議 tune。

### S5. main.gd test setup 無 outpost → 12.5 天必定斷糧
- **症狀**：300 food / (10人×0.1/tick×24tick/天) = 12.5 天；斷糧後人口死亡，UI 失效
- **根因**：`collect_resources` 只採 outpost 格，test setup 沒建 outpost
- **位置**：`scripts/ui/main.gd`（test setup）
- **建議**：加初始 outpost，或大幅增加初始食物（如 10000）
- **勘誤（2026-06-13）**：症狀數字（0.1/tick×24）為 2026-05 舊 prototype 行為；現行 burn 為 `FOOD_PER_PERSON_PER_DAY=2.4`/人/天，斷糧後的人口死亡鏈已由 2026-06-13 famine-death spec 補實（團級 famine_days minor/anon 耗損 + named hunger→blood 餓死，grace 7 天）。

### U4. 地圖移動後有時消失
- **症狀**：移動幾次後地圖變黑、旗子消失
- **根因**：player person 因食物不足死亡 → `player_tid=-1` → `discovered=[]` → 地圖全黑
- **連動**：S5（食物）是主因；player 無死亡保護是次因
- **勘誤（2026-06-13）**：「player 無死亡保護」為 2026-05 舊 prototype 行為；現行 famine-death spec 下，玩家 leader 餓死（blood=0）走既有 `_handle_player_leader_death` → `choose_heir` forced event（凍結世界等選繼承人），非靜默 `player_tid=-1`。地圖全黑殘留問題如仍存在屬 UI 層獨立議題。

### U5. 右側欄資訊不完整
- **缺少**：玩家 HP（body_parts 狀態）、attributes/values、skills
- **缺少**：team 完整資源列表（只顯示部分 key）
- **缺少**：faction 狀態（隸屬、等級）
- **位置**：`scripts/ui/right_sidebar.gd`

### U6. 圖塊資訊只有地形
- **缺少**：tile.resources（food/material/ore 庫存量）
- **缺少**：地形速度減益係數（plains 1.0 / forest 0.7 / mountain 0.4）
- **缺少**：outpost 類型/等級/擁有者
- **缺少**：harvest_factor（農業效率）
- **位置**：`scripts/ui/bottom_bar.gd:show_tile_info`

### Bug8. _test_on_team_extinct_to_storage 失敗 = stale test（非碼 bug）
- **症狀**：headless `food 應進公庫` assert 失敗
- **驗證（2026-06-15）**：**非碼 bug,是測試過時**。W6 重構後 `_on_team_extinct` 只標記 `teams_pending_erase`,實際路由延到 `cleanup_extinct_teams → _route_extinct_assets`(邏輯正確,進公庫)。測試只呼 `_on_team_extinct` 沒呼 `cleanup_extinct_teams` → 路由沒跑 → assert 失敗。
- **修**：測試加呼 `fai.cleanup_extinct_teams(state)` 再斷言。assert 值(50 food/30 coin)正確,「勿動」誤解除——值對,只缺呼全路徑。無守恆風險。

### U19. 強制事件無選單 → 卡死（H, blocker, 2026-06-14 run-verify 新發現）
- **症狀**：強制事件（乞食/繼承/勒索回應等）觸發但畫面無選單，一直卡（choose_heir 還凍世界）
- **根因**：`text_ui_main._process`（154-160）pre_encounter/encounter_active 有自動進模式，**一般 `forced_interaction` 無對等自動進選單** → 只顯「⚠強制事件」hint，玩家無從回應
- **修向**：`_process` 偵測 `forced_interaction` 非空 → `cancel_advance` + 進 forced-response 模式（仿 pre_encounter）；新 `_forced_mode` + handler 列 `forced_interaction.responses` 供選

### U10b. 全 Team 死亡直接退出（edge，2026-06-14 run-verify）
- **症狀**：遭遇戰中玩家全隊死亡 → 直接退出（應走 game-over / choose_heir）
- **修向**：encounter 結算偵測玩家隊全滅 → 接 `_handle_player_leader_death`/game-over，非靜默退出。低頻 edge

### U11b. 戰報 label 未顯（U11 修了但 GUI 沒出，run-verify）
- **症狀**：`_lbl_log` 戰報已加+wire（query_encounter_log）但玩家戰鬥沒看到
- **疑因**：encounter_log 玩家戰鬥未填 / facade 回空 / label 被佈局擠出。需 GUI 查
### U12b. 交易仍跳無資源（U12 direct preview 修沒對症，run-verify）
- **症狀**：互動→交易仍誤判。direct preview 加了但 text_ui trade 流可能仍走舊 path
### U13b. 裝備穿脫僅玩家，NPC named 成員無入口（run-verify）
- **修向**：member 面板加成員 equip/unequip（equip_item slot 已支援,需 member-target UI）
### U14b. 主畫面看不到自 team 武裝數（U14 reframe + U18，run-verify）
- **症狀**：玩家想在平時 UI 看自隊武裝 anon 數,非進場後。併 U18（武裝 anon 指令）+ status 顯 armed 數

### U18. 玩家無法武裝 anon（UI/指令皆缺）
- **症狀**：找不到 UI 武裝匿名兵
- **根因**：`armed_anon_ratio`/`equip_order` 由 `faction_ai` 為 NPC 自動設，**玩家無指令**（grep `player_command_system` 空）→ UI 自然無入口。同 S9 調薪類缺口
- **修向**：補 `player_command_system` 設 armed_anon_ratio/equip_order 指令 → 再上 UI。屬 P3 全動作覆蓋前置（sim 側缺口）
- **優先**：M

### U9. 圖形 Main.tscn UI 仍 reach-through raw WorldState（邊界債）
- **症狀**：`main.gd`/`encounter_view.gd`/`popup_layer.gd`/`debug_bar.gd` 大量 `_bridge.get_state()` 直讀 raw `WorldState`（body_parts/units/world.current_tick）→ 違反「UI 只經 player API」invariant（2026-06-14 新增）
- **狀態**：text_ui 已清（P1）；圖形 UI 未清。text-UI-only 階段不影響
- **優先**：M — 若推圖形 UI 或全面套 UI 邊界 invariant 才需解耦（範圍大,涉 encounter tactical view）。另案

### W7. 覓食 vs 乞食 仲裁（forage-foundation 遺留）
- **症狀**：`_find_forage_tile` 周圍無食物時仍回本格 → 小隊（pop≤15）恆覓食、不到乞食 Path4。枯竭區小隊空覓而非乞食富鄰
- **狀態**：2 年 multi 實測世界穩定（died=no、未顯退化）→ **暫不動，留量測**。主 session 曾試加 `best_food` 門檻使無食物回 -1,-1，但會弄紅 3 個依賴「urgent→SURVIVAL_TASK」的 baseline 測試（那些測試 setup 無食物 tile）→ 還原。要修需同步重整那批測試語意
- **優先**：L — 量測顯問題再開

---

### Bug5. DiplomacyAI demand_tribute 恆負
- **症狀**：90 天 120 次 evaluation，分數恆 −0.15（power_r=0.40, caution=0.80, pride=0.50）
- **根因**：caution=0.80 權重壓制 score 恆 < 0；同一決策每次重算同值
- **影響**：強者不勒索，AI 過保守
- **發現**：2026-06-09 integration test
- **結案（2026-06-15 量測）：非缺陷,原症狀誤判。** 經 warzone 整場量測:
  - **NPC demand_tribute 發起 = 0 次**。收方公式(`:129` `d_score=(power_r−1)×0.4 + caution×0.3 − pride×0.3`)其實**正確**——拒絕弱者勒索合理。舊「score 恆 −0.15 過保守」= 把正確的收方行為當 bug(−0.15 正是 power_r=0.4 弱者來勒索的應拒值)。
  - 真實狀態:**NPC 勒索機制休眠**。唯一發起點 `try_proactive_diplomacy:68` 被三重掐死:早 return(score>0.6 結盟/>0.4 貿易先返)、U20 同格 gate、**方向反**(`power_gap>0.5`=other 較大才發 → 弱勒強 → 必拒)。
  - **不破壞任何東西**(世界穩),屬休眠機制非 defect → **關閉**。要活化 NPC 勒索 = 設計題,見路線圖。

### W3. BREAKOUT_DIST / ENCIRCLE_DIST tune
- **症狀**：常數調為 2/1 適配 radius 4 測試地圖；正式地圖 radius 可能不同
- **發現**：2026-06-10 NPC wakeup
- **建議**：改 `min(N, map_radius)` 動態計算

### W4. NPC 不主動 promote / train
- **症狀**：multi 90 天 tier promotion = 0；戰場升等 0（因 0 combat），訓練 task 0 派
- **根因**：NPC AI 無 promote/train 決策邏輯
- **發現**：2026-06-10 anon tier merge 後
- **建議**：faction_ai 加 leader 個性 + 物資 自動評估 promote/train（接 W1 解了戰鬥才有戰場 exp）

## 🟡 低優先（體驗問題，不影響可玩性）

### U7. Camera 每 tick 強制回正
- **症狀**：每次推進 tick，鏡頭自動對齊玩家，無法保持手動視角
- **根因**：`refresh()` 每次呼叫 `_center_on_player()`
- **建議**：改為只在玩家移動時重置，或加 C 鍵手動回正

### U8. Members/History popup 待確認
- **症狀**：按成員按鈕可能不顯示 popup（已加 print debug，尚未確認）
- **位置**：`scripts/ui/popup_layer.gd`

### D1. SoloAI 保護條件脆弱 ⚠ 部分緩解（2026-06-15 驗證）
- **症狀**：`team.leader_id == state.player_id` 在子隊分裂後可能失效
- **根因**：subteam 分裂可能重新指定 leader_id
- **位置**：`scripts/simulation/faction_ai_system.gd:_evaluate_solo`
- **驗證（2026-06-15）**：部分點已加 `named_members` fallback(`:1049` `leader_id==player_id or player_id in named_members`)+ player_id≠−1 守衛(`:141`)。但 `_evaluate_solo`(`:907`) 仍只查 leader_id → 邊緣仍脆。低優先。

### A1. agent_repl stdin 模式 stdout 污染
- **症狀**：stdin 模式下模擬 `print()` 混入 JSON Lines stdout，污染協定
- **根因**：GDScript `print()` 寫入 stdout；stdin REPL 與模擬 print 共用同一 fd
- **影響範圍**：僅限 stdin 模式（Windows headless 走 TCP fallback，實際不受影響）
- **位置**：`scripts/debug/agent_repl.gd:_run_stdin_loop`
- **建議**：加 `--quiet` flag suppress 模擬 print，或在 stdin loop 前重導向 print 到 stderr

### S9. 玩家 team 名 NPC 薪資 UI
- **症狀**：玩家無法調整 named NPC 薪水，預設 0 → 自然扣 loyalty 直到叛逃
- **設計意圖**：玩家管理 loyalty 的關鍵手段（過薪換忠誠）
- **建議**：team panel 加每個 named NPC 薪資設定，顯示「目前 / 公平」比值

---

## Movement

- **mounts/wagons 速度**：⚠ 部分修（2026-06-15 驗證）。`_compute_team_speed`(`movement:138`) 現已 `× _compute_mount_bonus(team) × _compute_wagon_penalty(team)` → mount 加速、wagon 拖速**已有**。
  - **遺留**：speed_class（步兵/騎兵/輜重分類）仍缺——同隊內騎/步未分速,只算隊級平均 bonus。完整 unit-level speed_class 待 spec。
  - **發現**：2026-06-10 combat-engagement；2026-06-15 驗證 mount/wagon bonus 已實作

## 待 spec（按優先排序）

| 優先 | spec | 解的問題 |
|---|---|---|
| **H** | NPC 會合/攔截 | W1 + W2（0 Combat / 0 Trade）|
| **M** | mount 公庫系統 | mounts 改為 outpost public_storage（採集 / stable 產出 → 公庫，team 出征前 withdraw）；同時加 outpost 鄰格 wild_horses 自動採集 |
| **M** | 設施改制 B 期（材料層）| herb / 野馬群 圖塊資源 + 戰馬/野馬分離（民用馬廄馴野馬、軍用馬廄練戰馬）+ wagons 合成（野馬+mat+tools）+ medicine 配方接 herb。依賴 A 期 spec：2026-06-12-facility-overhaul |
| **L** | 信用貨幣（勢力券）| 各勢力自行發行、互不承認；coin 維持硬通貨總量固定。等 slot 專業化讓貿易量起來（C 期驗證）後再做。敘事接點：金銀挖完 → coin 通縮 → 勢力發券的歷史動機 |
| **L** | 新礦發現事件 | 低頻事件：tile 探出新礦脈（每脈有限量）— 後期擴張動機 + 淘金熱戰爭誘因，不破壞稀缺性 |
| **L** | 裝備回收鏈 | 戰損裝備 → 廢鐵 → 折損重煉（80%）。只在未來引入「銷毀事件」時才需要（守恆審計後現無銷毀）|
| **L** | goods 消費 sink | goods 目前純財富品無功能消耗；後續可加奢侈品 → named loyalty/滿足加成 |
| **L** | 子隊居民團 leader 留/回個性評估 + 合併 | outpost-residency-ai (ii) → (iii) 升級：流民駐紮後子隊 leader 個性決定留下（合併或共處）或回母團 |
| **L** | Residency dispatch print spam | NPC AI 派子隊到 outpost 後 sub pathing 失敗 / 母團 mobile，子隊未 settle → outpost 仍 missing resident → cadence 重派；in-flight check 在 sub task 被改 idle 時失效。invariant 過，但 print 多 |
| **M** | 人口循環受窮困抑制 | minor 長大簡版已實作（每月 10% → 平民，2026-06-12）。但 multi 90 天 0 次長大：reaction 收斂後世界窮 → P5 生育的糧食盈餘條件（>7 天份）幾乎無人達標 → 無小孩可長大。需 harvest/初始糧 tune 讓富裕村能生。完整人口結構 spec（性別/生育年齡）仍待 |
| **M** | task 優先權仲裁（Spec A）| current_task 被 5+ 系統互蓋（reaction bridge / faction goals / strategic dispatch / threat / survival），白名單散落。設計已討論（優先表 100 戰鬥/80 存亡/70 威脅/60 玩家/50 派遣/30 勢力/10 閒置 + 每層釋放條件），待 reaction 收斂後實作 |
| **M** | trade 三層問題殘餘 | TASK_TRADE 加入 faction_ai:660 exclusion（1 行）；trade partner 改限「tile 上有居民團」；DiplomacyAI reject cooldown；Equip print diff check |
| **M** | unrest / 抗命 玩家可見性 | unrest 完全沒露出 player API/UI。自家 team → team_stats 加欄位；同 faction → intel unrest_est；外人 → 躁動傳聞 message。[抗命] 事件玩家通知。等 UI batch |
| **L** | NPC 對 NPC 抗命 | arbiter 抗命窗口只開「50 挑戰玩家 60」；NPC leader 對 NPC 上級命令的抗命（50 vs 50 個性判定）後續另議 |
| **M** | encounter-engagement 後續 | 攔截方反追（prey 預測 attacker）；戰報廣播；玩家版反應 UI |
| **H** | salary 欠薪後果 | Bug2 |
| **M** | NPC promote/train AI | W4 |
| **M** | DiplomacyAI 平衡 | Bug5 |
| **M** | multi runner schedule 注入 | Bug6 |
| **M** | 戰場 mount unit-level | encounter 騎兵 unit + 衝擊 + 機動 + 戰場死亡（mounts/wagons spec 後續）|
| **L** | mount 細分 | 戰馬/馱馬/拉車馬；輕車/重車；草地補糧；城市買飼料 |
| **M** | named 升階機制 | anon tier spec 列後續 |
| **L** | tag drift | leader / event 改 tag |
| **M** | 團 vs 團突襲優勢 | 對稱：野獸伏擊已實作（AmbushSystem，2b-2）；團對團伏擊待做 — reuse `vision_system` 偵測（潛行降 exposure / 偵查偵測）+ 攻擊方未被偵測 → 首擊/陣位優勢 + 激活 dormant `_check_night_raid`。屬階段2+ 劫掠/戰團。**注意：團伏擊用 vision 偵測，非 beast 專屬 AmbushSystem** |
| **M** | AI 目標錨（策略延續②深層） | SoloAI 承諾慣性（solo_intent 加成，spec soloai-proactive-home）止短期 flip-flop；更深的「持久 goal 錨」（隊有慢變長期目標如稱霸/安身/致富，task 選擇朝 goal-aligned 跨多 tick）= 接 dormant `npc_ai.get_goal_task_override`。**先量測承諾慣性夠不夠再做**。**極克制 — 一個慢變 goal 欄位+偏好加成，非多層規劃器**（防戰略引擎無底洞） |
| **M** | 山村採礦換糧特化經濟 | 山地 food regen 低（種田餵不飽），真實山村靠採礦/畜牧→交易換糧（進口糧）。現食物模型只「收本地糧」→ 山村必餓。需缺糧村自動 trade ore→food / 進口糧 AI。階段3+ 經濟深度。現階段 explicit 村用 `outpost.terrain` 釘可農地規避 |
| **L** | 戰俘處置 | 賣/屠/招降 |
| **L** | 外交招募 / 雇傭軍 | 直接買高 tier anon |
| **L** | anon tier UI | team panel / 升等進度 / 死亡分檔 |

---

## 待討論（設計決策）

| 問題 | 選項 A | 選項 B |
|---|---|---|
| S1 視野門檻 | 降至 0.3（保留距離衰減） | 移除衰減，範圍內直接可見 |
| U7 Camera | 每次 tick 回正 | C 鍵手動回正 |
| D2 player 死亡 | Game Over 畫面 | 自動轉移到新角色 |
| S4 人口分裂 | 提高門檻 | demo 期間停用 |

