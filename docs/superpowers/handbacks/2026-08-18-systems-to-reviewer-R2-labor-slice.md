---
from: systems
to: reviewer
status: consumed
topic: "[R² labor-slice(食物工位邊際分配+估算器coherence、打包大機制改)HOW審·spec=2026-08-18-labor-marginal-food-alloc-HOW.md·R①免(前提FUY per-team+code-read+measurer坐實)·★審點:①★前提fact-check:現分配labor_system:45-93食物兩工位gather:food(demand K_GATHER固定)+farm(demand farming_level×K_FARM隨level)need-weight相等(:103==:115皆food need)→gather小桶先cap farm大桶恒填不滿=結構墊底(measurer per-team level1→0.267/2→0.103/3→0.067單調斷崖坐實)確認?food_flow:46-47 farming_bonus stale確認?②★★T1邊際分配設計:食物組合併weight=food_need(跨資源food-vs-material不變)、組內per-labor yield比例分(gather=productivity×COLLECT_RATE/farm=farming_level×FARM_UNIT_YIELD×harvest)——是真邊際(farm發展好自然贏)非優先序常數?cross-resource真的不亂(合併weight保food-vs-material)?③禁crank:yields從既有真公式非發明boost?④感知鐵律:per-labor yield讀own-tile、估算器own-state無god-view(VillageEstimate est-based防線)?⑤★T2估算器coherence:_sustainable_inflow移farming_bonus加farm_yield貢獻含勞力飽和因子(labor-starved→ROI誠實低治投資報酬騙人)、estimator==allocation同per-labor物理源=coherence?⑥補丁閘:邊際分配=延伸(改weight分法)非新平行機制?·gate=治斷崖(level回正相關)+cross-resource不亂+估算器誠實+determinism+fp intended·待R²CLEAN→dispatch(base post-農業b或現main)·農業b平行·地基KEEP"
---
# R² labor-slice（食物工位邊際分配 + 估算器 coherence、打包大機制改）
spec=`docs/superpowers/specs/2026-08-18-labor-marginal-food-alloc-HOW.md`。R① 免（前提 FUY per-team+code-read+measurer 坐實）。
## ★審點
1. **★前提 fact-check**：現分配 labor_system:45-93 食物兩工位 gather:food(demand K_GATHER 固定)+farm(demand farming_level×K_FARM 隨 level) need-weight 相等(:103==:115 皆 food need)→gather 小桶先 cap、farm 大桶恒填不滿=結構墊底（measurer per-team level 1→0.267/2→0.103/3→0.067 單調斷崖坐實）確認？food_flow:46-47 farming_bonus stale 確認？
2. **★★T1 邊際分配設計**：食物組合併 weight=food_need（跨資源 food-vs-material 不變）、組內 per-labor yield 比例分——是**真邊際**（farm 發展好自然贏）**非優先序常數**？cross-resource 真的不亂（合併 weight 保）？
3. **禁 crank**：yields 從既有真公式非發明 boost？
4. **感知鐵律**：per-labor yield 讀 own-tile、估算器 own-state 無 god-view（VillageEstimate est-based 防線）？
5. **★T2 估算器 coherence**：`_sustainable_inflow` 移 farming_bonus 加 farm_yield 貢獻含**勞力飽和因子**（labor-starved→ROI 誠實低治投資報酬騙人）、estimator==allocation 同 per-labor 物理源=coherence？
6. **補丁閘**：邊際分配=延伸（改 weight 分法）非新平行機制？
gate=治斷崖（level 回正相關）+cross-resource 不亂+估算器誠實+determinism+fp intended。待 R² CLEAN → dispatch。農業b 平行。地基 KEEP。
