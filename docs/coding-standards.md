# Coding Standards

## 相關文件
- [README](../README.md)
- [核心概念](game-design.md)
- [階段目標](project-goals.md)
- [待討論議題](open-questions.md)


## General

- 語言：**GDScript**，目標相容 Godot 4.2+。
- 縮排：**Tab**（不使用空格）。
- 命名：
  - 變數 / 函式：`snake_case`
  - 類別 / 常數：`PascalCase` / `SCREAMING_SNAKE_CASE`
- 每個腳本頂部加 `class_name` 宣告（如已有請維持）。

## File Responsibilities

| 檔案 | 唯一職責 |
|---|---|
| `config/game_config.gd` | 全域數值設定，禁止含邏輯 |
| `scripts/world_state.gd` | 純資料容器，禁止含模擬邏輯 |
| `scripts/world_generator.gd` | 生成邏輯；呼叫 `world_state.gd` 寫入資料 |
| `scripts/faction_system.gd` | 每回合勢力更新 |
| `scripts/message_system.gd` | 訊息產生、擴散、衰減 |
| `scripts/player_controller.gd` | 玩家移動輸入 |
| `scripts/ui_controller.gd` | HUD 顯示，禁止含遊戲邏輯 |
| `scripts/main.gd` | 場景協調；禁止直接操作遊戲數值 |

## Prohibited Practices

- 禁止在 `main.gd` 直接操作 `FactionData` 屬性。
- 禁止在 `world_state.gd` 內含任何演算法。
- 禁止硬編碼數值；一律引用 `GameConfig`。
- 禁止使用 `await` 在同步遊戲邏輯中（保持確定性回合）。
