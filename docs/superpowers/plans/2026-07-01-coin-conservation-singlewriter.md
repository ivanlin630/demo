# Plan — 單寫者 slice 1：coin 守恆補洞

> spec = `specs/2026-07-01-coin-conservation-singlewriter-design.md`。零行為變(純守恆補洞+audit)。
> 前置：headless 基準 PASS + coin_eq delta 記下。

## Task 1 — CoinAudit 全池求和（先量,揭現狀）
- 找現 coin_eq/CoinAudit 求和點（headless_test / invariant_audit）。擴求和納：`team.resources.coin` + `state.persons[*].coin` + `tile.public_storage.coin`（全 tile）+ `anon_treasury`（確認已納）。
- **先跑**：現狀 delta（可能非 0=揭洩漏 or 未記增發）。記 baseline。
- **DoD**：全池求和就位、baseline delta 在手。

## Task 2 — person.coin 單寫者（TDD）
- `resource_bank.gd` 加 `adjust_person_coin(person, delta, reason)`（或 PersonCoin helper）。
- 改 raw：`salary_system.gd:66`（薪資=團→person 轉移,兩側經 bank 守恆）、`person_generator.gd:99`（晉升 bonus=treasury→person 對稱）、`npc_combat_system.gd:495`（死亡清零,前 494 團 coin 和解對稱）。
- **測**：發薪前後全池 coin 不變;晉升 bonus 守恆;死亡 coin 不憑空滅/生。
- **DoD**：person coin 走單寫者、轉移守恆、測綠。

## Task 3 — mint 增發納 audit
- `outpost_system.gd:228/241` mint（ore→coin，真增發）記增發量（Probe `g1.mint_coin` 或 ledger）。
- CoinAudit delta = Σ全池 − Σ已記增發 → 該 0。
- 舊 `mint coin-cap 燒 ore off-ledger`（known_issues）：一併修（滿 cap 不燒 ore）or 明確標。
- **DoD**：mint 增發被 audit 認得（非誤報洩漏）、delta 0。

## Task 4 — 守恆閘
- headless PASS≥基準、**coin_eq 全池 delta=0**、pop 守恆、warring seed coin 守恆（含 person coin）、無 GDScript 錯。
- **DoD**：全池 coin 守恆綠。

## 不碰（scope + 並行 guard）
- faction_ai intent（首燒軌）、interaction（BEG軌）、tile granary 一般資源 bank（後 slice）、Pattern B 全域 ledger（後 slice）、roster。**只碰 salary/person_gen/outpost mint/npc_combat coin/banks/audit**。

## 完成
- handback：全池 coin audit 覆蓋、person coin 單寫者、mint 增發記錄、baseline→0 delta、發現的洩漏（若有）。
- ⚠ npc_combat 首燒不碰、outpost 首燒不碰 → 檔案 disjoint;若 faction_ai 有 coin 寫需協調（本軌盡量不碰 faction_ai）。
