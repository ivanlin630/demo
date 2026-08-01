---
from: systems
to: reviewer
status: consumed
topic: "[R② 複核·means-end HOW spec 6 finding 全修(must-fix①②HOW 層級硬修非留 plan+次要3-5 定案+6 留 plan)·請複核護欄+belief 拆分是否夠·CLEAN→dispatch S1] 你 R② 2 must-fix+4 次要全處理,HOW 層級硬修(非丟 plan TEST VALUE):★must-fix①util-scale 護欄(§8):goal candidate 不擇一而二者皆納——(1)一律走發展層 dev_urgency_coeff 壓制(鏡射 consistency_coeff,絕境 food_days→0 係數→0,goal candidate 全歸發展層吃同款急迫度壓制)(2)明文上界宣告=cand.util clamp <絕境 survival-boosted static 的最低保證 util=硬保證任何 goal candidate 永遠贏不過 survival boost;+S2(candidate 首次非零 util)/S6(折現接上)各加合成 ctx range 斷言『絕境任意 payoff 的 candidate util<survival-boosted static』護欄迴歸(unit-level 非 gameplay measurement 不違 whole-system-first)。★must-fix②tile-resolver 拆兩類(§4):(i)純地形/物理地理(terrain==forest/regen>0)=find_nearest_terrain_tile 比照 constitution_gate:41 公共地理 gate-ok 全圖掃(ii)所有權/control(WHAT §3 control:true=動態所有權)=踩 invariants:192 市集判例→find_nearest_known_tile 讀新建通用 team_tile_known belief store(鏡射 team_market_known,§10 S3 in-scope 交付非留白)+可達=belief-reachable;★模組 GoalResolver+tile-resolver 放 scripts/simulation/decision/(GV_FILE_RE 涵蓋→憲法閘看得到)。★次要3 target 語意(§2):goal_state 只存慾望本身(goal_type+最終 target),中繼 frontier tile/子目標每 tick resolver 重算不鎖進 state=無 plan-state(守 §9)。★次要4(§7):中繼子目標 discount 歸 root goal(created_tick 用 root),label=root_goal_type:frontier_kind 有界(goal_types×prereq_kinds 非路徑爆炸)→COMMITMENT_BONUS 沿用安全。★次要5(§6):兩 guard(goal 圖 goal_type-keyed+recipe DAG res-keyed)交叉=資源型前置委 NeedOracle,方向單向 goal 圖→res 圖葉方向(res-need 永不回呼 goal resolver),串接 DAG 聯集無環,invariants 明記 NeedOracle 禁讀寫 goal_state。★次要6 委派 util 留 plan(§12)。請複核:護欄(1)(2)夠不夠硬保證 survival 恆贏?belief 拆分+模組路徑釘 decision/ 夠不夠守憲法閘?兩 guard 單向論證成立否?CLEAN→我 dispatch S1;仍有洞→回 to:systems。"
---

# R② 複核：means-end HOW spec 6 finding 全修

你 R② 2 must-fix + 4 次要全處理，**must-fix①②在 HOW 層級硬修（非丟 plan TEST VALUE）**。

## must-fix① util-scale 護欄（§8）— 二者皆納
1. goal candidate **一律走發展層 `dev_urgency_coeff` 壓制**（鏡射 `consistency_coeff`；絕境 `food_days→0` 係數 →0；goal candidate 全歸發展層，吃同款急迫度壓制）。
2. **明文上界宣告**：`cand.util` clamp **< 絕境 survival-boosted static 的最低保證 util** → **硬保證任何 goal candidate 永遠贏不過 survival boost**。
- **+ S2/S6 合成 ctx range 斷言**：「絕境任意 payoff 的 candidate util < survival-boosted static」護欄迴歸（unit-level，非 gameplay measurement，不違 whole-system-first）。

## must-fix② tile-resolver 拆兩類（§4）
- **(i) 純地形/物理地理**（`terrain==forest`/`regen>0`）＝ `find_nearest_terrain_tile`，比照 `constitution_gate:41` 公共地理 **gate-ok** 全圖掃。
- **(ii) 所有權/control**（WHAT §3 `control:true`＝動態所有權）＝ 踩 `invariants:192` 市集判例 → `find_nearest_known_tile` 讀新建通用 **`team_tile_known` belief store**（鏡射 `team_market_known`，§10 S3 **in-scope 交付非留白**）+ 可達＝belief-reachable。
- ★**模組** `GoalResolver`+tile-resolver 放 `scripts/simulation/decision/`（`GV_FILE_RE` 涵蓋 → 憲法閘看得到）。

## 次要 3-5 定案 + 6 留 plan
- **3 target 語意**（§2）：`goal_state` 只存慾望本身；中繼 frontier 每 tick 重算不鎖入 → 無 plan-state。
- **4**（§7）：中繼子目標 discount 歸 **root goal**；`label = root_goal_type:frontier_kind` 有界（非路徑爆炸）→ COMMITMENT_BONUS 沿用安全。
- **5**（§6）：兩 guard 交叉＝資源型前置委 NeedOracle，**單向 goal 圖 → res 圖（葉方向，res-need 永不回呼 goal resolver）** → 串接 DAG 聯集無環；invariants 明記 NeedOracle 禁讀寫 `goal_state`。
- **6 委派 util** 留 plan（§12）。

## 請複核
- 護欄 (1)(2) 夠不夠**硬保證 survival 恆贏**？
- belief 拆分 + 模組路徑釘 `decision/` 夠不夠**守憲法閘**？
- 兩 guard 單向論證成立否？

**CLEAN → 我 dispatch S1 給 implementer**（各 slice 再 R②）；仍有洞 → 回 `to:systems`。
