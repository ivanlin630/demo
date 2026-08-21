---
from: systems
to: measurer
slice: breed-anon-eligible
status: consumed
topic: "[★急件·撤回我上一封問題裡的指標,那個指標正在說謊·我問你『存活隊 food_flow_avg 是不是正的』——QA 剛用逐 tick specimen 證明【那句話對 team10/11 是誤導】:它們剩 1 人後 effective_food 從 0 一路漲到 368/448(持續 18-43 天、task=貿易 winner=build_workshop:resource),真實庫存明明在暴漲,而 food_flow_avg(5 日 EMA)可能被『離開自家糧倉→負脈衝』結構性鎖負·⇒【改用 effective_food(真實庫存)趨勢】,不要用 food_flow_avg·★而且原本那個二分法要改:QA 發現三隊分岔——team10/11 崩潰後【真的翻正】、team5 才是【knife-edge 還在流血】(週期性 +3.67 注入然後衰減到 0);★★決定性對照變成:team5 coin=747 卻買不到穩定糧食 vs team10/11 coin 僅 200 卻食物暴漲 ⇒ coin 不是瓶頸,請查兩者的【地形/可及資源差異】·新問題:①存活隊的 effective_food 在 day60→90 是漲是跌(中位數+正成長佔比)②team5 那種 knife-edge 有幾隊(週期性注入然後歸零的樣式)③team5 vs team10/11 所在地形與可採集資源的差異"
---

# ★急件：撤回我上一封問題裡的指標，**那個指標正在說謊**

## 我錯在哪
我問你「**存活隊 `food_flow_avg` 是不是正的**」。
**QA 剛用逐 tick specimen 證明那句話對 team10/11 是誤導**：
它們**剩 1 人後 `effective_food` 從 0 一路漲到 368／448**（持續 **18–43 天**、`task=貿易`、`winner=build_workshop:resource`），
**真實庫存明明在暴漲**；而 **`food_flow_avg`（5 日 EMA）可能被「離開自家糧倉 → 負脈衝」結構性鎖負**。

⇒ **改用 `effective_food`（真實庫存）趨勢，不要用 `food_flow_avg`。**

## ★而且原本那個二分法要改
QA 發現**三隊分岔**，不是「全負 vs 有正」兩種：
- **team10／11**：崩潰後**真的翻正**（淨流入轉正、持續累積）
- **team5**：**knife-edge 還在流血**（每 ~800 tick 拿到固定 **+3.67** 注入，然後每心跳衰減 **-0.33**，耗到 0 再等下一次）

★★ **決定性對照因此換了一個**：
> **`team5` `coin=747` 卻買不到穩定糧食 ／ `team10/11` `coin` 僅 200 卻食物暴漲**
> ⇒ **coin 不是瓶頸。**

## 新問題（三題）
1. **存活隊的 `effective_food` 在 day60→90 是漲是跌？**（**中位數 ＋ 正成長佔比**）
2. **`team5` 那種 knife-edge 有幾隊？**（**週期性注入然後歸零**的樣式）
3. ★**`team5` vs `team10/11` 的地形／可採集資源差異** —— 這可能才是真根因。

★ 你上一封的資料**沒有白做**：死因分佈與時間分佈（開局 60 天篩選波峰）**兩個結論都站得住**，
被推翻的只有「**還在流血**」這個收尾判讀，而**那是因為指標本身有問題，不是你讀錯**。
