# Hand Back: P2a survival options（投靠/紮營/乞食）

branch: `feat/p2a-survival-options`（已 push，未 merge）

## 實作摘要

純加三個 unified-隊 engine option，補齊絕境 repertoire。無家深危 unified 隊按 leader 人格分流（義氣→投靠、野心→紮營、墊底→乞食），不再餓死。

改檔（每檔一行）：
- `scripts/simulation/decision/terms.gd`：加 3 常數（`DESPERATION_DAYS=3.0`/`DESPERATION_SCALE=1.2`/`BEG_FLOOR_FACTOR=0.5`，皆 TEST VALUE）+ eval 3 term（`join_drive`/`camp_drive`/`beg_drive`，共用 desperation magnitude）+ weight 3 key（`join`/`camp`/`beg`，對齊既有 `_join_pref`/`_camp_pref` 公式）。
- `scripts/simulation/decision/decision_context.gd`：加 7 絕境目標欄（strong_neighbor/farmable/aid 三組 has+id/pos）+ gather() 複用既有 finder（`_find_strong_neighbor`/`_find_unowned_farmable_tile`/`_find_aid_target`），共用單一 `_fa` 局部。
- `scripts/simulation/decision/options.gd`：REGISTRY +3 row、applicable +3 guard（皆 `food_days<DESPERATION` gate；紮營另 `not has_own_outpost`）、to_task +3 對映（投靠/乞食帶 `combat_target`，複用 P1 既有接線）。
- `scripts/simulation/faction_ai_system.gd`：**W1** camp-arrival block 由 `_evaluate_survival` 食物計算後 hoist 到 unified gate 前（player early-return 後）→ 引擎派 TASK_CAMP 的 unified 隊到達能立營；**W2** `_decide_unified` 加 player-join guard（投靠目標==玩家隊 → `_maybe_request_join_player` 寫 forced_event，非自動 merge）。
- `scripts/debug/headless_test.gd`：+5 測（term/options/camp-arrival W1/join-player W2/priority）+ 4 helper（manual WorldState 風格，仿 P1）。

## 與 spec/plan 差異

- 測試採 **manual WorldState 建構**（仿 P1 既有 passing 風格），非 plan 範例的 `GameSetup.setup`——避免 GameSetup 預設地形不確定性、給測試完全控制（plan 已授權「必要時 _mk 設 tile」）。assert 內容與 plan 一致。
- 其餘照 plan，無偏差。`DESPERATION_SCALE=1.2` 未調（量級驗序通過，見下）。

## world_sim 2yr 量測（unseeded，看機制 fire 非絕對閾）

- 跑滿 24 月（2yr）`=== world_sim DONE ===`，**存活隊穩定在 7**（非全滅、非塌成全定居）。
- **InvariantViolation = 0**。`[CoinAudit] delta=0.00`（4 config 全守恆）。framework S1–S6 全 PASS、DORMANT=0。
- 三 option 皆 **emergent**：`CrudeCamp` ×3、`SurvivalJoin` ×1（**標記1債 join = 敗隊投靠閉**）、絕境 survival 轉移（→投靠/→紮營/乞食）×2。
- **無 over-camp**：紮營早期少量觸發後世界穩定，健康 unified 隊照貿易/生產，未塌成全定居。
- SCRIPT ERROR = 0。headless 全綠（5 P2a 測 PASS）。

## 連動風險（主 session 決定是否補修）

- **W1 camp-arrival hoist**：唯一結構移動。block 移到食物計算前、不依賴 `days_left`，對所有持 TASK_CAMP 隊成立。non-unified 隊行為**不變**（原即走到此分支）；測 `_test_p2a_camp_arrival` 驗 unified 隊立營 fire。風險低，但建議主 session 確認 non-unified 主動紮營（SoloAI PRIO_DISPATCH）回歸測仍綠。
- **W2 player-join guard**：`_decide_unified` 一處。對齊舊 `_maybe_request_join_player`（同格 + 無 pending forced_event）。對玩家 UX = 流民求投靠走 forced_event 由玩家決定收留。風險：若玩家已有 pending event 則該輪跳過（既有行為），NPC 不卡（次輪重評）。
- **DESPERATION_SCALE 量級**：1.2 × weight(≤0.84) → drive util ≤~2，對齊 survival 域、不碾壓 forage(覓食 util 危時可達 8)/restock(返家 util 6)。驗序：有家→返家補給支配（`_test_p2a_survival_priority` PASS）、無 forage tile 時覓食 skip→人格分流 join/camp/beg。覓食仍 magnitude 最高（有獵場時優先），符合 spec。

## 待主 session 確認

- **係數調否**：`DESPERATION_SCALE=1.2`/`BEG_FLOOR_FACTOR=0.5` 目前驗序通過，未調。若後續平衡 pass 要絕境 option 更積極/更克制可動。
- **P2b 退役雙 owner 起點**：本 plan **未**退役舊 `_evaluate_survival`/`_trigger_survival`、未動 ~20 test 直呼點、non-unified 路徑零改（scope guard）。P2b 接手退役雙 owner。
- **不做項**（spec 明確排除）：hunt（無 TASK，P2b）、exemption 鏈、新 TASK_*、finder/crude-camp 機制改。
