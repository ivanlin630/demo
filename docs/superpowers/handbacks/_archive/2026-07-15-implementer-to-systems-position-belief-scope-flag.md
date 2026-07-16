---
from: implementer
to: systems
status: consumed
topic: "[主arc·核心完+scope flag待裁] 位置belief化 A-E核心+TDD 8綠;但 belief_pos 破 87 record_claim 測試面(缺tile_pos/last_tick)——遷移 approach 待裁"
---
# Hand Back：位置感知 belief 化（核心完 + 測試遷移 scope flag）

branch `feat/position-belief` @ `3b12b092`（已 push，WIP），base = origin/main `8427cc7b`。

## 核心 A-E 完成（機制正確，TDD 8 PASS）
- **Fix A** `BeliefSystem.belief_pos`：通道分流（跨-faction→BeliefSystem last-seen / 同-faction→known_member_states）+ staleness gate（`BELIEF_STALE_TICKS`）+ ★fallback (-1,-1) 禁退自身。
- **Fix B** options.gd to_task 8 分支→belief_pos（撲空 IDLE）；佔村→outpost tile 靜態真值。
- **Fix C** movement:37-56 逐 tick 追 belief_pos（(-1,-1)→保持不退自身）。
- **Fix D** `_nearest_independent` 補 has_belief gate + belief_pos 距離。
- **Fix E**（defer）observe_velocity 幾何不對稱 spec 接受先行；未動 observe_velocity → path_system SSSP 契約不受影響（belief_pos 只改移動目標，per-tick path cache 仍有效）。
- **TDD 8/8 PASS**（`position_belief_test.gd`）：通道分流(跨 7,7/同 4,4)、staleness、fallback 禁自身、movement fallback 不退自身、to_task 撲空。
- **憲法 sites=29 removed=0**；seeded warring reproducible OK（final 同 base：真-sim belief 帶 tile_pos 近活值，1200 tick staleness 少觸→逃脫故事屬 measurer 中性驗）。

## ★★scope flag：belief_pos 破大測試面（approach 待裁，非自決）
**發現**：headless **9 新 SE**（4 函數：`survival_decision_tree`/`stuck_allows_reeval`/`solo_commitment`/`solo_seek_home`）。根因＝**測試注入 synthetic belief claim 缺 `tile_pos`/`last_tick`**（如 `record_claim(...{population_est,armed_est})`）→ belief_pos (-1,-1)→to_task 撲空 IDLE→assertion 失敗。

**真-sim 無此問題（已查證）**：真 belief claim **帶 tile_pos+last_tick**——vision `_write_tier01:113-114` 加、distortion_engine:52/58 shift tile_pos、既有 faction_ai:291/309/1254 已 `.get("tile_pos")`。∴ belief_pos 對真-sim 正確；純**測試編碼 god-view**（靠活值 tile_pos）。

**但測試面系統性大**：headless **87 個 record_claim + 24 個 team_intel 注入全缺 tile_pos/last_tick**（只 ~9 SE 的 4 函數真失敗，餘 78 未 assert 位置故不 fail，但同缺欄位）。migration 非小、且有 approach 判斷：
- **(a) 逐函數機械遷移**：4 失敗函數的 record_claim 加 `tile_pos`(target 位)+`last_tick`(=current_tick)。部分在 loop（`for tid in [1,2]`）需 per-tid 位置，fiddly 但 bounded（~10 sites）。
- **(b) test-helper**：加 `_record_belief_with_pos(state,obs,tgt,...)` 自 target 補 tile_pos+last_tick，遷移 call-site 到 helper（大改但一致）。
- **(c) staleness 改讀 claim.tick**：belief_pos staleness 從 `value.last_tick` 改讀 claim 的 `tick`（record_claim 恆設）→ 測試 claim 自動 fresh（免加 last_tick），只剩 tile_pos 待補。**但語意**：value.last_tick=原觀測時（傳播失真後仍是原時,正確 staleness）；claim.tick=收到時（re-propagate 舊情報會誤判 fresh）→ (c) 語意較弱，我傾向不改。

**傾向 (a)**（bounded、語意不動）。但 87-site 系統性 + loop per-tid + 「headless 零新增」硬要求，先請 systems 裁 approach（避大改後方向錯）。**不自決**（大測試面 + approach 判斷）。

## 現狀
core A-E push 完（TDD 綠，機制正確）。context hold warm 等 systems 裁遷移 approach → 我照裁定補完測試遷移使 headless 回 baseline。完成判定 = systems + reviewer/QA + measurer 中性驗（逃脫故事）。
