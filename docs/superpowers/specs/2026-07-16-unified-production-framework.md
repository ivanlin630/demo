# Spec：統一生產/發展框架（de-patch 設施決策入思考層）

> **★★狀態：HELD 待 R① CLEAN（藍圖/用戶戳，2026-07-16）。**
> §根的 raw fact（file:line）已坐實，**但詮釋斷言未驗**（A2 是否主導病、移 A1 是否 emergent 分化、granary seam 是否真 fire、de-patch 是否產 surplus）——`file:line 坐實原始事實 ≠ 坐實詮釋斷言`。本 arc 詮釋錯 6 次 + 商業 accessor 前科。**R① CLEAN（可能含 measurer 一輪定主導閘）→ systems 確認/修前提 → 才進 R② 設計審 → dispatch。** 見 handback `systems-to-reviewer-production-framework-r2`。

> 生產 arc（甲）。用戶定：拆光生產/設施子系統所有補丁閘融進框架（引擎+人格），無殘補釘再量。
> **原則（沙盒憲法精準版）**：框架只管**規則/機制**（不決定），思考=**DecisionEngine+人格**（NPC 自己想）。
> de-patch = 把決策**抽出**機制交思考層，**非**把硬邏輯搬進 facility/order code（換地方藏補丁）。

## 根（measurer dynamic + 靜態稽核，file:line 坐實）
- **supply-wall-root（measurer）**：has_facility 隊**恆=1**（6 月不變）、8 隊 goods holding **恆=0**、`[Manufacture]` 全程僅 6 次、TASK_MANUFACTURE dispatch **1→11 隊卻每 tick 空轉 no-op**。非 material 稀、非 reserve、非 task-selection。
- **A1 恆-hungry hard override**（`faction_ai_system.gd:2942-2950`）：`hungry` → early-return `farming`，**跳過**下方 `_facility_score` 人格 argmax（工坊/冶煉/軍事）。seam：`own_granary_tile`（`resource_system.gd:386-390`）**位置相依**（隊站自家 outpost tile 才回糧倉，否則退私產≈0）→ 領主駐他處/評遠格 → 誤判 hungry → farming override 復活。farming deficit（`_facility_deficit:2011-2014` target pop×食×14）同 seam → 農田雙路佔優。
- **A2 製造 option 不查設施**（`decision/options.gd:71-72`：`"生產","駐守": if ctx.has_own_outpost`）：有 outpost 無製造設施 → 選「生產」→ dispatch TASK_MANUFACTURE → `manufacturing_system.gd:90-93` `level<=0 continue` **空轉 no-op**。死碼 `_can_manufacture`（`faction_ai:2103-2121`）**有正確 has_facility 邏輯但零 caller**。**＝dispatch 1→11 每 tick no-op 的直接機制，最擋 surplus。**
- **A3 infra 硬優先序**（`faction_ai:2858-2931`）：升級(2859)>擴建(2869)>攢公庫(2914)>蓋新(2918) = 固定 if 階梯 + first-match return，非 utility。
- **A4 攢公庫強制 GOVERN**（`2914-2917`）：vault_mat<`GOVERN_MATERIAL_TARGET` → 強制 TASK_GOVERN。
- **B**：facility 選擇平行 mini-utility（`_pick_facility`/`_facility_score`），有人格項（`_facility_personality` via `FACILITY_DEF.leader_pref`）**但被 A1 override 架空**。
- **E 製造 no-op 完全無 tap**（`manufacturing_system:78-93` 各 continue 無 Probe.bump）→ 病躲很久主因，**違全量暫態可觀測不變量**。

**★de-patch 故事強**：引擎/人格機制**本就在**（farming 是 FACILITY_DEF 一等公民 `outpost_system:49`、leader_pref 分化已接、_facility_score argmax 已跑），只被 A1 硬 override + A2 缺 precondition + A3/A4 硬階梯**架空/短路**。修 = 拿掉焊死物，讓既有思考層跑。

## 規則 vs 思考分層（原則套每項）
**機制/規則（留框架 flat，世界物理，不因人格變）：**
- `FACILITY_DEF`（`outpost_system:48-97`）設施 cost/build ticks/產出、slot cap、`FOOD_PER_PERSON_PER_DAY`、farming/manufacture 產什麼、守恆。
- **「製造需有設施」＝precondition 規則**（A2 修正是**補這條缺的規則**：沒工坊不能製造＝世界物理，非拆補丁）。

**決策/思考（移思考層——NPC 自己想）：**
- 建什麼設施（農/工坊/冶煉/軍事）、食安 vs 發展、升級 vs 擴建 vs govern vs 蓋新、想製造→無設施→該去蓋（means-end）。

**常數分層（別一律人格化）：**
- **決策門檻常數 → 人格/情境化**：hungry 門檻（`×0.8×7`）、best_score 門檻（`0.05`）、farming deficit target（`×14`）、GOVERN_MATERIAL_TARGET。
- **世界物理常數 → 留 flat**：facility material cost、build ticks、slot 數、食耗率（工匠蓋工坊比較便宜=怪，禁）。

## 交付切片（impl-internal TDD；★整框架完成才 full-HD 量，非拆一道就量）

### P1 — 製造 precondition 規則 + no-op tap（A2 + E）
1. **DecisionContext 加 `has_manufacturing_facility`**（重用死碼 `_can_manufacture` 的設施查邏輯：本格任一 RECIPE_GROUPS level>0 + 生產權 owner/同 faction）。
2. **`options.gd:71` `"生產"` applicable 改**：`if ctx.has_own_outpost and ctx.has_manufacturing_facility`。**補缺規則**（沒設施不能選製造）。「駐守」維持 has_own_outpost（駐守非製造）。
3. **means-end 承接**：隊想 goods 但無設施 → 「生產」不 applicable → 「建設」/facility argmax 接手蓋工坊（靠 P2/P3 workshop deficit 高自然贏；**故整框架完成才有 means-end 閉環**）。
4. **tap（全量暫態可觀測）**：`manufacturing_system` 各 no-op continue（`level<=0`/無 resident/`not _team_works_tile`）加 `Probe.bump("manufacture.noop_<reason>")`；`options.gd` 生產被 precondition 濾掉加 `Probe.bump("produce.appl_kill_nofacility")`。**觀測禁耗 RNG、禁污染**（照觀測不變量）。

### P2 — A1 恆-hungry override 拆 + granary seam 修（A1）
1. **移除 `_pick_facility:2942-2950` hungry early-return**。farming 留在 argmax loop（2953）靠 `_facility_score = terrain × (1+deficit) × personality` 競秤；食低 → farming deficit 高 → 自然贏（emergent，非 override）。
2. **granary seam 修**：facility-eval 的食安度量改**據點局部、非評估隊位置相依**——`_pick_facility`/farming deficit 讀「本 tile 糧倉（`tile.public_storage` food）+ owner/resident 團私產」，非 wandering leader 的 positional `effective_food`。（消耗/survival reader 的 positional `effective_food` **不動**——你站哪吃哪是對的；只 facility-eval reader 改。）
3. **demolish-for-farming 泛化**（`2945-2949` 只 hungry→farming 拆遷 → 通用）：slot 滿時，若 best facility utility > 現有 lowest utility + 門檻 → demolish+build（全設施通用 argmax，非 hungry 專屬硬 gate）。
4. **決策門檻常數人格化**：hungry/food-security 門檻、best_score → 人格（慎重↑保守食安、野心↑偏發展）/情境驅動。

### P3 — infra 優先序 utility 化（A3 + A4 + B 收尾）
1. **`_evaluate_infrastructure` 固定 if 階梯（升級/擴建/govern/蓋新）→ utility 排序**：各 infra action 算 score（升級 utility、擴建=best `_pick_facility` score、govern=公庫缺口×慎重、蓋新=擴張 utility×野心）→ argmax，退役 first-match ladder。
2. **A4 強制 GOVERN 拆**：govern 成競秤 option（公庫缺口 term），非 vault<門檻硬 force。
3. **B 收尾**：確認 facility 選擇全程無殘 override/硬 gate，純人格加權 argmax；決策常數人格化到位。

## 非回歸（de-patch 不傷既有）
- **FACILITY_DEF/build 機制純規則不動**（cost/ticks/產出/slot/守恆）。
- **真飢隊 farming 仍贏**：food 真低 → farming deficit 高 → argmax 選 farming（emergent，非 override）；驗真飢隊行為保留。
- **感知鐵律**：facility-eval 用本格+鄰格 obs（`_facility_terrain_fit` 已是），granary seam 修只讀**自家**據點糧倉（own data 非 god-view）。
- **A2 precondition 不誤殺**：有設施隊製造照跑（`level>0` 分支不動）；只濾無設施的 no-op 選擇。
- **觀測不變量**：新 tap 禁耗 global RNG、禁污染 Probe（on/off byte-identical，盲點閘③④⑤綠）。
- **既有交易/飢荒/戰鬥鏈**不受設施決策重構影響（seam 限 `_evaluate_infrastructure`/`_pick_facility`/`options.gd:71`/`manufacturing tap`）。

## 閘
- **新大框結構重構 → reviewer R② 必過**（spec 鎖 → dispatch 前審設計 CLEAN 才 impl）。
- **R① 免**：前提（4 閘+死碼+seam）全 file:line 坐實（靜態稽核 + systems code 複驗）。
- **★建議升異質框外審**（同 unified-commerce）：大框 + 藍圖/系統已對齊（2 方），異質家族（Fable）框外審抓結構盲點（商業教訓：異質審抓 3 缺口 homogeneous 漏）。reviewer 裁。

## 量測（★整框架完成後，中性 full-HD）
measurer `--path` branch full-HD：
1. **has_facility 成長**（製造設施隊數 >1，逐月升）。
2. **goods 產出 > 0**（`[Manufacture]` fire 大增、goods holding 破 0）。
3. **surplus 進市場**（sell_no_surplus 大降、deal_market 升）。
4. **deals 大幅升**（貿易活）。
5. **★人格分化**（工匠型/貪婪 leader 隊建工坊、農夫型/慎重續農、好戰建軍事——emergent 差異，非齊一）。
6. **製造 no-op 可觀測**（tap 計數：修前 no-op 高 → 修後趨零）。
7. **無殘補釘**（grep 確認 A1/A3/A4 硬 gate 全退、無新藏補丁）。
8. **中性世界**（byte-identical 三跑、盲點閘綠、守恆）。

## 溯源
- 生產 arc greenlight `2026-07-16-blueprint-to-systems-production-arc-greenlight-unify-all-gates`（用戶定甲+拆光融框架）。
- 原則 `2026-07-16-blueprint-to-systems-framework-rules-not-thinking-principle`（框架管規則不管思考）。
- 靜態稽核 `2026-07-16-blueprint-to-systems-production-audit-gates-map`（4 閘+死碼+分層+拆序）。
- supply-wall-root（measurer）；systems code 複驗全 file:line。
