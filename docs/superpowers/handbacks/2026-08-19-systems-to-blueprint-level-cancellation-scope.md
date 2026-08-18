---
from: systems
to: blueprint
status: open
topic: "[re-spec前深層發現須你確認scope(1st失敗因under-scope、避3rd)·★level-cancellation CONFIRMED(formula精確驗):farm production=fyield=level×FARM_UNIT_YIELD×flabor×harvest、flabor=labor_mult(farm)=fill×SCALE=alloc/(level×K_FARM)×SCALE→level分子(yield)與level分母(demand内fill)相消→labor-starved(fill<1、正是farm常態21%)時fyield=FARM_UNIT_YIELD×alloc×SCALE×harvest/K_FARM=LEVEL-INDEPENDENT·意思:發展farm於labor-starved完全不增production(demand=level×K_FARM抵銷yield的level)、只有滿飽和fill=1時level才生效(但farm從不飽和)·★∴你『production隨level升』gate用allocation單獨達不到:(a)真邊際分配無論怎麼分、只要production仍走level×fill(fill=alloc/level×K_FARM)、level就抵銷·★(a)『繞開demand-cap』的真義=farm production從fill/demand機制解耦:production=farm_alloc×per_labor_yield(per_labor_yield=level×FARM_UNIT_YIELD×harvest真level-dependent、發展farm每勞力真更產)→level不再抵銷+邊際分配讓高yield farm拿多份=雙贏·★但這比純allocation大:碰農業a farm_yield產出公式(resource:106)+估算器(farm_yield建模)+labor_mult語意·★確認scope:labor-slice v2=①食物工位真邊際分配②★farm production解耦fill/demand=alloc×per-labor-yield(level生效)③估算器同步·我lean這是唯一能達你production-隨-level gate的路(demand饱和你已否、但問題根是level雙計:yield有level+demand有level相消、解耦是移demand側的level不是貼補丁)·你確認scope(含production公式改)→我re-spec v2→R²·labor-slice HOLD·農業b/perf平行·地基KEEP"
---

# re-spec 前深層發現須你確認 scope（1st 失敗因 under-scope、避 3rd）

## ★level-cancellation CONFIRMED（formula 精確驗 resource:106 + labor_system）
`fyield = level × FARM_UNIT_YIELD × flabor × harvest`；`flabor = labor_mult(farm) = fill×SCALE = alloc/(level×K_FARM)×SCALE`。
→ **level 分子(yield) 與 level 分母(demand 内 fill) 相消** → labor-starved(fill<1、farm 常態 21%)時 `fyield = FARM_UNIT_YIELD × alloc × SCALE × harvest / K_FARM` = **LEVEL-INDEPENDENT**。
- 發展 farm 於 labor-starved **完全不增 production**（demand=level×K_FARM 抵銷 yield 的 level）；只有 fill=1 飽和 level 才生效（但 farm 從不飽和）。

## ★∴「production 隨 level 升」gate 用 allocation 單獨達不到
(a) 真邊際分配**無論怎麼分**、只要 production 仍走 `level×fill`（fill=alloc/(level×K_FARM)）、level 就抵銷。

## ★(a)「繞開 demand-cap」真義=farm production 從 fill/demand 解耦
`production = farm_alloc × per_labor_yield`（per_labor_yield=level×FARM_UNIT_YIELD×harvest 真 level-dependent、發展 farm 每勞力真更產）→ **level 不再抵銷 + 邊際分配讓高 yield farm 拿多份=雙贏**。

## ★但比純 allocation 大（scope 須你確認）
碰農業a farm_yield 產出公式（resource:106）+ 估算器（farm_yield 建模）+ labor_mult 語意。
- **labor-slice v2=①食物工位真邊際分配 ②★farm production 解耦 fill/demand=alloc×per-labor-yield(level 生效) ③估算器同步**。
- 我 lean 這是唯一達你 production-隨-level gate 的路。demand 饱和你已否、但**問題根是 level 雙計**（yield 有 level + demand 有 level 相消）、**解耦=移 demand 側的 level 不是貼補丁**（是修雙計）。

★你確認 scope（含 production 公式改）→ 我 re-spec v2 → R²。labor-slice HOLD。農業b/perf 平行。地基 KEEP。
