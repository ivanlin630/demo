# Hand Back: 性別資料 + 生育需兩性

Plan: `docs/superpowers/plans/2026-06-22-gender-breeding.md`
Branch: `feat/gender-breeding`（worktree `.worktrees/gender-breeding`）

## 實作摘要（改了哪些檔案）

- `scripts/data/person_data.gd`：加 `var sex: String = "male"`（"male"/"female"，④Trait 前置資料）。
- `scripts/simulation/person_generator.gd`：`generate()` 內 `p.age` 後加 `p.sex = "female" if rng.randf() < 0.5 else "male"`（seeded，可重現）。
- `scripts/data/team_data.gd`：加 `var anon_female_ratio: float = 0.5`（anon 女性占比 metadata，不影響 pop count；放在 `minor_population` 旁，不動 anon_cohort schema）。
- `scripts/simulation/reaction_system.gd`：加 `_breed_balance(team, breeder_sex := "")` helper + `_evaluate_life_events` 出 P5_breed 前乘 balance（balance<=0 → 全單性 → 不繁衍）。
- `scripts/debug/headless_test.gd`：加 `_test_person_sex`、`_test_breed_needs_both_sexes`，註冊於「Economy Bootstrap 生育分層」測群之前。

Commits：
- `feat(data): PersonData.sex + generate 50/50 (Trait前置資料)`
- `feat(reaction): 生育需兩性 — anon_female_ratio+balance gate(全男隊不繁衍)`
- 本 handback commit。

## 確認到的簽名（plan 要求先驗）

- **`PersonGenerator.generate`**：`static func generate(state: WorldState, seed_offset: int, role: String = "member") -> PersonData`。
  **無 rng 參數**（plan 草稿的 `pg.generate(rng)` 是錯的）；內部 `var rng := RandomNumberGenerator.new(); rng.seed = seed_offset` 自建 rng。
  → 測試與實作都對齊真實簽名：用不同 `seed_offset` 取樣 200 次，`p.sex` 設在 `p.age` 後用該內部 rng。實測 200 抽 男=112 女=88（兩性皆有、近均衡）。
- **`ReactionSystem._evaluate_life_events`**：`func _evaluate_life_events(p: PersonData, t: TeamData) -> Array`。
  **只有 (p, t)，無 state** → 函式內**取不到 `state.persons`**，無法遍歷 named PersonData.sex。
- `PersonData.needs` 為 Dictionary（`{"food","safety","belonging"}`）；`team.named_members` 為 id Array；`AnonTierSystem.total_pop(team)` = anon 桶總數。Fixture 對齊無誤。

## named 性別計數如何處理（近似，非精確）

因 `_evaluate_life_events(p, t)` 簽名無 state（確認如上），**無法在該函式內枚舉全隊 named 的 sex**。
依 plan 指示採**近似**：

- `_breed_balance(team, breeder_sex)`：anon 用 `anon_female_ratio` 估男女數（`m = anon×(1-ratio)`、`f = anon×ratio`）；
  named 只把**當前 breeder 自身的 sex**（`p.sex`）計入一方（+1）。
- `_evaluate_life_events` 呼叫 `_breed_balance(t, p.sex)`。
- `min(m, f) <= 0 → 0`（全單性不繁衍）；否則 `min(m,f) / max((m+f)/2, 1)`。

**這是近似，不是精確全隊 named 性別計數。** 全隊其他 named 的 sex 未計入。對「全 anon 同性 + breeder 同性」的全單性隊判定正確（→0）；但若隊內 named 性別組合與 breeder 不同，平衡值只反映 breeder 一人，未反映其他 named。
→ **呈報系統**：若要精確 named 性別計數，需把 `_evaluate_life_events` 簽名改為帶 `state`（或在 team 上快取 named 性別計數）。系統可後續精修。目前近似足以實現「全單性隊不繁衍」的核心契約。

## 全男隊不繁衍 — emergent 證據

控制走查（healthy 兩性 vs healthy 全男，各 2000 次 `_evaluate_life_events`，足糧足安全 cap=5）：
- **兩性隊**（ratio=0.5、female breeder）：`minor=5`（長到 cap，正常繁衍）。
- **全男隊**（ratio=0、male breeder）：`minor=0`（即使足糧足安全且 cap 有空位，完全不繁衍）。

單測 `_test_breed_needs_both_sexes` 亦證：`_breed_balance(全男隊)==0`、`_breed_balance(兩性隊)>0`、全男隊 + male breeder 200 抽不出 P5_breed。

## 2 年 world_sim 結果（pop + conservation）

`.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`（max_ticks=172800 = 2.0 年，起始 8 隊）：
- 跑滿 24 個月，月 24 存活 6 隊（無世界全滅、無 timeout）。
- **`不變量違反累計=0`**（每 240 tick InvariantAudit 全程 0 違反）。
- `=== world_sim DONE ===` 正常收尾。
- 兩性隊（config 預設 anon_female_ratio=0.5）繁衍機制未被 gate 誤殺；emergent 繁衍以上方控制走查確證（world_sim 內 NPC 受戰損/飢荒壓力，pop 在 3-6 浮動屬正常模擬，非 gate 問題）。
- **conservation 安全**：`anon_female_ratio` 為純 metadata，不進 pop getter、不動 anon_cohort schema → pop count 不受影響。

## 全回歸結果

`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`：
- `=== DONE ===`，0 SCRIPT ERROR / 0 Assertion failed。
- `person sex OK (男=112 女=88)`、`breed needs both sexes OK`。
- 既有生育測 `Bootstrap Task3a/b/c/d OK` 全綠（兩性 fixture 預設 ratio=0.5 + breeder male → balance>0 仍繁衍，**無需改 fixture**）。
- `InvariantAudit population OK`、`InvariantAudit faction 雙向 OK`、`InvariantAudit subteam 雙向 OK`。
- coin_eq 守恆斷言通過（未碰 resources/coin）。

## 連動風險 / 待主 session 確認

- **`_evaluate_life_events` 簽名**：named 性別精確計數需 state（見上）。建議系統決定是否改簽名傳 state，或在 TeamData 快取 named 性別計數。目前近似（breeder sex + anon ratio）達成核心契約。
- **combat 接點（標記，待他域）**：戰損扭斜 `anon_female_ratio`（戰爭傷疤 → 女性占比偏移）= 待他域 combat 系統實作（未決）。目前 `anon_female_ratio` 全程固定 0.5，無任何系統會改它（含戰損）。需 combat 統一傘後接線。
- **生成端 anon sex**：anon 為 cohort 抽象無個體 sex，`anon_female_ratio` 預設 0.5 為 TEST VALUE；named（PersonGenerator.generate）為 50/50。world_gen / GameSetup 種隊時若要非 0.5 的 anon 性別分布，需另設 config 欄位（目前未做，沿用預設）。
- **無其他已知連動風險**：未動 cohort key schema、未碰 resources/coin、population getter 不變。

## 後續建議 task

- combat 統一後：戰鬥傷亡按 armed/anon 抽桶時扭斜 `anon_female_ratio`（男性多打仗死 → 女性占比升），讓「戰爭傷疤」emergent。
- 若 ④Trait 需要 anon 個別性別（非比例），屆時再評估 cohort schema 是否要加 sex 維度（目前刻意避開以零衝突 cohort 測）。
