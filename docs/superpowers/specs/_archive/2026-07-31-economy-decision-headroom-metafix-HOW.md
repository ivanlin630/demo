---
type: spec
owner: systems
topic: economy-decision headroom meta-fix（survival dominance 條件化於真實威脅）HOW
status: ready-for-R2
---

# HOW spec：economy-decision headroom meta-fix（一根解全家）

> **blueprint 裁 (b) 系統性 de-patch（2026-07-31）**：economy/logistics 決策該能在「survival 沒真受威脅」時贏——survival dominance 條件化於真實威脅（食物 scaled、runway sense modulate）；fed 隊 economy 贏、starving 隊 survival 贏；保 must-fix① 本意（威脅時仍贏、不再無條件）。**一根解 trade-trip + founding + convoy + construction 全家**。序：①meta-fix 先（prerequisite），②③④ convoy plumbing 建其上。

## 0. ★親驗 refined 機制（別在錯前提設計）
- **survival boost 已 food-scaled**（`decision_engine:75-76`）：`if food_days < SURVIVAL_BOOST_FLOOR(2.0) and opt∈SURVIVAL_OPTION_SET: u += SURVIVAL_BOOST_MAX(2.5)×(2.0−food_days)/2.0`。**fed 隊(food_days>2.0)無 boost**、絕境(food_days=0)才滿 2.5。∴ **survival-conditional 大體已做**、非無條件常數（blueprint「無條件壓死」前提已 partly 由此路條件化，refine）。
- **★真 binding = `GOAL_UTIL_CAP=1.5`（goal_resolver:16）無條件封頂 economy goals**：static option（覓食/govern/外交，`decision_engine:64-66` terms×coeff）**不受 1.5 cap**→可 >1.5→**即使 fed 隊，economy goal(≤1.5)也贏不過強 static option**。+ distance discount 倒扣（goal_resolver:333-337，遠 candidate util 越低）+ 無可靠性項。
- ∴ **meta-fix 真 lever（grounded、非再 scale survival）＝食物 scaled goal-cap headroom + distance-fix + reliability**。

## 1. Fix（3 部分、系統性、全家共用）

### 1a. ★食物 scaled goal-cap headroom（核心，runway modulator）
`GOAL_UTIL_CAP` 從**無條件 1.5** 改**食物 scaled**：
- `goal_cap = GOAL_CAP_BASE + safety_factor × GOAL_CAP_HEADROOM`
  - `safety_factor = clampf(food_days / SAFE_FOOD_DAYS, 0, 1)`（或用 runway/food_flow banked sense；fed→1、starving→0）。
  - **fed（safety→1）**：`goal_cap = 1.5 + headroom`（e.g. headroom=1.5→cap=3.0）→ economy goal **能競爭甚至贏 static option**（覓食 fed 時無 survival boost）。
  - **starving（safety→0）**：`goal_cap = GOAL_CAP_BASE`（≤ survival 2.5，如 1.5）→ **保 must-fix①**（絕境 survival(2.5) 仍 > goal → 活命奪 argmax）。
- ★**must-fix① 本意保**：真威脅(low food_days)時 goal_cap 降回 <survival→survival 贏；只 fed 時 cap 升。**survival boost 也 food-scaled(:76)雙保險**——絕境 survival boost 滿 2.5 + goal_cap 降 <2.5＝雙重保絕境活命。
- ★**憲法**：非 scripted（cap 是 util 上界的 food-modulated 連續值、非硬類別閘）；人格 WEIGH 保（cap 內 payoff/discount 照人格秤）。runway sense(banked)=modulator。

### 1b. distance discount 不對 own-supply logistics 倒扣
`_estimate_delay_days`/`_discount_rate`（goal_resolver:333-360）對 own-supply-fetch（pull-convoy：拿自家 remote surplus）**距離是價值本身非純成本**：
- own-supply candidate 的 discount rate **降**（`_discount_rate` 對 own-supply 類乘一 <1 因子，或 delay 對 own-supply 折半）——「肯為 guaranteed 自家供給走遠路」。
- ★仍有界遞減（非取消 discount，遠仍略折、只不倒扣殺死）；純算術。

### 1c. guaranteed-own-supply 可靠性通用維度
candidate util 加**可靠性因子**（通用、非 convoy-only）：
- `reliability = f(取得確定性)`：own-supply（自家 surplus 已存在、known qty）=高；市場買（GATE-B 不確定成交）=中；覓食（yield 隨機）=低。
- 乘進 payoff 或當獨立乘數（`util = payoff × dev_coeff × discount × reliability`，reliability∈(0,1]、own-supply≈1、uncertain<1）。
- ★這是 economy 決策**該有的真維度**（guaranteed vs uncertain 取得），三案共用差異化——non-scripted util-weigh。

## 2. ★★heavy 驗（make-or-break，blueprint 命）
- **★隊仍 survive、不因 economy 餓死**：seed1337 6mo，starving 隊（low food_days）goal_cap 降→survival 仍奪 argmax→**economy-caused starvation 不增**（fix 前後餓死案例對比，同 founding floor team14 timing）。
- **★世界不 destabilize/不凍**：seed1337 attrition 非→0、非暴增、churn 正常、三跑 determinism byte-identical。
- **★全家真 fire（execution-verified）**：fed 隊 economy goal（trade-trip/founding/convoy/construction）**真贏 argmax 真執行**——measure decision fire count（`construct.start`/`complete_build`/trade-trip/convoy dispatch）fed 隊上升 vs baseline。**非只 candidate 生成**（本 session 的鬼）。
- must-fix① 回歸：絕境 survival 仍 100% 奪 argmax（單測：food_days=0 隊 → survival option 贏所有 goal）。
- 純算術零 RNG（cap/reliability/discount 零 randf）；constitution 74 + observability PASS + headless 0-new + determinism 三跑。

## 3. 交付
→ R²（★★make-or-break 從嚴：食物 scaled cap 真讓 fed economy 贏 + 絕境 survival 仍贏（must-fix① 不破）+ distance-fix 邊界 + reliability 維度非 scripted + heavy 驗 survive/不凍/全家真 fire）→ implementer（goal-cap food-scale + distance-fix + reliability + heavy TDD）→ measurer（★全家 fed 隊真 fire + starving 不餓死 + 不凍）→ QA。**★這是 session 最高槓桿 fix、觸核心決策公式、R² 最嚴。** meta-fix merge 後 → convoy ②③④ plumbing 建其上。
