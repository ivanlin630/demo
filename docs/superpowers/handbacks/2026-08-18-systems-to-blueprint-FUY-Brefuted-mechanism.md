---
from: systems
to: blueprint
status: consumed
topic: "[FUY farm-labor code-read定案(你B嫌疑REFUTED)+grounded機制+per-team measure route·★★B嫌疑(farm need沒接B5升級)REFUTED:_workstation_need farm(:115)與gather:food(:103)need計算完全相同(皆need_keep(food)+demand(food))、:112註明「同gather:food need權重法」→farm讀相同food need、B5飢餓升級兩者皆得=非漏escalation misconfig·★grounded真機制(rebalance:45-93):demand gather:food=K_GATHER小常數(:49)vs farm=farming_level×K_FARM=5大(:56);need-weight兩者相同(食need);分配=need-weight加權capped-by-demand+溢出串聯→farm demand大(5/level)+池有限+gather:food小demand先cap填滿→farm拿剩餘21%·★★結構洞見:gather:food+farm都food_need加權=兩個食物工位競同一食need(冗餘)、便宜gather(小demand)先填、farm系統性拿leftover(非team-size獨因、是redundant food-labor競爭cheaper先贏)·★兩解待per-team measure確認:(i)K_FARM=5太高farm demand過大(misconfig候選)or(ii)大團staff farm小團forage(guns-vs-butter正確emergence)or(iii)★結構:gather/farm冗餘食競爭farm恆leftover(不論team size=設計問題:farm該不該優先於gather:food once developed)·per-team measure route measurer(大vs小團staff farm分野)·FARM_UNIT_YIELD凍(非根、B refuted+結構才是)·農業b+perf刀3平行·地基KEEP"
---
# FUY farm-labor code-read 定案（B refuted）+ grounded 機制
## ★★B 嫌疑 REFUTED（你點的第一名 misconfig）
`_workstation_need` farm(:115) 與 gather:food(:103) **need 計算完全相同**（皆 `need_keep(...,"food")+demand(...,"food")`）、:112 註明「同 gather:food need 權重法」→ **farm 讀相同 food need、B5 飢餓升級兩者皆得**=**非漏 escalation misconfig**。
## ★grounded 真機制（rebalance labor_system:45-93）
- demand：`gather:food=K_GATHER`（小常數 :49）vs `farm=farming_level×K_FARM=5`（大 :56）。
- need-weight：兩者**相同**（食 need）。
- 分配=need-weight 加權 capped-by-demand + 溢出 → farm demand 大（5/level）+ 池有限 + gather:food 小 demand 先 cap 填滿 → **farm 拿剩餘 21%**。
## ★★結構洞見
gather:food + farm **都 food_need 加權=兩食物工位競同一食 need（冗餘）**、便宜 gather（小 demand）先填、**farm 系統性拿 leftover**（非 team-size 獨因）。
## 三解待 per-team 確認
(i) K_FARM=5 太高 farm demand 過大（misconfig）/ (ii) 大團 staff farm 小團 forage（正確 emergence）/ **(iii)★結構：gather/farm 冗餘食競爭 farm 恆 leftover**（不論 size=設計問題：farm 該不該優先於 gather:food once developed）。
→ **per-team measure route measurer**（大 vs 小團 staff farm 分野）。FARM_UNIT_YIELD 凍（非根）。農業b+perf 刀3 平行。地基 KEEP。
