---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN+1較重必查項(食物帳before/after量化gate缺)+1設計建議(乘法非加法)] settlement農業(獨立生產線+⑥據點放大器)HOW——★大經濟改親驗三條最要害premise:①farm_yield chokepoint親grep全scripts/零命中,確認『未建』屬實②親讀resource_system.gd:289逐字確認gain*=(1.0+float(src_tile.farming_level)*0.5)——這行在:280『gain=採集productivity×current×COLLECT_RATE×day_fraction』(野地池採集公式)內部,farming_level目前100%是gather乘數、非獨立產線,drift診斷精確坐實③親讀team_data.gd:48-49 pop_cap_from_leadership(skill)確認clampi(round(49×min(skill/0.8,1))+1,1,50)只吃leadership skill單一參數,零據點/settlement因子,『領導唯一、無據點放大』屬實;三條premise皆親驗精準,無citation問題;★較重必查項(審點②經濟擾動風險,這是這輪R②命門):spec §3 gate五項(雙源獨立/守恆可溯源/guns-vs-butter/放大器genuine/determinism)裡沒有一項是『移除既有gather乘數+新增獨立生產線後,聚合食物供給總量/居民food-security分佈,前後對比不能突然mass-starve或爆倉』這種量化淨效應檢查——目前的gate只驗證『兩套機制概念上獨立』跟『各自genuine非crank』,但沒有驗證『UNIT_YIELD這個新常數的量級校準得跟被移除的×(1+farming×0.5)乘數量級接近』,若UNIT_YIELD拍腦拍太低=淨食物供給驟降大量餓死,拍太高=糧食經濟被削弱意義;要求§3明確加一項『measurer聚合帳:全樹food production/team food-security分佈,drift正位前vs正位後對比,非只驗兩系統獨立,要驗總量級沒有意外暴衝或塌陷』;★設計建議(⑥放大器形式,spec自己開放議):建議乘法effective_pop_cap=leadership_base×amplifier非加法——這session已有的MarginalEconomy._inflow_est(outpost_mult×pop_mult×farming_bonus×...)是完全同款『據點/等級縮放乘性合成』的既有precedent,乘法讓『好領主+好據點』真的複合放大、『爛領主+好據點』不會靠據點單獨撐到跟好領主一樣的承載量,語意上更符合"據點是領導力的放大器"這個⑥ ruling原文字面表述,非只是『兩個都算但用加的』;L0不放大這條靠outpost_level=0天然乘數=1(既有S2a camp_level獨立flag設計已經確保L0沒有outpost_level>0)結構上自動成立不需額外code;④冗餘查/③禁crank/⑥守恆/⑦感知鐵律皆親驗合理;判決=CLEAN+1較重必查項(食物帳量化gate)+1設計建議(乘法)→農業a plan→dispatch"
---

# R②判決：settlement 農業（農田獨立生產線+⑥據點放大器）HOW — CLEAN + 1較重必查項

## ★大經濟改，親驗三條最要害 premise

**①farm_yield chokepoint 未建**：親 grep 全 `scripts/` 零命中，確認「未建」屬實。

**②drift 診斷精確**：親讀 `resource_system.gd:289` 逐字確認 `gain *= (1.0 + float(src_tile.farming_level) * 0.5)`——這行在 `:280`「`gain = 採集 productivity × current × COLLECT_RATE × day_fraction`」（野地池採集公式）內部，`farming_level` 目前 **100% 是 gather 乘數**、非獨立產線，drift 診斷精確坐實。

**③pop-cap 現況「領導唯一」**：親讀 `team_data.gd:48-49` `pop_cap_from_leadership(skill)` 確認 `clampi(round(49×min(skill/0.8,1))+1, 1, 50)` **只吃 `skill` 單一參數**，零據點/settlement 因子，「領導唯一、無據點放大」屬實。

三條 premise 皆親驗精準，無 citation 問題。

## ★較重必查項（審點②經濟擾動風險，這輪 R②命門）：缺聚合食物帳 before/after 量化 gate

spec `§3` gate 五項（雙源獨立/守恆可溯源/guns-vs-butter/放大器 genuine/determinism）裡**沒有一項**是「移除既有 gather 乘數+新增獨立生產線後，聚合食物供給總量/居民 food-security 分佈，前後對比不能突然 mass-starve 或爆倉」這種**量化淨效應檢查**。

目前的 gate 只驗證「兩套機制概念上獨立」跟「各自 genuine 非 crank」，但沒有驗證「`UNIT_YIELD` 這個新常數的量級，校準得跟被移除的 `×(1+farming×0.5)` 乘數量級接近」——若 `UNIT_YIELD` 拍腦拍太低=淨食物供給驟降、大量餓死；拍太高=糧食經濟被削弱意義（種田變成免費午餐）。**要求** `§3` 明確加一項：**measurer 聚合帳**——全樹 food production/team food-security 分佈，drift 正位前 vs 正位後對比，非只驗兩系統概念獨立，要驗總量級沒有意外暴衝或塌陷。

## ★設計建議（⑥放大器形式，spec 自己開放議）：建議乘法非加法

建議 `effective_pop_cap = leadership_base × amplifier` 非加法。這 session 已有的 `MarginalEconomy._inflow_est`（`outpost_mult × pop_mult × farming_bonus × ...`）是完全同款「據點/等級縮放乘性合成」的既有 precedent——乘法讓「好領主+好據點」真的複合放大、「爛領主+好據點」不會靠據點單獨撐到跟好領主一樣的承載量，語意上更符合⑥ ruling 原文「據點是領導力的放大器」這個字面表述，非只是「兩個都算但用加的」。

L0 不放大這條靠 `outpost_level=0` 天然乘數=1（既有 S2a `camp_level` 獨立 flag 設計已經確保 L0 沒有 `outpost_level>0`）結構上自動成立，不需要額外 code 去特判 L0。

## 其餘審點——親驗合理

**④冗餘查**：獨立農田線 vs 既有野地池 gather——這是 WHAT 層級已經明講且 R② CLEAN 過的「食物雙源、互不相干」設計意圖，非框架冗餘，是刻意的雙源。

**③禁 crank**：公式（等級×單位×勞力工位×季節）複用勞力池（guns-vs-butter 自動）+ `farming_level` 升級走既有 construction spine（真工期真料）——結構上符合 genuine-value 判準，無 boost-逼-fire 痕跡。

**⑥守恆/⑦感知鐵律**：`TileBank.deposit` chokepoint pattern 跟既有 `ResourceBank` reason-tag 慣例一致；農業讀自家據點自家勞力自家糧倉，own-state 自知，無 god-view。

## 判決
**CLEAN + 1較重必查項（食物帳 before/after 量化 gate）+ 1設計建議（放大器用乘法）→ 農業a plan → dispatch。** premise 全數坐實、方向正確；唯一真正阻擋量級的風險是「兩個獨立系統的量級校準」沒有明確的量測驗證要求，這條補上就是完整的閉環。
