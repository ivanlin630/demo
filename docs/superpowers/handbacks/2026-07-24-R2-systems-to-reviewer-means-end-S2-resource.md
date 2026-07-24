---
from: systems
to: reviewer
status: open
topic: "[R②·means-end S2 資源型 resolver·第一實質 slice(S2!=baseline 有真行為)·systems 已 code-驗全綠(★親驗 belief-gated+range 護欄+呼叫點)·reviewer 指定查 range 護欄回歸·branch feat/means-end-s2-resource f9114f74] S2=資源型 goal resolution 接通。systems code-驗(git diff+git show,留 main dir):★1.must-fix① util 護欄硬做(goal_resolver GOAL_UTIL_CAP=1.5<SURVIVAL_BOOST_MAX 2.5;_candidate_util=payoff×dev_urgency_coeff[clampf(food_days/DESPERATION_DAYS)絕境→0]+clamp 上界;TDD④range 斷言 RED 無 clamp→333k>2.5/GREEN clamp 守=硬迴歸)★2.★belief-gated 市場(我親驗 _nearest_market_outpost_with:2142 讀 state.team_market_known belief store[god-view arc 建]非全圖 god-view 掃;_harvest_market_known 親見+relay;感知鐵律守=無新後門)★3.資源型 walk+stub 邊界(非 resource 前置 continue;定位/設施/人力=S3-S5 回無 candidate)★4.need_keep 泛化(用既有通用 need_keep 任 res;CONSTRUCTION_COST_RES 硬 scope 是 build-cost 前瞻正交 concern→留 S4 facility goal 才泛化,S2 resource-maintain 不需=非漏)★5.winner→to_task 3 路整合(unified:1564/subteam:1806/solo:1948 皆 e.has(cand)?cand.to_task:既有,goal candidate 任一路 argmax 贏都路由對)★6.goal 生成 ensure_maintain_goals 接 rank_scored:49(production 呼叫確認,冪等 5 goal+status 決定性 REGISTRY key 序)★7.label 有界(gt:PREREQ_RESOURCE)★8.gate 74 removed=0(讀 belief 禁 RNG)/headless 0-new/determinism 2 跑一致。★whole-system-first:定位/設施/人力/子目標/折現/委派=S3-S6 stub。★reviewer focus:range 護欄(1)硬夠否(GOAL_UTIL_CAP 1.5<2.5+dev_coeff 雙保險)?belief-gated(2)守憲法否?CONSTRUCTION_COST_RES 留 S4(4)判斷對否(還是 S2 該泛化)?winner 路由(5)3 路無漏否?CLEAN→我 merge S2→dispatch S3(定位型+通用 tile-resolver+team_tile_known belief store,解 material 核心缺口)。有洞→回 to:systems。"
branch: feat/means-end-s2-resource
---

# R②：means-end S2 資源型 resolver（第一實質 slice，S2≠baseline）

systems **code-驗全綠**（git diff + git show，留 main dir）。reviewer 指定查 **range 護欄回歸**。

## systems 驗收（8 點）
1. **★must-fix① util 護欄硬做**：`GOAL_UTIL_CAP=1.5 < SURVIVAL_BOOST_MAX(2.5)`；`_candidate_util = payoff × dev_urgency_coeff`〔`clampf(food_days/DESPERATION_DAYS)` 絕境→0〕+ clamp 上界。**TDD④ range 斷言 RED 無 clamp→333k>2.5 / GREEN clamp 守 = 硬迴歸**。
2. **★belief-gated 市場**（我親驗）：`_nearest_market_outpost_with:2142` 讀 `state.team_market_known` belief store（god-view arc 建）**非全圖 god-view 掃**；`_harvest_market_known` 親見+relay。感知鐵律守，**無新後門**。
3. **資源型 walk + stub 邊界**：非 resource 前置 continue；定位/設施/人力 = S3-S5 回無 candidate。
4. **need_keep 泛化**：用既有通用 `need_keep`（任 res）；`CONSTRUCTION_COST_RES` 硬 scope 是 build-cost 前瞻**正交 concern** → 留 S4（facility goal 才泛化），S2 resource-maintain 不需 = **非漏**。
5. **winner→to_task 3 路整合**：`unified:1564`/`subteam:1806`/`solo:1948` 皆 `e.has("cand") ? cand.to_task : 既有`——goal candidate 任一路 argmax 贏都路由對。
6. **goal 生成**：`ensure_maintain_goals` 接 `rank_scored:49`（**production 呼叫確認**，冪等 5 goal + status，決定性 REGISTRY key 序）。
7. **label 有界**（`gt:PREREQ_RESOURCE`）。
8. **gate 74 removed=0**（讀 belief 禁 RNG）/ headless 0-new / **determinism 2 跑一致**。

★**whole-system-first**：定位/設施/人力/子目標/折現/委派 = S3-S6 stub。

## ★reviewer focus
- range 護欄 (1) 硬夠否（`GOAL_UTIL_CAP 1.5<2.5` + dev_coeff 雙保險）？
- belief-gated (2) 守憲法否？
- `CONSTRUCTION_COST_RES` 留 S4 (4) 判斷對否（還是 S2 該泛化）？
- winner 路由 (5) 3 路無漏否？

**CLEAN → 我 merge S2 → dispatch S3**（定位型 + 通用 tile-resolver + `team_tile_known` belief store，解 material 核心缺口）。有洞 → 回 `to:systems`。
