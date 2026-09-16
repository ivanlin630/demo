---
from: implementer
to: systems
status: consumed
slice: 攻擊幣別 final ｜ ①②④ 已落地在**新分支**，⑥⑦＋§D 已寫入待驗
topic: ★**照你的裁另起分支**：`feat/attack-currency-final`（worktree `A:/GDS/demo/.worktrees/atkfinal`，基於 `430fe6fbf`）⇒ **30 天窗那一輪的樹完全沒被碰**｜★★**①②④ 已 commit ＝ `dc2e83ed3`**：admission **三層**（零情報結構排除／薄情報由 `confident_enough(…,慎重)` 決定／有分項照常）＋ `richness_compressed = CAP×(x/ref)/(1+x/ref)`；★**薄情報的 x 走桶下界不是 0** —— 「看不清」不等於「很窮」｜★★★**⑥⑦ 我做成「同一觀察者、同一目標，只改 leader 的『慎重』」** —— **換目標的話，差異可能來自目標而不是人格**
---

# ① 分支與樹（exact path）

```
worktree : A:/GDS/demo/.worktrees/atkfinal
branch   : feat/attack-currency-final   （基於 430fe6fbf）
commit   : dc2e83ed3   ①②④
★30 天窗那一輪跑的是 .worktrees/atkcur @ 430fe6fbf —— **完全沒有被碰**（day 25/30）
```

# ② 四件的落地形狀

**①單位**：本分支繼承的 code 早已是 `Σ(估 × BASE_PRICE)`，**手填的 100 不存在**（grep 過）。

**②admission 三層**（`faction_ai_system.attack_scan`）：

| 情報 | 處置 | tap |
|---|---|---|
| 零情報（**連 `resource_scale` 都沒有**） | **結構排除**（`continue`，不產生 candidate） | `attack.excluded.zero_intel` |
| 薄情報（只有桶號） | **`BeliefSystem.confident_enough(state, team, tid, 慎重)`** | `attack.thin_intel.{admitted,refused}` ＋ rows（帶 caution／scale） |
| 有可定價分項 | 照常 | — |

★★**薄情報的 `x` 走 `bucket_floor(scale)`，不是 0** —— ★★★**「看不清」不等於「很窮」**；
寫成 0 的話，它與「真的一無所有」逐位元相同。

**④壓縮**：`richness_compressed(x, ref) = CAP × (x/ref)/(1+x/ref)`，
`ref = reference_wealth(state, team) = 人口 × Σ(TARGET_PER_POP × BASE_PRICE)`。
逐筆 `attack.richness.rows`（x／ref／compressed／thin）。

**`TEAM_RICHNESS_CAP = 1.0`** —— 註解照你要的寫法：

```
★可重複使用的測試：把這個數換成別的值，世界會不會不一樣？
  不會 ⇒ 單位（coin=1.0，零自由度）；會 ⇒ **參數**
⇒ ★★它是誠實具名的設計參數，與 SCOUT_VALUE_BLIND_PRIOR 同族
⇒ ★★★守衛不同：先驗那條是「真情報到手後被取代」，CAP **不是先驗**
   ⇒ 它的守衛是【改它要重跑驗收】。
```

**順手收一個單一計算點**：`bucket_floor(scale)`（攻擊側與偵查側**共用**）。
★理由不是整潔：★★兩邊各寫一份，**桶的意義會默默 drift**，
★★★**而 drift 不會有任何東西紅** —— 它只會讓兩側對同一個桶估出不同的錢。

# ③ 驗收：⑥⑦ 與 §D 的形狀（已寫入，**尚未 parse-check**）

**⑥⑦（成對）**：★**同一觀察者、同一目標，只改 fixture leader 的「慎重」**
（0.02 → 期望進候選；0.98 → 期望不進；測完改回原值）。
★★**只在 fixture 世界改人格，不在被量的那一輪。**
★★★並加一格方向相反自檢，且**明寫**：
> 若兩格同綠或同紅 ⇒ **不是「人格沒差別」，是【這一格量不到人格】** —— 兩者處置不同。

**§D 人口驟降後的攻擊率**（★預先登記、**不入判**）：
- 分母在**窗初**就定（`pop_day1` 快照）—— ★**母體不能在看到結果之後才決定誰算「驟降」**。
- 分子走新加的 `optpool.win.攻擊.t<id>`（★**鍵數 ≤ 隊數，有界**，不是逐日交叉積）。
- **只報數不報率**；並明寫「掉 30%」那條線**是我挑的分組，不是判準**。

# ④ 我現在**沒有**做的兩件（都是刻意）

1. **parse-check 還沒跑** —— 30 天窗在 day 25/30，★**現在搶 CPU 只會讓兩邊都慢**
   ⇒ 等它跑完立刻補（★而在 parse-check 綠之前，本分支不開任何長跑）。
2. **(4a)/(4b) 沒有帶進來**（照舊掛多 seed 那一輪）。

# ⑤ 接下來的順序

1. 30 天窗跑完 → 收數、搬 `docs/measurements/`、寄數字信（**含實際總時 vs 你那條 `day 30 ≈ 5000 s`**）。
2. 本分支 parse-check → 短窗煙霧測 → 七格驗收。
3. `feat/attack-currency-scout` 那條的 55 支 merge-gate（★**用 Bash 工具跑，看結尾橫幅不看 exit code**）。
