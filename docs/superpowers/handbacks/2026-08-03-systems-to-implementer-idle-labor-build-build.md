---
from: systems
to: implementer
status: open
topic: "[B idle-labor→建設 genuine激勵開工(MVP建設-only,blueprint GO,領導軸size-matter治§8 ratio0.38-0.45)·spec docs/superpowers/specs/2026-08-03-idle-labor-build-incentive-HOW.md(R²CLEAN+1追蹤項)·做:①DecisionContext加idle_labor欄=maxf(pool_of(state,tile)−Σtile.labor_alloc[k].demand,0)(gather時算,只PRODUCE軍隊天然不在pool_of)②建設option util加idle_employ_value(terms.gd 建設drive或settle_fit擴)·★★追蹤項(reviewer anti-crank,乙教訓):idle_employ_value禁發明PER_HAND常數→從manufacturing真worker_rate反推:idle_employ_value=min(idle_labor/d_new,1.0)×facility_full_output×need_weight,其中d_new=候選facility新增demand(level×K_MFG),facility_full_output=該facility fill=1滿載真輸出=level×1.0×LABOR_SCALE×(0.5+avg_skill)×RATES[recipe](即manufacturing:92,150-159真公式代fill=1),need_weight=need_oracle(候選產物)·=雇用閒勞力真need-weighted期望產出,idle=0或無需求→0,self-limit·★guardrail硬約束:只加建設,禁漏combat/survival/trade/move/social(grep),憲法非硬gate(連續乘非if idle>X)·dev-verify:idle→build因果(idle>0+真需求可建→建設util升選建/idle=0不升)+genuine非crank(idle=0或無需求→term=0不亂建)+guardrail grep+determinism+headless baseline·隔離branch feat/idle-labor-build·交付後我R²融合驗→§8 re-measure領導軸ratio追平(誠實measured才宣稱)"
branch: feat/idle-labor-build
---

# B idle-labor→建設 genuine 激勵 — 開工（MVP、領導軸 size-matter）

**spec**：`docs/superpowers/specs/2026-08-03-idle-labor-build-incentive-HOW.md`（R² CLEAN + 1 追蹤項）。blueprint GO MVP 建設-only。治 §8 領導軸 ratio 0.38-0.45<1（大隊 idle 勞力浪費、建設決策太晚）。

## 做
1. **DecisionContext 加 `idle_labor` 欄**（gather 時算、team 所在 tile）：
   `idle_labor = maxf(LaborSystem.pool_of(state, tile) − Σ tile.labor_alloc[k].demand, 0.0)`（只 PRODUCE、軍隊 TAG_MILITARY 天然不在 pool_of → guardrail 自然）。lazy 直讀 labor_alloc（勞力池 cadence 已存、頻率解耦）。
2. **建設 option util 加 `idle_employ_value`**（terms.gd 建設 drive 或 settle_fit 擴）。

## ★★追蹤項（reviewer anti-crank、乙教訓）：PER_HAND 禁發明、從真公式反推
**禁**獨立發明 `PER_HAND_OUTPUT` 常數（否則縮小版乙）。**從 manufacturing 真 worker_rate 反推**：
```
d_new              = 候選 facility 新增 demand = level × K_MFG          # spec §2
facility_full_output = level × 1.0 × LABOR_SCALE × (0.5+avg_skill) × RATES[recipe]
                     # ↑ manufacturing:92,150-159 真公式代 fill=1（滿載真輸出）
idle_employ_value  = min(idle_labor / d_new, 1.0) × facility_full_output × need_weight
                     # min(...)=閒勞力能填新 facility 的 fill 比例；need_weight=need_oracle(候選產物 need_keep+demand)
```
- ＝**雇用閒勞力的真 need-weighted 期望產出**（每因子皆真 grounding、無發明常數）。
- `idle=0` 或**無需求**（need_weight=0）→ term=0（不亂建）；self-limit（idle 隨 facility 吸收遞減）。

## ★guardrail 硬約束（違＝reject、R² grep）
- idle-labor term **只加建設**、grep 無漏進 combat/survival/trade/move/social。
- 憲法決策**非硬 gate**（idle 連續乘、無 `if idle>X` 階梯）。
- 只 PRODUCE-idle（pool_of 天然排軍隊）。

## dev-verify（交付前自跑）
1. **idle→build 因果**：team idle>0 + 有真需求可建 facility → 建設 util 升 → 選建（vs idle=0 不升）。
2. **genuine 非 crank**：idle=0 → term=0；無需求產物 → need_weight=0 → term=0（不建沒用的）。
3. **guardrail**：grep idle_labor 只在建設 drive、combat/survival/trade/move 零。
4. determinism 三跑 byte-identical + gates 綠 + headless baseline + 全量 tap（idle_labor/build util 分項）。

## 交付
- code 寫 worktree `feat/idle-labor-build`（隔離）、handback `to:systems`（帶 bed 數字：idle→build 因果 + genuine 邊界 + determinism）→ 我 R² 融合驗 → **§8 re-measure 領導軸 ratio 追平（誠實 measured 才宣稱、同 SLICE A）** → §5 合量。
- 卡/PER_HAND 反推難/scope 變 → 報 `to:systems`。
