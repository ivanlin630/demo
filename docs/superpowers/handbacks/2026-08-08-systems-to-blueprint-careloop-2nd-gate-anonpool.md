---
from: systems
to: blueprint
status: open
topic: "[★★ii care-loop 量測=fix 必要但不足、2nd gate=anon-pool exhaustion(已知遞迴根、跨 arc)·真需你裁 scope(whack-a-mole vs 結構 vs iii-pivot)·量測誠實:care-loop vpos de-patch 有效(vpos (-1,-1)→(17,24) roster 真解出)+零回歸(3seed byte-identical、標準床 dormant)但★無 observable 效果(death-spiral 沒破、Team2 仍 pop=1 死、attrition 20.8% 不變)=教科書『修對一 gate 下游還有一個』·2nd gate 鎖定:_dispatch_care_scout 內呼 dispatch_anon_messenger 撞 AnonTierSystem.total_pop(lord)<1——lord anon 池 day5 前被同輪其他 side-dispatch(herald/scout/distribute/migrant/invest/relocate 同一 INFO_DISPATCH_CADENCE 迴圈)耗盡、45天 never 回補(migrant 永久搬走+recall 回補疑 leak+breeding 慢)·★★這是本 session cohesion①natural care-loop arc 已診斷同根(dispatch_anon_messenger sid=-1 anon 耗盡)=跨 arc 遞迴結構根:lord 的整個 proactive-care 器官(全 side-dispatch 家族)共用有限 anon 池、早耗盡→proactive relief 全斷(非只 care-scout)·★深層 pattern:relief-death 是深 gate-chain(vpos[修] → anon-pool[現] → 可能更多)、全根於 lord proactive-care 資源餓死·[[project_hand_obeys_brain_arc]]結構列舉 drop 點·★裁點(你 WHAT):①anon-pool 修法方向=(a)quick de-patch anon-pool gate(care-scout/relief 高優先搶 anon 或 pool 免耗於低優先 dispatch)vs(b)結構修(anon-pool sizing/refill/recall-return-leak 查=proactive-care 器官可持續)——需先焦點診斷 anon-pool bug(recall 不還=leak)vs genuine(僧多粥少)才定②★或 iii-pivot 重新權衡:relief-death 深 gate-chain 顯示『racing relief 穿越資源餓死器官』可能治標、真根或是 iii(餓隊該不該這麼易 defect=cohesion prevent-defect 勝於 race-relief)=你之前 flag 深根、現量測加重此權衡·③care-loop de-patch(89af4837)處置=hold branch 疊 anon-pool 修(combined 才 observable、避 merge 無效果 change)vs merge 為 banked-correct building block·我建議:先焦點診斷 anon-pool(bug vs genuine、cheap)→回你裁 a/b/iii-pivot·care-loop branch hold 疊·地基 KEEP·待你裁 scope"
---

# ★★ii care-loop 量測 = fix 必要但不足、2nd gate = anon-pool exhaustion（已知遞迴根）

真需你裁 scope（whack-a-mole vs 結構 vs iii-pivot）。

## 量測誠實
care-loop vpos de-patch **有效**（vpos (-1,-1)→(17,24) roster 真解出）+ **零回歸**（3seed byte-identical、標準床 dormant）**但 ★無 observable 效果**（death-spiral 沒破、Team2 仍 pop=1 死、attrition 20.8% 不變）= 教科書「修對一 gate 下游還有一個」。

## 2nd gate 鎖定
`_dispatch_care_scout` 內呼 `dispatch_anon_messenger` 撞 `AnonTierSystem.total_pop(lord)<1` —— lord anon 池 **day5 前被同輪其他 side-dispatch**（herald/scout/distribute/migrant/invest/relocate 同一 cadence 迴圈）**耗盡、45天 never 回補**（migrant 永久搬走 + recall 回補疑 leak + breeding 慢）。

## ★★跨 arc 遞迴結構根
這是本 session **cohesion①natural care-loop arc 已診斷同根**（dispatch_anon_messenger sid=-1 anon 耗盡）：lord 的整個 **proactive-care 器官（全 side-dispatch 家族）共用有限 anon 池、早耗盡 → proactive relief 全斷**（非只 care-scout）。★深層 pattern：relief-death 是**深 gate-chain**（vpos[修] → anon-pool[現] → 可能更多）、全根於 lord proactive-care 資源餓死（[[project_hand_obeys_brain_arc]] 結構列舉 drop 點）。

## ★裁點（你 WHAT）
1. **anon-pool 修法方向**：(a) quick de-patch anon-pool gate（care-scout/relief 高優先搶 anon / pool 免耗於低優先 dispatch）vs (b) 結構修（anon-pool sizing/refill/recall-return-leak 查 = proactive-care 器官可持續）—— 需先焦點診斷 anon-pool **bug（recall 不還=leak）vs genuine（僧多粥少）** 才定。
2. ★**或 iii-pivot 重新權衡**：relief-death 深 gate-chain 顯示「racing relief 穿越資源餓死器官」可能治標；真根或是 **iii（餓隊該不該這麼易 defect = cohesion prevent-defect 勝於 race-relief）**= 你之前 flag 深根、現量測加重此權衡。
3. **care-loop de-patch（89af4837）處置**：hold branch 疊 anon-pool 修（combined 才 observable、避 merge 無效果 change）vs merge 為 banked-correct building block。

## 我建議
先焦點診斷 anon-pool（bug vs genuine、cheap）→ 回你裁 a/b/iii-pivot。care-loop branch **hold 疊**。地基 KEEP。待你裁 scope。
