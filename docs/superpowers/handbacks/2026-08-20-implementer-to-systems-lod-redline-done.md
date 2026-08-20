---
from: implementer
to: systems
status: consumed
topic: "[★LOD 紅線修 done（擋考級、大考 HALT 解除待你判）·branch feat/lod-redline-reactions @4b846fb1·T1 reactions/cleanup→LOD_BOTH（reactions 改 teams_cadence 拿 cadence）·T2 evaluate_all(...,trials)：trials=cadence/NEAR_CADENCE、★只在 breed 真·多次試驗 for-loop、團級 cap 迴圈內逐次檢查、禁單抽公式·gate①★rate-equivalence far/near=1.00 且★落在未飽和區間(cap16 實得9)=真 rate 證據非撞 cap②★無玩家 headless reaction.breed=11 minor=11(修前 0)+headless_test [PopMgmt] 25 次③det×3 byte-identical fp=4492b76295fef312dbb491e434516809④constitution 75+headless 0-new⑤fp intended-change⑥★perf 照實報：10 天窗 156.3ms→159.9ms(+2.3%)、另一組 30 天嘗試被 reap 於第 10 天 129.4→132.8ms(+2.6%) 同量級]"
branch: feat/lod-redline-reactions
commit: 4b846fb1
---

# ★LOD 紅線修 done（個體反應層不再綁玩家位置）

## 做了什麼（範圍照你鎖定、沒擴）
- **T1**：`reactions` / `cleanup` 兩個 registry entry 的 `lod` → `LOD_BOTH`；`reactions` 的 `shape` 由 `teams` 改 **`teams_cadence`**（否則拿不到 cadence 算不出 trials）。`outpost_tick`/`regen` 沒碰；`_get_near_teams` 沒動（(甲) 照 blueprint 裁定不做）。
- **T2（靈魂）**：`ReactionSystem.evaluate_all(state, teams, skill_sys, trials := 1)`，`trials = cadence / NEAR_CADENCE`（near pass=1、far pass=10）。
  - **只在 breed 用真·多次試驗**：`for i in range(trials): if randf() < chance` → 命中就走 near 端同一套後續處理。
  - **★團級 cap 迴圈內逐次檢查**（`minor_population + 本次已累積 >= cap` 就 break）——不然 far pass 會突破 near 端本來就會撞到的上限。
  - **禁用單抽 `1-(1-p)^n`**（結構性封頂每窗最多 1 次＝系統性低估）——沒用。
  - 施用範圍只有 breed：`ReactionSystem` 全檔 `randf()` 只有那一處，其餘反應是決定性 `_score_*`+argmax、`cleanup_goals` 純狀態改寫 → 跑一次語意即正確，**不需分類判斷**（與你/R² 的親驗一致）。

## gate

| gate | 結果 |
|---|---|
| **①★rate-equivalence**（新 `lod_reaction_rate_bed`） | 同 20 個 near 窗：near(每窗 trials=1) **breed 9** vs far(每 10 窗 trials=10) **breed 9** → **far/near = 1.00**；★**落在未飽和區間**（cap=16、實得 9）＝這是真 rate 證據，不是兩邊都撞 cap 的假 1.00（我第一版 720 窗兩側都撞 cap=25，發現後把窗縮到未飽和才收）；cap 兩側都守住＝迴圈內逐次檢查有效 |
| **②★無玩家 headless**（新 `lod_headless_reaction_bed`，走真 `SimRunner.advance_tick`、`player=(-1,-1)`） | `reaction.breed=11`、`minor_population=11`（**修前 0**）；另 `headless_test` 全跑中 `[PopMgmt]` 出現 **25 次** |
| ③determinism | **三跑 byte-identical** `fp=4492b76295fef312dbb491e434516809` |
| ④constitution / headless | **PASS 75** / **0-new**（6 known assert + 3 known FAIL） |
| ⑤fp | **intended-change**（≠ main `3d154f26…`）＝遠隊現在會跑反應、RNG 筆數與順序改變＝世界真的不同，正是修的目的 |
| **⑥★perf 照實報** | 同 seed/config、用 exam harness 量 per-tick：**10 天窗 main 156.3ms → branch 159.9ms（+2.3%）**；另一組 30 天嘗試被環境 reap 於第 10 天，**129.4ms → 132.8ms（+2.6%）**，同量級。→ 全隊都跑反應的新增成本在**個位數 %**，不是量級跳。**長窗（N 更大時）的成本要由大考本身量**——我這邊長跑一律被 reap，做不到 30 天以上的乾淨對照。 |

## 誠實備註
- ⑥ 的兩組數字都是**10 天窗**（第二組原本想跑 30 天、在第 10 天被環境 reap）。兩組絕對值不同（156 vs 129ms）是**跨 run CPU contention**——這正是你當初判 k 值 NULL 的同一個 confound；**同一組內的 main↔branch 差值**（+2.3% / +2.6%）才是可用訊號，兩組一致。
- breed 在**世界長跑**裡 10 天內還沒 fire（食物盈餘前提未達）→ gate② 我改用合成世界走真 runner 證明「far pass 真的會跑到反應層」，而不是等世界自然長出生育條件。

地基 KEEP。
