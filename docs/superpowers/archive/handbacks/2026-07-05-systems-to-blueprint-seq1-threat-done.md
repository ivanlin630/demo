---
from: systems
to: blueprint
status: consumed
topic: 序1 threat 溶入 done(merged 804432e)——融合驗雙關綠(repertoire 4/4+率表);seeded 46/8/1/380→48/8/1/382(合理非退化,你平衡意圖要否覆判);term additive偏離認可;下序2 solo我起
---

# 序1 threat 溶入 done — arc 首張綠

憲法溶入 arc wave1 首張完成、merged main（804432e）、獨立碼證綠。

## 融合非刪達成（你的硬驗收）
- **repertoire 沒少**：融合驗 4 人格原型各達對應反應（FLEE/DEFEND/PREPARE/求和）+ 居民守衛（居民不迎戰）。手算 `_dispatch_threat_response` 撕除 → 引擎 `rank_threat` 秤。
- **該出現還出現**：率表 seeded flee13/prepare4/defend1/pacify0=18>0，non-unified 路徑逐類 **bit-identical**（忠實鏡射舊公式）；unified 隊 threat option 進主 rank 浮現頂端（不被日常決策壓過）。

## 待你看一眼（平衡意圖，不擋 arc）
**seeded 世界漂移 46 隊 → 48 隊**（factions 8/established 1/pop 380→382 守恆）。
- 來源：純 unified 隊（商隊/生產隊）threat option 進主 rank 後偶選 備戰/迎戰/求和 微調軌跡；non-unified 隊逐類零變。
- 我判定「合理非退化」（無滅團潮、faction 結構守恆、世界健康）。**但 46 vs 48 是否符你的世界規模平衡意圖 = 你的 call**。若你覺無感 → 就此定 48 為新 baseline；若你在意 → 我列 unified threat 反應細節你評。
- QA 覆判（充足性）我建議排在 **wave 級交付**（arc 多張溶完），非每張——per-slice 只驗融合雙關（已綠）。你同意這 QA 節奏嗎？

## 一個實作偏離（我已認可，報備）
term magnitude 我原 plan 設 multiplicative（eval×weight），實作改 **additive personality-dominant**（weight=1.0，人格 baked in eval）。因 `threat_react` unbounded（弱隊遇強隊威脅分達 3.27）→ 乘法爆量壓過 survival 絕境 → 忠實鏡射舊 additive 公式。**架構上更貼舊行為、用引擎既有 idiom（intent_fit 同法），非繞過**。認可。

## 下步（我這邊）
- **序2 solo 溶入 spec 我起**（arc-order 序2，`_evaluate_solo` 自建 scores 手算 argmax=平行第二引擎，語意同構翻 options，多數已在 REGISTRY，比 threat 更輕）。無需你決策即起。
- 殘 watch（unified 迎戰/求和 下游 resolver 未端到端驗）入 known_issues，非急。
