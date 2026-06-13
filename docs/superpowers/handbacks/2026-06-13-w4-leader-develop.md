# Hand Back: W4 收尾 (leader 駐家 + 公庫派工)

## 實作摘要

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/faction_ai_system.gd` | (1) `_dispatch_builder` gate 改吃**腳下公庫**合併池：leader 站自家 outpost → `vault(material/tools) + 私產` 一起算 1.5x 安全餘量；fail log 改印 `公庫X+私Y`。(2) 新 `_fund_subteam_from_vault`：caravan-load — 公庫優先裝車、差額補 owner 私產（守恆純轉移）。dispatch 成功後改呼叫此函數（傳 `home_tile` = leader 腳下 tile，非 target）。(3) `_evaluate_solo` 加「治理」選項：`own_pos = _find_own_outpost`，公庫 material < `GOVERN_MATERIAL_TARGET(75)` 時 `治理分 = (慎重*0.4 + 野心*0.2 + 0.15) * tag_weight`；best_task match 加 `"治理": solo_target = own_pos`。 |
| `scripts/simulation/faction_ai_system.gd` | const `GOVERN_MATERIAL_TARGET: float = 75.0`（TEST VALUE）。 |
| `scripts/debug/headless_test.gd` | 6 新測試：Task1a/b/c（公庫足派工成功 / 腳下無公庫只算私產失敗 / caravan-load 守恆）、Task2a/b/c（慎重選治理 / 好戰漫遊不治理 / 公庫達標不治理）。全過。 |

與 spec 一致，無偏離。`_dispatch_builder` 沿用既有 `_fund_subteam_cost`（升級/擴建路徑不動），只新據點路徑改 `_fund_subteam_from_vault`。

## 驗證

- **headless_test：`=== DONE ===`，6 W4 測試全過，無 SCRIPT ERROR。**
- **coin 守恆：4 scenario delta 全 0.00**（game_sim_test/tyrant/merchant/warzone）。
- caravan-load gate 確實生效：2 年 log fail 訊息全帶 `公庫X+私Y`，公庫值隨稅累積上升（Faction2 公庫 0→46）。
- `[SoloAI] 治理` 確實會觸發（Team3，獨立隊）。

## ⚠️ W4 是否真解：**否。建造數仍 = baseline 1/0/1/0，0 新據點。**

2 年（172800 tick × 4 scenario）跑完，`FacilityStats` 仍 `1/0/1/0`，`派建造子隊` 成功 **0 次**，`派工失敗` 40 次。**核心指標未達標。** 卡點如下：

### 卡點 A（主因）：military 據點 tools gate 不可滿足
- `_pick_outpost_type`：好戰+野心 > 慎重+貪婪 → 選 `military`。Faction1/Faction2 leader 皆好戰型 → 全選 military。
- military L1 cost = `{material:80, tools:3}`，1.5x gate 需 tools 4.5。
- **tools 在公庫與私產恆為 0**（log: `tools 有 0(公庫0+私0)`）→ 數學上永遠過不了。material 反而夠（Faction1 衝到 120 > 80×1.5）。
- tools 來源（weaponsmith/workshop 設施）需先有設施 → 而設施/據點又卡在這 gate → 雞生蛋死結。

### 卡點 B：治理（Task 2）與建造 actor 錯位，幾乎無效
- `_evaluate_solo`（治理所在）只跑 `faction_id == -1` 的**獨立隊**（faction_ai :463）。
- 但新據點派工 `_dispatch_builder` 只由 `_evaluate_infrastructure` 呼叫，後者**只跑 faction leader**（faction_id != -1）。
- 兩者 actor 不相交：**faction leader 永遠拿不到「治理」傾向**，獨立隊有治理卻不會派建造子隊。
- 結果：2 年「治理」只觸發 1 次，對建造鏈 0 貢獻。Plan 設想的「治理→攢公庫→`_evaluate_infrastructure` 派工」鏈在 faction leader 上**沒有治理這一環**。

### 卡點 C：faction leader 公庫偏低
- 公庫值 16~46，因 leader 未必在 infra eval 時站自家 outpost（caravan-load 只在腳下=自家 outpost 才吃公庫）。civilian gate（material 75）其實搆得到，但因卡點 A 沒選 civilian。

## 待主 session 確認（建議後續 task）

1. **tools 死結（卡點 A，最關鍵）**：選項 — (a) military L1 cost 去 tools / 降 tools 需求；(b) 起始給少量 tools；(c) 缺 tools 時 `_pick_outpost_type` fallback civilian；(d) 1.5x 安全餘量對 tools 放寬。建議 (c)+(a)。
2. **治理 actor 錯位（卡點 B）**：把 leader 駐家治理傾向也接到 **faction leader idle 決策**（非只 `_evaluate_solo`），或讓 `_evaluate_infrastructure` 在公庫不足時主動「召 leader 回家攢公庫」。否則 Task 2 對 W4 真解無實質作用。
3. `GOVERN_MATERIAL_TARGET=75` 為 TEST VALUE，待卡點 A/B 解後再校。
4. 治理 task 被動性：設「治理」後 `_evaluate_solo` 因 task != idle 不再重評，team 永久駐家不會因公庫填滿改行為（plan 已預期，記錄待觀察）。

## 連動風險

- `_fund_subteam_cost`（升級/擴建路徑）未改動，行為不變。
- caravan-load 只影響新據點 dispatch；公庫扣款守恆，coin/material 審計無回歸（delta 0）。
- 新 task 字串「治理」：下游 movement 照 move_target 行進，到家後無 handler 清 task（停留治理態）；無 crash，但 task 永久 sticky（見待確認 4）。
