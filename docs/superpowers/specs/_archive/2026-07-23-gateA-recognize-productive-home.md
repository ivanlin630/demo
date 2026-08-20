# spec：GATE-A — 認自家食物源（返家補給看 home tile 產能非只 granary stock）

> 層級：L3（3 touch，決策模型 measure-sensitive）。off main（食糧 arc keystone）。
> 來源：食糧地方安全 arc，GATE-A（positional-harvest 離家棄產，假稀缺主體）。blueprint sanity-check 通過 + 授權（`...-gateA-framing-sanitycheck-approved`）：= 2026-07-14 look-before-leap 原則套到「要不要離家」；**只糾正「home 其實夠但沒認出來」specific mismatch，非強制全隊留家**（forest 真養不活隊仍正確離家/貿易）。
> ★keystone：連 desperation-economy/武器/goods 全 meta-pattern。

## 根（file:line 坐實）
- **harvest positional**：`resource_system:53,71-76` 採隊**站的** tile；food regen→tile pool（:88-92）非 granary；farming_level 只是採集乘子（:268 需在場）。→ 離 food-rich home 買糧 → home regen 沒人採、granary 恆 0 → 餓死在 surplus 平原（T28：at_market/granary 0/plains regen 12.8≫burn 4.8）。
- **返家補給 被 granary-empty 閘擋**：`options.gd:74-86` applicable = `home_food >= RESTOCK_MIN`（空家不返，原意=forest 空家別回乾耗）+ `terms.gd:84-87 restock_need = home_food/RESTOCK_MIN`（drive 也綁 granary stock）。→ **離家後 granary 空 → 返家補給 both applicable=false（或 drive≈0）→ 回不去 → granary 恆空**（trap：空 granary→不返→granary 恆空）。**閘無法區分「空 granary 且 tile 貧」（forest，別返=對）vs「空 granary 但 tile 產得起」（plains，該返採=被誤擋）**。

## 修（3 touch，look-before-leap：認家門口真糧非市場海市蜃樓）
### ① `decision_context.gd` gather：加 `c.home_food_productive`
- `home_food_productive` = 家 outpost tile 的 sustainable food regen ≥ 隊 burn：
  ```
  if not has_home_outpost: c.home_food_productive = false
  else:
    home_tile = _find_own_outpost tile
    regen_per_day = ResourceSystem.REGEN_RATE[home_tile.terrain]["food"] * home_tile.harvest_factor
    burn = pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY
    c.home_food_productive = regen_per_day >= burn
  ```
- ★感知鐵律 clean：隊**擁有**自家 outpost、知自家 tile terrain/產能（非 god-view 世界；自家知識）。
- proxy：sustainable harvest ≈ regen（steady state 池 harvest=regen）；plains 12.8≥4.8 ✓、forest 4.7<5.6 ✗ = 乾淨分離確認案例。measure 驗 proxy。

### ② `options.gd:80-83 返家補給` applicable：granary OR 家 tile 產得起
```gdscript
return ctx.has_home_outpost \
    and (ctx.home_food >= DecisionTerms.RESTOCK_MIN or ctx.home_food_productive) \
    and ( (ctx.is_merchant and ctx.food_days < DecisionTerms.RESTOCK_DAYS) \
          or ctx.food_days < DecisionTerms.DESPERATION_DAYS )
```

### ③ `terms.gd:84-87 restock_need` drive：反映家產能非只 granary stock
```gdscript
"restock_need":
    if opt != "返家補給": return 0.0
    var granary_q: float = clampf(ctx.home_food / RESTOCK_MIN, 0.0, 1.0)
    var productive_q: float = 1.0 if ctx.home_food_productive else 0.0   # 家 tile 產得起→返家採=高值(即使 granary 空)
    return maxf(granary_q, productive_q)
```
- ∴ home productive → restock_need=1.0 → 返家補給 drive 高 → out-rank 買糧（**非商隊**：買糧 buyfood 0.3×0.5-1.0=0.15-0.3 vs 返家 1.0×1.0=1.0 → 返家勝）。

### ④ ★`options.gd 買糧` applicable：加 `and not ctx.home_food_productive`（reviewer R² 必加，閉商隊 trap）
```gdscript
"買糧": { "applicable": func(ctx): return ctx.food_days < DecisionTerms.DESPERATION_DAYS \
    and ctx.has_food_market and ctx.has_specie and ctx.has_buyable_food \
    and not ctx.home_food_productive,   # ★home 產得起→別買市場海市蜃樓,結構偏好真家糧(鏡射 material-buy food-ok gate)
    ... }
```
- **★為何必加（reviewer R²）**：③ 返家 out-rank 買糧 **非商隊真**（1.0 > 0.3）；但**商隊 toss-up**（返家 survival_pressure 1.0 ≈ 買糧 merchant buyfood 1.0×drive）→ productive-home **商隊**仍可能選 買糧 海市蜃樓餓死（**T28 at_market=商隊型 trap 未閉**）。∴ 加 buyfood gate `not home_food_productive` = **結構偏好真家糧**（非靠 drive 競贏），閉所有 archetype trap。
- targeted：forest（home_food_productive=false）→ 買糧 applicable 不變 → 仍正確離家買/貿易（多樣性保）。

## 為何 look-before-leap + 不傷多樣性
- 返家補給（回真家糧/採產能）競過 買糧（GATE-B 常買不到=海市蜃樓）——認家門口真糧。
- **forest 真養不活**（regen<burn）→ home_food_productive=false → ②③不變 → 仍走 買糧/貿易/遷移（正確離家）。**只糾正 productive-home-abandoned mismatch**。

## 驗收
- **TDD**：①plains 家（regen≥burn）+空 granary+food低 → 返家補給 applicable=true、restock_need=1.0 ②forest 家（regen<burn）+空 granary → 返家補給 applicable=false + **買糧 applicable=true**（不變，走買糧=多樣性）③granary 滿 → restock_need 照舊（granary_q 主導）④home_food_productive 算式（regen×harvest_factor vs burn）⑤無 home outpost → home_food_productive=false ⑥**★買糧 gate**：plains 家（home_food_productive=true）→ 買糧 applicable=**false**（結構偏好家糧，閉商隊 trap）；forest → 買糧 applicable=true。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（純算術，無 RNG）。
- **★★measure（→measurer §④b+specimen→QA 長跑）**：end-state food_days<3 比例（24-37%→?）/ 返家補給 chosen 數（productive-home 隊）/ T28 型隊（plains at_market）是否返家脫餓 / buy-fill 漏斗壓力洩（seek 數降?）/ farming survival-crush fire 變化 / **facility 建成數**（食穩→脫 subsistence→specialize 有無起色）/ 回歸：forest 隊仍離家貿易（無誤鎖家）+ 無新餓死。
- **送 QA 判故事**：productive-home 隊食低→返家採飽→脫餓 coherent；forest 隊仍正確離家；假飢餓消失、真缺（forest）留給 GATE-B。

## 排序
GATE-A 一刀（3 touch 同 home_food_productive 信號）。R²（home_food_productive proxy regen-vs-burn 準嗎/感知鐵律 自家知識/restock_need max 語意/返家補給 是否真 out-rank 買糧[或需 buymfood gate]/forest 不誤鎖/無 RNG）→ dispatch。GATE-B（死法②空間分配）= 下刀，待 measurer bail 分解 + GATE-A measure。
