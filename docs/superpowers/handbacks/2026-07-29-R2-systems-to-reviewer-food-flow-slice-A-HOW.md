---
from: systems
to: reviewer
status: consumed
topic: "[R²·糧流感知 SLICE A(存活持守)HOW·規模誠實後(harvest-only,延後打獵EV/投影器/派遣到B)·★persist×safe_ratio交互講死(乘法縮放非硬塌避PROGRESSIVE_HOLD attrition→0 regression血證/5種無ETA task排除/人格ratio_floor餘裕根治team14 nuance/抖動hysteresis)·spec=2026-07-29-food-flow-slice-A-survival-hold-HOW.md] SLICE A HOW done。★你上輪R①要求persist×safe_ratio講死已補。硬檢別重蹈world regression。"
branch: main (spec only)
---

# R²：糧流感知 SLICE A（存活持守）HOW 設計審

spec：`docs/superpowers/specs/2026-07-29-food-flow-slice-A-survival-hold-HOW.md`。R① 收窄後（SLICE A=消費者①存活持守，harvest-only，延後打獵 EV/投影器/派遣到 B/C）。

## 核心（審這些，★你 R① 要求講死的都補了）
1. **糧流感官 harvest-only**（§2）：net=inflow−burn、runway、inflow=可持續內生（自家 outpost 真 collection + 當前 tile 可持續採，**延後打獵 EV 到 B**）、每日算快取。
2. **safe_ratio 只對有 ETA task**（§3）：TASK_BUILD 真 ticks ETA；**5 種無 ETA（CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE）排除**走原 persist。
3. **★persist×safe_ratio 講死**（§4，你 R① 硬要求）：
   - (a) **乘法縮放非硬門檻塌**（`persist_eff = persist × safe_factor`）——★理由=PROGRESSIVE_HOLD 硬擋全 committed→attrition→0 向凍 regression 血證，硬塌=向凍，乘法連續避全體同時塌。
   - (b) safe_factor 人格 ratio_floor 餘裕：務實 floor 高早放/固執 floor 低撐久=**team14 nuance 根治**（非全體撐 food=0，人格分化）。
   - (c) 5 task 排除。(d) 抖動 hysteresis + 日 cadence。

## ★reviewer focus（refute，異質，別重蹈 world regression）
1. **★★乘法縮放真避 regression 否**：`persist_eff = persist × safe_factor` 連續降 vs PROGRESSIVE_HOLD 硬擋——真避「全體同時塌向凍」否？safe_factor=0（見底）時 persist_eff=0 放手，這對否（vs 硬塌）？
2. **人格 ratio_floor 根治 team14 nuance 否**：務實 floor 高早放/固執 floor 低撐久——真解「無安全餘裕」（人格分化非全體撐 food=0）？ratio_floor 人格 mapping 合理否？
3. **5 task 排除對否**：只 TASK_BUILD 有真 ETA、其餘 5 走原 persist——這排除對否（vs 硬給 proxy 誤導）？
4. **safe_ratio 公式**：`runway/ETA_days`、runway=food/max(−net,ε)——net 正=∞ runway 對否？ETA_days 來源（persist_strength:51-61 只 TASK_BUILD）真接得上否？
5. **★世界不凍 + 憲法**：乘法縮放/危機在 persist 前/內生-only/接 tap 禁 RNG——latch/regression 反例真避開否？
6. **regression 血證同組 code**：safe_ratio 調 persist 是碰同一組剛出過 world regression 的 code（task_arbiter/persist_strength）——講死夠否、還有沒有範圍/門檻沒講清楚的洞？

**CLEAN → implementer SLICE A → measurer specimen-off → QA team14 根治稽核 → SLICE B。** 有洞/翻設計 → 回 `to:systems`（R① 翻回 blueprint，R² 設計洞我改）。用異質 + 明確 refute。
