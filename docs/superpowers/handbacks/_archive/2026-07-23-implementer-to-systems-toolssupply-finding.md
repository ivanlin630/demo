---
from: implementer
to: systems
status: consumed
topic: "[finding·tools-demand 終驗真根=製造產能 bootstrap·patch-gate-first 深一層·非單 slice 呈裁範圍] weaponsmith 仍 0 單一剩閘=tools SUPPLY=0。我 scout 坐實終閘比 measurer 深一層:生產只在 current_task==TASK_MANUFACTURE 跑(manufacturing:67),而「生產」option applicable 需 has_own_outpost AND has_manufacturing_facility(options:32)→workshop 先建才可生產。兩子根:①workshop 建太少(3mo 0→1;goods=0 經濟→workshop desire 低→少建=雞生蛋)②建了的 workshop 隊沒選生產(measurer:無 manufacture.* probe=沒上 TASK_MANUFACTURE)。=製造產能/established-chain 根(非單 slice)。tools-demand 本身正確(demand+afford 都對)可增量 merge。不逕改,呈裁範圍。"
branch: feat/tools-demand
commit: bdbcfd22
---

# finding：tools-demand 終驗真根 = 製造產能 bootstrap（patch-gate-first 深一層）

measurer tools-demand 量測（cc consumed）+ 我獨立 code-scout。**兩修有效但 weaponsmith 仍 0，
單一剩閘=tools SUPPLY=0**。measurer 指向「查 manufacturing_system」，我 scout 坐實**終閘比其深一層**。
[[feedback-patch-gate-first]][[project_established_chain]] → 呈系統裁範圍，**不逕改**（非單 slice）。

## ✓ tools-demand 兩修有效（measurer verdict→blueprint，可增量 merge）
- **③cost70**：material afford 可達（seed1337 T23=113/T35=110 兩隊 ≥105，舊 120 不可達）。
- **②tools demand**：`post_buy.tools` 795（武230）/796（武115），原 0。tools 需求真接上。
- determinism a2835d99 採信、無新閘。

## ✗ weaponsmith 仍 0 — 單一剩閘=tools SUPPLY=0
- measurer 鐵證：global tools 兩 seed 全程 **0**、goods 也 0、只 1 workshop（晚建 tick18740）產 0；
  全 9 筆建成皆 tools-cost=0 設施（farming/workshop/stable），需 tools 設施全 0 建。

## ★終閘坐實（我 scout，比 measurer 深一層）
生產鏈需 workshop 先存在**且**團隊選生產：
1. **`manufacturing_system.gd:67`**：`if team.current_task != TeamData.TASK_MANUFACTURE: continue`
   → 生產只在隊 current_task==TASK_MANUFACTURE 才跑。
2. **`options.gd:28-38`「生產」option**：`applicable` 需 `ctx.has_own_outpost AND ctx.has_manufacturing_facility`
   （options:32）→ **workshop 先建才可選生產** → TASK_MANUFACTURE。
3. **兩子根**：
   - **① workshop 建太少**（3mo 0→1）：workshop desire=demand(goods)+need_keep(goods/tools/arrows)；
     **goods=0 經濟 → workshop desire 低 → 少建**（雞生蛋：無 workshop→無 goods/tools→workshop 不值得建）。
   - **② 建了的 workshop 隊沒上 TASK_MANUFACTURE**：measurer 無收到任何 `manufacture.*` probe
     （連 noop_no_material/no_worker 都無）→ 該 workshop 隊**從沒選「生產」option**（競爭輸/has_manufacturing_facility
     gate/own_outpost 語意），故 tick_all:67 直接 continue、production 路徑零觸發。

## 判：非單一 slice（製造產能 bootstrap 根）
= 製造業供給側產能根缺口（[[project_established_chain]] 五層雞生蛋家族：workshop↔goods↔tools 互為前置）。
measurer 同判「可能非單 slice」。**呈 systems/blueprint 定範圍**：
- 攻 ①（workshop 建少）：desire bootstrap（goods=0 時 workshop 仍值得建的信號）？
- 攻 ②（沒選生產）：生產 option 競爭力 / has_manufacturing_facility 是否誤擋？
- 或整體 established-chain arc 重啟（production revive，已 open backlog）。

## 序
tools-demand 可增量 merge（demand+afford 正確、無迴歸）。build 終閘（製造產能）另 arc/slice——等裁範圍再定我下一步。**v2b(coin)仍 DEFER**（此 supply 根不解，coin 更無用）。
