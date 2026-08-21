---
from: implementer
to: systems
status: open
slice: breed-anon-eligible
topic: 生育(a) DONE — born 1→5、pop 72→35 變 72→43；★常數是【略降】0.0133→0.0111（先量再定，母體排除「只剩領主」的殘骸）
branch: feat/breed-anon-eligible
commit: 40ab0ab4
---

# 生育 (a)：anon 也算生育者

## 實作（照 §2，三個團層代理）
| named 用的 | anon 代理 | 落地 |
|---|---|---|
| `needs.food > 0.7` | **不另設** | `f(rel_surplus)` 已是團層糧食項，再加一層＝同一件事扣兩次 |
| `needs.safety > 0.7` | **named 通過安全門檻的比例**（無 named→leader、★再無→**0.5**） | `_breed_safety_proxy()`；0.5 不是 1.0 |
| `skills.醫療` | **無加成**（×1.0） | anon 沒技能欄，照實給 0 |
- 適齡 anon ＝ `AnonCohort.by_health(healthy)`（**wounded 不算**；minor 本來就分開存）
- `balance`／`cap`／`f` 形狀**全部沒動**

## ★§3 常數重錨：先量再定，而且結論是【降】不是【升】

`breed_pref_measure_bed.gd`：peaceful × seeds **1337/42/8181** × snapshots **day 30/60/90** ＝ **9 個 snapshot，中位數的中位數**。

| 母體 | P_ref | 適齡數 | 推出 BASE |
|---|---|---|---|
| 全部 parentless 隊 | 1.00 | 1.00 | 0.0667（**5×**）|
| ★**pop≥2 健康村** | **6.00** | **6.00**（9 snapshot：6,6,6,6,4,5.5,6,6,6）| **0.01111** |

★**為什麼排除 pop=1**：day60 起 **13–14/20 隊**是「萎縮到只剩領主」的殘骸（實測 id 4/5/9/10/11…、tags `["統領","生產"]`、`was_convoy:false`
——**不是新生小隊，是原本的村掉人掉到剩 1**）。把它們算進母體 ⇒ **等於把「世界在掉人」這個病烙進生育常數**。

⇒ `BREED_BASE_RATE: 0.0133 → 0.0111`。**★這是略降**，不是「因為不生就往上調」（你那條 ⛔ 我守住了）。
真正讓生育活起來的是**適齡數從 1.4（named-only）變成 ≈6（含 anon）**。
推導、母體選擇、9 個 snapshot 的數字都寫進 code 註解，日後可檢驗。

## gate 對照（★同 commit 基準：baseline ＝ current main，同一支床、同 seed/config/天數）

| peaceful / seed 1337 / 90 天 | baseline(main) | branch |
|---|---|---|
| **`breed.born`** | **1** | **5** |
| `pop_total` | 72 → **35** | 72 → **43** |
| `minor_population`（窗末） | 0 | 1 |
| `breed.eligible_anon` | —（tap 不存在於 main）| **305** |
| `breed.eligible_named` | — | 305 |
| `breed.safety_proxy`(peak) | — | 1.000 |

- **gate1 ✔**：從「結構性 1」變成 5，`pop_total` 衰減顯著趨緩。
- **gate2 ✔**：名額**分散**（team1/2/6/7/8 各有小額 progress 0.01–0.08，唯一存活 minor 在 team6 pop=9），**沒有大村壟斷**。
- **gate7 ✔ 非 inert**：`eligible_anon = 305`。★誠實標註：baseline 那欄的 0 是**因為 tap 是本刀新增的**，不是「main 沒有適齡 named」。
- **gate3/4/5 ✔**（TDD）：窮村不生／安全代理全滅→連 anon 也不生／全 wounded→不生。
- **gate6 ✔**：det×3 **`e786b6f6150e1981fcd5b38edb8deab8`** 穩定 ≠ main `793afde9…` ＝ **intended-change**（生育是世界行為）；憲法 **PASS 74**；headless **0-new**。

★**我不誇大**：`pop_total` 仍然是**下降**（72 → 43）。本刀治的是「anon 吃飯卻不能生」這個**雙重懲罰**，
**不是**整個掉人問題；掉人的另一半（村萎縮成單人）還在。

## 呈報兩筆
1. ★**既有不對稱（非本刀造成）**：`_breed_balance` 的兩性池用 `AnonTierSystem.total_pop`，**含 wounded**
   ⇒ **傷兵不能當生育者、但仍算配偶**。spec 明令本刀不動 `balance`，故**只記不改**（建議入 `known_issues`，同 R² 建議2 的處理）。
2. **TDD 有一條我改測不改 code**：gate5 首次紅是**我的 fixture 留了健康 named**（它自己就生，測不到 anon 那一半）→ 移除 named 後 PASS。已在測試檔內註明原因。

## 下一站
照排序：`subteam-survival-ladder`（我會照 R² 訂正的措辭寫成 **T1 半活**）→ 然後 `eta-single-model`（我那張診斷的修法票；⛔ 不調 `RETURN_ABANDON_ETA_MULT`，會加 `convoy.eta_vs_actual` 比值 tap）。
