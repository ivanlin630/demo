# UI & Balance Fixes Design Spec

**Date:** 2026-05-31
**Status:** Approved → Implementation

---

## 問題背景

動態測試（`ui_logic_test.gd`）+ code review 發現 8 個問題。見 `docs/known_issues.md`。

---

## 設計決策

### 1. Simulation 常數（S2 S3）

**問題：** `SALARY_INTERVAL=30`（1.25天發薪）、`SEASON_LENGTH=30`（1.25天/季）導致遊戲在第 2 天就崩潰。

**決策：** 均改為 720 tick（30天）。薪水改為月付，季節改為每季 30 天（1 年 120 天）。這是測試值，正式平衡再調整。

---

### 2. Test Setup（S4 S5）

**問題：**
- `統領=0.0` → `pop_cap=1` → tick 10 即觸發分裂
- `food=300` / (10人×0.1/tick×24tick) = 12.5 天斷糧

**決策：**
- 初始食物 300→5000（demo 生存 > 200 天）
- 初始幣 20→200
- 所有 leader 給 `統領=0.5`（`pop_cap=32`，10 人不觸發分裂）
- 加 `生產=0.3`、`戰鬥=0.2` 做初始多樣性

---

### 3. 視野門檻（S1 U3）

**問題：** `exposure + scout×0.3 > 0.5`，pop=10 plains dist=2 → `eff_exp=0.45 < 0.5`，永遠看不到。

**根因分析：**
- dist=1: `dist_f=0.875`，`eff_exp=0.60×0.875=0.525` → 可見 ✓
- dist=2: `dist_f=0.75`，`eff_exp=0.60×0.75=0.450` → 不可見 ✗

**決策：** 門檻 0.5→0.3，保留距離衰減公式。dist=2 的 pop=10 team 變成可見（`0.45 > 0.3` ✓）。

---

### 4. 移動邊界（U2）

**問題：** `move_target` 可設定到地圖外，team 移動出界無報錯。

**決策：** `_on_set_move_target` 設定前驗證 `state.world.tiles.has(pos.x*1000+pos.y)`，不合法則 print + return。

---

### 5. Camera 行為（U7）

**問題：** 每 tick `refresh()` 呼叫 `_center_on_player()`，無法保持手動視角。

**決策：**
- `setup()` 初始化一次自動對齊
- `refresh()` 只 `queue_redraw()`，不重置鏡頭
- 加 `H` 鍵手動回正玩家

---

### 6. 圖塊資訊視野分層（U6）

**設計：** 圖塊資訊應反映「玩家已知資訊」，而不是全知視角。

**三層分類：**

| 狀態 | 判斷條件 | 顯示內容 |
|---|---|---|
| 視野內 | `hex_dist ≤ VISION_RADIUS(3)` | 地形 + 速度減益 + 農業效率 + 資源 + outpost + 該格 teams |
| 已探索但視野外 | 在 `team_intel` 記錄中 | 地形 + 「情報可能過時」 |
| 未知 | 其餘 | 「未知區域」 |

速度減益係數：plains 1.0 / forest 0.7 / mountain 0.4（UI 顯示用，非 VisionSystem 常數）

---

### 7. Stale Team Markers（U3 U4）

**問題：** 地圖上看不到 NPC 旗子（S1 視野問題修後改善）；discovered 但已離開視野的 team 應有「舊情報」標記。

**決策：**
- 在當前視野內 + discovered → 彩色旗子（現有行為）
- discovered 但當前 dist > 3 → 從 `team_intel[player_tid][tid]["tile_pos"]` 取上次已知位置，灰色半透明圓（`Color(0.5,0.5,0.5,0.6)`）
- 未 discovered → 不顯示

---

### 8. 右側欄擴充（U5）

**加入：**
- 玩家 person HP（body_parts 最差狀態：正常/輕傷/重傷）
- 忠誠度、壓力
- 所有 skills（值 > 0.01）
- Team 疲勞度、位置
- 完整資源（所有 key > 0，最多顯示 8 條）
- 未成年人口

---

### 9. 玩家死亡保護（D2）

**問題：** `state.player_id` 的 person 可被殺死，之後所有 UI 讀取已刪除 person → 錯誤。

**決策：** `_on_tick_advanced` 開頭檢查 `player_id` 是否還存在，若不存在則顯示「玩家已陣亡」並暫停 TurnControls。不做 Game Over 畫面（demo 階段簡化）。

---

## 不做的事

- 不新增 outpost 到 test setup（S5 用增加食物解決）
- 不做 Game Over 畫面（D2 只暫停）
- 不改 S4 人口分裂公式本身（改 test setup 的技能初始值）

---

## 實作文件

計畫：`docs/superpowers/plans/2026-05-31-ui-balance-fixes.md`
