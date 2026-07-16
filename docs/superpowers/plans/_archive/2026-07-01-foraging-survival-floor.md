# Plan — 覓食 = 苟活地板（產出 capped、繁榮須交易）

> 實作 plan。spec = `specs/2026-07-01-foraging-survival-floor-design.md`。系統已定 seam。
> **核心**：覓食來源食物 net-bank cap 到 subsistence buffer；超額不 bank、不耗 wild_game。地形 regen / forage 決策權重**不動**。

## 前置（開頭必跑）
```bash
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # 基準 PASS 數記下
```
重型 seed 用 `GODOT_TIMEOUT=2000` + run_in_background。

## Task 1 — subsistence cap 常數 + buffer 公式
- `resource_system.gd`：加 `const FORAGE_FLOOR_DAYS: float = 1.5  # TEST VALUE — 覓食淨貢獻上限=幾日餬口`。
- buffer 公式：`SUBSIST_BUFFER = team.population * FOOD_PER_PERSON_PER_DAY * FORAGE_FLOOR_DAYS`（`FOOD_PER_PERSON_PER_DAY=2.4` 已存 `:3`）。
- **DoD**：常數存在、公式 helper（`static func _forage_subsist_buffer(team) -> float`）可呼叫。

## Task 2 — flush 端 cap（主 seam，TDD）
- **先寫測**（`headless_test.gd` 新 `_test_forage_subsistence_cap`）：
  - 造覓食隊（無據點、pop 小、wild_game 足），跑數日覓食。
  - 斷言：team 覓食來源食物 net-bank ≤ `SUBSIST_BUFFER`（食物 latch 苟活線，不無限囤）。
  - 斷言：超 buffer 時 `wild_game` **不被消耗**（不憑空滅世界資源）。
- **改 `flush_forage_episodes`（`resource_system.gd:193-209`）**：flush 前算 team 現有可累積食物 + 本輪 forage_today，若超 `SUBSIST_BUFFER` → 只 bank 到 buffer 差額，餘棄；對應未 bank 的份**回退 wild_game 消耗**（若消耗記在 hunt 端，改為 hunt 端查 buffer 前置 gate，見 Task 2b）。
- **Task 2b（cap 落點裁定）**：若 flush 端無法乾淨回退 wild_game（消耗已發生在 `hunt_system`），改把 buffer gate 前置到 `hunt_small_game`（`hunt_system.gd:9-22`）累積前：team 覓食食物已達 buffer → 該次不獵（不耗 wild_game、不加 forage_today）。**傾向 2b（source 端 gate，守恆乾淨）**，2a flush-clamp 為備。plan 執行時擇一、測證守恆。
- **DoD**：測綠、覓食隊食物 latch subsistence、wild_game 守恆（不憑空滅）。

## Task 3 — 驗成長不由覓食驅動（驗收面）
- **測**（`_test_forage_no_growth`）：純覓食隊（無 granary、無貿易）→ 斷言 `surplus_ok`（`reaction_system.gd:201`）**不 fire**、無 `P5_breed`（覓食封頂 < pop*2.4*7）。
- **測**（`_test_settled_still_grows`）：plains 定居隊（outpost harvest regen 8 填 granary）→ 斷言 granary surplus → breed **仍 fire**（cap 不誤傷定居繁榮）。
- **若 Task 2 沒乾淨切**（覓食 buffer 仍偶推 surplus）→ B fallback：`reaction_system` growth surplus test 改讀 granary-only（排除覓食來源 team food）。**傾向不需**，先驗 A 夠。
- **DoD**：覓食隊不 breed、定居隊 breed；兩測綠。

## Task 4 — 活世界回歸（戰國 seed）
- `warring_states_seed` + `econ_bed.json` 變體重跑（`GODOT_TIMEOUT=2000` + bg）：
  - 覓食隊不再無交易自足膨脹（pop 不靠覓食暴長）。
  - forest/mountain 定居隊繁榮只在賣特產換糧 fire 後（trade loop 真轉）；plains 仍原生繁榮。
  - **若 trade loop 仍不 fire**：measure（別猜）——grep buyfood/換糧 print，可能 `econ-floor` spec §C 的 buyfood weight 需提（TEST VALUE，本 plan 可含微調）。
- **DoD**：覓食隊不膨脹證、trade loop fire 證（或 measure 出下一閘並記 known_issues）。

## Task 5 — 守恆 + 回歸閘
```bash
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd    # PASS 數 ≥ 基準
# coin_eq delta=0 / pop 守恆 / InvariantAudit 0 / 1000+ tick 無錯
```
- **DoD**：framework S1-S6 PASS、coin_eq=0、pop 守恆、無 GDScript 錯。

## 不碰（scope guard）
- `REGEN_RATE`（不 nerf 地形）、`terms.gd` forage util 權重（不 nerf 決策）、`FOOD_PER_GAME`/hit chance（不 nerf 單次 yield）、戰鬥/P1/交易數學。

## 完成
- handback → 系統：cap 落點（2a/2b 哪個）、buffer 量級 seed 校結果、trade loop fire 與否（沒 fire 則 measure 出的下一閘）。**誠實標**活世界 emergence 到不到。
