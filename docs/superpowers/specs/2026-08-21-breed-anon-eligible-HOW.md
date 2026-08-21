# HOW spec：生育 (a) —— 讓 anon 也算「生育者」

slice: breed-anon-eligible
date: 2026-08-21 ／ owner: systems ／ **WHAT ＝ 用戶 2026-08-21 拍板「(a) 匿名也能生（推薦）」**
（授權真檔：`2026-08-21-blueprint-to-systems-five-rulings.md`）

## §1 前提（全部實測坐實，非推論）

**病**：`breed_rel_surplus` 的分母是 **`t.population`（含 anon 全部）**，
而適齡迴圈**只跑 `state.persons`（named only）**
⇒ **anon 吃飯拉低 `rel_surplus`、卻不能生 ＝ 雙重懲罰**。

**實測後果** `breed.born=1 · n_persons 24→24 凍結` **@70a792b3 2026-08-21**
（repro：`EXAM_CONFIG=peaceful EXAM_MONTHS=3 EXAM_SEED=1337 .	ools\godot.ps1 --headless --script scripts/debug/exam_12mo_bed.gd`）。

### ★三個把範圍縮小的事實（查證後才敢寫）
1. **anon 不是個體、是 cohort 計數**：`team.anon_cohorts` ＝ `"tier|health" → count`（`team_data.gd:207`）
   ⇒ **不需要實例化任何個體**。
2. ★**`_breed_balance` 早就把 anon 算進兩性池**（`reaction_system.gd`）：
   `m = anon_total × (1-ratio)`、`f = anon_total × ratio`，再依 named breeder 的性別 +1。
   ⇒ **anon 一直是「配偶」，只是不算「生育者」** —— 本刀補的正是這一半。
3. **新生兒一律長成 anon 平民**（`population_system.gd:22` `add_anon(TIER_PLEB)`）
   ⇒ **生育路徑上沒有血脈**，本刀**不觸及**「named 子女要不要存在」
   （**王朝 arc 掛點，用戶裁定不現在開、不塞這刀**）。

## §2 設計：一條公式、兩種人口

現行：`daily = Σ_{named 適齡} BASE × f(rel) × 醫療加成 × balance`
改為：`daily = BASE × f(rel) × balance × ( Σ_{named 適齡} 醫療加成  +  適齡anon數 )`

### 適齡 anon 數
`AnonTierSystem.total_pop(team)` **扣掉 `wounded` 桶**。
（`minor_population` 本來就分開存，不在 anon 池內 ⇒ 不必扣未成年。）

### ★anon 沒有個別 `needs`／`skills` ⇒ 團層代理（**本刀真正的設計工作量**）
| named 用的 | anon 的代理 | 理由 |
|---|---|---|
| `needs.food > 0.7` | **不另設** | **`f(rel_surplus)` 已經是團層的糧食項**；再加一層 ＝ 同一件事扣兩次 |
| `needs.safety > 0.7` | **該隊 named 通過安全門檻的比例**（無 named 時取 leader；再無則 1.0） | **用既有世界訊號，不新增機制**；「當家的人覺得安全」是 anon 處境的合理代理 |
| `skills.醫療` 加成 | **無**（乘 1.0） | anon 沒有技能欄。**照實給 0 加成，不假裝有** |

★ **`balance` 不動**：它本來就已經把 anon 算進兩性池了。

## §3 ★常數重新錨定（不是 crank，是換掉一個站不住的推導）
現行 `BREED_BASE_RATE = 0.0133` 的推導是「健康村 `f≈0.5` × **5 名適齡成人** → 1 名額/30 日」。
**實測 24 named / 17 隊 ≈ 1.4 名/隊** ⇒ **那個推導的錨從一開始就不存在**。

**新錨（透明寫出，供日後檢驗）**：
- **參考村** ＝ `population ≈ P_ref`（**由量測定，不由我猜**：取 peaceful 世界的**中位隊伍規模**）
- **目標** ＝ 用戶已拍的 pacing **(B) ≈ 一個月一個名額**（健康村、`f≈0.5`、`balance≈1`）
- ⇒ `BASE = (1/30) / (0.5 × 適齡數(P_ref))`

⛔ **禁止**：因為「還是不生」就把 `BASE` 往上調。
**低產出要先問是不是 genuine**（世界真的窮 ⇒ `f` 本來就低），**再談常數**
（memory `feedback_genuine_value_not_crank`）。

## §4 gate
1. **世界層級真的生**：peaceful 90 天 `breed.born` **明顯 > 1**、`n_persons`／`population` **不再凍結**
   ★ **不預設目標值**——只要求「**從結構性零變成有**」，實際速率由 §3 的錨決定。
2. ★**per-capita 而非總量**：大村比小村生得多（**單位人口速率相同**）；
   **不得出現「大村壓倒性吃掉全部名額」** —— `cap = max(1, pop×0.25)` 仍在。
3. **窮村仍不生**：`rel_surplus ≤ 0` 的隊 `f = 0` ⇒ **零產出**（(甲) 精神不破）。
4. ★**安全代理有效**：合成床——同糧食、**named 安全門檻全滅** ⇒ 該隊生育速率**顯著下降**。
5. **wounded 不算**：合成床——把 anon 全移進 `wounded` 桶 ⇒ 該隊**不生**。
6. **det×3 穩定**；`fp` **intended-change**（生育是世界行為，**會變**）；憲法 ≤74；headless 0-new。
7. ★**taps**：`breed.eligible_named` / `breed.eligible_anon` / `breed.safety_proxy` 分開計
   —— **若 anon 那項恆為 0，就是本刀 inert，要在帳上明寫**（同 T1／T3 的處理）。

## §5 不做
- **不觸及血脈／named 子女**（王朝 arc 掛點）。
- **不改 `cap`**、**不改 `_breed_balance`**、**不改 `f(rel)` 的形狀**。
- **不給 anon 個別 `needs`**（那等於把 cohort 拆成個體，是另一個量級的改動）。
