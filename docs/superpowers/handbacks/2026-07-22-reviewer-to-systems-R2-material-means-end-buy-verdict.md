---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·material means-end + 買料·issues(2 要求,核心 sound)] chicken-egg means-end 破+blueprint 合憲+買料閉環 direction CLEAN。①遞迴:material-scope 有界 CLEAN(material 非 facility output,親驗),但★『depth-1 不遞迴』是 scope-依賴非結構——ore_steel 是 smeltery output→擴展 ore_steel=無限遞迴(need_keep(ore_steel)→facility_deficit(smeltery)→need_keep(ore_steel));須明標守則/擴展 guard。②cap 要求(多 facility 疊爆 over-buy)。③憲法 utility×utility CLEAN④人格穿秤 CLEAN-HOW⑤無 overlap(買料 demand vs 囤貨 supply)⑥⑦ agree。"
---

# R² verdict：material means-end need + 買料 action（Gate B 核心）

**VERDICT: issues（2 要求，核心 direction sound）** — chicken-egg 破法（means-end facility 慾望→material need）+ blueprint 合憲 + 買料閉環方向對；2 要求（cap + 遞迴守則明標）。`premise_contradiction: false`。factcheck 對 HEAD。

## Root 坐實
`need_keep(material)=_self_use(PURE_INTERMEDIATE→0)+_supply_chain(gated on _team_has_facility)` → builder 無 facility → material need=0 → want<0 → DEAL=0（供給 OK）。QA：候選集無「買 material」action。chicken-egg 坐實。

## 審點逐一（file:line 親驗）

1. **★①遞迴守衛 → material-scope 有界 CLEAN，但推理 scope-依賴（flag 擴展）**。
   - **遞迴鏈**：`need_keep(material)`→`_construction_facility_need(material)`→`_facility_deficit(facility)`→[A 類]`need_keep(output_res)`→`_construction_facility_need(output_res)`→**line 18 `if res!="material": return 0`**→終止。
   - **material 非任何 facility output**（親驗 `FACILITY_DEFICIT_DEF:3184-3188`：goods/tools/arrows/medicine/armor/**ore_steel**/mounts，無 material）→ `_facility_deficit` 從不呼 `need_keep(material)` → 不遞迴回。**material-scope 有界、fan-out 終止**（perf OK：facility×output 有界）。**CLEAN（本 slice）**。
   - **★但「depth-1 不遞迴」是 scope-依賴、非結構 guard**：有界只因 **material 恰非 facility output**。**spec flag「可擴 ore_iron/ore_steel」= 陷阱**——**`ore_steel` 是 smeltery output**（`:3187`）→ 擴展後 `need_keep(ore_steel)→_construction_facility_need(ore_steel)→_facility_deficit(smeltery)→[A 類]need_keep(ore_steel)→_construction_facility_need(ore_steel)→...` **無限遞迴 hang**。
   - **要求**：`_construction_facility_need` **明標守則**「scope 限**非-facility-output** 資源；擴展到 facility-output 資源（ore_steel 等）**必加真遞迴 guard**（排除 self-output facility：`if def.outputs.has(res): continue`，或 visited-set/depth 上限）」。本 slice material 安全，但別讓未來 dev 擴 ore_steel 就 hang。

2. **★②cap → 要求**。`total += cost_mat × desire` 逐 buildable facility 加總 → **多 facility 疊爆**（一格能建多 facility 各想建→material need = Σ 全部 → over-buy 囤料扭曲市場）。**要求 clamp**（≤ 單一最貴 facility material，或 pop-relative cap；TEST VALUE）。spec 已建議、我判**必加**（robustness）。

3. **③憲法 utility×utility → CLEAN**。`material need = Σ(facility_material_cost × _facility_deficit 慾望)` = **連續 utility 加權耦合**（means-end：facility 慾望驅料需），**非 scripted if-then**（無「若想 weaponsmith 則買 120」硬碼）。blueprint 判合憲（engine utility 餵 utility）成立，我複核認可。

4. **④買料 term 人格穿秤 → CLEAN-HOW**。`buymaterial_drive` = material_shortfall 標度 × 人格（商業/貪婪），非 flat。權重=blueprint/measure。

5. **⑤與既有 option 不重疊 → CLEAN**。**買料=demand-side**（缺料想建→買 input）vs **囤貨（`:270`）=supply-side**（致富+餘糧→低買高賣 wealth-driven）vs **貿易=roam economic_opp**→ **不同側，無 overlap/搶**。買料 vs **買糧（`:237`）= 同 pattern 不同 res**（buy-input-when-short）→ parallel（仿買糧，consistent 既有 pattern），可接受。
   - **DRY note（次要非 blocker）**：買糧/買料 結構同型→未來可 genericize `buy_input(res)` 參數化（如 A 類 facility-deficit 那樣收斂）；但 買糧已獨立存在，買料仿之 consistent，不強求本 slice。

6. **⑥tools/coin 分開 → agree**（material-only 本刀；tools=0 全域供給 gap、mil coin 另軌）。

7. **⑦無 RNG → CLEAN**。純 utility 算術。

## 回覆
issues（2 要求，核心認可）→ chicken-egg means-end 破法 + 買料閉環方向對，兩要求：
1. **②cap total material need**（多 facility 疊爆 over-buy；clamp 上界）。
2. **①遞迴守則明標**（scope 限非-facility-output；擴展 ore_steel 等 facility-output 必加 self-output-exclusion/visited guard——別讓「depth-1」誤導成結構安全）。
+ ⑤ DRY note（買糧/買料 未來可 genericize，非本刀）。measure 帶 §④b+specimen→QA 讀故事（想建→買料→建成→產武器 motive-chain）。
改好回 R² → dispatch。

——「值得細審」對：①的 **「depth-1 不遞迴」是最易 confirm-bias 的前提**（聽起來有界，實則靠 material 恰非 output 的巧合，非結構 guard；ore_steel 擴展即 hang）。今日多次翻案的教訓=前提要驗到原始事實（material 非 output=事實 → 有界；「depth-1」=詮釋 → 不完整）。[[feedback_fileline_vs_interpretation]]。
