# Hand Back: 階段1 覓食地基

Plan: `docs/superpowers/plans/2026-06-14-stage1-forage-foundation.md`
Branch: `feat/forage-foundation`

## 實作摘要

- `scripts/data/team_data.gd`：新增 `TASK_FORAGE` const + `forage_today: float` 累積欄位。
- `scripts/simulation/resource_system.gd`：新增 `FORAGE_RATE=0.02` const、`_forage_from_tile()`（食物 only、枯竭、pop_mult 封頂 2.0）、`flush_forage_episodes()`（日彙整、只玩家隊發訊息）；`collect_resources` 的 `outpost_level==0` 分支由 `continue` 改為呼叫覓食。
- `scripts/simulation/faction_ai_system.gd`：`SURVIVAL_TASKS` 納入 `TASK_FORAGE`、新增 `FORAGE_VIABLE_POP=15` const、`_trigger_survival` 插 Path 3.5（小群覓食）、新增 `_find_forage_tile()` helper。釋放走既有 `_evaluate_survival` hysteresis（糧恢復 ≥ SURVIVAL_RECOVER_DAYS 自動釋放）。
- `scripts/simulation/sim_runner.gd`：日邊界呼叫 `flush_forage_episodes(state, state.teams.keys())`，玩家隊訊息以 `[ForageEpisode]` print（UI 接入待後續 plan）。
- `config/survival_start.json`（新建）：流民小隊（pop3、無 outpost、food30）+ 野村（pop20、有 outpost）。
- `scripts/debug/headless_test.gd`：新增 6 個單元測試 + 註冊。

## 與 spec 的差異

- **episode flush 範圍**：plan Step 1 建議只 flush `near_team_ids`，實作改為 flush `state.teams.keys()`（全隊）。原因：far-zone 隊也會覓食累積 `forage_today`，只 flush near 會讓 far 隊欄位無上限增長。全隊 flush 成本低（僅歸零 + 玩家判定），且只玩家隊發訊息，不增 spam。
- **Path 4 決策樹測試**：既有 `_test_survival_decision_tree` 的 (4) 默認→乞食用 pop=5，新覓食 Path 3.5 會先攔截（pop≤15 + 有食物 tile）。改該測試 pop=20 使其仍落到乞食路徑，保留原測試意圖（驗證乞食 fallback）。此為 spec 明訂的優先序（覓食在乞食之前）的必然結果。

## 驗收結果

headless 全測試：6 覓食測試全綠。**附帶修好 3 個 baseline 既有失敗**（緊急觸發應為 SURVIVAL_TASKS / survival 應進入評估 / survival 應蓋掉貿易）——原本這些飢餓隊無 prey/ally/aid 時 release 回 idle，現在改為覓食（屬 SURVIVAL_TASKS）。

2 年 multi（survival_start, tyrant, warzone）：
- 三 config `died=no`；survival_start pop 23→41（小隊靠覓食撐過開局並成長）。
- 三 config `[CoinAudit] delta=0.00`（覓食不破守恆）。
- 大軍（pop>15）**無** `task=覓食`（門檻有效）；玩家隊 268 條 `[ForageEpisode]`。
- TEST VALUE `FORAGE_RATE=0.02` / `FORAGE_VIABLE_POP=15` 無需 tune。

## 連動風險

- `InteractionSystem._try_interact` (interaction_system.gd:233)：multi-sim 尾段噴 3 次 `Out of bounds get index '5' (on base: 'Dictionary')`。**baseline 既有**（不在本 plan diff），與覓食無關，但建議另案查。
- `headless_test` baseline 仍存 1 既有失敗：`food 應進公庫`（`_test_on_team_extinct_to_storage`，與覓食無關，stash 驗證確認 pre-existing）。
- `sim_runner` 日邊界 flush：episode 目前只 print，未接玩家事件流/UI。spec/plan 標示 UI 接入屬後續。

## 待主 session 確認

- episode flush 範圍改全隊（見差異）是否接受。
- UI/事件流接入 `[ForageEpisode]` 訊息：建議列入 UI plan。
- 上述 2 個 baseline 既有失敗（interaction:233、on_team_extinct food 公庫）是否需另開修復 task。
