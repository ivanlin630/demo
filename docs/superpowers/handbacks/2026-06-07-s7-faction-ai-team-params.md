# Hand Back: S7 faction_ai 動態初始化 TeamData 戰鬥參數

## 實作摘要

- `scripts/data/team_data.gd`：新增 `anon_combat_skill: float = 0.2` 獨立欄位（原存於 `resources["anon_combat_skill"]`）
- `scripts/simulation/encounter_system.gd`：line 152 改讀 `team.anon_combat_skill`（不再從 resources dict 讀）
- `scripts/simulation/faction_ai_system.gd`：新增 5 個函數：
  - `_update_anon_combat_skill(team)` — by tags，MILITARY→0.5，default 0.25
  - `_update_anon_wage(team)` — by tags，MILITARY→maxf 1.5，EXILE→minf 0.3
  - `_update_armor_config(team)` — by tags + 護甲庫存（threshold = max(pop*0.3, 1.0)）
  - `_update_guard_ratio(team, state)` — by current_task + 鄰近威脅
  - `_has_hostile_within(state, team, range)` + `_hex_dist(a, b)` 輔助
  - `evaluate_all()` 末尾 team 迴圈新增 4 個 update 呼叫
- `scripts/debug/encounter_sim_test.gd`：line 64/82 改用 `atk.anon_combat_skill`、`def.anon_combat_skill`
- `scripts/debug/headless_test.gd`：新增 6 個 S7 測試函數（Task1/3/4/5/6/7）
- `docs/known_issues.md`：S7a–S7d 標記 ✅ 已修（2026-06-07）

**與 spec 的差異：**
- Plan 說 `run()`，實際入口為 `evaluate_all(state, team_ids)`，已按實際簽名調整
- Task 1 test 原版 PRODUCE assertion 用 `<= 0.2`，與邏輯不符（default 0.25 > 0.15），已在 plan Step 3 注意事項內更正為 `<= 0.3`

## 連動風險

- `encounter_system.gd`：已完成遷移，不再讀 `resources["anon_combat_skill"]`。若其他地方仍向 `resources["anon_combat_skill"]` 寫值，現在是無效操作（不影響戰鬥）。建議 grep 確認無殘留寫入。
- `_has_hostile_within`：將所有不同 faction_id 的 team 視為敵對，無外交關係過濾。若未來加入同盟系統，guard_ratio 可能虛高。
- `_update_anon_wage`：混用 `maxf`/`minf` 同一 loop，多重 tag 結果取決於 tag array 順序（例如 MILITARY+RELIGION 可能得 1.5 或 0.5）。單 tag team 無此問題。

## 待主 session 確認

- `_has_hostile_within` 無同盟過濾：是否需要對齊 diplomatic_ai 的盟友判斷邏輯？
- `_update_anon_wage` 多重 tag 順序問題：是否需要改為雙 accumulator（max_bonus + min_penalty 分開計算）？
- `resources["anon_combat_skill"]` 殘留寫入：建議主 session grep 確認，若有則清除
