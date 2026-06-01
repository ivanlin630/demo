# Invariants

## World

- 世界獨立運作
- 玩家不是世界中心

## Map

- Hex Grid Only
- 禁止 Square Grid 假設

## Time

- 大地圖與遭遇戰共用時間尺度

## Information

- 認知不等於真實
- NPC 可說謊
- 訊息可能失真

## Simulation

- Event = Consequence
- 禁止 Scripted Outcome

## 關鍵設計規則

- **不直接 script 結果**：所有行為從 NPC values/skills/stress/loyalty 計算產生
- **新功能前定義**：影響的世界狀態、資訊流動、時間消耗、受影響群體、二次後果

## NPC

決策來源：

- Values
- Skills
- Needs
- Memories

禁止硬編碼結果