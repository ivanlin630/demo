# Hand Back: 絕境驅動多元生存行為

Plan: `docs/superpowers/plans/2026-06-14-desperation-survival-behavior.md`
Branch: `feat/desperation-survival`

## 實作摘要

- `scripts/data/team_data.gd`：新增 `const TASK_CAMP := "紮營"`。
- `scripts/simulation/faction_ai_system.gd`：
  - 新增 gate const：`LOOT_GATE/JOIN_GATE/CAMP_GATE`、`CRUDE_CAMP_FOOD_SEED`（皆 TEST VALUE）。
  - `TASK_CAMP` 併入 `SURVIVAL_TASKS`（釋放判定一致）。
  - pref helpers：`_loot_pref/_join_pref/_camp_pref`（values 線性，非決策樹）。
  - `_find_unowned_farmable_tile`（本格+鄰格找無主可農地，山排除）。
  - `establish_crude_camp`（即時立 civilian L1，免建材/免工期，種子糧同抬 cap）。
  - `_trigger_survival`：Path 2/3/3.4/3.5/4 重構為「desperation × values」cascade —
    warning 用個性門檻（pref ≥ gate）、urgent gate=0 解閘；依 pref 高→低試 loot/join/camp；
    墊底序保留 獵獸→覓食→乞食→idle。Path 0（蓋農田）/ Path 1（own outpost 回家）不動。
  - `_evaluate_survival`：加 TASK_CAMP 到達結算（腳下無主可農地 → `establish_crude_camp` + release）。
- `scripts/debug/headless_test.gd`：
  - 新測試 `_test_survival_prefs / _test_find_unowned_farmable / _test_crude_camp / _test_desperation_cascade`（全綠）。
  - 既有 fixture 微調（見下「與 spec 差異」）。

## 與 spec/plan 的差異

1. **既有 survival 測試 fixture 調整**（plan Task4 Step4 已預留「必要時微調並記錄」）：
   - `_test_survival_decision_tree` case 4（測乞食墊底）：aid 隊 pop 10→18，並把周圍格標 `outpost_owner=7`。
     原因：urgent 解閘後，pop10 的 aid 同時符合「弱獵物」→ 被 loot 蓋過乞食；且無主平原會先被紮營搶走。
     改 pop18 使其非弱獵物（≥t4×0.7）、非強鄰（<t4×1.5），周圍標有主排除紮營，才落到乞食。
   - `_test_npc_forage_viability`：把腳下 tile 標 `outpost_owner=7`（level 維持 0）。
     原因：urgent 解閘後小隊在無主平原會「紮營」優於「覓食」（camp 在 cascade，forage 在墊底，by design）。
     標有主排除紮營，才隔離測覓食 pop 門檻。
   - 兩處皆為「新行為正確 → 舊 fixture 過時」的調整，非邏輯回歸。

## 量測（SIM_CONFIGS=survival_start,tyrant,warzone，各 2 年 21600 tick）

| config | died | coin_eq delta | pop init→final | teams_final |
|---|---|---|---|---|
| survival_start | no | 0.00 | 23→21 | 2 |
| tyrant | no | 0.00 | 88→131 | 30 |
| warzone | no | -0.00 | 134→161 | 35 |

- **守恆**：三 config coin_eq delta=0 ✓（crude camp 認領無主地、免建材，未破壞守恆）。
- **無新增 SCRIPT ERROR** ✓（headless test 僅剩 baseline 既有失敗，見下）。
- **行為分佈多元**（三 config 合計）：SurvivalLoot 130 / SurvivalCamp 17 / CrudeCamp 14 /
  SurvivalForage 14 / 乞食 15 / 投靠+SurvivalJoin 9 / BeastHunt 6 — 多項 >0，非全擠一種 ✓。
- **不誤觸**：395 次 [Survival] 觸發全 days_left ≤ 3（=WARNING_DAYS），高糧隊零誤觸 ✓（觸發條件未改）。
- **建村率合理**：CrudeCamp 14（2年×含camp的configs），非遍地建村 ✓。
- **camp 在真 sim 確實生效**：CrudeCamp/SurvivalCamp >0 證明 establish_crude_camp 成功（tile_id 編碼一致）。

## 待主 session 確認

1. **survival_start team0 仍餓死滅團 — 但屬量測 harness 限制，非 cascade bug**：
   - `survival_start.json` 設 team0 為玩家隊（`"player": {"team_id": 0}`）。
   - `_evaluate_survival` 開頭對玩家隊 early-return（NPC 生存 AI 不接管玩家）。
   - `game_sim_multi` 的 auto-driver 只自動跑 encounter，不替玩家隊做生存決策 → team0 放著餓死。
   - **NPC 生存 cascade 正常運作**（其餘 config 大量 camp/loot/forage/beg、pop 成長、無滅團潮）。
   - plan 驗收列「team0 不再餓死」在此 harness 下對玩家隊無法由 NPC AI 達成。
     **建議**：若要量測 team0 生存，需 (a) 把 survival_start team0 改 NPC（移除 player 標記）做純觀測 config，
     或 (b) 在 game_sim_multi auto-driver 補玩家隊 hands-off 生存代跑。屬量測工具範疇，未在本 plan 改。

2. **數值全 TEST VALUE**（pref 權重 / LOOT_GATE 0.55 / JOIN_GATE 0.55 / CAMP_GATE 0.50 /
   CRUDE_CAMP_FOOD_SEED 40）：loot 在分佈中偏高（130 vs 其餘各 ~15），符合「多元」但若要更均衡可調權重/gate。
   建議一次一變因量測再 tune。

3. **camp 在 warning 也可觸發**（pref ≥ CAMP_GATE 即可，非僅 urgent）。目前未見遍地建村；
   若日後 CrudeCamp 爆量，plan Step4 表建議「升 CAMP_GATE / 限 camp 僅 urgent」。

## 連動風險

- `resource_system`：crude camp 立 civilian L1 後，該 tile 進入 `collect_resources` 被動採集路徑
  （outpost_level>0 分支）。種子糧同抬 resource_cap → regen 不卡地形預設（沿用 tile_food_init 修原則）。已驗守恆 delta=0。
- `outpost_system`：crude camp 不走 `start_build`（免成本/工期，求生豁免）→ 不影響正常建造成本鏈；
  但日後若有「outpost 數量/型別」統計或 AI 以 outpost 判據，會把 crude camp 計入 civilian L1。需留意。
- `strategic_ai / faction_ai`：TASK_CAMP 為 PRIO_SURVIVAL(80)，與其他 survival task 同級，
  既有 sticky/release（SURVIVAL_RECOVER_DAYS）一體適用，無新增 latch（已加入 SURVIVAL_TASKS）。

## Baseline 既有失敗（非本 plan 造成）

- headless_test 既有 1 筆 assertion 失敗：`food 應進公庫`（`_on_team_extinct` 滅團遺糧進公庫測試）。
  在 main / 本 branch baseline 皆失敗，與絕境生存無關，未處理。建議主 session 另案查。
