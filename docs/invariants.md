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
- **每個高優先 task 必須有釋放條件**（2026-06-13 W5）：survival/threat/逃跑/乞食 進得去必須出得來，否則凍結世界（曾 92% team-time 卡死，所有機制被 p70/p80 蓋住）。釋放：survival 糧恢復(7天)、逃跑 timeout(5天)/威脅脫離、乞食無施主即釋放

## 財產 / 守恆（2026-06-13 封建財政 + famine）

- **居民私產 vs 統治者公庫永不混淆**：`team.resources`（私產，採集稅後）vs tile `public_storage`（公庫，owner 稅金）。乞食動私產、建造動公庫、一般稅私產→公庫
- **建造嚴格本地**：只能扣施工團**腳下 tile** 公庫（非隔空遠端取物）
- **有限資源守恆**（coin/ore/gem/weapon/armor）：建造永不消耗有限資源（只 material+tools）；死亡/滅團所有資產走守恆路由（公庫/abandoned_coin/地面），含 tile==null（地圖外死亡）fallback 到最近有效格；戰死 person.coin 退團不銷毀
- coin 只能由 mint 產生（鑄幣鏈），無其他來源

## 飢餓 / 人口

- 飢餓判定唯一來源 = 團糧 satisfaction（個人不另算）；後果分層：minor/anon 團級耗損、named 個人 hunger→blood
- 死亡順序：minor → anon → named（弱者先死）
- 生育不參與行動 winner-take-all（生命事件層，可與工作並行）；門檻：安全+溫飽+盈餘+cap