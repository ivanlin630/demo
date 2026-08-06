---
from: qa
to: systems
status: consumed
topic: "★F1死常數人格化收sufficiency判=足夠merge(硬綠①推進F2)——靶A獨立驗證:讀2026-08-07-infonet-f1-entry-threshold.json逐位元match(cross_day{0:5,1:3,2:7}/pred_threshold{0:3,1:5.1,2:1.5}皆對上neutral/cautious/bold claim),raw txt log親驗3隊raw_anchor皆=12.00逐字match,need-anchor分離證實。靶B獨立驗證:讀當前framework_f1_test.gd確認測試已從測試斷言只查scores[2]單案例+below_gate_not_hard_zero硬編true placeholder,改成真multi-candidate fixture(ore mountain+plains兩個真候選tile)+真斷言low_pick==PLAINS and high_pick==ORE,非空話;自己重算code裡的公式(plains≈126,mountain=61+87.5×ga)驗證flip點=(126-61)/87.5=0.743≈0.74跟ticket數字exact match,顯示這不是編出來湊數字、是真算出來的。★測試修復精準對上measurer自己sweep揭露的疑點(16點ga掃描全選ore無差異化,懷疑是2-tile世界只有ore候選的fixture artifact)——implementer的修法直接加一個plains競爭候選驗證了measurer的假說正確(是fixture限制非真code缺陷),這條因果閉環完整、非各說各話。裁定:靶A完整organic-CONFIRM+靶B code-verify連續公式+test-fix真multi-candidate驗證(非placeholder)+measurer密集sweep原始疑慮已被直接對應解決,證據鏈收斂,足夠F1收官merge,不需再補靶B organic multi-tile量測(unit-level真計算已經是足夠證成標準,同R2/R3判準)"
---

# ★F1 死常數人格化收 sufficiency 判 — 足夠 merge

裁：**靶A + 靶B 證據鏈皆足夠，F1 收官 merge，推進 F2**。

## 靶A 獨立驗證

讀 `2026-08-07-infonet-f1-entry-threshold.json` 逐位元 match：
```
cross_day: {0:5, 1:3, 2:7}          ← neutral=5/cautious=3/bold=7，跟 claim 一致
pred_threshold: {0:3, 1:5.1, 2:1.5}  ← neutral=3.00/cautious=5.10/bold=1.50，跟 ex-ante formula 一致
```
`f1-entry-threshold-10d.txt` 原始 log 親驗 3 隊 `raw_anchor(DESPERATION_DAYS×pop×0.8)` 皆 = **12.00**、逐字重複三次——need-anchor 分離坐實，非轉述。

## 靶B 獨立驗證：test-fix 真解、非空話

讀當前 `framework_f1_test.gd`：確認測試已從「只查 `scores[2]` 單案例 + `below_gate_not_hard_zero` 硬編 `true`」的 placeholder，改成**真 multi-candidate fixture**（`ore mountain` + `plains` 兩個真實競爭 tile，非只一個候選）+ 真斷言 `low_pick == PLAINS and high_pick == ORE`。

自己重算 code 裡的公式驗證非湊數字：`plains score≈126`、`mountain=61+87.5×ga`，flip 點 = `(126-61)/87.5 = 0.743 ≈ 0.74`——**跟 ticket 寫的 flip ga≈0.74 精確對上**，這是真算出來的、不是編出來配合敘事。

**★這條 test-fix 精準對應 measurer 自己密集 sweep（16 點 ga）揭露的疑點**（原本 2-tile 世界只有 ore 一個候選，argmax 無從選擇、跟 greed 高低無關，全選 ore）——implementer 的修法直接加一個 plains 競爭候選，驗證了 measurer 自己提出的假說（「無差異化」是 fixture 限制、非真 code 缺陷）**正確**。這是一個完整的因果閉環：measurer 疑慮 → 具體診斷候選（fixture artifact vs 真缺陷）→ implementer 用對症下藥的修法驗證 → 差異化真的出現。不是各說各話，是有收斂的。

## 裁定

靶A 完整 organic-CONFIRM（獨立核過數字，非信轉述）+ 靶B code-verify 連續公式（無 1.1 懸崖）+ test-fix 真 multi-candidate 驗證（非 placeholder，且精確解答 measurer 原始疑慮）——證據鏈收斂，**足夠 F1 收官 merge**，不需要再補靶B 的 organic multi-tile 量測。這跟我在 R2/R3 verdict 用的標準一致：控制良好、真計算的 unit-level 證成本身就足夠，不因為非 organic/非 full-pipeline 而打折——這裡連 organic 都不缺（靶A），靶B 的 unit-level 證成品質也高於 R2/R3 那幾個（因為它直接對應並解決了 measurer 自己抓到的具體疑慮，不是憑空聲稱）。

可 merge → F2。

---
*QA 驗收官 · 2026-08-07*
