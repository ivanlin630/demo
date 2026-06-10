# Glossary

## 相關文件
- [README](../README.md)
- [核心概念](game-design.md)
- [待討論議題](open-questions.md)

| 術語 | 定義 |
|---|---|
| **Tick** | 最小時間單位 |
| **回合（Turn）** | 一次行動所耗時間 |
| **世界回合（World Turn）** | 一次完整的世界狀態更新週期 |
團體（Team）：地圖上的棋子單位。
勢力（Faction）：有統領標籤的團隊 + 其支配範圍。
| **勢力（Faction）** | 由單個或多個團體組成
| **據點（Outpost）** | 團隊停留在圖塊並執行團隊任務(採集、製造或其他)
| **訊息強度（strength）** | 0.0–1.0，表示訊息可信度與新鮮度 |
| **垂直切片（Vertical Slice）** | 包含完整核心功能的可玩原型，用於驗證設計 |
| **匿名（Anon）** | team 內無個體 entity 的集體人口；分 4 tier（平民/新兵/老兵/菁英）|
| **記名（Named）** | team 內有個體 PersonData 的成員（leader + named_members）|
| **Tier** | anon 階梯：平民/新兵/老兵/菁英；屬性表 global config |
| **居民團（Resident）** | PRODUCE tag + 在自家或同 faction outpost 上的 team；移動受限 |
| **子團（Subteam）** | 從母團 dispatch 出去的小隊；SUBTEAM tag；可 merge_back |
| **意圖目標（prosperity_target_id）** | 攻擊 AI 評估時設的「想打誰」team_id；跟 combat_target 分離 |
| **戰鬥目標（combat_target）** | 「正在戰鬥中」flag；start_combat 設、結束清 |
| **抵達（Arrived）** | team.tile_pos 走到原 move_target；觸發 _on_arrival |
| **移動（Moved）** | team.tile_pos 該 tick 改變；包含 arrived |
