---
from: implementer
to: measurer
status: consumed
topic: tools-demand 註冊 + weaponsmith cost70 — measure（兩 build 閘一起解，終驗 weaponsmith 真建成）
branch: feat/tools-demand
commit: bdbcfd22
spec: docs/superpowers/specs/2026-07-23-tools-demand-registration.md
---

# tools-demand + weaponsmith cost70 — 做完，量測請收

## 改動（3 修，兩 build 閘一起解）
weaponsmith 0 建 = 兩硬 build 閘皆非 material-trade（血證 T26 material80+coin70 仍不建）。
tools=0 全域 = **生產端 demand-routing 缺口**（order_system 無 tools 買單→demand(tools)=0→
workshop tools-recipe 恆輸 goods）。

- **① need_oracle._construction_facility_need**：material-only → build-cost {material,tools}
  （`CONSTRUCTION_COST_RES` 白名單、`cost_r=upgrade_cost().get(res,0)` 泛化）。
  ★★**兩層遞迴守衛**（tools = build-cost ∩ facility-output=workshop 產 tools → hazard）：
  (a) **output-guard** `if res in _facility_output_res(facility): continue`（自指邊 skip；
      `_facility_output_res` 讀 `FACILITY_DEFICIT_DEF` outputs，special[weaponsmith/mint/farming]無 outputs→[]）
  (b) **re-entrancy guard** `static _construction_visiting`，入口 res 正算中→回 0
      （graph-independent 切任何 material↔tools 環；A-class evaluator 讀 need_keep(outputs)=真回呼
       路徑 need_keep(material)→_facility_deficit(workshop)→need_keep(tools)→…）。
- **② order_system**：`_ORDER_ELIGIBLE_RES`(:6) + proxy list(:121) 加 `tools`（mil reserve(tools)>holding 發買單）。
- **③ outpost_system:87**：weaponsmith material cost **80→70**（blueprint 裁②；70×1.5=105<天花板 117
  穩達；僅 weaponsmith，armorsmith 不動）。

## 自驗（皆綠）
- TDD `tools_demand_test` **11/11**。RED 確認：①tools scope 3→0 / ③b re-entrancy 手動置 visiting→再入 0→100(guard 失效) / ⑤ proxy 移 tools→單消失 / ⑥ cost 70→80。
- `material_buy_test` ① 斷言 80→**70**（cost 改，測試維護）+ 全綠。
- headless 0-new（3 baseline：p2a join weight / combat_target 197 / rung intent）。
- gate PASS sites=75（無新閘）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `a2835d99`（純 utility 無 RNG，diff 無 randf）。

## 量測請抓（spec §驗收，餵 QA 判故事）
1. **tools 全域產量 > 0**（§④b：哪些 workshop/team 產、tool 數 3-10 樣本）。
2. **mil tools 買單發出數** / demand(tools) at workshop > 0。
3. tools 賣盤 / 進市場 / 成交。
4. build-tick workshop 選 **tools-recipe 次數**（vs goods 競爭勝率）。
5. **★weaponsmith 建成數 > 0**（兩閘皆開的**終驗**；§④b：哪些 mil 隊建成、build tick、耗 material/tools 樣本）。
6. **afford 通過率**（cost70 後 mil 隊 avail≥105 達成率）。
7. **material-need before/after**（reviewer② workshop 耦合：tools-need 升→workshop tools-target 升→
   material-need 可能變；通常 goods demand 巨主導 min→invisible。差異=語意正確耦合非 bug）。
8. 回歸：goods 產量 / doom-delta / **無餓死**。
9. **★感知鐵律驗**：`demand(tools)` 走既有 `_trade_demand`（need_oracle:142 讀 `state.team_known`=
   **親聞買單** belief-gated，非 global order book）→ 確認 tools 未繞道全域 order book（civ workshop
   只對**聽過**的 tools 買單生產）。

床：`godot --path .worktrees/tools-demand` 對 branch bdbcfd22 跑（★禁原地 checkout）。

## 完成判定 = systems + reviewer（★merge-gate R² 複 confirm 遞迴守衛 impl）
做完 → to:QA 判故事：**mil 想建 weaponsmith → 發 tools 需求 → workshop 產 tools → tools 進經濟 →
mil 買齊 material(≥105)+tools → weaponsmith 真建成 coherent**。若 weaponsmith 仍 0 = 診斷未盡（QA 判剩餘閘）。
