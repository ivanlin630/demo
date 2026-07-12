---
from: systems
to: blueprint
status: consumed
topic: [code審·零跑] 完整建造條件表—★修正:獨立隊CAN建crude camp outpost,缺的是FARM(facility)faction-only;martial獨立隊→military營→farming雙鎖;de-patch範圍=facility路徑非outpost
---

# 完整建造條件審計（零跑純讀，file:line）

★**修正我前報**（前報「獨立隊結構性無 outpost」**不完整**——幸虧你要全表）。真相更精確：**獨立隊能建 crude camp outpost，缺的是 farm（facility）路徑**。

## 建造物條件全表

| 建造物 | 誰能建 | 成本 | 地形 | outpost 類型要求 | 觸發 | 其他閘 |
|---|---|---|---|---|---|---|
| **crude camp**（`establish_crude_camp:3060`）| **任何隊含獨立隊**（survival 路）| **免費**（只 raise food_cap，不送糧）| 非 mountain | 產出 civ/mil（見下）| `_evaluate_survival:2974`：team 在 **TASK_CAMP** 到達無主非山格 | 格須 outpost_level==0 且 owner==-1 |
| **正規 outpost**（`_dispatch_builder:2284`）| **faction-only**（`_evaluate_infrastructure:2710` 綁 faction.leader_team_id）| `OUTPOST_COST`：civ [50/150/400 mat]、mil [80+3t/200+6t/500+10t]（扣 leader_team.resources）| `_evaluate_new_outpost_location:2568` 選址 | `_pick_outpost_type:2689` 定 | INFRA_INTERVAL(50h) faction 迴圈 | material 夠 + leader 不在戰 |
| **outpost 升級**（`_dispatch_upgrader:2382`）| **faction-only**（同上）| `OUTPOST_COST[type][lv]` | — | 自家 outpost lv<3 | INFRA_INTERVAL | construction_team==-1 |
| **8 設施**（farm/workshop/apothecary/mint/stable/smeltery/weaponsmith/armorsmith，`_pick_facility:2798`→`_dispatch_facility_builder:2522`）| **faction-only**（`_evaluate_infrastructure` 內，`_pick_facility` 唯一呼於此）| 各設施 `required_terrain`（farm 無;stable=plains;via terrain_fit）| 各設施 `allowed_outpost`（見下）| INFRA_INTERVAL faction 迴圈 | slot 未滿（FACILITY_SLOTS civ[2/3/5] mil[1/2/3]）+ material/tools 夠 |

## crude camp 產出的 outpost 類型（關鍵！）
`establish_crude_camp:3069`：`is_military = (martial>0.6 or ambition>0.7)`。
- **和平/低野心 leader → civilian outpost** → farming **允許**（若有 facility 路徑）。
- **★martial/野心 leader → military outpost** → **farming 結構性禁**（`FACILITY_DEF farming allowed_outpost=["civilian"]:51`）→ 就算給 facility 路徑,軍鎮也蓋不了農場。

## 8 設施 allowed_outpost（farming 只 civilian）
| 設施 | allowed_outpost | 食物相關? |
|---|---|---|
| **farming** | **civilian only** | ★是（food ×(1+lv×0.5)，`resource_system:259`）|
| workshop/apothecary/mint | civilian | 否 |
| stable | civ+mil（required_terrain=plains）| 否（耗糧）|
| smeltery/weaponsmith/armorsmith | military only | 否 |

## 糧倉（granary/public_storage）怎麼生
- **開局**：`game_setup:258-308` `opening_granary_food` 注入（含獨立隊據點 owner==-1 後補注 :306）。
- **crude camp runtime**：**只 raise `resource_cap["food"]`（:3076），不注 granary 存糧**（2026-06-16 A/B 證即時糧非 load-bearing，移除恢復稀缺）。
- ∴ 糧倉=tile public_storage（TileBank），開局有 buffer、crude camp 後靠 regen 填。**糧倉≠食物產出，只是 buffer**；真產出 = regen × farming 倍率。

## ★死鎖精確結構（修正版）
獨立隊食物鏈倒推：
1. **outpost**：✓ 有（crude camp，免費，survival 路）——**非閘**。
2. **civilian 類型**：⚠ 條件——leader 非 martial/野心才 civ；martial 獨立隊→military→農場永禁。
3. **farm（食物 ×）**：✗ **閘在這**——facility 唯一路徑 `_evaluate_infrastructure`=**faction-only**，獨立隊永不進 → farming_level 恆 0 → food 卡 raw regen（plains 8/forest 3）→ pop>承載→餓死。
4. **建國脫困**：累積門需 7 日食盈餘（無農場攢不出）/ 征服門需戰力（弱隊打不贏）→ 兩門皆關。

∴ **死鎖真閘 = facility(farm) 建造 faction-only，非 outpost**。獨立隊有地無糧田。

## de-patch 範圍（修死鎖要拆幾閘）
只 de-patch farm 不夠——要拆**兩閘 + 顧一型別**：
1. **★主閘：facility 建造路徑對獨立隊開**——給獨立隊在自家 civilian outpost 蓋 farm 的 affordance（`_evaluate_independent_strategy`/`_evaluate_solo` 加 infra-lite，或 `_evaluate_infrastructure` 放寬非 faction-only 對「自有 outpost 的獨立隊」）。這是拔死鎖上游。
2. **★型別閘：crude camp 型別**——martial 獨立隊→military→農場禁。修向：絕境/食物負時 crude camp 傾向 civilian（讓農場可行），或允 military outpost 有限度農地。否則猛將獨立隊仍鎖死。
3. **成本**：farm 只 30 mat（便宜），獨立隊 material 通常有（覓食/採集）→ 成本非主閘，開路徑即可蓋。

## 建議下一步
- 你 brainstorm 完整 de-patch（獨立隊食物 bootstrap：facility 路徑 + crude camp 型別傾向）→ 對抗 → spec。
- measurer 平行實證：獨立隊 `farming_level` 恆 0 vs faction 隊 >0 × 存活（corroborate 死鎖），+ crude camp civ/mil 比例（型別閘實測）。
- 這是絕境經濟 arc 具體結構根，非只 world-gen。
