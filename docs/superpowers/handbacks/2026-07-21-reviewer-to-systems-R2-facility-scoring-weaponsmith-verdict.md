---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·facility-scoring weaponsmith·issues(2 設計要求)] ①max 兩路徑語意 CLEAN(自衛 OR 市場,無 double-count)。★③DRY 要求:_weapon_market_deficit=A 類 generic min_per_res+demand 的重寫=冗餘求解器,須抽 helper 複用非平行實作(收斂為一)。④建議拆 ②(workshop cliff→連續=獨立 goods 行為改,綁一起 conflate measure;①單獨解核心)。②人格穿秤 CLEAN-HOW(讀真貪婪/商業,權重=blueprint)。⑤無 RNG⑥measure sound。"
---

# R² verdict：facility-scoring weaponsmith 納武器 demand

**VERDICT: issues（2 設計要求，非重設計）** — ① 兩路徑 max 方向對（blueprint 選①授權），但 ③ DRY（冗餘求解器）須收斂 + ④ 建議拆 ②。`premise_contradiction: false`。factcheck 對 HEAD `301c1d84`。

## Root 坐實
`_facility_deficit`（`:3195-3230`）：`if entry.has("special"): call special` 否則 **A 類 generic**（min_per_res/pooled_sum + `if use_demand: tgt += NeedOracle.demand`，:3208-3218）。
- **workshop**（`:3184` A 類 `use_demand:true`）→ generic demand-responsive。
- **weaponsmith**（C 類 special `_deficit_weaponsmith`）→ `clampf(0.6-armed_anon_ratio,0,1)×militancy` = armed-ratio-only，**無 demand**。
- ∴ asymmetry 坐實：workshop demand 驅、weaponsmith 不驅 → 武器 demand 再高不建 weaponsmith → 60 樣本僅中 1。

## 審點逐一

1. **max 兩路徑語意 → CLEAN**。`max(self_defense=armed_ratio×militancy, market=demand×commercial)`：自衛急（armed 低）**OR** 軍火商（demand 高×商業人格）任一驅建，兩動機皆合理。**max 非 sum → 無 double-count**（取較強動機）。militaristic 隊走自衛路、commercial 隊走市場路，湧現自然。合綜合發展模型。

2. **商業人格穿秤 → CLEAN-HOW**。`_commercial_inclination = clampf(貪婪×W1 + 商業技能×W2)` 讀**真人格值**（非 flat 硬寫繞過）→ 守「穿人格秤」。權重 W1/W2 = **blueprint/measure-tune 域**（TEST VALUE，非我裁）。
   - **DRY note（非 blocker）**：從既有 `lv = TradeValuation.leader_vals`（`:3195` 已算並傳入 deficit evaluators）讀人格，別 re-query。既有 `economic_opp`（`terms.gd:97`）是 role/opportunity-based（商隊 role 因子）非純人格 scalar → 未必直接複用；ad-hoc composite 可接受，但**優先複用既有 commercial scalar 若有**。

3. **★★③ DRY → REUSE A 類 generic（firm 要求，非選項）**。spec 的 `_weapon_market_deficit`（weaponsmith outputs min_per_res，`tgt=need_keep+demand`）= **A 類 generic（:3208-3218）逐字重寫** = **冗餘求解器**（refute-checklist #2：新 solver 跟既有做重疊的事，血證 join vs 整併）。
   - **要求收斂為一**：**抽出 A 類 generic demand-deficit block 成 reusable helper**（`_generic_demand_deficit(state, team, outputs, use_demand, agg_mode, lv)`），weaponsmith 市場路**呼叫此 helper**（`outputs=[weapon_melee_low, weapon_ranged_low], use_demand=true, agg_mode=min_per_res`）；special `_deficit_weaponsmith` = **thin wrapper** `max(self_defense, helper_market × commercial)`。
   - **禁平行實作 `_weapon_market_deficit`**（重寫 = 兩份 demand 邏輯 drift 風險，血證同型）。generic 已有 min_per_res+demand，複用即可。
   - （替代：weaponsmith 給 hybrid entry——A 類 def{outputs:weapon_*, use_demand:true} 供 market + special-fusion max self_defense——亦收斂。impl 選乾淨點，重點=**別重寫 demand 邏輯**。）

4. **④ 拆 ② → 建議（measure 隔離）**。② workshop demand cliff(中度→1.0)→連續 = **獨立 goods facility 行為改**，與 ①（weaponsmith）**不同 subsystem**。綁同 slice → doom-delta **分不出**「weaponsmith 修效果 vs workshop goods 改效果」（承 Slice E coherent-vs-broken 隔離教訓）。**① 單獨已解核心**（兩者都 demand-responsive 後，weaponsmith 憑 terrain_fit near ore_iron 競爭贏）→ **拆 ② 獨立 follow-up + 獨立 measure**（②是公式品質 polish 非急）。①先行。

5. **無新 RNG → CLEAN**。純算術（demand/holding 比 + 人格權重 via lv）。零 randf。

6. **measure-sensitive 非盲改 → CLEAN**。spec 含 facility-build-by-type + weapon 產出 + score 分布 + doom-delta + 8 config + §④b 樣本（Probe.bump_sample 剛過的工具）。sound。不需 QA（formula 事實，同意）。

## 回覆
issues（2 設計要求）→ ① max 兩路徑方向認可，兩要求：
1. **★③ REUSE A 類 generic**（抽 helper，weaponsmith 市場路複用；禁重寫 `_weapon_market_deficit`=冗餘求解器）。
2. **④ 拆 ②**（workshop 連續 = 獨立 follow-up + 獨立 measure；① 先行）。
+ ② 人格從 `lv` 讀、複用既有 commercial scalar 若有。
改好回 R² → dispatch。

——③ 是本 slice 的 R²-核心：spec 自己 flag「別重寫 A 類」——**對，這正是冗餘求解器**。facility-deficit 架構已有 special/generic 乾淨 dispatch，weaponsmith 市場路 = 純 A 類，該複用；self_defense = 真 special（armed_ratio 非 demand-gap）。混合 = wrapper max(special, generic)，不是兩份 demand 邏輯。[[feedback_no_patch_on_settled_architecture]]（延伸統一非平行加）。
