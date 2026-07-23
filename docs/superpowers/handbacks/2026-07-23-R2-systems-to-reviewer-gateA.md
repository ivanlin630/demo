---
from: systems
to: reviewer
status: open
topic: "[R²·GATE-A 認自家食物源·食糧 arc keystone·look-before-leap 套離家決策] spec=2026-07-23-gateA-recognize-productive-home.md。根:harvest positional(採站的 tile),離 food-rich home 買糧→home regen 沒人採→餓死在 surplus 平原(T28);返家補給被 granary-empty 閘擋(applicable+restock_need drive 都綁 home_food granary stock→離家後 granary 空→回不去=trap,無法區分 forest 空且貧 vs plains 空但產得起)。修 3 touch(同 home_food_productive 信號):①decision_context c.home_food_productive=家 tile regen(REGEN_RATE[terrain].food×harvest_factor)≥burn(pop×FOOD_PER_PERSON)②返家補給 applicable 加 OR home_food_productive③restock_need drive=maxf(granary_q, home_productive?1:0)→home productive→drive 1.0→out-rank 買糧→返家 TASK_RETURN_HOME→被動採脫餓。★核審:①home_food_productive proxy(regen≥burn 準嗎,sustainable harvest≈regen 對嗎)②感知鐵律(自家 outpost terrain=自家知識非 god-view)③返家補給 真 out-rank 買糧?(非商隊 buyfood weight 0.3 → 返家 survival 1.0 應勝;商隊 1.0 需驗)——若不勝需否 gate 買糧?④forest(regen<burn)不誤鎖家(home_food_productive=false→②③不變仍離家=多樣性)⑤無 RNG。blueprint 認可 framing(look-before-leap 延伸,只糾 mismatch 非強制留家)。CLEAN→dispatch(feat/gateA-productive-home)。measure→QA。GATE-B 下刀。"
---

# R²：GATE-A 認自家食物源（食糧 arc keystone）

spec：`docs/superpowers/specs/2026-07-23-gateA-recognize-productive-home.md`。blueprint sanity-check 通過（look-before-leap 套「離家」決策，只糾「home 夠但沒認出」mismatch，非強制留家）。

## 根
- harvest positional（`resource_system:53,71-76` 採站的 tile，regen→tile pool 非 granary）→ 離 food-rich home 買糧 → home regen 沒人採 → 餓死在 surplus 平原（T28 plains regen12.8≫burn4.8/granary 0）。
- 返家補給（`options:80` applicable + `terms:84 restock_need`）**都綁 `home_food` granary stock** → 離家後 granary 空 → 返家補給 both 掛 → **回不去（trap）**。閘無法區分 forest（空且貧，別返=對）vs plains（空但產得起，該返採=被誤擋）。

## 修（3 touch，同 `home_food_productive` 信號）
- ① `decision_context` `c.home_food_productive` = 家 tile regen（`REGEN_RATE[terrain].food × harvest_factor`）≥ burn（pop × FOOD_PER_PERSON_PER_DAY）。
- ② 返家補給 applicable：`home_food >= RESTOCK_MIN OR home_food_productive`。
- ③ `restock_need` drive：`maxf(home_food/RESTOCK_MIN, home_food_productive ? 1.0 : 0.0)`。

## ★核審點
1. **home_food_productive proxy**：`regen≥burn` 準嗎？sustainable harvest ≈ regen（steady-state 池 harvest=regen）對嗎？（plains 12.8≥4.8 / forest 4.7<5.6 乾淨分離確認案例；marginal 案例 measure 驗）。
2. **★感知鐵律**：`home_food_productive` 讀**自家 outpost** terrain/regen = 自家知識（隊擁有自家 outpost）非 god-view 世界——clean 嗎？
3. **★返家補給 真 out-rank 買糧嗎？**（關鍵：applicable 但排不上=白修）。非商隊：買糧 buyfood weight 0.3×base(0.5-1.0)=0.15-0.3 vs 返家補給 survival_pressure 1.0×restock_need(1.0)=1.0 → 返家勝。**商隊**：買糧 1.0×(0.5-1.0) vs 返家 1.0×1.0 → 返家 ≥。驗此推算；若不勝 → 是否需加 買糧 look-before-leap gate（home_productive→買糧 not applicable）？
4. **forest 不誤鎖家**：regen<burn → home_food_productive=false → ②③不變 → 仍走買糧/貿易/遷移（正確離家=多樣性保）。
5. **無 RNG**（純算術）。

## 回覆
`to:systems`：CLEAN / 修正（尤 ③ranking 是否真勝、proxy 準度）。CLEAN → dispatch（新 branch `feat/gateA-productive-home`）。measure 帶 §④b+specimen→QA（food_days<3 比例/返家 chosen/T28 脫餓/buy-fill 壓力洩/forest 不誤鎖）。GATE-B（死法②空間分配）= 下刀，待 bail 分解。
