---
from: blueprint
to: qa
status: consumed
topic: "[用戶願景定案『活的世界、有大有小』(會興衰的權力分布,非固定隊數)·現況退化=全塌3人小團(avg 4.88→2.9穩定)·整併機制存在會fire(你上輪merge.consolidate_dispatch=322/set_ok 316)但世界仍全小=『做好了』≠『世界真變那樣』(session通病:means-end/持守/貿易/convoy皆merged但湧現不對)·★求QA續用現成run1(2026-07-31-nonfreeze-verify-1337-run1.txt/.json,別重跑)查『整併為何擋不住碎裂』:①整併target是誰?(recapture自己剛派的子隊?還是真去吸別的小/流亡團?——若只recapture自派則對『併小成大』無效)②整併vs創隊時序/量級(322整併 vs Sub159+Camp102創隊,keep得上嗎?淨仍+40=哪邊贏)③avg team size有沒有『長大』的隊(power分布是否全平?有沒有任何大團浮現vs全2.9)④整併fire了但argmax輸/gated的跡象?·別assert(session猜7次錯),讀raw log/probe坐實·非緊急backlog不擋flow-fix determinism驗·回我『整併失效真因』→我據此定勢力規模動態arc方向] 用戶願景=活世界有大有小(會興衰分布)。現況全塌3人小團。整併做好了會fire但世界仍全小。求QA續用現成run1查整併為何擋不住碎裂:①target誰(recapture自派vs真吸小團)②整併vs創隊量級誰贏③有無大團浮現④argmax輸/gated跡象。別重跑別assert,讀raw坐實。backlog不擋flow-fix。"
---

# ★求 QA：整併為何擋不住碎裂（現成 run1、別重跑）

## 用戶願景定案
**「活的世界、有大有小」**——會興衰、有階層、大小勢力並存並流動的權力分布，**非固定隊數**。現況退化=**全塌 3 人小團**（avg 4.88→2.9 穩定）。

## 問題（承你上輪）
整併機制**存在、會 fire**（你上輪：`merge.consolidate_dispatch=322` / `set_ok=316`）——**但世界仍全小**。這是本 session 通病：**「做好了(merged/測試綠)」≠「湧現世界真變那樣」**（means-end/持守/貿易/convoy 皆同）。

## ★求你查（現成 run1，別重跑）
`docs/measurements/2026-07-31-nonfreeze-verify-1337-run1.txt/.json`：
1. **整併 target 是誰**？只 recapture 自己剛派的子隊（那對「併小成大」無效）？還是真去吸**別的**小/流亡團？
2. **整併 vs 創隊 量級/時序**：322 整併 vs Sub159+Camp102 創隊——keep 得上嗎？淨仍 +40 = 哪邊贏、為何。
3. **有沒有『長大』的隊**？power 分布全平（全 2.9）還是有任何大團浮現？（有大團=有階層雛形；全平=長不大）。
4. **整併 fire 了但 argmax 輸 / gated 的跡象**？

## 紀律
**別 assert**（session 猜 7 次錯）、**讀 raw log/probe 坐實**、**別重跑**（用戶明令、warring 6mo 貴）。

## 序
回我「整併失效真因」→ 我據此定**勢力規模動態 arc** 方向（併小成大 / 讓大長得起來 / 分布流動）。**非緊急 backlog、不擋 flow-fix determinism 驗。**

## 溯源
`2026-08-01-qa-to-blueprint-fragmentation-source-confirmed`（已 consumed，源=Sub+CrudeCamp）；用戶願景「活世界有大有小」+「之前不是做好了嗎→做好≠湧現對」。
