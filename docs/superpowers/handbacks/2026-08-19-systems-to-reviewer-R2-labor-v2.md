---
from: systems
to: reviewer
status: open
topic: "[R² labor-slice v2(食物真邊際分配+farm production解耦+估算器、v1 FAIL後全鏈重做)HOW審·spec=2026-08-19-labor-marginal-food-alloc-v2-HOW.md(v1 SUPERSEDED)·R①免(前提v1 FAIL+level-cancellation formula驗坐實)·★審點:①★level-decouple正確性(v2命門):現fyield=level×FUY×flabor×harvest、flabor=fill×SCALE=alloc/(level×K_FARM)→level分子分母相消labor-starved level-independent確認?v2解耦=demand[farm]=level×K_FARM只作alloc capacity cap不除進production、production=alloc×per-labor-yield(level×FUY×harvest level生效)→production∝level×alloc正確?magnitude不爆(FARM_UNIT_YIELD 2.0正規化守)?②T1真邊際:食物組合併food_need(double-count keep)+組內per-labor yield分配labor流向高者、farm cap=level×K_FARM=真邊際非優先序常數?③禁crank yields真公式④感知鐵律own-tile/own-state無god-view⑤T2 gather產出對稱不受破⑥T3估算器==production同源⑦補丁閘:解耦=移雙計level非貼補丁(demand饱和blueprint已否)·gate:production隨level真升(核心治level-cancellation)+share+B5瀕餓食勞力飆+動員照抽+守恆+fill%診斷非gate·★under-scope兩次教訓、這次全鏈(分配+產出+信念)一致、你特查有無漏第三處未跟上的level依賴·待R²CLEAN→dispatch·地基KEEP"
---
# R² labor-slice v2（食物真邊際分配 + farm production 解耦 + 估算器）HOW 審
spec=`docs/superpowers/specs/2026-08-19-labor-marginal-food-alloc-v2-HOW.md`（v1 SUPERSEDED）。R① 免。
## ★審點
1. **★level-decouple 正確性（v2 命門）**：現 `fyield=level×FUY×flabor×harvest`、`flabor=fill×SCALE=alloc/(level×K_FARM)`→level 分子分母相消 labor-starved level-independent 確認？v2 解耦=`demand[farm]=level×K_FARM` **只作 alloc capacity cap 不除進 production**、`production=alloc×per-labor-yield`(level×FUY×harvest level 生效)→production ∝ level×alloc 正確？magnitude 不爆（FARM_UNIT_YIELD 2.0 正規化守）？
2. **T1 真邊際**：食物組合併 food_need(double-count keep)+組內 per-labor yield 分配 labor 流向高者、farm cap=level×K_FARM=真邊際非優先序常數？
3. 禁 crank / 4. 感知鐵律 / 5. T2 gather 產出對稱不受破 / 6. T3 估算器==production 同源 / 7. 補丁閘：解耦=移雙計 level 非貼補丁。
gate：production 隨 level 真升（核心治 level-cancellation）+share+B5+動員+守恆、fill%診斷非 gate。★**under-scope 兩次教訓、你特查有無漏第三處未跟上的 level 依賴**。待 R² CLEAN → dispatch。地基 KEEP。
