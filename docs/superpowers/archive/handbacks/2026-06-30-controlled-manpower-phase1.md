# Hand Back: 受控人力統一系統 Phase 1（anon 吸收解 (a)）

> branch `feat/controlled-manpower-phase1`。純 anon、零跨域。解 (a)＝征服吸收敗方 anon → 同化併主團 free pop → 征服 pay。

## 實作摘要（改了哪些檔案）

- `scripts/data/team_data.gd`：新增 `captive_groups: Array`（元素 Dict `{cohorts, morale, origin_faction, entry, treatment_history}`）。**population getter 不計 captive**（既有 getter 只投影 leader+named+anon_cohorts，captive 隔離=非戰力，零改 getter）。
- `scripts/simulation/anon_tier_system.gd`：常數 `CAPTURE_RATE=0.5` / `CAPTIVE_INIT_MORALE=0.25`（TEST VALUE）。守恆 API：
  - `absorb_as_captive(state, holder, loser, rate)`：按 rate 逐桶從 `loser.anon_cohorts` remove → 組 captive_group append 到 holder（loser↓ == captive↑，保 tier|health 鍵）。
  - `assimilate_captives(holder, group)`：group.cohorts 各桶 `AnonCohort.add` 進 holder.anon_cohorts（captive→free pop，解 (a)）→ erase group。
  - `detach_captives(holder, group, fraction)`：暴動/逃 部分脫離（回脫離 cohorts dict，caller 路由）。
  - `total_captives(team)`：遙測/guard 用查詢（不入 pop）。
- `scripts/simulation/npc_combat_system.gd`：`_end_combat` 敗方陣亡結算（`kill_random`）後、`_apply_pursuit`/`_try_subjugate` 前插入 `absorb_as_captive(winner, loser, CAPTURE_RATE)`。
- `scripts/simulation/manpower_system.gd`（**新檔**）：
  - `decide_treatment(state, holder, group)`：means-end driver。缺糧（food_per_cap<0.5 含 captive 口）→「釋放」；否則厚待 util(`0.3+野心*0.6-殘忍*0.4`) vs 苛待 util(`0.2+殘忍*0.7-野心*0.3`) argmax → 「厚待」/「苛待」。
  - `tick_captives` / `tick_all`：morale 閾軌跡。厚待 +0.02、苛待 −0.015；morale≥ASSIM_T(0.75)→同化；≤REVOLT_T(0.08)→暴動（脫離+REVOLT_COMBAT_LOSS=0.4 鎮壓亡+holder unrest+逃散成流民隊）；≤FLEE_T(0.2)且機會（看管薄/readiness<0.4）→逃（FLEE_FRACTION=0.5 流民隊）；釋放→全脫離流民隊。`treatment_history` 記待遇（provenance）。
- `scripts/simulation/sim_runner.gd`：`_step_captives` → `ManpowerSystem.tick_all`（每日 cadence，內部 gate），tick 末、cleanup 前。
- `scripts/simulation/invariant_audit.gd`：`_check_captive_cohort`（captive_groups cohorts 鍵合法 + count>0；captive 不入 population 故 _check_population 看不到，此網守底層完整性）。
- `scripts/debug/headless_test.gd`：4 個 mp1 測（absorb_conserves / treatment_trajectory / treatment_driver / believability）+ helpers。
- `scripts/debug/warring_states_seed.gd`：加 p1.assimilate/revolt/flee probe 印（(a) 量測）。
- `docs/progress.md`：Phase 1 狀態。

## 守恆驗證（命脈）

- **吸收守恆**：`_test_mp1_absorb_conserves` — loser 掉量 == captured（captured=10，loser pop20→10），captive 不入 winner.population。✅
- **同化守恆**：同化後 winner.population == winner_pop0 + captured（解 (a)）。✅
- **暴動/逃守恆**：苛待 60–80 tick 後 captive 全脫離，holder 戰力 pop 不變（非白增同化）；breakaway 流民隊 pop ≤ 原 captive（鎮壓亡部分=真死亡路由，非憑空消）。✅
- **InvariantViolation=0**：`game_sim_multi` 4 場景（game_sim_test/tyrant/merchant/**warzone**）違反取樣總計=0。warzone 有戰鬥→吸收→captive 軌跡實跑，仍 0。✅
- **coin_eq delta=0**：4 場景全 delta=0.00。✅
- **captive 不計 population**：getter 不變（隔離），InvariantAudit population drift 不觸。✅

## (a) 量測（climb / warring seed）

> **誠實標：(a) climb/warring seed 量測未完成。** climb_diagnose（12 sim-yr=86400 tick）+ warring_states_seed（172800 tick）在子 session 內背景跑逾 5+ 分鐘未收斂（sim 極重），子 session 未取得 CONQUER/能人 pop 累積數字。**主 session 必須重跑驗收 (a)**：
> - `$env:GODOT_TIMEOUT=1500; .\tools\godot.ps1 --headless --script scripts/debug/climb_diagnose.gd`（讀「能人最高 rung 分布」是否突破 rung2＋pop 累積）
> - `$env:GODOT_TIMEOUT=3000; .\tools\godot.ps1 --headless --script scripts/debug/warring_states_seed.gd`（讀意圖分布 CONQUER 0→? ＋ probe p1.assimilate/revolt/flee）
> 子 session **未**宣稱 (a) 已解——只證機制就位 + 守恆。**(a) 數字驗收待主 session。**

- **機制就位驗證**（headless + believability 測證）：征服→吸收（npc_combat 插入，[P1Absorb] print）→ 厚待同化（[P1Assim]，captive→free pop，征服 pay）/ 苛待暴動逃（[P1Revolt]/[P1Flee]）全跑通。
- **CONQUER 0→?**：warring seed 意圖直方圖 + p1.assimilate probe（背景量測；見下誠實標）。
- **能人 pop 累積**：climb_diagnose 能人最高 rung 分布（背景量測）。

## headless 全綠

- `=== DONE ===`，無 SCRIPT ERROR/Parse Error。4 mp1 測全 PASS。
- 既有戰鬥/loot/敗損對稱/P2a join 測未回歸（吸收在陣亡後、erase 前，不破 loot/feud/pursuit/subjugate 順序）。
- 預存 `[FAIL] 弱目標未加入攻擊 goal` = **baseline 既有 print-style soft check**（非 assert，DONE 仍達），與本塊無關。

## framework S1-S6

- framework_validation：S1 立國 / S2a feud / S2b vendetta / S3 scout / S4 ambush / S5 mint / S6 order_fulfilled 全 PASS（7/7，DORMANT=0）。

## 與 spec/plan 差異（HOW 說明）

- **captive_groups 非 subteam**：spec §4 受控狀態欄「掛 subteam/cohort」。Phase 1 純 anon→走 holder 上獨立 `captive_groups`（subteam dispatch 強制 named leader + cohort 鍵固化不可擴）。Phase 2 named 俘虜可引 captive subteam。**呈報藍圖知會。**
- **無「仁慈」value**：人格池無「仁慈」，厚待 driver 用 **野心高 + 殘忍低**（野心驅動欲壯兵）。
- **暴動鎮壓戰損**：spec 只說「暴動/逃 = pop 轉移非消失」；實作中暴動脫離後 REVOLT_COMBAT_LOSS=0.4 在鎮壓中真死（守恆＝真死亡路由，非憑空消）。逃散部分成流民隊（TAG_EXILE，無 faction）。
- **encounter prisoner_population 未改走 captive_groups**：plan 提「encounter 對稱插入」。encounter 的 `prisoner_population` 是獨立 legacy per-unit scalar（俘虜收押計數，非 anon cohort 轉移）。**未動**（避免破既有 encounter 測 + 它非 anon-cohort 守恆路徑）。npc_combat 是 (a) 主征服路徑，已接。**列待主 session 裁：encounter 俘虜是否 Phase 2 統一進 captive_groups。**

## 連動風險

- **npc_combat `_end_combat` 插入**：在 `kill_random` 後、`_apply_pursuit`/`_try_subjugate` 前。吸收只 remove loser 殘餘 anon（rate=0.5），loot/feud/pursuit/subjugate 順序與數值不動。`_try_subjugate` 仍把整隊併入 faction（captive 是另外擄走的殘餘，與 subjugate 不衝突——subjugate 是 faction 收編活隊，captive 是隔離 anon 批次）。**風險點**：若 loser 隨後被 subjugate 進 winner faction，captive 與 loser 同 faction 共存——captive origin_faction 記原值，語意仍清。
- **population getter**：未改（captive 不入）。既有 pop 讀者不受影響。
- **暴動 spawn 流民隊**：`_spawn_breakaway` 建 TAG_EXILE 無 faction 隊，註冊 team_known/team_discovered（與 unrest_split `_split_team` 同 pattern）。新隊參與既有 solo AI/erase 流程。
- **holder 死亡時 captive_groups 消失**：captive 不是 holder pop，holder erase 時 captive_groups 隨之消（未路由）。**不破 population 守恆**（captive 從不計入任何 pop total）。但 believability 上「holder 滅團俘虜該獲釋」未做 → Phase 2 stakes（救援/guard-cap）範疇。**列待確認。**

## 待主 session 確認

- (a) climb/warring 量測數字解讀（征服 pay 否 / CONQUER 0→小正 / 能人 pop 累積 / 不 over-war）— 若背景量測未完，主 session 重跑 `climb_diagnose.gd`（`GODOT_TIMEOUT=1500`）+ `warring_states_seed.gd`（`GODOT_TIMEOUT=3000`）。
- 常數平衡（CAPTURE_RATE/CAPTIVE_INIT_MORALE/ASSIM_T/REVOLT_T/morale delta 全 TEST VALUE）：morale 升降速率 vs cadence（每日 +0.02 → 同化需 ~25 天厚待）合理否。
- captive_groups 非 subteam 的 HOW 決策認可否。
- encounter prisoner_population 是否 Phase 2 統一進 captive_groups。
- holder 滅團 → captive 路由（獲釋/被原 faction 救）= Phase 2/3 stakes。
- Phase 2 起點：named 俘虜戲 / 其他 entry 通道 fold / guard-cap·救援 stakes / rung2→3（獨立另案）。
