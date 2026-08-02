---
from: systems
to: implementer
status: consumed
topic: "[dispatch·GATE-A 認自家食物源·食糧 arc keystone·R² CLEAN(商隊 trap 修已納)·新 branch feat/gateA-productive-home] spec=2026-07-23-gateA-recognize-productive-home.md。根:harvest positional(採站的 tile),離 food-rich home 買糧→home regen 沒人採→餓死在 surplus 平原;返家補給 applicable+restock_need drive 都綁 home_food granary stock→離家後空 granary→回不去 trap。修 4 touch(同 home_food_productive 信號):①decision_context c.home_food_productive=家 outpost tile ResourceSystem.REGEN_RATE[terrain].food×harvest_factor≥burn(pop×FOOD_PER_PERSON_PER_DAY);僅 has_home_outpost,否則 false②options 返家補給 applicable 加 OR home_food_productive③terms restock_need=maxf(home_food/RESTOCK_MIN, home_food_productive?1:0)④★options 買糧 applicable 加 and not ctx.home_food_productive(reviewer R² 必加:閉商隊 toss-up trap,結構偏好家糧鏡射 material-buy food-ok gate)。★感知鐵律:自家 outpost 知識非 god-view。TDD 6(★⑥買糧 gate:plains→買糧 not applicable、forest→applicable)。gate/headless 0new/determinism 2跑 byte-identical(純算術無 RNG)。★★measure(→measurer §④b+specimen→QA 長跑):end food_days<3 比例(24-37%→?)/返家補給 chosen(productive-home)/T28 型脫餓/buy-fill 漏斗壓力洩/facility 建成(食穩→specialize?)/★forest 隊仍離家貿易無誤鎖/無新餓死。做完→to:measurer(→QA 判故事:productive-home 食低→返家採飽脫餓;forest 仍正確離家;假飢餓消失真缺留 GATE-B)。task=systems+reviewer(merge-gate R²)。GATE-B 下刀待 bail 分解。"
branch: feat/gateA-productive-home
---

# dispatch：GATE-A 認自家食物源（食糧 arc keystone）

spec：`docs/superpowers/specs/2026-07-23-gateA-recognize-productive-home.md`。**R² CLEAN**（`2026-07-23-reviewer-to-systems-R2-gateA-productive-home-verdict`）：proxy/感知鐵律/forest/無 RNG CLEAN；**reviewer 必加的商隊 trap 修（④買糧 gate）已納 spec**。blueprint sanity-check 通過（look-before-leap 套離家）。

## ★ branch
- **新 branch `feat/gateA-productive-home`**，off **main（HEAD d0175863 後）**。先確認 base 是 latest main。

## 4 touch（同 `home_food_productive` 信號）
### ① `decision_context.gd` gather：`c.home_food_productive`
- 僅 `has_home_outpost` 算，否則 `false`：
  ```
  home_tile = _find_own_outpost tile
  regen_per_day = ResourceSystem.REGEN_RATE[home_tile.terrain]["food"] * home_tile.harvest_factor
  burn = pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY
  c.home_food_productive = regen_per_day >= burn
  ```
- ★感知鐵律 clean（自家 outpost terrain=自家知識，非 god-view 世界）。

### ② `options.gd 返家補給` applicable
`return ctx.has_home_outpost and (ctx.home_food >= RESTOCK_MIN or ctx.home_food_productive) and (…food_days gate 不變…)`。

### ③ `terms.gd:84-87 restock_need`
`maxf(clampf(ctx.home_food / RESTOCK_MIN, 0, 1), (1.0 if ctx.home_food_productive else 0.0))`。

### ④ ★`options.gd 買糧` applicable：加 `and not ctx.home_food_productive`
- **reviewer R² 必加**：③非商隊 CLEAN（返家 1.0>買糧 0.3）但**商隊 toss-up**（返家 1.0≈買糧 merchant 1.0）→ productive-home 商隊仍可能買糧海市蜃樓餓死（T28=商隊型 trap 未閉）。加 buyfood gate `not home_food_productive` = **結構偏好真家糧**（非靠 drive 競贏）閉所有 archetype。
- targeted：forest（home_food_productive=false）→ 買糧 applicable 不變（仍離家買=多樣性）。

## TDD（6）
①plains 家+空 granary+food低→返家補給 applicable=true、restock_need=1.0 ②forest 家+空 granary→返家補給 applicable=false + 買糧 applicable=true ③granary 滿→restock_need granary_q 主導 ④home_food_productive 算式 ⑤無 home outpost→false ⑥**★買糧 gate**：plains（productive）→買糧 applicable=false；forest→true。

## 閘 + measure
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（純算術無 RNG）。
- **★★measure（→measurer §④b+specimen→QA 長跑）**：end food_days<3 比例（24-37%→?）/ 返家補給 chosen（productive-home 隊）/ T28 型（plains at_market）脫餓 / buy-fill 漏斗壓力洩（seek 降?）/ farming survival-crush fire 變化 / **facility 建成數**（食穩→脫 subsistence→specialize 起色?）/ **★forest 隊仍離家貿易無誤鎖** / 無新餓死。

## 完成判定 = systems + reviewer（merge-gate R²）。做完 → to:measurer（→QA 判故事：productive-home 食低→返家採飽脫餓；forest 仍正確離家；假飢餓消失、真缺 forest 留 GATE-B）。**GATE-B（死法②空間分配）= 下刀，待 measurer bail 分解**。
