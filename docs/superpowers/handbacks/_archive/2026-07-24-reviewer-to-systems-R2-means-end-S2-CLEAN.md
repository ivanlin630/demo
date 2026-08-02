---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN] means-end S2 資源型(f9114f74)——must-fix①護欄親驗數學成立+belief-gated 確認+第3消費點排查，merge 放行→dispatch S3"
---

# R② 判決：means-end S2 資源型 resolver — CLEAN

`git show f9114f74` 逐行核 + 額外自行排查 2 項你摘要沒細寫的角落（非只信你 code-驗結論）：

## ★must-fix① util 護欄——親算數學，非只信「clamp 有寫就過」
`goal_resolver.gd`：`GOAL_UTIL_CAP=1.5`（const，< `DecisionEngine.SURVIVAL_BOOST_MAX(2.5)`，我已核實該常數真是 2.5）。`_candidate_util = clampf(payoff × dev_coeff, 0, GOAL_UTIL_CAP)`，`dev_coeff = clampf(food_days/DESPERATION_DAYS, 0, 1)`。我自己代入 TDD 三案例驗算：
- payoff=1e9, food_days=0.001 → dev_coeff≈0.00033 → 1e9×0.00033=333333 → clamp→**1.5**（<2.5 ✓，且 1.5 比 survival 絕境真實 floor 更保守——survival 絕境 util= base_u(≥0) + boost(→2.5)，1.5 連 boost 單獨一項都不到）。
- payoff=1.0, food_days=0.001 → 0.00033 → 不觸頂，≈0（遠慾望正確歸零）。
- payoff=1e9, food_days=100 → dev_coeff clamp 到 1.0 → 1e9 → clamp→**1.5**（GOAL_UTIL_CAP，恆有界不爆）。
三算全通過我自己重算，非只信 TDD 綠燈字面。雙機制（dev_coeff 壓制 + 硬 clamp）確實都做了，非擇一。

## belief-gated 確認——親讀函式本體
`_nearest_market_outpost_with`（`faction_ai_system.gd:2139-2156`）：`state.team_market_known.get(team.team_id,{})` 起手——**真讀 belief store**，非全圖 `world.tiles` 掃（鏡射既有 `_nearest_market_outpost` 同款合法模式）。感知鐵律守住。

## ★我額外排查：`e.has("cand")` routing 是否漏第4消費點
你摘要只提 3 路（unified/subteam/solo），我另 grep 全檔 `DecisionOptions.to_task(` 呼叫點，發現 2 個不在你 patch 清單的（`:857 rank_ambient` 消費 / `:3526 rank_survival` 消費）——**追查後確認非漏**：`rank_ambient`(`decision_engine.gd:213-224`)與`rank_survival`(`:156-177`)**各自獨立 `DecisionOptions.applicable(ctx)` loop 現算 scored**，**皆不呼叫 `rank_scored_ctx`、不 append `GoalResolver.frontier_candidates`**——這兩條 rank 路結構上永遠碰不到 goal candidate，不需要 `cand` check。3 路 patch 清單完整、無遺漏。

## 其餘
- 資源型 walk 邊界（非 resource 前置 continue）：TDD③ 顯式驗證，程式碼逐行核對正確。
- need_keep 泛化範圍（S2 用既有通用 `need_keep`，`CONSTRUCTION_COST_RES` 白名單留 S4 才泛化）：同意你的判斷——S2 資源維持 goal 讀的是 need_keep **整體值**，不需深挖 construction 子項白名單；那是 S4 設施型 goal 才會踩到的正交 concern，非本 slice 漏做。
- label 有界（`gt:PREREQ_RESOURCE`）：吻合 HOW §7 bounded label 設計。
- 冪等 `ensure_maintain_goals`：TDD 顯式驗二次呼叫不增。

**CLEAN → 放行 merge → dispatch S3**（定位型+通用 tile-resolver+`team_tile_known` belief store）。S3 是 must-fix② 落地首戰場——地形/所有權查詢拆分是否真守住，我會盯。
