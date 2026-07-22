---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·tools-demand·CLEAN(當前圖)+2 建議] ★①遞迴守衛=當前圖終止 CLEAN(output-guard+白名單;material 0-producer/tools 唯一 workshop 被切/非白名單→0,鏈~depth3 有界)——但 output-guard 足夠性 graph-依賴(未來 material-producer facility+costs tools→M↔workshop 環切不斷)→建議加 depth-cap/visited-set 結構保險(第2次此 hazard)。②byte-identical 非結構保證(workshop 在 material-need 迴圈,deficit 用 need_keep(tools)→耦合;通常 goods 主導 invisible,goods 滿足時變)→qualify。③cap 交互 agree④無 RNG⑤demand belief-gate 驗。"
---

# R² verdict：tools-demand 註冊（means-end 深一層）

**VERDICT: CLEAN（當前 facility 圖遞迴終止，核審點過）+ 2 建議（depth-cap 保險 / byte-identical qualify）**。`premise_contradiction: false`。factcheck 對 HEAD `a22fee96`。

> 這正是我前 verdict flag 的擴展 hazard（tools=build-cost ∩ facility-output）。systems 採 flag + 加 output-guard——good，我複驗其足夠性。

## ★★① 遞迴守衛（核審點）→ 當前圖 CLEAN，但 graph-依賴
**guard**：output-guard（`_construction_facility_need(res)` 迴圈內 `if res in facility.outputs: continue` 切自指邊）+ 白名單 `CONSTRUCTION_COST_RES{material, tools}`（非白名單 res → 0）。

**當前 facility 圖親驗（producer graph）**：
- **material producers = 0**（無 facility 輸出 material；`FACILITY_DEFICIT_DEF` outputs=goods/tools/arrows/medicine/armor/ore_steel/mounts）。
- **tools producers = workshop only**（`:3184`）。
- **workshop cost=`{material:60,tools:0}`**（`outpost:56`）→ material-need 迴圈含 workshop。

**終止論證（有界，親驗對）**：
- `need_keep(material)`→`_construction_facility_need(material)`→迴圈（含 workshop，material∉workshop.outputs 不切）→`_facility_deficit(workshop)`→`need_keep(tools)`→`_construction_facility_need(tools)`→迴圈**切 workshop**（tools∈workshop.outputs）→其他 tools-costing facility G(≠workshop)→`_facility_deficit(G)`→`need_keep(G.output)`→`_construction_facility_need(G.output∉{material,tools})`→**0**。**鏈 material→tools→非白名單→0，~depth3 有界終止**。material 本身無 producer→material 從不當 output 再入。**當前圖無環，CLEAN**。

**★但 output-guard 足夠性 = graph-依賴（非結構 cycle-breaker）**：
- 安全**因**（a）material 無 producer（b）tools 唯一 producer=workshop 被 output-guard 切。
- **未來若加 facility M 輸出 material（material-producer）且 costs tools** → **M↔workshop 成環**：tools-need 迴圈含 M（tools∉M.outputs 不切）→`_facility_deficit(M)`→`need_keep(material)`→material-need 含 workshop→`need_keep(tools)`→tools-need 含 M→…**無限環，output-guard 切不斷**（M 出 material 非 tools、workshop 出 tools 非 material，互不被對方 res 的 output-guard 切）。
- ∴ **systems「output-guard 足夠、非需 visited-set」= 當前圖真、一般假**。
- **★建議（結構保險，非 blocker）**：加 **depth-cap（如 ≤2）或 visited-res set**——**這是第 2 次此遞迴 hazard**（我前 verdict flag→tools→spec 還計畫 ore_iron/ore_steel）；每擴展需 per-graph 環分析=脆。depth-cap ~2 行**終結此 class**。至少：assert/comment 圖不變量「CONSTRUCTION_COST_RES 成員的 producer-facility 全被 output-guard 覆蓋 + 無 material↔tools 型跨環」，供未來擴展複核。

## ② material 路徑 byte-identical → 非結構保證（qualify）
- **workshop 在 material-need 迴圈**（costs material 60），其 desire=`_facility_deficit(workshop)`（min_per_res over goods/tools/arrows）用 `need_keep(tools)`。
- **擴展後 `need_keep(tools)` 含 construction-need（非 0）** → workshop 的 tools-target 升 → workshop deficit **可能**變 → material-need（gate workshop desire + 疊 workshop 60）**可能**變。
- **通常 invisible**：goods demand 3573 巨 → workshop min_per_res 由 goods 主導（deficit≈1）→ tools-target 變不移 min → material-need 不變。**但 goods 滿足時 tools 成 bottleneck → 耦合顯現**。
- ∴ **「material 路徑 byte-identical」非結構保證**（workshop 經 need_keep(tools) 耦合）→ **qualify**：期望通常同（goods 主導），但 measure material-need 分布 before/after 確認；差異=語意正確耦合（tools-need 升→workshop 想建→合理）非 bug。determinism（2 跑同 seed）不受影響（無 RNG）。

## ③④⑤
3. **tools cap 交互 → agree**。cap 100、tools cost 3-10、material（50-500）主導不撞 cap。tools 小額不爆。
4. **無 RNG → CLEAN**。純 utility。
5. **感知鐵律：tools 買單走訊息傳播才算 demand → 驗（likely CLEAN）**。tools demand 應讀**relayed order 訊息**（civ 親聞買單，同 material-buy 的 belief-gate 範式）非全域 order book god-view。**impl 確認 `NeedOracle.demand(tools)` 讀 team_known/belief-gated orders 非 global**（同 has_material_market 範式）→ 守感知鐵律。

## 回覆
CLEAN（核審點：當前圖遞迴終止，親驗）→ dispatch。2 建議：
1. **depth-cap/visited-set 結構保險**（第2次 hazard；擴展計畫 ore_iron/ore_steel→終結 class；或至少 assert 圖不變量）。
2. **② byte-identical qualify**（workshop 經 need_keep(tools) 耦合；measure material-need before/after，通常同）。
+ ⑤ 確認 demand belief-gated（relayed order 非 global）。afford② WHAT tension 呈 blueprint=對（不在本刀）。
改好回 R² → dispatch。

——① 圖-依賴 vs 結構 guard 的分野=本 slice R²-核心。output-guard **當前圖真終止**（我驗了），但 material↔tools 型跨環在 material-producer 出現時破功。這族 hazard 已 2 次——depth-cap 一勞永逸勝過每次 per-graph 論證（今日多次翻案警惕：別讓「當前安全」的圖-依賴前提被當結構保證）。[[feedback_fileline_vs_interpretation]]（「output-guard 足夠」=詮釋，需驗到「當前圖 material 0-producer」原始事實才坐實、且標明條件）。
