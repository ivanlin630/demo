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
- 任何資訊命令都需傳遞 ,永不跨距離傳播,也不全知

## Simulation

- Event = Consequence
- 禁止 Scripted Outcome
- **遍歷 id 快照前必驗存在**：team/person id 陣列是 tick 開頭的快照，元素可能在本 tick 內滅團/死亡被移除；存取 dict 前先驗 `.has(id)`，否則 Invalid get index

## 關鍵設計規則

- **不直接 script 結果**：所有行為從 NPC values/skills/stress/loyalty 計算產生
- **新功能前定義**：影響的世界狀態、資訊流動、時間消耗、受影響群體、二次後果

## 對稱性

- **無玩家專屬機制**：任一交互 / 生存系統（戰鬥 / 貿易 / 外交 / 覓食 / 狩獵 / 任務 / 賞金…）NPC 必須同樣能用
- 玩家與 NPC 走同一套底層數學；差別只在玩家可手動接管、NPC 自動解算

## 玩法節奏

- **decisions-not-chores**：玩家做決策，模擬跑雜活；壓力存在是為製造決策岔路，不是逼玩家重複操作
- 可跳時間；事件只在 juncture 介入
- **激情時刻全手動 + 真風險**，且主要由玩家冒險決策觸發（非隨機 spam）

## UI 邊界

- **UI 只經 player API**：UI 層（`scripts/ui/*`）禁止直讀/直寫 `WorldState`；一切經 `SimBridge` → `PlayerQueryApi`/`PlayerCommandApi` 的 DTO
- **DTO 是 UI 契約**：玩家 UI 需要的任何 sim 資訊，必須 map 進 DTO（非讓 UI 繞道取）→ 換 UI（文字↔圖形）只需接同一 API

## NPC

決策來源：

- Values
- Skills
- Needs
- Memories

禁止硬編碼結果

## Interaction

- **嚴禁非同格互動**：戰鬥 / 貿易 / 外交 / 投靠 / 徵收 / 信使 / 安頓 / 安撫 全部需 `team.tile_pos == other.tile_pos`
- 觸發點：`interaction_system.process_on_move`（mover 對全 team 掃同格 → try_interact）

## Anon

- anon 是 team-level 抽象集體，**無個體 entity**
- 4 tier scalar（平民/新兵/老兵/菁英）儲存於 `team.anon_tiers` dict
- 變動只透過 `AnonTierSystem` API：`add_anon` / `remove_anon` / `add_exp` / `kill_random` / `transfer_proportional` / `try_promote`
- `anon_combat_skill` / `anon_wage` 為 computed getter（不可直接寫）
- 入團時保留來源 tier（戰俘 / 投靠 帶原 tier 進入）

## Task

- `current_task` 是團體狀態（不是個體）
- `combat_target` 是「正在戰鬥」flag（戰鬥中設、結束清）
- `prosperity_target_id` 是「想攻擊誰」意圖（攻擊 AI 評估時設）
- 兩者語意分離，不可混用
- **每個高優先 task 必須有釋放條件**：進得去必須出得來，否則凍結世界（高優先 task 蓋住一切）

## 財產 / 守恆

- **居民私產與統治者公庫永不混淆**：私產（採集稅後）vs 公庫（owner 稅金）兩錢包分明
- **建造資源嚴格本地**：建材來自施工團自身 + 腳下據點公庫（兩源皆可），不可動用他處據點的資產（非隔空遠端取物）
- **有限資源守恆**：建造永不消耗有限資源；任何死亡 / 滅團，資產走守恆路由，永不憑空銷毀
- coin 只能由鑄幣產生，無其他來源

## 飢餓 / 人口

- 飢餓判定唯一來源 = 團糧（個人不另算飢餓）
- 死亡順序：弱者先死（minor → anon → named）
- 生育是生命事件（可與行動並行），不與行動反應競爭單一名額