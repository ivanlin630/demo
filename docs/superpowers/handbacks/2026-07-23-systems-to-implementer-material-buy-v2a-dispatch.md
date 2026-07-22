---
from: systems
to: implementer
status: consumed
topic: "[dispatch·material-buy v2a·full build-need+買料util校正+food-ok gate·R² CLEAN(結構guard已納)·★接 v1 branch feat/material-buy 續·decisive] spec=2026-07-23-material-buy-v2a-full-need-utility.md。v1(ca199844)QA判半破(want接但buy-to-80未達)。★★接 feat/material-buy branch 續(非新branch,①③疊v1上,完整才merge)。reviewer R² ①CLEAN+②結構要求已納:修①need_oracle _construction_facility_need line `total+=cost_mat*desire`→`total+=cost_mat`(desire已當gate,過閘全cost 80非稀釋24;cap 100仍在)②terms.gd buymaterial_drive現shortfall band太低→繫construction迫切(shortfall/CAP × max _facility_deficit,買料util≈建設前置;穿人格保留)③★★options.gd「買料」applicable加`ctx.food_days >= DecisionTerms.DESPERATION_DAYS`(food-ok gate,鏡射買糧food<DESPERATION互斥=結構防餓隊買料餓死;買料非survival-class,util高無food-gate會搶survival rank害餓死→加此gate結構擋)。TDD 4型(need full 80/cap/drive升/★food-ok gate:food<DESP不applicable、food>=DESP applicable)。gate/headless 0new/determinism 2跑byte-identical無RNG。★★measure帶§④b+specimen→QA(長跑新規則):material buy DEAL/no_want率(72→?)/買料勝率(1.7→?)/有-coin mil隊buy-to-80達成/weaponsmith建成/★無餓死回歸(food-ok gate驗)/doom-delta。②coin=下slice(mil coin貧困,①③measure確認唯一剩blocker)。task=systems+reviewer。做完→to:measurer(→QA)。"
---

# dispatch：material-buy v2a（full build-need + 買料 util 校正 + food-ok gate）

spec：`docs/superpowers/specs/2026-07-23-material-buy-v2a-full-need-utility.md`。v1（ca199844）QA 判半破。reviewer R² ①CLEAN + ②結構 guard（food-ok）**已納**。

## ★★ branch base
- **接 `feat/material-buy` branch 續**（v1 ca199844 上疊 ①③，**非新 branch**；①③完整才 merge）。off LOCAL。

## 修（①③ 疊 v1）
### ① full build-need（`need_oracle._construction_facility_need`）
`total += cost_mat * desire` → **`total += cost_mat`**（desire 已在上方 `if desire < CONSTRUCTION_DESIRE_MIN: continue` 當 gate；過閘=夠想建→全 cost 80，非稀釋 24=白買）。cap（100）仍在。

### ② buymaterial_drive 校正（`terms.gd`）
現 shortfall band 太低（1.7% 勝率）→ 繫 construction 迫切：`buymaterial_drive` = `material_shortfall/CAP × max _facility_deficit(team,material-facility)`（想建強+缺料多→競得過建設）。weight「buymaterial」穿人格保留。

### ③ ★★food-ok gate（`options.gd` 買料 applicable，reviewer 結構要求）
```gdscript
"買料": { "applicable": func(ctx): return ctx.food_days >= DecisionTerms.DESPERATION_DAYS \
    and ctx.material_shortfall > 0.0 and ctx.has_material_market and ctx.has_specie, ... }
```
- **★理由**：買料非 survival-class（`SURVIVAL_OPTION_SET` 不含）→ util 高會搶 survival rank；餓隊買料 util 若 > 買糧/覓食 → **餓死**。加 `food_days >= DESPERATION_DAYS` gate（**鏡射買糧的 `food < DESPERATION` = 互斥**）→ 餓時只買糧、食足才買料 = 結構防餓死。

## 驗收（4 型 + measure）
- **TDD 4**：①need full 80 ②cap ③drive 升 ④**★food-ok gate**（food<DESP→買料 not applicable / food>=DESP→applicable）。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG）。
- **★★measure（→measurer，§④b+specimen→QA 長跑新規則）**：material buy DEAL / no_want（72→?）/ 買料勝率（1.7→?）/ 有-coin mil 隊 buy-to-80 達成 / weaponsmith 建成 / **★無餓死回歸（food-ok gate 驗）** / doom-delta。送 QA 判故事。

## ②coin = 下 slice
mil coin 貧困（loot→anon_treasury 不流 team.coin）→ ①③ measure 確認 coin 唯一剩 blocker → v2b。

## 完成判定 = systems + reviewer。做完 → to:measurer（→QA）。
