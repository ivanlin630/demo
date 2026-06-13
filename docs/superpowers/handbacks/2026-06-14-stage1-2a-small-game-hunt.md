# Hand Back: 階段1 Plan 2a 小獵物食物層

分支：`feat/small-game-hunt`（commit f79709e）

## 實作摘要

- `scripts/simulation/world_generator.gd`：`_apply_resources` 平原 20% / 森林 30% 灑 `wild_game`（2-6 隻），明寫 `resource_cap["wild_game"]` = 初始值（供月再生 cap 判定）。
- `scripts/simulation/harvest_system.gd`：新增 `_regen_wild_game()`，`tick_all` 月邊界呼叫；每月 30% 機率 +1，上限 `resource_cap["wild_game"]`。
- `scripts/simulation/hunt_system.gd`（新建 `class_name HuntSystem`）：`hunt_small_game(state, team, tile, active)` — 求生技能均值 roll（active base 0.4 / passive 0.08，+survival×0.4，cap 0.95）→ 成功枯竭 1 隻 + 食物（12×(1+survival×0.3)），併入 `team.forage_today`。
- `scripts/simulation/resource_system.gd`：
  - `collect_resources` forage 分支 `_forage_from_tile` 後，腳下有 `wild_game` → `hunt_small_game(active=false)` 被動低率小獵。
  - **`_collect_from_tile` 排除 `wild_game`**（同 `wild_horses`）— 見下方連動風險。
- `scripts/simulation/player_command_system.gd`：registry 加 `"hunt"` → `_action_hunt`（主動狩獵，self-action target=-1）。
- `scripts/debug/headless_test.gd`：註冊 5 新測試（seeded / regen / hunt roll / passive forage / player hunt），全綠。

## 與 spec 的差異

- 無功能差異。一處超出 plan 明文的修正：plan 未列「generic collect 須排除 wild_game」，但實作驗證時發現 `_collect_from_tile` 會把 wild_game 當一般資源採進私產（並洩漏進戰鬥 loot pool）。已比照 `wild_horses` 加入排除。理由：wild_game 設計為活物、僅經 HuntSystem 取得，否則雙重產出且破壞活物語意。

## 驗收結果

- 單元測試：5 新測試全 OK，`=== DONE ===`，無新增 SCRIPT ERROR。
  - baseline 既有失敗 `food 應進公庫`（Bug8）仍在 — 非本 plan 引入，plan Task 6 已認可。
- 2 年 multi（survival_start / tyrant / warzone，21600 tick）：
  - 三 config `died=no`，跑滿無崩潰。
  - `[CoinAudit] delta=0.00`（三者）— 守恆不破（小獵物只給 food，非 coin_eq 追蹤項）。
  - `SCRIPT ERROR` count = 0。
  - survival_start pop 23→36：小隊未因小獵物食物通膨爆肥，成長溫和 → `FOOD_PER_GAME=12` / 命中率現值合理，未 tune。

## 連動風險

- `_collect_from_tile` 已排除 wild_game（已修）。請 review 是否還有其他「遍歷 tile.resources 通用處理」的路徑會誤動 wild_game（例如商隊吸收 / 市場 / 其他 loot 來源）。已確認 `regenerate_tiles` 只動 food/material，戰鬥 loot 來源為 team.resources（修正後不含 wild_game），無殘留洩漏。
- `HuntSystem._avg_survival` 只計 leader + named_members（不含 anon）。大群 anon 隊的求生命中等同 named 平均，符合「抽象小獵」設計，但若日後要讓 anon 影響命中需另議。
- TEST VALUE（`WILD_GAME_*` / `FOOD_PER_GAME` / 命中率）為粗值，正式平衡期需連同其他時間/數值常數一起調。

## 待主 session 確認

- generic-collect 排除 wild_game 的修正（超出 plan 明文）是否認可保留。
- Plan 2b（危險野獸戰鬥 + 伏擊偵測 + `predator_density`）為後續，本 plan 未碰戰鬥系統。
- 是否需在 `game_sim_multi` 加 wild_game 總量統計 print（目前 wild_game 枯竭/再生動態由單元測試覆蓋，sim 層無現成統計）。
