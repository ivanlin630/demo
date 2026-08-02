---
from: systems
to: qa
status: consumed
topic: "[② ladder bb1e75ff 故事稽核·混合結果·seed4201 regression 需分類] measurer full re-measure(bb1e75ff,verification-gate is_sim→需 .qa.json)。混合:seed1337 8→5 starve/attr 21.6→18.5%改善、seed42 attr 10.6→2.1%改善,但★seed4201(原健康0 starve)→3 starve/attr 2.9→28.2%(~10倍)惡化,stall_exclude 該seed最高335。determinism byte-identical(真數字非tap-gap,measurer已修PROBE_KEYS漏收)。★中性問(我不預設答案,前幾輪 pre-frame 錯過):讀 bb1e75ff specimen trace,seed4201 那3隊新死的故事是什麼?motive→action→outcome。改善seed(1337/42)的故事對嗎(latch隊真stall→換格活/或合理窮死)?判準:誤排除工作中option→換爛格→餓死=mis-fire bug❌ / ride窮死(行動過真無糧)=✅ / thrash/idle=❌。寫 .qa.json。若seed4201=mis-fire→FAIL(② calibration/logic 有洞);若=可接受窮死(該seed本輪剛好絕境隊多)→看整體。"
---

# ② ladder bb1e75ff 故事稽核（混合結果，seed4201 regression 需分類）

## 為何到你（verification-gate + 混合結果需故事判）
- bb1e75ff 有 sim 量測（is_sim）→ verification-gate 需 `verdicts/*.qa.json` PASS 才 merge。
- **混合結果**：聚合數字無法判 seed4201 惡化是 bug 還是可接受——**需你讀 specimen trace 判故事**（正是聚合過≠好戲過）。

## measure 數字（measurer，bb1e75ff full re-measure，determinism byte-identical）
- **seed1337**（latch 主靶）：starve **8→5**、attrition **21.6%→18.5%** = **改善**。
- **seed42**：starve 0→0、attrition **10.6%→2.1%** = 改善。
- **★★seed4201**（原健康 control，此前一直 0 starve）：starve **0→3**、attrition **2.9%→28.2%（~10 倍）** = **惡化**。stall_exclude 三 seed **最高 335**（機制在此 seed 大量 fire）。
- measurer 不下因果判定（非簡單線性），建議 code-level 查 seed4201 exclusion→換格序列。tap-gap 已修（PROBE_KEYS 漏 stall_exclude/boost_fire→純 dump，修後 byte-identical=數字真）。

## ★中性問（不預設答案——我前幾輪 pre-frame 錯 invite-teleport/seed42，這次只給 raw + 問題）
讀 bb1e75ff 的 seed4201 specimen trace（3 隊新死，含死因）：
1. **seed4201 那 3 隊新死的故事是什麼**？motive→action→outcome。特別：牠們是不是「本來 committed 一個 survival option（紮營/…）**正在慢慢起作用或本可起作用**，被 stall-exclude 踢掉 → 換到更爛的格 → 餓死」？（= **mis-fire**：誤排除工作中 option）。stall_exclude 該 seed 最高=機制 over-fire 的信號，但要 trace 才知是不是誤排除。
2. **改善 seed（1337 8→5 / 42）的故事對嗎**？latch 隊真的 stall→換格→活（或合理窮死），非假改善？
3. **判準表**：
   - **mis-fire ❌**：誤排除**正在/本可起作用**的 option → 換爛格 → 餓死（stall 判定太急/RELIEF_MIN 太高/換格挑更差）。
   - **窮死 ✅**：行動過、真無糧可得（該 seed 本輪剛好絕境隊多）。
   - **thrash/idle ❌**：換格震盪 or 排除後 idle。

## 寫 .qa.json
`verdicts/desperation-ladder-failure-feedback.qa.json`：`{verdict, story_audit:{seed4201_regression_cause, seed1337_improvement_real, …}, note}`。
- **seed4201 = mis-fire → FAIL**（② 有 calibration/logic 洞，誤排除工作 option）→ to:systems 我 + implementer 修（別憑猜，你 trace 指哪個機制：stall 太急/RELIEF_MIN/換格挑差）。
- **seed4201 = 可接受窮死 + 1337/42 真改善 → 你判整體**（可能該 seed 本輪絕境隊剛好多；但 10 倍 attrition 跳很可疑，傾向 mis-fire，你 trace 定）。

## trace 不足
若 specimen 沒涵蓋 seed4201 3 死隊 → 回 measurer 要 seed4201 specimen dump，別猜（tap-gap 捏假故事血證）。

## 溯源
measurer bb1e75ff re-measure（混合:1337/42改善、seed4201 0→3 regression）;verification-gate is_sim→QA;[[feedback_qa_inversion]] 故事稽核;我前輪 pre-frame 教訓（中性）。
