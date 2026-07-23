---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·GATE-A productive-home·issues(③商隊 out-rank gap)] ①proxy CLEAN(regen×harvest_factor=tile regen,regen≥burn 準 sustainable)②感知鐵律 CLEAN(自家 tile 知識)④forest 不誤鎖 CLEAN⑤無 RNG。★③返家 out-rank 買糧:非商隊 CLEAN(返家 1.0 > 買糧 0.3),但★商隊 toss-up(返家 survival_pressure 1.0 ≈ 買糧 merchant buyfood 1.0×drive)→productive-home 商隊可能仍買糧海市蜃樓餓死(T28 at_market=商隊型 trap 未閉)。spec「不需 gate 買糧」對非商隊真、商隊 over-stated。要求 gate 買糧 when home_food_productive(結構偏好真家糧,鏡射 material-buy ②)。"
---

# R² verdict：GATE-A 認自家食物源（productive-home）

**VERDICT: issues（③ 商隊 out-rank gap）** — ① proxy / ② 感知鐵律 / ④ forest 不誤鎖 / ⑤ 無 RNG 全 CLEAN；但 **③「返家 out-rank 買糧」對商隊不成立（toss-up），T28 型（at_market 商隊）trap 未閉**。`premise_contradiction: false`。factcheck 對 HEAD `d0175863`。

## Root 坐實
harvest positional（`resource_system:88 food_regen=REGEN_RATE[terrain].food × harvest_factor`，採站的 tile）→ 離 food-rich home 買糧→home regen 沒人採→granary 恆 0→餓死 surplus 平原。返家補給被 granary-empty 閘擋（`options:80 home_food≥RESTOCK_MIN` + `terms:87 restock_need=home_food/RESTOCK_MIN`）→ 空 granary→不返→granary 恆空 trap；閘無法區分「forest 空且貧（別返=對）」vs「plains 空但產得起（該返=誤擋）」。坐實。

## 審點逐一

1. **★① home_food_productive proxy → CLEAN**。`REGEN_RATE[terrain].food × harvest_factor ≥ pop × FOOD_PER_PERSON_PER_DAY`。親驗 `resource_system:88`：tile food regen **就是** `REGEN_RATE × harvest_factor`。sustainable harvest ≈ regen（steady-state 池 harvest=regen，取不過 regen）→ **regen≥burn = 隊在家 positional-harvest 採得到 ≥ burn**（食就在 tile，在場採到）。plains 12.8≥4.8✓/forest 4.7<5.6✗ 乾淨分離。harvest_factor 動態（季節 0.1-2.0）→ 反映當前產能，合理。proxy 準。

2. **② 感知鐵律 → CLEAN**。隊**擁有**自家 outpost、知自家 tile terrain/harvest_factor（自家知識，非 god-view 世界掃）。乾淨。

3. **★★③ 返家 out-rank 買糧 → 非商隊 CLEAN，商隊 toss-up（issue）**。
   - 返家補給（`options:75`）= `[restock_need, survival_pressure]`；**survival_pressure=1.0**（`terms` 常數，T1-normalized）；fix 後 **restock_need=max(granary_q, 1.0 if productive)=1.0** → **返家 util=1.0**（productive home）。
   - 買糧（`:238`）= `[buyfood_drive, buyfood]`；**buyfood weight=`1.0 if merchant else NON_MERCHANT_TRADE_FACTOR(≈0.3)`**。
   - **非商隊**：買糧 util=0.3×buyfood_drive ≤ 0.3 < 返家 1.0 → **返家結構勝** ✓。
   - **★商隊**：買糧 util=**1.0**×buyfood_drive；food-crisis+市場+coin→buyfood_drive≈1.0 → **買糧≈1.0 ≈ 返家 1.0 = toss-up**（commitment bonus/tie-break 決）→ **productive-home 商隊可能仍選買糧**（GATE-B 常買不到=海市蜃樓）→ **餓死在 productive home（T28 trap 對商隊未閉）**。
   - **spec「不需 gate 買糧（返家競贏）」對非商隊真、對商隊 over-stated**。**T28 血證=at_market（商隊型行為）**——正是最可能買糧的類→leaving merchants in toss-up 削弱 keystone（該類正是要救的）。
   - **★要求**：**gate 買糧 when `home_food_productive`**（或 buyfood_drive × (1−home_food_productive)）→ productive-home 隊（含商隊）**結構偏好返家真家糧非市場海市蜃樓**。鏡射 material-buy ② 的結構求生主宰（別靠 weight 磁量 toss-up）。這樣返家對全隊型結構競贏。

4. **④ forest 不誤鎖家 → CLEAN**。forest regen(4.7)<burn(5.6)→home_food_productive=false→②③不變→仍走買糧/貿易/遷移（正確離家）。只糾 productive-home-abandoned mismatch，不傷多樣性。✓

5. **⑤ 無 RNG → CLEAN**。純算術（regen/burn 比、term 常數）。determinism 保。

## 回覆
issues（③商隊）→ ①②④⑤ CLEAN、方向對（look-before-leap 認家門真糧），一要求：
- **gate 買糧（或 drive 抑制）when home_food_productive** → 全隊型（含商隊）結構偏好返家。否則 T28 型 at_market 商隊仍 toss-up 買糧→海市蜃樓餓死，keystone 對主要 trap 類未閉。
- 或：measure 先驗商隊在 productive-home 是否仍 trap；若是→加 gate（但我建議直接結構 gate，血證已指商隊型）。
改好回 R²（尤商隊 out-rank 結構化）→ dispatch。

——③ 同 material-buy ② 家族：**經濟 option（買糧/買料）vs 真求生（返家/覓食）的競爭，對商隊（經濟 weight 1.0）靠 weight 磁量=toss-up=脆**。結構 gate（productive-home→不買糧、food-crisis→不買料）=真家糧/真求生**結構壓過市場海市蜃樓**，非 tuning-luck。keystone 該對全隊型閉 trap。[[feedback_symptom_vs_root_retry]]。
