# Hand Back: coin 守恆單寫者 slice 1

branch: `feat/coin-conservation`（已 push，未 merge）
plan: `docs/superpowers/plans/2026-07-01-coin-conservation-singlewriter.md`

## 實作摘要
- `scripts/simulation/coin_audit.gd`（新）：`CoinAudit.total(state)` 全 coin 池求和 = team.resources.coin + team.anon_treasury + person.coin + tile.public_storage.coin + tile.abandoned_coin。
- `scripts/simulation/resource_bank.gd`：加 `adjust_person_coin(person, delta, reason)` = person.coin 單寫者（clamp ≥0）。
- `scripts/simulation/salary_system.gd:66`：`p.coin += paid` → 單寫者（團側已 ResourceBank.remove，一轉移守恆）。
- `scripts/simulation/person_generator.gd:99`：晉升 bonus `p.coin += bonus` → 單寫者（treasury 側 AnonTreasuryBank.withdraw 對稱）。
- `scripts/simulation/npc_combat_system.gd:495`：死亡 `p.coin = 0.0` → `adjust_person_coin(p, -p.coin)`（前 494 團 coin 和解不動）。
- `scripts/simulation/reaction_system.gd:292`：**plan 未列**的第 4 處 raw `person.coin += steal`（N5 勒索）→ 一併改單寫者（否則單寫者不完整）。
- `scripts/simulation/outpost_system.gd` `_tick_mint`：(1) 修 known_issues「mint coin-cap 燒 ore off-ledger」= 先算 coin room，只鑄容得下的量、不燒 ore；(2) 加 `Probe.add_amount("mint_coin", coin_added)` ledger。
- `scripts/debug/probe_stats.gd`：加 `amounts` 浮點累計器 + `add_amount`/`amount`（enabled 才記，正常 run no-op）。
- `scripts/debug/headless_test.gd`：`_run_sim_test` 200-tick 全池守恆閘（delta == Σminted，實測 0）；新單元測 salary/晉升/死亡/滿-cap-mint 守恆；`_coin_eq_sum` 改 delegate `CoinAudit.total`。

## 與 spec/plan 的差異（設計決策，待確認）
1. **coin_eq 口徑改純 coin，剔除 ore**。plan Task 3 傾向「mint 增發走 ledger」，spec 另留「ore-inclusive」為選項。查證後**剔除 ore**：`resource_system.gd` 採集 ore 是 `productivity × skill 乘數` 產出（非守恆，如 food），若把 ore 當 coin-equivalent 計入 coin_eq，採礦會讓 coin_eq 憑空長 → 守恆律破。故 coin_eq = 純 coin 池，mint 為唯一 coin 來源，走 Probe ledger 認得增發。**舊 `_coin_eq_sum` 的 ore×ratio 已移除**。
   - 連帶：`_test_mint_conserving`（ore+coin 同口徑的**局部**價值守恆測）**保留未動** — 它驗的是 mint 轉換不丟值（cap-burn），與全池 coin_eq 口徑無關，仍有效。
2. **baseline delta = 0**（Task 1）：200-tick 多隊含戰鬥場景，現狀全池 delta 本就 0 → 未揭真洩漏。本 slice 價值 = audit 覆蓋補全（原 `_coin_eq_sum` 盲 person.coin + tile vault）+ 單寫者紀律 + 守恆閘常駐，非修既有洩漏。
3. **ledger 用 Probe 累計器**（非 WorldData 新欄位），避免動世界模型；正常 run Probe.enabled=false → 零成本，守恆閘內臨時開啟。

## 連動風險
- `faction_ai_system.gd:1763`（滅團遺財路由進 tile vault + abandoned_coin）：**未改**（scope=不碰 faction_ai）。CoinAudit 已納 tile.public_storage.coin + abandoned_coin → 此轉移對 audit 守恆。**但** `_route_extinct_assets` 有 pre-existing「radius 全無有效格 → coin 憑空丟失」LEAK（:1753），radius-4 正常 run 不觸發；若後續大地圖跑守恆閘可能報 delta≠0 → 屬已知 leak，非本 slice 回歸。
- `Probe.enabled` 在 `_run_sim_test` 200-tick 期間開啟後關閉；Probe 只記數不改 state，但若其他系統將來依賴 Probe 狀態需注意。
- tile.public_storage 一般資源（含 ore）bank / roster chokepoint / Pattern B 全域 driver-ledger = 明列後 slice，未碰。

## 待主 session 確認
- **設計裁定**：coin_eq 剔除 ore 是否符合系統意圖？（我判 ore=採集產出非守恆，剔除為正解；若系統要 ore-inclusive 需先讓採集守恆，範圍大）。
- **建議後續**：`_route_extinct_assets` no-tile LEAK（:1753）可納下一 slice 或明確標永久豁免；invariant_audit.gd:4 註解稱 coin_eq「註冊於此」但 coin 守恆本質是兩時點差、非單快照不變量 → 實際落在 headless 閘，註解可校正。
