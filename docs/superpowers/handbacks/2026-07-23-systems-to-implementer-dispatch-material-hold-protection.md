---
from: systems
to: implementer
status: consumed
topic: "[dispatch·material-hold-protection·脫貧第三腿·decouple 兩 urgency·R² CLEAN·新 branch feat/material-hold-protection·off extraction merge 後 main] spec=2026-07-23-material-hold-protection.md。R² CLEAN(7 點親驗:根/food-only decouple 沿用既有結構/construction-need 判定兩次各自平衡呼叫非巢狀遞迴/acute-food 釋放守護結構正確/cost×1.5 是真 afford 公式非 117 誤植/blast-radius 限縮/無 RNG)。根:trade_valuation:94 material reserve=need_keep×_reserve_factor,_urgency=max(food,coin)→coin_urg 壓→construction-material 賣掉不累積→afford 不過。修 4:①_reserve_factor_food_only(新,=_reserve_factor 但 _urgency 只用 food_urg 非 max)②reserve(material)(trade_valuation:94):若 NeedOracle._construction_facility_need(material)>0→用 food-only factor,否則照舊 ×_reserve_factor③acute food(food_days<DESPERATION→food_urg 高→factor 降→料可賣=守護)天然含在 food_urg 項④coin_need(extraction _consider_extraction)material 分量對齊 cost×1.5−material_holding(非只 need_keep shortfall)。★reviewer 效率備註(非必要):reserve() 算一次 _construction_facility_need 結果快取傳兩處用免算兩遍(值得順手)。TDD 6(★②construction-material+coin_urg 高+food OK→reserve 高不賣;③construction-material+acute food<DESPERATION→reserve 降可賣[守護硬驗餓隊能賣];④非-construction/無 construction-need 照舊;⑤coin_need=cost×1.5−holding;⑥守恆無 RNG)。gate/headless 0new/determinism 2跑 byte-identical。★★measure(→measurer §④b+specimen→QA 長跑,★三腿齊=extraction merged+GATE-A+本刀):construction-material 累積(賣壓降/holding 升)/afford×1.5 達成率/★facility 端到端升(三腿齊=成功、不升=還有漏,blueprint 判準)/★★守護硬迴歸=有沒有隊抱著 protected material 餓死(acute food 隊 protected material 有無釋放)/無新餓死 total。做完→to:measurer(→QA 判故事:committed 想蓋隊守料熬過 coin 焦慮→建成;★acute 餓隊仍賣料求生不抱料餓死)。task=systems+reviewer(merge-gate)。★base=extraction merge 後 main(先確認 feat/extraction-need-driven 已 merge)。generalize(means-end committed 資源)標記先 scoped material 別 over-reach。"
branch: feat/material-hold-protection
---

# dispatch：material-hold-protection（脫貧第三腿·decouple 兩 urgency）

spec：`docs/superpowers/specs/2026-07-23-material-hold-protection.md`。**R² CLEAN**（7 點親驗；cost×1.5=真 afford 公式非 117 誤植；1 效率備註非 blocking）。脫貧三腿之三（食 GATE-A + coin extraction + 本刀）。

## ★ branch
- **新 branch `feat/material-hold-protection`**，**off extraction merge 後 main**（先確認 `feat/extraction-need-driven` 已 merge）。

## 修（4 touch）
- ① `trade_valuation` `_reserve_factor_food_only`（新，= `_reserve_factor` 但 `_urgency` 只用 `food_urg` 非 `max(food,coin)`）。
- ② `reserve(material)`（:94）：`if NeedOracle._construction_facility_need(material) > 0 → 用 food-only factor；else → 照舊 ×_reserve_factor`。
- ③ acute-food 釋放（守護）天然含在 food_urg 項（`food_days<DESPERATION → food_urg↑ → factor↓ → reserve↓ → 料可賣`）——不需額外 code，food-only factor 自帶。
- ④ `coin_need`（extraction `_consider_extraction`）material 分量對齊 `cost×1.5 − material_holding`（非只 need_keep shortfall）→ extraction 拉夠 coin 買足量。
- ★**效率**（reviewer 備註，非必要）：`reserve()` 算一次 `_construction_facility_need` 快取傳兩處用（免算兩遍）。

## TDD（6）
①construction-material + coin_urg 高 + food OK（food_days≥DESPERATION）→ reserve **高**（不被 coin 壓）不賣 ②construction-material + **acute food**（<DESPERATION）→ reserve **降** → **可賣**（★守護硬驗：餓隊能賣 protected material 求生）③非-construction / 無 construction-need → 照舊 ④coin_need material = `cost×1.5−holding` ⑤守恆 ⑥無 RNG。

## 閘 + measure
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical。
- **★★measure（→measurer §④b+specimen→QA，★三腿齊）**：construction-material 累積（賣壓降/holding 升）/ afford×1.5 達成率 / **★facility 端到端升**（三腿齊=成功、不升=還有漏，blueprint 判準）/ **★★守護硬迴歸=有沒有隊抱著 protected material 餓死**（acute food 隊 protected material 有無釋放）/ 無新餓死 total。

## 完成判定 = systems + reviewer（merge-gate R²）。做完 → to:measurer（→QA 判故事：committed 想蓋隊守料熬過 coin 焦慮→建成 coherent；★acute 餓隊仍賣料求生不抱料餓死）。**generalize（means-end committed 資源）標記先 scoped material 別 over-reach**。
