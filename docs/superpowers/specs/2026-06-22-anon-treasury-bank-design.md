# Pattern B banker — anon_treasury（第三池，coin 守恆敏感）

> `state-fight-scope` Pattern B：anon_treasury 24 寫/8 檔，delta + 數處 `=0` 歸零，無銀行 → **貨幣守恆風險**。承 Unrest/Loyalty banker 模式。**coin 守恆敏感 → coin_eq/CoinAudit 為硬閘。**

## 病
anon_treasury（隊公庫 coin）散 24 寫：deposit（薪/訓沉澱）+ withdraw（extract）+ **配對轉移**（winner += loser; loser = 0）+ standalone `=0`（faction_ai:1456/1487，疑 leak）。分離 += / =0 = 守恆脆（一寫失敗即洩/憑空）。

## 修：AnonTreasuryBank 單一 owner（原子轉移=守恆 by construction）
新 `scripts/simulation/anon_treasury_bank.gd`：
```
static func deposit(team, amt, reason)        # += amt（薪/訓/撿 abandoned_coin 入庫）
static func withdraw(team, amt, reason)->float # -= min(amt, bal)；回實扣（extract）
static func transfer(src, dst, amt, reason)    # 原子：src -= m; dst += m（m=min(amt,src.bal)）
static func transfer_all(src, dst, reason)     # dst += src; src = 0（戰勝吞庫/吸收）
static func reset(team, reason)                # = 0（蓄意,僅確認 coin 已他移/隊滅）
```
- 路由 24 寫：
  - deposit（salary:76/train:189/anon_tier:240/movement:233/player:189）→ `deposit`。
  - withdraw（faction_ai:1390/person_generator:100）→ `withdraw`。
  - 配對 `from -= ; to +=`（player:1145-1146 share/subteam:91-92/encounter 1132-1133）→ `transfer`。
  - `winner += loser; loser = 0`（encounter:1127-1128,1136-1137,1448-1449/subteam:99-100）→ `transfer_all`。
  - subteam split（42-43 `sub = parent*frac; parent -= sub`）→ `transfer(parent, sub, parent*frac)`。
  - **standalone `=0`（faction_ai:1456,1487）→ 查上下文**：若 coin 已先他移/隊滅 → `reset(team, reason)`；若無（憑空蒸發）→ **守恆 bug，回報**（coin_eq 應已紅或 treasury 未入 audit）。
- 禁裸 `anon_treasury =`（除 bank）= grep 驗。

## 守恆（硬約束）
- **coin_eq/CoinAudit 必綠不變**：transfer/transfer_all 原子 → 守恆 by construction（優於現分離寫）。deposit/withdraw 對應既有 coin 流（薪/extract 另一端已記）。
- withdraw clamp min(amt,bal)（不透支=不憑空）；transfer 同。
- standalone =0 若實為 leak → 揭出（不在本塊掩蓋；回報 systems 決是否補守恆）。

## 驗收
- AnonTreasuryBank deposit/withdraw/transfer/transfer_all/reset 單測（含 transfer 守恆：src+dst 總和不變）。
- **coin_eq/CoinAudit 全綠不變**（最關鍵）；既有 encounter/subteam/salary/extract 測綠。
- 2 年 world_sim：coin 守恆（CoinAudit delta=0）、treasury 流動正常、headless 全綠、InvariantAudit 0。
- grep 驗無裸 anon_treasury 寫。

## 檔案
- 新 `scripts/simulation/anon_treasury_bank.gd`。
- 改 24 寫者（grep 定位）：encounter_system/faction_ai_system/movement_system/person_generator/player_command_system/salary_system/subteam_system/anon_tier_system。
- `headless_test.gd`：bank 單測（含守恆）+ 既有沿用。
- 2 年 world_sim（重點看 CoinAudit）。

## 非本塊
- resources banker（110 寫,最大,守恆）、outpost_owner（race）= 各別 slice。
