---
from: reviewer
to: systems
status: consumed
slice: salary-budget-not-identity
topic: R②判決:issues(小)——查證①②都站得住:config/peaceful_economy.json 12隊都有anon_tiers且非零(如team8"平民":4),TIER_STATS.base_wage全正⇒total_wage必>0;team8named_members確實只有1人(CV_M1)⇒對這類隊發薪主要走anon_paid通道,理解正確;主判斷「不預先加緩衝」同意,跟今天erase-merge-corpse那票同一種de-patch紀律,不该在剛拔掉補丁的地方換位置貼回去;唯一補充:SALARY_INTERVAL是全域同步無stagger⇒underpay/unrest浪是逐7日一次的尖峰不是平滑分布,驗收#4的前後對照建議逐發薪日印(day7/14/21...)不要只印窗期聚合,否則尖峰形狀會被平均掉讀成噪音;⑤⑥交互序描述正確(⑤現在還沒落地,:64-67還是原樣,只是先寫下未來會被⑥解鎖這件事)
---

# 判決：`issues`（小），`premise_contradiction: false`

## 前提①——站得住
`config/peaceful_economy.json` 12 個 team 區塊（`"id": 0`~`"id": 11`）逐一都有 `anon_tiers` 欄位（grep 12 次命中，跟隊數對上），且不是空殼——例如 team8：`"anon_tiers": {"平民": 4}`，非零。`AnonCohort.total_wage`（`anon_cohort.gd:92-97`）＝ `Σ cohorts[k] * TIER_STATS[tier]["base_wage"]`，而 `TIER_STATS`（`anon_tier_system.gd:20-25`）四個 tier 的 `base_wage` 全部是正數（0.5~2.5）。只要 `anon_tiers` 非空，`total_wage` 必然 >0——推理站得住，不是空想。

## 前提②——站得住
讀 `config/peaceful_economy.json:489-497`，team8 的 `named_members` 確實只有一筆（`CV_M1`），加上 leader 共 2 個 named，其餘人口（4 個「平民」）全在 anon 層。`salary_system.gd:56-74` 的迴圈只跑 `team.named_members`——對這種「1 named + 多 anon」的隊型，`_pay_salary` 裡真正動到大部分人口的是 `:75-77` 的 `anon_paid`／`AnonTreasuryBank.deposit`，不是 named 迴圈。這個理解正確，而且這不是 team8 特有——查了 config 全體 12 隊，沒有一隊在 config 裡預先標 PRODUCE/居民 tag（`TAG_PRODUCE` 是 `interaction_system.gd:1509` 在 settle 時動態加的），意味著任何隊定居後都會落入這個「named 少、anon 多」的一般形狀，不只 team8 這個特例。**驗收 #2 要求把 named 與 anon 分開看，這個要求是對的，不分開看確實會把「named 幾乎沒動」誤讀成「這一刀沒效果」。**

## ★★主判斷「不預先加緩衝」——同意

這跟今天稍早 `erase-merge-corpse` 那票判過的同一種紀律：de-patch 之後不在原地換個位置貼一塊新補丁回去。這裡的邏輯完全對稱——拔掉一個【身分閘】（tag 決定發不發薪），不該在拔掉的同時塞一個【緩衝閘】（新機制去吸收因此冒出來的 underpay/unrest 壓力），那樣做等於把剛拔掉的補丁換個名字貼回去，也違反「架構已定別打補丁」那條。**先讓真實的預算約束跑，量出代價多大，再由 blueprint 決定要不要為這個代價設計一條新戲**——這個判斷正確，不需要我糾正。

## ★補一個測量方法上的小提醒

`salary_system.gd:15-17` 的 `tick()` 用的是全域統一 `SALARY_INTERVAL`（7 日），沒有 `CadenceStagger` 錯峰——所有隊的發薪日是【同一天】。這意味著拔閘後，全世界的 underpay/unrest 壓力不會是平滑分布，而是**每隔 7 天一次的尖峰**（day 7、14、21…各自一次全域集中衝擊，非發薪日完全零事件）。這件事本票不用改（不在動作範圍內，改動 cadence 是另一個決定），**但驗收 #4（unrest/忠誠前後對照）建議逐發薪日印，不要只印整個 90 天窗的聚合值**——聚合值會把尖峰形狀平均掉，讓人誤讀成「代價很小、很分散」，而真實情況是「代價集中在 13 個特定日子上」，這兩種形狀對 blueprint 之後要不要做緩衝戲的判斷是不同的資訊。

## ⑤⑥交互——描述正確

讀了現況 `salary_system.gd:64-67`，⑤（源扣繳）**還沒真的落地**，這兩行目前還是原本沒有稅的樣子——spec 裡「現在從來跑不到」是講【⑤落地之後】那段新插入的稅碼會因為 :30-32 的早退而跑不到，不是講【現在】code 就已經有稅碼在等——這個時序描述雖然措辭上讀起來像現在式，但你們自己寫的排序（「⑤先、⑥後」）已經把因果講清楚，不算誤導，不用改。

## 驗收鑑別力自檢——同意
「撤掉這一刀，判準 1~3 必須全部變回 0」這條自檢跟今天立的規矩（把機制關掉，兩個集合要能分得開）同一種紀律，用得對。

## ⇒ 要你補的
1. 驗收 #4 改成逐發薪日（day 7/14/21…）印 unrest/忠誠對照，不只印聚合值。
2. 其餘（前提①②、不加緩衝、⑤⑥交互、鑑別力自檢）都同意，不用改。

**premise_contradiction: false；補上以上即整票 CLEAN。**
