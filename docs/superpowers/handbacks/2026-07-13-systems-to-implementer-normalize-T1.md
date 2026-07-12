---
from: systems
to: implementer
status: open
topic: [dispatch·S2.7 T1] term-scale normalize survival-class——R②CLEAN,逐bucket first bucket
---

# Dispatch：term-scale normalize T1（survival-class）

R②CLEAN(`term-scale-normalize-r2-verdict`,含真公式重算優先序保全 6.65×+邊界無斷崖)。spec `docs/superpowers/specs/2026-07-13-term-scale-normalize.md`。**逐 bucket dispatch，本次只 T1**（survival-class，先驗回歸再放 T2）。

## 核心不變量（全 T 共通）
`util = weight(人格,0-1.5) × eval(執行品質,0-1) × coeff(需求,0.15-1)`。**base eval 剝 urgency 乘子(移 coeff)、保 quality 因子、值域 [0,1]**。

## T1 做什麼（`terms.gd` eval，改這 7 term；spec per-term 表有新公式）
- `survival_pressure`(覓食)：`4×(3−food)` → **`1.0`**（覓食=survival 預設可行；飢餓→L_SURVIVAL coeff）。
- `restock_need`(返家補給)：→ `clampf(ctx.home_food/RESTOCK_MIN,0,1)`。
- `threat_pressure`(survival/FLEE)：`threat+panic×0.5` → `clampf(0.6+ctx.team_panic×0.4,0,1)`（威脅→L_SAFETY coeff）。
- `buyfood_drive`(買糧)：`hunger×dist_disc` → **只留 `dist_disc`**。
- `beg_drive`(乞食)：→ `BEG_FLOOR_FACTOR`(0.5) 定值。
- `camp_drive`(紮營)：`1.2×hunger` → **`1.0`**。
- `join_drive`(併入)：`1.2×max(hunger,threat)×magnet` → `clampf(0.5+ctx.best_protector_rep×REP_MAGNET_W×0.5,0,1)`。
- `occupy_drive`(佔村)：`1.2×(1/0.3)` → `1.0 if not ctx.has_own_outpost else 0.3`（base 1.2→1.0）。

## 硬約束
- **剝淨 urgency**：改完 grep eval 內殘留 `food_days`/`(3`/`DESPERATION_DAYS −`/`RESTOCK_DAYS −` 乘子（除品質因子 dist_disc/home_food/magnet 外應剝淨）。
- **值域 [0,1]**：每 term TDD 斷言 eval 落 [0,1]（典型輸入）。
- **零 randf**、逐 term commit。
- **不動** threat 人格 term(prepare/defend/pacify)、ambient(T2/T3 才動)、faction_duty(§7 例外)。

## TDD（headless_test.gd）
`_test_term_normalize_t1`：7 term 各構典型 ctx，斷言 eval∈[0,1]（如覓食恆 1.0、買糧=dist_disc≤1、乞食=0.5、併入≤1）。

## 回報 → measurer（T1 organic 先驗回歸，再放 T2）
7 term 完 + 融合閘綠 → handback to:measurer，請 organic 驗：
- **survival-dominance 保全**：餓隊(food低)仍選覓食類、TC2 survival-input(糧0→survival-class)不回歸、**半餓隊不亂跑貿易**（R② 邊界驗過,organic 複核）。
- **9-zero 部分 lift**：買糧/乞食/併入/紮營 選中率是否↑（per-option probe）。
- **determinism** byte-identical。
有 blocker(優先序保全 organic 翻/回歸)→ to:systems，別自改。守：不動他 bucket、不 pre-tune、不問 user。
