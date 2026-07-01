# Hand Back: G3 Phase E — enforce（belief 真正驅動決策）

> plan = `docs/superpowers/plans/2026-07-01-g3-phase-e-enforce.md`
> branch `feat/g3-phase-e-enforce`（未 merge，等系統 session 確認）

## 實作摘要

### 補的 5 處 god-view leak（決策改讀 `BeliefSystem.best_estimate`，非他隊真值）
- `scripts/simulation/diplomatic_ai_system.gd`
  - **1a** `try_proactive_diplomacy` demand_tribute 的 `power_gap`：`other.population` → `_get_pop_est(...)`（無估 fallback=self_pop 保守等強→不求貢）。
  - **1d** `handle_diplomacy_message` demand_tribute 回應：收貢方對 sender 實力 `sender_team.population` → `_get_pop_est(...)`（fallback=self_pop 保守）。
  - **1e+Task3** `consider_betrayal` 重寫 + 新 `betrayal_assessment(state, self, ally) -> Dictionary`：盟友實力優先 faction `known_member_states` snapshot（同 faction 共享情報豁免），次 belief est，皆無→最保守不背叛。
- `scripts/simulation/faction_ai_system.gd`
  - **1b** `_find_strong_neighbor`：`t.population` → belief est；無情報→`has_belief` 守衛 `continue`（不列 candidate）。
  - **1c** `_find_aid_target`：`t.population`/`t.resources.food` → belief `population_est`+`food_est`；無 belief 或無 `food_est`→保守跳過。

### Task3 背叛 belief 驅動化（去純 RNG）
- `betrayal_assessment` 純函數（無 RNG）：`driver = 人格(野心/背信/薄義) + advantage×BETRAY_ADVANTAGE_GAIN`（advantage = belief 盟弱我強），`power_gap>0.5` 抑制 −0.3；`confidence = 1−belief uncertainty`。`would_betray = driver≥BETRAY_DRIVE_MIN and confidence≥BETRAY_CONF_MIN`。
- `consider_betrayal`：driver 為主驅（`driver≥BETRAY_DRIVE_HARD`→觸發），僅門檻邊界保留小 stochastic tie-break（取代舊 `betrayal_score>0.65 and randf()<0.1`）。driver 可解釋。
- 新常數（皆 TEST VALUE）：`BETRAY_ADVANTAGE_GAIN=0.6 / BETRAY_CONF_MIN=0.5 / BETRAY_DRIVE_MIN=0.65 / BETRAY_DRIVE_HARD=0.9 / BETRAY_MARGIN_CHANCE=0.3`。
- `_execute_betrayal` 加 `Probe.bump("g3.betrayal")`（率可觀測）。

### 測試（TDD，`scripts/debug/headless_test.gd`）
- 新增 5 測，每處「真值≠belief」兩向斷言決策跟 belief：`_test_leak_tribute_powergap_belief`(1a)、`_test_leak_tribute_response_belief`(1d)、`_test_leak_strong_neighbor_belief`(1b)、`_test_leak_aid_target_belief`(1c)、`_test_betrayal_belief_driven`(Task3：advantage/would_betray/confidence gate 三案)。
- **既有測遷移**（leak 補後決策需 belief，比照 G3-targeting 遷移）：`_mk_strong_neighbor_team` 內建 record_claim；survival 決策樹 Path3(投靠)/Path4(乞食)、find helpers、p2a join_player_forced 補植 belief。

### 文件
- `docs/invariants.md`：Information 段補「決策讀 belief 非真值（G3 Phase E — provenance enforce）」條 + 5 leak 清單 + 刻意豁免清單（同 faction 協調/tally/位置物理）+ 審計手段=回歸測。

## 驗證
- `headless_test.gd`：5 新測綠；全框架 PASS（唯一 FAIL = 基準既有 `[FAIL] 弱目標未加入攻擊 goal`，**非本 phase 引入**，見下）；coin_eq 守恆/pop 守恆/InvariantAudit population+faction+subteam 雙向 OK；`=== DONE ===`。
- warring_states seed：完整 172800 tick 跑因 wrapper 輸出緩衝被 kill 前不 flush（無數字）→ 改跑 **8000 tick**（config 暫調後還原）確認活世界，無 SCRIPT ERROR：
  - 世界不崩：teams 42→107、factions 8→9、established=1（有立國）。
  - 意圖分布 `{CONQUER:1, RICH:0, DEFEND:7, HOLD:1}`（多防衛，合理）。
  - **背叛率合理**：`g3.betrayal=15`（belief 驅動、非 0 非暴增）；`indep.found_ally=4`；`g3.trust_up/down=11743/12628`（G3c 被動口碑迴路正常 churn）；`g3.scout_dispatch=0`（短窗未觸發，非本 phase）。
  - **自信地錯（誠實標）**：本 phase enforce 機制到位（決策真讀 belief，欺敵可有後果），但**未加專屬「按假 belief 行動並被咬」計數器** → 8000-tick 短窗無法量化「自信地錯」emergence。需 Phase D（植假）+ 專屬 probe 才量得到；本 phase 只證「決策跟 belief 走」（回歸測綠）。

## 連動風險
- **`_find_aid_target` 同 faction 施援**：plan 1c 規定 aid 一律走 belief（未如 1e 給 faction snapshot 優先）。同 faction 成員若無 team_intel belief（僅 faction snapshot 有其 food）→ 現會被跳過 → 內政/同盟施援可能弱化。**建議系統決**：aid 是否比照 1e 對同 faction 成員優先讀 `known_member_states` snapshot（同勢力協調豁免）。目前忠實照 plan（belief-only）。
- **背叛率**：driver≥HARD 走 deterministic（舊為 randf<0.1 機率）→ 高野心+薄義+盟弱 leader 背叛更果斷。seed 率見上；若暴增需調 `BETRAY_DRIVE_HARD`/`BETRAY_MARGIN_CHANCE`（皆 TEST VALUE）。
- **`_find_strong_neighbor`/`_find_aid_target` 情報依賴**：無 belief 的鄰居不再被視為投靠/施援對象 → 早期未偵察世界投靠/乞食機會下降（設計預期：不靠 god-view）。survival loot gate 失敗有其他絕境路徑；投靠/乞食無情報→落其他 option 或 idle（觀察 seed 是否卡死）。

## 待主 session 確認
- **基準既有 FAIL**：`_test_...`（headless:~2570）`[FAIL] 弱目標未加入攻擊 goal` 在**改動前 baseline 即失敗**（`_update_goals` commander-v2，非本 phase 5 leak）。本 phase 未觸碰 `_update_goals`。建議另開單追（belief 直設舊式 Dict → 弱目標未加攻擊 goal），或確認為已知刻意行為。
- **審計手段選擇**：plan Task2 給「回歸測 or runtime probe」二選一，實作裁為**回歸測**（`_test_leak_*` + betrayal 測；成本低、可重現）。未加 runtime god-view 掃描 probe。若系統要 runtime probe 可後續補。
- **銜接 Phase D（植假）**：enforce 已使欺敵有後果地基就位（決策真跟 belief 走）。Phase D 植假 primitive/離間/假和 = 下一步，本 phase OUT。
