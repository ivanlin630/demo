# Hand Back: G2c rung×archetype → task 映射

branch: `feat/g2c-rung-task`（已 push origin，未 merge）

## 實作摘要

- `scripts/simulation/ambition_ladder.gd`：加 `static func rung_task(state, team) -> String`。(archetype, rung) → 既有 `TASK_*`（零新 task）。rung1 武力→TRAIN / 商業→TRADE / 定居→PRODUCE；rung2 武力→""(交 prosperity) / 商業→TRADE / 定居→BUILD；其餘 rung（生存/立國/稱霸）→""。
- `scripts/simulation/faction_ai_system.gd`：
  - `_evaluate_prosperity_attack` 加 ladder gate：僅 `archetype==武力 且 rung>=擴張` 才評估主動征服（leader null 檢查後、calc_attack_score 前）。
  - `evaluate_all` per-team 迴圈末（所有高優先評估之後、`_auto_withdraw_mounts` 後）加 ambient caller：team idle 時取 `rung_task` → 非空則 `PRIO_AMBIENT` try_set（最低優先,只填 idle，move_target=team.tile_pos）。
- `scripts/debug/headless_test.gd`：新 3 測試（`_test_rung_task_map`/`_test_ambient_ladder_task`/`_test_prosperity_gated_by_ladder`）+ 註冊。修 2 既有測試（見下「與 spec 差異」）。
- `docs/invariants.md`：「隊目標單一 owner」段補 ambient ladder 常態行為 + 優先序規則。
- `docs/known_issues.md`：G2 進度 G2c ✅ 標記。

## 與 spec 的差異

- 修了 **2 個既有測試**（新 gate/ambient 造成的合理行為變更，非削弱）：
  1. `_test_evaluate_prosperity_trigger`：原 attacker 未設 ambition 欄位 → 新 gate 擋下。補 `ambition_archetype=武力; ambition_rung=擴張`（該隊本就是武力征服者意圖）。
  2. `_test_trade_timeout`：trade timeout release→idle 後，**同一 evaluate_all 內 ambient caller 即刻重填**（leader 預設 values derive 出 FORCE+ACCUMULATE→TASK_TRAIN）。原 assert `==IDLE` 改為 `!=TRADE`（仍驗 zombie TRADE 已解除，容忍 ambient 重填）。
- 其餘 prosperity skip 測試（低野心/低 readiness/同 faction）皆 assert IDLE，gate 只是多一層 skip 理由 → 不破。

## 連動風險

- `faction_ai evaluate_all`：本 plan 改動點與 **G2d（脫軌/vendetta，PRIO 55）** 和 **G1b（訂單系統）** 都動 evaluate_all + headless_test。三者各自 worktree 基於同一 main HEAD（309c691）→ **merge 時 evaluate_all 尾段 + headless_test 註冊清單會衝突**，主 session 按序解。ambient caller 插在迴圈最末，與 G2d 的脫軌評估（應在 prosperity 之後、ambient 之前）順序需主 session 確認。
- `prosperity gate` 對齊 ladder 後：**未設 ambition 欄位的隊（archetype="" rung=0）永不主動征服**。新建團在首次 `AmbitionLadder.update`（cadence）前 archetype="" → 該窗口內不攻擊。預期行為（生存 rung 不征服），但若有測試/路徑假設「新團即可 prosperity attack」會受影響。已掃 headless 測試僅 trigger 一處需補欄位。
- `ambient TRADE 空轉`：商業隊 ambient 指派 TASK_TRADE 但 ambient 只設 task 不找標的，依既有 trade 邏輯（strategic_ai `_find_trade_partner` / member_trade）找對象。無對象時 task 啟動但無 move_target → 可能空轉至 TRADE_TIMEOUT(1440) 釋放再重填。非崩潰，但商業隊 idle 窗口可能反覆 TRADE↔idle。遠程商隊依 G1（未上線）。

## 待主 session 確認

- **ambient caller vs G2d 脫軌順序**：plan 註明優先序 脫軌(55) > prosperity(50) > ambient(10)。merge G2d 後須確認脫軌評估在 ambient caller 之前執行（否則 ambient 填了 idle，脫軌那 tick 看不到 idle）。建議 merge 時把 ambient caller 保持在迴圈**最末**。
- **rung_task 不查 _tag_weight**：ambient 指派不過 tag 權限（如 商隊 archetype 被 derive 成武力 → 指派 TASK_TRAIN，雖無 軍隊 tag）。設計上 ambient=「本性傾向」非執行授權，try_set 不檢 tag。若藍圖要求 ambient 也受 tag gate，需後續加。
- **驗證**：headless `=== DONE ===`、0 assert fail、coin_eq 守恆 OK、InvariantAudit population/faction/subteam OK。game_sim_multi 21600 tick 0 SCRIPT ERROR 無崩潰。multi drift 數字未 gate（unseeded）。
