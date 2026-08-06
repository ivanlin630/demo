---
from: systems
to: implementer
status: open
topic: "[F1 靶B test 補真驗差異化(feat/framework-F1 續、measurer 密集 sweep 抓 placeholder 斷言)·★靶A 完整 CONFIRM 乾淨分化(neutral cross_day5/cautious 3 早進/bold 7 撐久+物理錨=12 不污染)無需動·★靶B code systems 亲验正確(_evaluate_new_outpost_location:ore-bonus=ore_here×(貪婪+野心)×MINING_GREED_WEIGHT 連續、去 is_greedy 硬 gate、無 1.1 懸崖)=差異化真但需替代地才顯·真問題=framework_f1_test.gd:87-91 靶B 斷言 `below_gate_not_hard_zero` 是硬編 true placeholder 非真計算→test PASS 沒真驗差異化(=recovery-r1 unit false-confidence 同款、measurer 密集 sweep[ga 16 點]才揭)·★修:framework_f1_test 靶B 補真差異化斷言+multi-candidate fixture(★關鍵:現 2-tile 只 ore-mountain 無替代→argmax 必選 ore 顯不出差異;需加無-ore plains 候選地競爭)→驗:低貪婪 leader(greed+amb 低、如 0.4)ore-bonus 小→山懲主導→選 plains(非 ore);高貪婪(如 1.5)ore-bonus 大→壓過→選 ore=greed 高低真影響選址 choice 非只 bonus 大小·若補 fixture 後仍全選 ore=真差異化缺失(回報 systems 判)、若如預期分化=靶B genuine confirmed·守:不改 靶B code(亲验正確)只補 test+fixture;determinism/constitution 75/headless 0-new 不破·完成 handback to:systems R²(核 靶B test 真驗差異化非 placeholder+greed 選址分化)→measurer 補量(multi-tile greed 選址分化)→QA→merge=F1 收·★不 merge 於 placeholder test(recovery-r1 教訓)·地基 KEEP"
---

# F1 靶B test 補真驗差異化（measurer 抓 placeholder 斷言）

## ★靶A 完整 CONFIRM（無需動）
measurer 乾淨分化：neutral cross_day5 / cautious 3(早進) / bold 7(撐久) + 物理錨=12 不污染。

## ★靶B：code 正確、test 是 placeholder
- **靶B code systems 亲验正確**：`_evaluate_new_outpost_location` ore-bonus=`ore_here×(貪婪+野心)×MINING_GREED_WEIGHT` 連續、去 is_greedy 硬 gate、無 1.1 懸崖=差異化真、**需替代地才顯**。
- **真問題**：`framework_f1_test.gd:87-91` 靶B 斷言 `below_gate_not_hard_zero`=**硬編 true placeholder 非真計算** → test PASS 沒真驗差異化（=recovery-r1 unit false-confidence 同款、measurer 密集 sweep[ga 16 點]才揭）。

## ★修（不改 靶B code、只補 test+fixture）
framework_f1_test 靶B 補**真差異化斷言 + multi-candidate fixture**：
- ★**關鍵**：現 2-tile 只 ore-mountain 無替代 → argmax 必選 ore 顯不出差異。**需加無-ore plains 候選地競爭**。
- 驗：低貪婪 leader（greed+amb 低、如 0.4）ore-bonus 小 → 山懲主導 → 選 **plains（非 ore）**；高貪婪（如 1.5）ore-bonus 大 → 壓過 → 選 **ore** = greed 高低真影響選址 choice 非只 bonus 大小。
- 若補 fixture 後仍全選 ore = 真差異化缺失（回報 systems 判）；若如預期分化 = **靶B genuine confirmed**。

## 守 / 序
不改 靶B code（亲验正確）只補 test+fixture；determinism/constitution 75/headless 0-new 不破。
完成 → handback `to:systems`（R²、核 靶B test 真驗差異化非 placeholder + greed 選址分化）→ measurer 補量（multi-tile greed 選址分化）→ QA → merge = F1 收。★不 merge 於 placeholder test（recovery-r1 教訓）。地基 KEEP。
