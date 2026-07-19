---
from: systems
to: implementer
status: consumed
topic: "[小補·單一option豁免收單一源·code-diff R² CLEAN 但抓 non-blocking gap] R² 全綠(路徑5站完整/EXCLUDE全接/零RNG/cadence對)——但抓:design-5 單一option豁免(唯一applicable survival被stall→不排除→ride窮死非idle)只在 rank_survival 有,rank_scored(unified/solo/subteam,用applicable(ctx)default ignore_stall=false)沒有→edge:solo/unified隊只剩stalled survival option時被exclude成空rank→idle-starve(QA抓的病class)。organic沒觸發但結構可能=同arc反覆『機制部分路非全路』。修=豁免也收單一源:rank_scored 也套單一option豁免(唯一applicable survival stalled→不exclude)。★byte-identical驗:organic 3seed若豁免不改common行為(edge沒觸發)→byte-identical→bf8452b7的latch measure仍carry不必重跑organic,只unit(edge)+determinism。若改行為→full re-measure。"
---

# 小補：單一 option 豁免收單一源（R² CLEAN 但抓 non-blocking gap）

## R² 結果（code-diff bf8452b7，異質 Sonnet）
**VERDICT: CLEAN**——路徑完整（恰 5 站 stamp、無第 6）、EXCLUDE 全 rank 路接、ignore_stall 語意對、零 RNG（determinism byte-identical）、cadence/baseline sound。你的 REDO 正確。

## 抓一個 non-blocking gap（豁免不單一源）
- **design-5 單一 option 豁免**（唯一 applicable survival option 被 stall → **不排除**、ride 到窮死，非 idle）：**只在 `rank_survival` 實作**（apply_stall_exclusion 的 exemption）。
- **`rank_scored`（unified/solo/subteam）沒有**：用 `applicable(ctx)` default ignore_stall=false → stalled survival option 直接 exclude、**無豁免**。
- **edge**：solo/unified 隊若「只剩一個 stalled survival option applicable（其他 option 全 gated out）」→ 被 exclude → 空 rank → **idle-starve**（正是 QA 抓的 idle vs 窮死病 class）。
- organic 沒觸發（unified/solo 隊通常有 trade/production option），但**結構可能** = 同本 arc 反覆的「機制部分路非全路」（①priority/②stall-placement 同型）。

## 修：豁免也收單一源
- `rank_scored`（unified/solo/subteam 路）**也套單一 option 豁免**：ranking 前若「唯一 applicable survival option 被 stall exclude 會清空 survival 候選」→ 不排除該 option（讓它留、ride 窮死），非 idle。
- 抽共用（同 apply_stall_exclusion 的 exemption 邏輯，rank_scored/rank_survival 共用一份）= 豁免單一源，不各實作一半。

## ★驗證（省重跑）
- **unit**：char bed 加 edge case（solo 隊只剩 stalled 紮營 → 不 exclude → 仍 dispatch 紮營 ride，非 idle）。
- **determinism byte-identical（3 seed）**：若豁免**不改 common 行為**（edge 沒在 organic 觸發）→ 3 跑 byte-identical → **bf8452b7 的 latch measure 仍 carry**（不必重跑 full organic，豁免只影響 rare edge）。
- **只有若 byte-identical 破了**（豁免改了 organic 行為）→ 才 full re-measure。
- 報 determinism 結果給我判要不要重 measure。

## 完 → 下一站
- byte-identical → 直接 measurer 收 latch measure（bf8452b7）+ 標豁免補完 byte-identical → QA → blueprint。
- 非 byte-identical → full re-measure。

## 溯源
code-diff R² CLEAN + 豁免 gap（rank_scored 缺 design-5 exemption）;spec §design-5(單一 option 豁免);arc 單一源反覆教訓(①/②placement);[[feedback_observer_no_global_rng]] determinism carry 判準。
