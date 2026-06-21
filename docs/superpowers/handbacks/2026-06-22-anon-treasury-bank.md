# Hand Back: AnonTreasuryBank（Pattern B 第三池）

## 實作摘要

新增單一 owner banker，將 `team.anon_treasury`（隊公庫 coin）全部寫者收斂到 5 個原子 API。transfer/transfer_all 守恆 by construction（不再分離 `+=` / `=0`，消除錯配漏 coin 風險）。

### 改了哪些檔案
- `scripts/simulation/anon_treasury_bank.gd`（新）：banker，5 static func。
- `scripts/simulation/anon_tier_system.gd`：訓練餉銀 → deposit。
- `scripts/simulation/salary_system.gd`：匿名薪水沉澱 → deposit。
- `scripts/simulation/player_command_system.gd`：玩家訓練餉銀 → deposit；招募 anon 帶 treasury 份額 → transfer。
- `scripts/simulation/movement_system.gd`：撿 abandoned_coin → deposit。
- `scripts/simulation/faction_ai_system.gd`：徵用 extract → withdraw；滅團路由兩 standalone `=0` → reset（見下）。
- `scripts/simulation/person_generator.gd`：anon→named 晉升 bonus → withdraw。
- `scripts/simulation/encounter_system.gd`：戰利公庫（全給/比例/全滅補拿/屠村）→ transfer / transfer_all。
- `scripts/simulation/subteam_system.gd`：派子隊 split → transfer；merge back（比例/清空）→ transfer / transfer_all。
- `scripts/debug/headless_test.gd`：加 `_test_anon_treasury_bank`（deposit/withdraw/transfer 守恆/transfer_all/withdraw clamp）+ 註冊。

## Bank API
```gdscript
AnonTreasuryBank.deposit(team, amt, reason)          # += maxf(amt,0)   sink
AnonTreasuryBank.withdraw(team, amt, reason) -> float # clamp min(amt,bal) 回實扣  extract
AnonTreasuryBank.transfer(src, dst, amt, reason)      # 原子 clamp min(amt,src) 守恆
AnonTreasuryBank.transfer_all(src, dst, reason)       # 全移 src→dst src=0  守恆
AnonTreasuryBank.reset(team, reason)                  # =0 + Probe.bump("g1.treasury_reset")
```

## 路由清單（24 寫者 / 8 檔，已分類）

| 分類 | 數 | 寫者 |
|---|---|---|
| deposit | 4 | anon_tier_system(訓練餉)、salary_system(薪水)、player_command_system:189(訓練)、movement_system(撿遺財) |
| withdraw | 2 | faction_ai_system:1390(徵用 extract)、person_generator(晉升 bonus) |
| transfer | 4 | encounter_system(loot 比例)、player_command_system(招募份額)、subteam_system(split)、subteam_system(merge 比例) |
| transfer_all | 4 | encounter_system(全給)、encounter_system(全滅補拿)、encounter_system(屠村)、subteam_system(merge 清空) |
| reset | 2 | faction_ai_system:1456(滅團無 tile)、faction_ai_system:1487(滅團已路由) |

> subteam split 原為 `sub = parent*frac; parent -= sub`；`sub` 為新建隊 treasury=0 → `transfer(parent, sub, parent*frac)` 等價且守恆。
> withdraw 的兩處（extract/bonus）`amt` 皆已在 call 前 clamp（`treasury*ratio` / `minf(...,treasury)`），coin 目的端用同一 local `amt`，精確守恆。

## standalone `=0` 處置（leak vs reset）

`_route_extinct_assets`（faction_ai_system）兩個裸 `=0`：

1. **line 1487（滅團主路徑）= 合法 reset。** coin 在歸零前已先路由：outpost 分支進 `public_storage`/溢出 `abandoned_coin`；無 outpost 分支 line 1483 `tile.abandoned_coin += treasury + coin`。讀取後歸零 → 目的端先收，守恆。改 `reset(team, "extinct_routed")`。

2. **line 1456（邊緣 fallback）= PRE-EXISTING 洩漏，已標 FLAG。** 條件：team 死在地圖外格 **且** `_nearest_valid_tile`（擴環 radius 12）也找不到任何有效格 → coin 無處可路由，原 code 直接 `team.anon_treasury = 0.0; resources.clear()`，coin 憑空丟失。改 `reset(team, "extinct_no_tile_LEAK")` 保留行為（不掩蓋——reason 點名 LEAK），**但這是真守恆破口**。
   - 影響：僅 degenerate config（spawn 超出地圖半徑且半徑 12 鄰域全空）才觸發。正常地圖不可能（任一格自身即有效）。
   - coin_eq 是否抓得到：**抓不到**。coin_eq/CoinAudit 對 `state.teams` 求和；team erase 後其 coin 已不在和內，無論歸零與否 delta 都=0（漏的 coin 是「該被路由到 tile 卻沒有」，非「team 裡殘留」）。故此漏 audit 沉默。
   - **建議主 session**：此 fallback 應改為「找不到 tile 就不 erase / 延後」或「擴大搜尋半徑保證命中」，使 coin 必有 tile 落點。屬獨立小修，非本 banker arc 範圍 → 不在此 session 動世界模型。

## coin 守恆證據

- **headless coin_eq 硬閘全綠**：`anon treasury bank OK`、`投靠守恆整合(coin_eq) OK`、`W4 Task1c(caravan-load 守恆) OK`、`Bug10 屠村守恆 OK`、`G1a 鑄幣端到端守恆`、`InvariantAudit population/faction/subteam OK`。`=== DONE ===`，ERROR_COUNT=0（0 assert / 0 SCRIPT ERROR / 0 Parse Error）。
- **coin_eq 確含 anon_treasury**：`headless_test._coin_eq_sum` line 969 `total += ... + t.anon_treasury`；`game_sim_multi._coin_equivalent_total` line 136 同。
- **2 年 game_sim_multi CoinAudit（4 config 全 delta=0）**：
  - `game_sim_test` init=4455.0 final=4455.0 **delta=0.00**，violations=0
  - `tyrant` init=4195.0 final=4195.0 **delta=0.00**，violations=0
  - `merchant` init=2930.0 final=2930.0 **delta=0.00**，violations=0
  - `warzone` init=1280.0 final=1280.0 **delta=0.00**，violations=0
- **2 年 world_sim（172800 tick = 2.0 年, 8 隊）**：`=== world_sim DONE ===`，0 SCRIPT ERROR。Team3/7/6/1 滅團「遺財已路由」正常（走 reset 合法分支，treasury 流動正常）。

## grep 驗證（無殘留裸寫）
`grep anon_treasury\s*(=|+=|-=)` over `scripts/simulation/**` → 僅 `anon_treasury_bank.gd` 內 7 行命中（banker 本體）。其餘 0 殘留裸寫。

## 連動風險
- `Probe`：reset 呼 `Probe.bump("g1.treasury_reset")`，新 probe key，純計數無副作用。
- 無其他系統行為改變（同 coin 流，僅換 API）。

## 待主 session 確認 / 後續
- **faction_ai:1456 邊緣洩漏**（見上）——pre-existing，建議獨立小修。
- **Pattern B 剩餘池**：`resources`（~110 寫，最大池，含 coin/ore/food/material…）、`outpost_owner`（tile 所有權）尚未收斂到 banker。本 session 只清第三池 anon_treasury。

## 回歸
- headless：全綠，0 error，`=== DONE ===`。
- 2 年 world_sim：`=== world_sim DONE ===`，滅團遺財路由正常。
- game_sim_multi CoinAudit：4 config 全 delta=0.00，violations=0。
