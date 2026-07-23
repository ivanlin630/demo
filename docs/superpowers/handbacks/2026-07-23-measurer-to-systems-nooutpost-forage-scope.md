---
from: measurer
to: systems
status: consumed
topic: "[measure 完·★重要 reframe:end-state 絕境主體=GATE-A(56-61%)非 no-outpost(8-13%)+subsistence rate inputs] main 0bf1fed9 seed42/1337。①end-state 絕境(food_days<3)分類跨 seed:settled-left-home(GATE-A)=56%/61%=★主體;settled-on-productive=36%/23%;no-outpost=8%/13%;forest-real-cost=0%/3%。★no-outpost 不是主體(僅 8-13%),GATE-A(擁 productive home 卻離家、positional effective_food 低,疑離家超 PROVISION_DAYS=10 buffer)才是。②rate inputs:no-outpost hunt=1.08-1.21 food/day/隊(≪burn 6.4-8=深赤);with-outpost collect=5.58-6.55/day/隊(勉強≥pop8 burn6.4、<pop10 burn8=薄利,解釋 settled-productive 23-36% 仍餓)。subsistence target ∈(1.2,5.6)。★blueprint 裁(a)no-outpost forage 只救 8-13%;主體 GATE-A(離家 positional)+settled 薄利 harvest 未觸及。★我上輪 transient T48 datum(no-outpost 蹲 pool)為 real 但非 end-state 主體——誠實 reframe。你 patch-gate-first re-scope。別下 fix 結論。"
measured_at_head: "main HEAD 0bf1fed9"
seeds: "42 + 1337（各 3mo）"
---

# no-outpost 主體確認 + subsistence rate inputs → systems（★重要 reframe）

工單（`2026-07-23-systems-to-measurer-nooutpost-forage-scope`，consumed）。main 0bf1fed9、seed42/1337 3mo。**別下 fix 結論**。temp 探針 **已 revert、main clean、grep 零殘留**。

## ① end-state 絕境隊分類 —— ★主體是 GATE-A 非 no-outpost（跨 seed 確認）
| 分類 | seed42（25 隊） | seed1337（31 隊） | 讀法 |
|---|---|---|---|
| **settled-left-home（GATE-A）** | **14（56%）** | **19（61%）** | ★**主體**：擁 productive home 卻離家 |
| settled-on-productive | 9（36%） | 7（23%） | 蹲自家 outpost 仍餓（harvest 薄利，見②） |
| **no-outpost** | **2（8%）** | **4（13%）** | ★**少數**（非主體） |
| forest-real-cost（pop>regen） | 0（0%） | 1（3%） | 極少 |

- **★no-outpost 不是 end-state 絕境主體（僅 8-13%）**；**GATE-A（settled-left-home）才是（56-61%）**：這些隊**擁有 productive home outpost 卻不在家**，positional effective_food 讀低（疑離家超 `PROVISION_DAYS=10` 乾糧 buffer → buffer 耗盡 → 家中糧倉滿卻 positional 餓）。
- **settled-on-productive 23-36%**：蹲自家 outpost 仍餓——見②，collect 收成薄利（≈burn）。

## ② subsistence rate 設計 inputs
| 指標 | seed42 | seed1337 |
|---|---|---|
| **no-outpost hunt food/day/隊** | **1.21** | **1.08** |
| **with-outpost collect food/day/隊** | **5.58** | **6.55** |
| plains: hunt/collect total（次） | 2659(338) / 8029(1997) | 2062(259) / 13356(3314) |
| forest: hunt/collect total（次） | 1340(180) / 2935(2670) | 1666(217) / 2800(2524) |
- **no-outpost hunt = 1.08-1.21 food/day/隊 ≪ burn（pop8=6.4、pop10=8.0）= 深赤**（狩獵 wild_game 有限+枯竭，觸不到腳下 plant pool）。
- **with-outpost collect = 5.58-6.55 food/day/隊**：**勉強 ≥ pop8 burn(6.4)、< pop10 burn(8.0)= 薄利**——解釋 settled-on-productive 23-36% 仍餓（收成剛好打平消耗、無 buffer 累積）。
- **subsistence rate target ∈ (1.2, 5.6)**：> 現 no-outpost 1.2（要救得動）、< with-outpost 5.6（保 settlement 仍值升級）。中點 ~3-4/day/隊（pop8 約打平 burn 一半、靠交易補）。

## ★重要 reframe（誠實，供你 re-scope）
- **blueprint 裁(a) no-outpost forage 只救 8-13%**（end-state 少數）。**主體 GATE-A（56-61%，離家 positional）+ settled-on-productive（23-36%，薄利 harvest）未觸及**。
- **★我上輪 transient datum（T48 no-outpost 蹲 120-299 pool）為真**（那是 harvest-gap 的**瞬時**時刻）**但非 end-state 主體**——end-state 持續絕境是 GATE-A（離家）。兩族群不同：transient 抓到 no-outpost 覓食時刻，end-state 抓到誰最後真困死=GATE-A。**你上輪據我 transient datum HOLD GATE-A；此 end-state 分類反而指 GATE-A 是主體**——誠實 reframe，供你重判。
- **你 patch-gate-first re-scope**：GATE-A（離家超 provision buffer / positional effective_food 不算家中糧倉）是主體根？settled 薄利（collect≈burn）需 harvest rate？no-outpost forage（裁 a）補少數 + transient floor？**我沒下 fix 結論，數字給你定 rate + re-scope**。

## 溯源
raw：`docs/measurements/2026-07-23-nooutpost-{1337,42}.txt`（分類 4 桶 + hunt/collect rate + team-days）。temp 探針（resource_system collect-food + hunt_system hunt-food 分地形）**已 revert、clean**。determinism-safe（add_amount/bump-only 零 RNG）。3mo（rule3）。分類「settled-left-home」= 擁 outpost_owner==tid 的 productive tile 但當前 pos≠該 tile；positional effective_food 是否=真餓由你判（可能離家 buffer 耗盡=功能性真餓 vs 家糧滿=positional artifact）。
