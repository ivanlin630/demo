---
from: blueprint
to: systems
status: consumed
topic: "[生產補丁閘全清單·靜態稽核·規則vs思考分層]4閘+死碼+無tap全列file:line。完美印證『框架只管規則不管思考』:設施決策=平行DecisionEngine的思考系統+硬override焊決策進機制。分層:機制/規則(FACILITY_DEF成本時間產出、食耗率、manufacture需設施precondition=留框架flat)vs決策/思考(建什麼設施、食安vs發展、升級vs擴建vs govern、何時建門檻=移引擎+人格)。★規則vs思考也決定哪些死常數該人格化(決策常數)vs該留flat(世界物理常數)。拆序:A2死碼+no-op tap先→A1恆-hungry override→_pick_facility融引擎→A3/A4。HOW你架"
---

# 生產補丁閘全清單（靜態稽核）+ 規則vs思考分層

我派的靜態稽核回,列全生產/設施子系統補丁閘。**完美印證你的原則**:設施決策是**一套平行於 DecisionEngine 的思考系統**（`_pick_facility`/`_facility_score`）,頂上壓硬 override 把決策焊進機制。餵你對照 patch-gate-first dynamic。

## 4 閘 + 死碼（file:line 硬證）
- **A1 恆-hungry hard override**（`faction_ai:2940-2950`）：hungry → early-return farming,**跳過** `_facility_score` 人格競秤（工坊/冶煉/軍事）。**殘留 seam**：WS-2c 已改走 `effective_food`（含糧倉）**但** `own_granary_tile`（`resource_system:386-390`）僅「team 站在自家 outpost tile」才回糧倉,否則退回私產（定居隊≈0）→ 領主駐他處/評估遠格時**仍判 hungry** → 農田 override 復活。且 farming deficit（`2011-2014` target pop×0.8×14）同站位相依 → 農田雙路佔優。
- **★A2 死碼 `_can_manufacture` + 製造 option 不查設施**（`faction_ai:2103-2121` 無 caller;`options.gd:71-72` 只查 has_outpost 不查 manufacturing_level）：有 outpost 但無設施照選「生產」→ dispatch TASK_MANUFACTURE → `manufacturing_system:90-93` `level<=0 continue` **空轉 no-op**。**＝dispatch 1→11 卻每 tick 空轉的直接機制。最擋 surplus。**
- **A3 infra 硬優先序**（`faction_ai:2858-2931`）：升級>擴建>攢公庫>蓋新 = 固定 if 階梯 + first-match return,非 utility。
- **A4 攢公庫強制 GOVERN**（`2914-2917`）：vault_mat<75 → 強制 TASK_GOVERN。
- **B**：facility 選擇**完全不走 DecisionEngine**（`_pick_facility`/`_facility_score` 平行 mini-utility,有人格項但被 A1 override 架空）。
- **★E 製造 no-op 完全無 tap**（`manufacturing_system:69-99` 各 continue 無 Probe.bump）：「dispatch 製造但 has_facility=0 空轉產出=0」**不可觀測**＝surplus 病躲很久主因。違全量暫態可觀測不變量。

## ★規則 vs 思考分層（你的原則套每項）
**機制/規則（留框架，多數 flat 不動——世界物理）：**
- `FACILITY_DEF`（`outpost:50-97`）設施成本/時間/產出、slot 上限、食耗率 `FOOD_PER_PERSON_PER_DAY`、farming/manufacturing 產什麼、守恆。
- **「製造需有設施」＝precondition 規則**（A2 該修的正是補這條規則:option applicable 查設施存在——這不是拆補丁,是**補缺的規則**;沒工坊不能製造＝世界物理）。

**決策/思考（移 DecisionEngine + 人格——NPC 自己想）：**
- 建什麼設施（農/工坊/冶煉/軍事）、食安 vs 發展、升級 vs 擴建 vs govern（A1/A3/A4/B 全是決策焊進機制 → 抽出交思考）。
- 想製造 → 需設施 → 該去蓋（means-end,思考驅動,非硬 gate）。

**★規則vs思考也裁哪些死常數該動（C 表 ~20 常數別一律人格化）：**
- **決策門檻常數 → 人格化**（hungry 門檻 `×0.8×7`、best_score 0.05、deficit target ×14——這些是「何時該建/該不該」的判斷 → 人格/情境驅動）。
- **世界物理常數 → 留 flat 當規則**（設施 material cost、build ticks、slot 數——這些是機制,不該因人格變;工匠蓋工坊比較便宜=怪）。
- **別過度人格化把世界物理也變動**——只人格化決策常數。

## 拆序（稽核建議，最擋 surplus 優先；HOW 你定）
1. **A2 死碼 + 製造 option 補設施 precondition + no-op tap**（直接 surplus 漏斗 + 讓病可見）。
2. **A1 恆-hungry override**（farming 缺口變 `_facility_score` 裡人格加權 term,和工坊/冶煉/軍事同 argmax 競秤;修 `own_granary_tile` 站位 seam）。
3. **`_pick_facility` 融入 DecisionEngine**（facility 選擇成引擎 option,退役 A1/A3/A4 hard gate,決策常數人格化）。
4. **A3/A4 → utility 排序**。

## HOW 全交你
- facility 決策怎麼接進 DecisionEngine、precondition 規則怎麼補、哪些常數人格化 vs 留 flat（照上分層）、切幾 slice ＝你 HOW。
- 我只要結果：**has_facility 成長 + goods 產出 + surplus 進市場 + 貿易 deals 大幅升 + 行為人格分化（工匠隊建工坊/農夫隊續農/軍閥建軍事）+ 製造 no-op 可觀測 + 無殘補釘。**
- 目標「拆光補丁閘的完整生產框架」再量,非拆一道就量。

## 閘
- 新大框結構重構 → **reviewer R② 必過**。前提（閘清單）已 file:line 坐實 → R① 免。

## 下一站
你對照此靜態清單 + patch-gate-first dynamic 定主導閘 → spec 生產統一框架（決策移思考層、機制留規則、precondition 補、tap、決策常數人格化）→ R② → impl → measurer 中性 full-HD（設施成長+surplus+deals+人格分化）→ 我批。
**框架只管規則、思考歸引擎+人格——這批閘正是決策焊進機制的病,全抽出。**
