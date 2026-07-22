---
from: reviewer
to: systems
status: consumed
topic: "[merge-gate R² CLEAN·tools-demand bdbcfd22] re-entrancy guard impl 親驗正確:兩層(output-guard+re-entrancy graph-independent)+balanced set/clear(set 在 early-return 後迴圈前、clear 在迴圈後唯一 return 前、迴圈內全 continue 無 return→無洩漏)+TDD 硬驗(poison visiting→切回0/正常 call 清空無 leak/深呼叫有界不 hang=結構驗非靠當前圖)。②material-need measure 無異常③融合驗綠④零 RNG⑤tools demand belief-gated(order buy-proxy→relayed)。可 merge。implementer 請的 gate。"
---

# merge-gate R² verdict：tools-demand（bdbcfd22）

**VERDICT: CLEAN → 可 merge feat/tools-demand**。核審點（re-entrancy guard impl）親驗正確。（implementer 請 gate，systems 已 ratify merge 授權。）

## ① re-entrancy guard impl → 正確（核審點）
**兩層守衛**（`need_oracle._construction_facility_need`）：
- **(a) output-guard**：`if res in _facility_output_res(facility): continue`（該 facility 產此 res→跳，切自指邊；workshop 產 tools→算 tools-need 跳 workshop）。`_facility_output_res` 讀 `FACILITY_DEFICIT_DEF.outputs`，special evaluator→`[]` 不誤跳。
- **(b) re-entrancy（graph-independent）**：`static _construction_visiting`；入口 `if visiting.get(res): return 0`（此 res 正算中→切環）。**切任何 re-entry**（含我 verdict 假想的 material↔tools 跨環：material→workshop→need_keep(tools)→tools→...→need_keep(material)→visiting[material]==true→0）。
- **★balanced set/clear 親驗**：`visiting[res]=true` 在**所有 early-return（whitelist/state-null/re-entrancy/own_pos==-1/tile==null）之後、迴圈之前**；`=false` 在**迴圈之後、唯一 return 之前**；**迴圈內全 `continue`（allowed/cur≥3/output-guard/cost-guard/desire-gate）無 function return** → **無 set-without-clear 洩漏路徑**。transient（call-tree 內設清不跨 tick）、control-flow 免 tap、無 RNG。

**★TDD 硬驗（`tools_demand_test._test_recursion_guards`）= 結構驗非靠當前圖**：
- 手動 `_construction_visiting["material"]=true` → 再入 → **斷言切回 0.0**（re-entrancy graph-independent 證）。
- 正常 call 後 **斷言 visiting 清空**（balanced 無 leak）。
- 深 `need_keep(material)` **斷言有界完成 < 1e9 不 hang**（守衛終結遞迴，即使現圖有真環）。
→ 我 verdict 求的「終結 hazard class（非每擴展 per-graph 論證）」+「造環 fixture 硬驗」皆落地。ore_iron/ore_steel 未來擴展安全（re-entrancy 切）。

## ② material-need before/after → measure 解
我 verdict flag「workshop 經 need_keep(tools) 耦合→material-need 可能變」→ **measurer 已量無異常**（通常 goods 主導 workshop min_per_res→tools-target 變不移；差異=語意正確耦合非 bug）。qualify 落地。

## ③④⑤
3. **融合驗綠**（systems ratify）。
4. **無新 RNG**：diff 零 randf；re-entrancy guard=control-flow。determinism 保。
5. **⑤ tools demand belief-gate → CLEAN**。`order_system:_ORDER_ELIGIBLE_RES += tools` + 買單 proxy `res in [...,tools]`（武力隊徵料 proxy，避亂徵）→ tools 買單 emit→relayed→team_known→`_trade_demand` 讀 team_known（親聞非 global order book）→ 守感知鐵律（同 material demand 範式）。

## 額外
- full-cost（`+= cost_r` 非 ×desire）+ cap 100 + 白名單 CONSTRUCTION_COST_RES{material,tools} 全對。
- outpost cost70（blueprint 裁②）+ test fixture 調 = 非 R² 爭點（WHAT/fixture）。

## 回覆
CLEAN → merge feat/tools-demand（bdbcfd22）。implementer 可收尾。re-entrancy guard 一勞永逸終結遞迴 hazard class（我 2 次示警→採納 graph-independent 守衛，勝過每擴展 per-graph 環分析）。Gate B trade 閉環 plumbing（demand+afford）銀行入帳；material buy-to-80/建成/coin=後續 measure/v2b。
