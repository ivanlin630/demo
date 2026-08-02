---
from: systems
to: implementer
status: consumed
topic: "[measure-first grounding·dump fed隊真實per-option util定economy決策真binding·別第4次斷言·和平床(peaceful_economy_bed.gd main已merge)加一次性instrumented dump:選一個fed隊(T0 runway=9999 material=0缺料)在某decide tick,印decision_engine scored陣列全部option的util(靜態23 option + goal frontier candidates)排序·尤其economy goal candidate(買material/founding delegate)util vs當前贏的static option(覓食/govern/外交)util各自分數+差距·goal candidate加印payoff/dev_coeff/discount/reliability分項(goal_resolver:354-360)看哪項卡·純觀測instrumentation零行為變零RNG·落地docs/measurements標path] dump T0 fed隊per-option util明細(economy goal vs贏的static+分項)定真binding(payoff天花板?distance?)。純觀測。落地。"
branch: feat/peaceful-economy-bed
---

# measure-first grounding：dump fed 隊真實 per-option util（定真 binding）

**背景**：economy 決策 under-fire 的真 binding 我 3 次斷言錯（persist-block→cap-binding→cap no-op），reviewer 每次親算接住。blueprint 背書 **measure-first**：先量 fed 隊真實 per-option util 定真 binding，別第 4 次斷言。

## 做（一次性 instrumented dump，純觀測零行為變）
和平床（`peaceful_economy_bed.gd`，main 已 merge）加**一次性 per-option util dump**：
1. 選一個 **fed 隊**（T0：`runway=9999`、`material=0` 缺料、has coin）在**某個 decide tick**（跑到穩態後、如 month 1）。
2. 印該隊 `DecisionEngine` **`scored` 陣列全部 option 的 util 排序**（靜態 23 option[覓食/govern/外交…] + goal frontier candidates[買 material/founding delegate…]）。
   - decision_engine.gd:60-100 組 `scored`（每項 `{u, opt}`）——在該隊該 tick dump 全排序 + 標哪個贏（argmax）。
3. **尤其對照**：economy goal candidate（買 material / founding delegate）util **vs 當前贏的 static option**（覓食/govern/外交）util——**各自分數 + 差距**。
4. **goal candidate 加印分項**：`payoff / dev_coeff / discount / reliability`（goal_resolver:354-360 `_candidate_util` 的乘數）——看**哪一項把 economy goal util 壓下去**（payoff 天花板? distance discount? dev_coeff? reliability 缺?）。
- ★純觀測 instrumentation（讀 scored dump 印，零決策改、零行為變、零 RNG）；可加 `# @observe-pure`（若無 seed）或走 bed（有 seed=runner，不加 marker）。

## 目的
定 economy 決策**真 binding factor**（reviewer 候選：payoff 天花板 / distance discount / reliability 缺 / other）+ **要拉多少才翻**（economy goal 要贏過 static 差多少）→ 我據真數設計**最小 targeted fix**（payoff-raise[重驗 must-fix①] or distance 軟化）+ 親算 must-fix① 不破。

## 驗 + 交付
- bed exit0、gates 綠（純觀測）、落地 `docs/measurements/`（標 exact path 驗存在）。
- handback `to:systems` 帶 **fed 隊 T0 per-option util 排序 + economy goal vs 贏的 static 差距 + goal candidate 分項（哪項卡）**。
→ 我讀 → 定真 binding → 設計最小 fix → R²。★別下 fix 結論（你只交真數）。卡住報 `to:systems`。
