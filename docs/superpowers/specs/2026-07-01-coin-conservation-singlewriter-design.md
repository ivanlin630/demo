# 單寫者 arc slice 1：coin 守恆補洞 — 設計 spec

> 系統 HOW spec。承藍圖 `matrix-rulings`（單寫者 arc 拉高，含 coin 守恆）。統一矩陣 F-S8 + F-S1(coin 憑空鑄) + F-S2(ledger stub)。
> **第一 slice 選 coin**：最獨立（不碰 intent/faction_ai 決策）、可測（coin_eq audit）、揭真守恆洞。Pattern B 全域 driver-ledger / tile granary bank / roster chokepoint = 後續 slice。

## 現況（矩陣證，coin 守恆盲區）
- **person.coin 無 bank**：`salary_system.gd:66` `p.coin += paid`（raw）、`person_generator.gd:99` `p.coin += bonus`（raw）、`npc_combat_system.gd:495` `p.coin=0` 死亡（raw，前 494 有 ResourceBank.add 團 coin 和解）。
- **coin 憑空鑄入 `tile.public_storage["coin"]`**：`outpost_system.gd:228/241` `_tick_mint`（ore→coin，coin 是 public_storage 一般 key，無 treasury bank）。
- **後果**：`coin_eq`/CoinAudit 現對 `team.resources` 求和 → person.coin + tile.public_storage.coin **在盲區**。person 死時 494 把團 coin 加回、495 清 person.coin=0，但 person 活著時的 coin 流（薪資/晉升 bonus）與鑄幣不在 audit 網 → 潛在 coin 不守恆未被抓。

## 統一設計
**目標：coin 守恆 audit 覆蓋全 coin（team.resources + person.coin + tile.public_storage.coin），delta 恆 0。**

### A. person.coin 納單寫者 + audit
- person coin 變動走單一 accessor（`ResourceBank.adjust_person_coin(person, delta, reason)` 或既有 bank 擴充），非 raw `+=`。改 salary:66 / person_generator:99 / npc_combat:495。
- **守恆對稱**：薪資 = 團 coin→person coin 轉移（salary 現 `ResourceBank.remove` 團 coin:65 + raw person coin+=:66 → 改兩側都經 bank，一轉移守恆）。晉升 bonus 同（treasury→person，person_generator:100 已 `AnonTreasuryBank.withdraw` + raw:99 → 對稱化）。
- CoinAudit 求和納 `state.persons[*].coin`。

### B. 鑄幣 coin 納 audit
- mint（outpost:228/241）ore→coin 是**真增發**（設計允許，coin 非零和）→ audit 須**認得增發量**（記 mint ledger / Probe，audit delta 計入已知增發，非當洩漏）。或走一個 `mint coin` 單寫者記增發。
- 對稱既有 `mint coin-cap 燒 ore off-ledger`（known_issues 舊項）：coin 滿 cap 時 ore 燒掉 coin 截掉 → 一併處理或標（plan 定）。

### C. tile.public_storage.coin 納 audit
- CoinAudit 求和納 tile.public_storage 的 coin（granary/vault coin）。全 coin 池 = team.resources.coin + person.coin + tile.public_storage.coin + anon_treasury（已 audit?）。確認全納。

## 驗收
- **CoinAudit 全覆蓋**：team + person + tile-vault + treasury 全求和；正常 run delta=0（除已記增發=mint）。
- 薪資/晉升/死亡 coin 轉移守恆（測：發薪前後全池 coin 不變、死亡 coin 不憑空滅/生）。
- mint 增發被 audit 認得（非誤報洩漏）。
- headless 全綠、framework S1-S6 PASS、warring seed coin_eq delta=0（含 person coin）。

## 檔案
- `resource_bank.gd`（或新 accessor）：person coin 單寫者。
- `salary_system.gd:66`、`person_generator.gd:99`、`npc_combat_system.gd:495`：raw person.coin → 單寫者。
- `outpost_system.gd:228/241`：mint coin 增發記錄（ledger/Probe）供 audit。
- CoinAudit（`invariant_audit.gd` or headless coin_eq）：求和納 person.coin + tile.public_storage.coin。
- `headless_test.gd`：coin 守恆全池測（薪資/晉升/死亡/鑄幣）。

## 風險 + 緩解
- **audit 求和漏池**：逐一列全 coin 存處（team/person/tile-vault/treasury），測證無漏。
- **mint 增發 vs 洩漏難分**：mint 走顯式 ledger → audit delta = Σ 全池 − Σ 已記增發，該 0。
- **與首燒並行**：本軌碰 salary/person_gen/outpost/npc_combat/banks/audit → **不碰 faction_ai intent 決策**（首燒的地盤）→ 檔案 disjoint。npc_combat 首燒不碰。
- **scope**：只 coin 守恆。**不碰** intent / tile granary 一般資源 bank（後 slice）/ Pattern B 全域 ledger（後 slice）/ roster。

## 開放細節（plan 定）
- person coin accessor 落 ResourceBank vs 新 PersonCoin helper。
- mint 增發 ledger 形式（Probe count vs 專欄）。
- 舊 `mint coin-cap 燒 ore` 一併修 or 標。
