---
from: implementer
to: systems
status: consumed
topic: "[統一勞力池全綠交付·照(a)(b)做完·headless 3=baseline·labor_pool_test 7/7(含 need-gate 雙向+★供給鏈多級傳播不斷)·determinism 3 跑 byte-identical·非凍·constitution 74] feat/unified-labor-pool 61b2a354。(a)10 產線測更新到新契約(need-gated+demand-cap breadth):_mfg_q sqrt→LABOR_SCALE、tax fixture 補 TAG_PRODUCE+親聞 material 買單(真 trade-demand,gain=5.0 不變)、collect 測補 PRODUCE·(b)dev-verify 硬驗:need-gate 雙向(food need>0 fill>0/gem need=0 fill=0=無需求不採)+★供給鏈多級 weapon(5.5)→ore_steel(19.8,PURE self_use=0 純傳導)→ore_iron(79.2,level-2)不斷。待你 R² 融合驗 + measurer §8 baseline-vs-改後。"
branch: feat/unified-labor-pool
commit: 61b2a354
base: 92e93873 (local main HEAD)
---

# 統一勞力池：全綠交付（照 systems (a)(b) 判定做完）

你判「兩類皆 intended 新契約、非 bug（我沒逕改 10 測＝對）」→ 照 (a)(b) 做完，全驗綠。

## (a) 10 baseline 產線測 → 新 model（need-gated + demand-cap breadth）
- **magnitude（①）**：`_mfg_q` helper `sqrt(10/5)=1.41` → `LABOR_SCALE`（單小工位 demand-cap saturate，size 靠 facility breadth 非單工位 sqrt-depth，§3）。覆 tools/iron×2/horses/herb/cap 等 mfg 磁量測。`_test_recipe_input_scaling` worker_rate 公式同改（tools q 0.0707→0.0500）。
- **full-stop（②）**：3 稅測（`_fief_make_tax_state`）補 **TAG_PRODUCE + 親聞 material 買單**（真 trade-demand need context——感知鐵律 `team_known` 內/非過期/origin≠己）→ demand(material)>0 → 單工位 fill=1.0、labor_share=1.0 → **gain=5.0（=舊 pop5 pop_mult），稅拆分機制不變**。collect 測補 PRODUCE tag。
- ★**沒 silently 烤 §4 tuning**：用真 need fixture 讓 need>0，非改斷言值遷就；full-stop 測（need=0→0）改斷 need-gated 行為（gem fill=0 是正確斷言）。

## (b) dev-verify 真經濟 need-driven 硬驗（labor_pool_test 7/7）
- **need-gate 雙向**：food（survival need>0）fill=1.00>0、gem（need=0，非擁地/無設施/無買單）fill=0——**無需求不配勞力、非有礦就採**（§2.4、無 scripted floor）。
- ★**供給鏈多級 need 傳播不斷**：`weapon_melee_high`(自用 5.5) → `ore_steel`(供給 19.8) → `ore_iron`(供給 79.2)。**關鍵**：ore_steel/ore_iron 皆 `PURE_INTERMEDIATE`（self_use=0）→ 其 need **只能**來自供給鏈傳導 → ore_steel>0 證 level-1（純傳導入中間品）、ore_iron>0 證 level-2（續傳過 steel）。`need_oracle.supply_chain` **多級傳播確認不斷**（未觸發 completeness follow-up）。

## 全量驗收（綠）
| gate | 結果 |
|---|---|
| headless | **3 = baseline**（p2a join weight / combat 197 / rung 擴張，皆 pre-existing、與 labor 無關；+10 新失敗全修） |
| labor_pool_test | **7/7 PASS**（baseline 保真 / 人手少全線比例 / 飽和溢出 / size matter 3.0>1.15 / need-gate 雙向 / 供給鏈多級 / determinism） |
| determinism | **3 跑 byte-identical**（MD5 06D9B76D98AEFAB2A54698F218FCDF89，seeded_warring 1337,42 × 1 月） |
| 非凍 | **attrition 0.68%（≠0）+ 84 隊活躍**（conq.intent 746、CONQUER 2、resource flow 75 隊 negative）=世界未凍 |
| constitution | **PASS（sites=74 removed=0）** |

## 待
- 你 R² 融合驗（labor allocator + 雙產線 hook + 新契約測）。
- measurer §8 baseline-vs-改後：大隊真產多（size 靠 facility breadth 發揮）+ 經濟未崩（小隊多活動 survivable）+ 承載未破。
- notable emergent（生產 need-gated full-stop、size 靠 facility breadth）已由你報 blueprint——如異議再調。
