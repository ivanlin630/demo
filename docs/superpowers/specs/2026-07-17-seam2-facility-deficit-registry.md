# Spec：seam#2 facility deficit 資料驅動（match→REGISTRY 擴充，byte-identical）

> framework 做好 stream② seam#2。用戶標準：擴充性=加設施動幾處。北極星:加一個設施=1 registry entry（非改 `_facility_deficit` match + `_pick_facility` + `_pick_outpost_type` 多處）。
> **★前提先驗（2026-07-17，systems 逐 code）**：seam#2 原 premise「facility 走 TARGET_PER_POP 各算=單一源違規」**已 stale**——need-oracle **S6 已 merged**，`_facility_deficit`（`faction_ai_system.gd:3061-3116`）**已讀 NeedOracle 單源**（workshop/apothecary/armorsmith/smeltery/stable = `NeedOracle.need_keep(+demand)`）。∴ **單一源不必再做**，seam#2 = **純擴充 refactor**（match→registry），同 seam#1 S1 pattern（已 merged 5cfc2483 可 reuse idiom）。

## 根（結構已讀）
`_facility_deficit(state, team, facility, tile) -> float`（`:3061-3116`）= `match facility:` 逐設施硬 case。加設施=加 case。三類 case：
- **A 泛型（NeedOracle-gap）**：workshop（goods/tools/arrows = need_keep+demand）、apothecary（medicine need_keep）、armorsmith（armor_low+high need_keep ×militancy）、smeltery（ore_steel need_keep）、stable（mounts need_keep）。**共同形:`1 − min(holding / (need_keep[+demand]))`，可選 ×militancy**。
- **B facility-gating**：smeltery 需 weapon/armorsmith 存在（`:3099`）、armorsmith/weaponsmith ×`_militancy`（軌2 閘1 de-patched）。
- **C 特殊（非 NeedOracle-gap）**：weaponsmith（`0.6 − armed_ratio × militancy`，非 res gap）、mint（tile-bound ore world-mechanic `:3103-3111`）、granary（local food S2 granary seam `:3068-3072`）。

## 目標：FACILITY_DEF registry data-driven
### ★schema（R② 補完 2 缺口後——reviewer 抓 apothecary ×0.5 + workshop/armorsmith 聚合異質）
`FACILITY_DEF[facility] = {`
- `outputs: [res...]`——deficit 目標資源。
- `use_demand: bool`——target = need_keep（false）or need_keep+demand（true，workshop）。
- **`agg_mode: "min_per_res" | "pooled_sum"`**（★R② 補）——多資源聚合策略：
  - `min_per_res`：逐資源分別算比取**最差**（worst bottleneck，某資源夠≠整體夠）。**workshop** 用（goods/tools/arrows 三獨立目標）。
  - `pooled_sum`：多資源**先加總持有 vs 加總目標再算一次比**（可互抵）。**armorsmith**（armor_low+high）用；單一資源者（apothecary/smeltery/stable）亦用（單 res 下兩模式等價）。
- **`output_scale: float = 1.0`**（★R② 補）——deficit 尾乘。**apothecary=0.5**，其餘=1.0。
- `militancy_scaled: bool`——×`_militancy(team,lv)`。**armorsmith=true**（+weaponsmith 但它 C 特殊），其餘 false。
- `gating: 前置條件`——**smeltery**=weapon/armorsmith 存在（`:3099`），其餘 none。
- `special_evaluator: ref`（C 類專用，A 類 null）。`}`

**A 類泛型 evaluator**（讀 entry）：`deficit = clampf(1 − agg(holding, target, agg_mode), 0, 1) × output_scale × (militancy_scaled ? _militancy : 1.0)`，target 依 use_demand。加 A 類設施=1 entry。
- **A 類明細**：workshop{[goods,tools,arrows], use_demand:true, min_per_res}、apothecary{[medicine], pooled_sum, scale:0.5}、armorsmith{[armor_low,armor_high], pooled_sum, militancy}、smeltery{[ore_steel], pooled_sum, gating:weap/armor}、stable{[mounts], pooled_sum}。
- **C 類特殊 evaluator**：weaponsmith（`0.6−armed_ratio × militancy`）、mint（tile ore 二元 `1.0 if ore>10 else 0`）、granary（local food S2 seam）→ registry entry `special_evaluator` ref，**不硬塞泛型**（seam#1 threat 教訓）。

### 範圍
- 連帶 `_pick_facility`/`_pick_outpost_type` 若含平行 facility 列舉 → S2 一併收（低優先，非本輪 blocker）。**★S2 前置（R② 記）**：`_pick_facility` argmax 跨 facility 比 deficit 大小時，須用 seam#1 教訓審「不同 facility deficit 語意能否直接互比」（本輪 deficit 只各自獨立算 float 不互比=安全避開塌陷）。

## ★關鍵設計（seam#1 threat 教訓應用）
- **A 泛型 vs C 特殊的界線=真異質不硬併**：seam#1 血證=把 filtered threat 硬併全 pool 塌陷。此處 mint/granary/weaponsmith **語意真不同**（非 res-gap）→ registry 容特殊 evaluator，非逼泛型。**byte-identical 硬要求**（同輸出同 Probe）。
- **militancy_scaled 旗標**：armorsmith/weaponsmith ×`_militancy`（軌2 de-patched 人格秤）——registry 標記，evaluator 套用，語意保。

## 交付切片（TDD，byte-identical）
- **S1 FACILITY_DEF registry + A 類泛型 evaluator**：workshop/apothecary/armorsmith/smeltery/stable 走 registry 泛型算，C 類（mint/granary/weaponsmith）registry entry 帶 special evaluator。`_facility_deficit` 讀 registry dispatch。**byte-identical**（同 deficit 值、同 Probe、同 facility gating）。加 A 類 dummy 設施=1 entry 驗擴充。
- （若 `_pick_facility`/`_pick_outpost_type` 含平行列舉）**S2 收 registry**——待 impl 盤點是否值得（低優先，非 blocker）。

## 非回歸
- **facility deficit 值 byte-identical**（各設施 deficit 全等，seeded 對照）。
- **facility gating 保**（smeltery 需 weapon/armorsmith 存在等）。
- **militancy scaling 保**（armorsmith/weaponsmith）。
- **NeedOracle 單源不變**（S6 已建，本 slice 只重構讀取結構非改 need 算）。
- **觀測 byte-identical**（Probe 計數，同 seam#1 S1 要求）。

## 閘
- **R② 必過**（結構重構，非大框 redirect→標準同框 R② 即可，非異質；無 threat 類收斂語意風險，S6 已解單源）。
- premise 坐實（S6 merged 逐 code 驗、facility cases 讀齊）→ R① 免。
- **measurer**：facility deficit byte-identical（seeded 對照 + Probe 計數）+ 擴充 proof（加設施=1 entry）。同 S1 中性複核法。

## 溯源
seam#1 S1 registry（merged 5cfc2483，pattern reuse）；need-oracle S6（`faction_ai_system.gd:3064` 遷 NeedOracle）；[[project_unification_matrix]] stream② seam#2；[[project_economy_arc]]；seam#1 threat 教訓（異質不硬併，[[feedback_frame_challenge]]）。
