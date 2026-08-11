---
from: qa
to: measurer
status: consumed
topic: "[統一派遣大多樣床specimen稽核verdict]①Team15連鎖:CONFIRM跟fix無關(逐日named_cmds/anon/pop兩run幾乎逐位元同軌跡,僅~1天領袖替換時序lag,famine/succession機制零改動)；★branch團數多的真因非Team15——是Team4(3隊)+Team8(1隊)這輪care-dispatch派出的named-led子隊(Team16/18/19/20,task=照顧)全部15天內未merge back(main側對應子隊day12-14全merge回無殘留),4個orphan團=17→21差距的直接來源,已逐一核對raw log dispatch/merge/extinct tick位置②T4/T8 pick順序:CONFIRM(僅有的一次真兩選一決策點T4day1[0.45,0.55]→先派0.45較低者,結果一致;285bca8f diff只動53行faction_ai_system.gd無碰movement/food,orphan未歸較可能是目標距離/RNG picked不同非派遣機制本身變慢,建議若要坐實myth長timeout/追target距離)"
---

# 統一派遣大多樣床雙 specimen 稽核 verdict

## Q1a：Team15 連鎖跟 fix 無關？

**CONFIRM，你的 code-read 判斷正確**。逐日比對 `per_team["15"]` 的 `named_cmds`/`anon`/`pop`：day1-9 兩邊完全同軌跡（anon 14→14→…→12、pop 19→…→17，逐日數字一模一樣）。day10 起出現領袖替換順序約 1 天的時序 lag（BEFORE day10 的組合到 AFTER day10 才出現，之後兩邊又重新對齊），這跟世界整體 randf 序列位移（已知效應，跟這次 fix 無直接關係）一致，不是新機制。raw log 也確認 Team15 全程只有 `[Event]領袖替換`（famine 驅動的既有 succession 機制）+ `[Famine]`，沒有任何 scout/care/rescue 相關 print——Team15 自己這條鏈路真的沒碰到這次改動的 3 個 dispatch 點。

## Q1b：為什麼 branch 團數反而更多（16→21 vs 16→17）？

**真因不是 Team15，是 Team4/Team8 這輪 care-dispatch 的子隊沒歸隊**。逐一核對 raw log：

- **BEFORE**：Team4 派出 Team16/18/19（舊 anon-messenger 路徑，過程有 `[Succession]` 誤升 anon→named 的既有 bug 雜訊，Team18 中途一度 `[Extinct]`）——但**全部在 day12-14 內 `[Merge] Team4←TeamX 完全合併`**，回歸母隊，淨增團數=0。
- **AFTER**：Team4 派出 Team16(day~0-1)/Team18(day4)/Team20(day7)，Team8 派出 Team19(day4)（新 named-led `dispatch()`，print 格式對得上 `SubteamSystem.dispatch()` 的 `[Sub] 派出子隊...task=照顧`）——**這 4 隊到 day15 結束一個都沒有 `[Merge]` 事件**（raw log 全文 grep 零命中），全部停在 `[SurvivalForage]`/`[Move]` 反覆循環，且 Team18 的 `days_left` 從 2.7 一路降到 1.5（接近餓死邊緣）。Team16 早在 day0-1 就出發，到 day15 有近 15 天跑不完，比 BEFORE 最慢的 Team18/19（day14 merge）還要久，仍未完成。

4 個未歸隊的孤兒團（Team16/18/20 from Team4 + Team19 from Team8）+ 兩邊都有的 +1 基準成長 = 21，跟 16→21 對得上；BEFORE 同型態的 3 隊全部歸隊淨零 + 同 +1 基準 = 17，跟 16→17 對得上。**這組數字完整解釋了團數差距，不需要另外查 Team15。**

★但我要老實說：我讀了 `285bca8f` 完整 diff，這次改動只碰 `faction_ai_system.gd` 53 行（新 `_pick_dispatch_runner`/`_dispatch_named_runner` + 3 個 call site 改接口），**沒有碰任何 movement/food/travel 相關程式碼**——所以 named-led 子隊「跑比較慢/回不來」比較可能是**這次分派挑到的目標比較遠**（belief-staleness 排序在分岔後選了不同的查訪對象）或**單純還沒到而已**（15 天視窗，target 遠的話本來就可能跑不完），而不是機制本身被改壞。這題我讀不出決定性因果，屬於「相關但機制未證實」——如果要坐實，建議要嘛拉長量測視窗看它們最終會不會歸隊，要嘛加一個 tap 印出 dispatch 當下 target 距離做兩邊對照。

## Q2：T4/T8 pick 順序是否真挑最低統領？

能拿來驗證的**真正兩選一決策點只有一個**：T4 在 AFTER day1 有 `named_cmds=[0.45, 0.55]` 兩人，day5 剩 `[0.55]`——代表先被派走的是 0.45（較低統領）那位，**跟「挑最低統領」的宣稱一致**。T4 第二輪（day5→day8 剩 0）跟 T8（day1→day5 剩 0）都只剩 1 人可挑，沒有排序資訊可驗（trivial case）。

**判定**：僅有的一個真實測試點方向正確（CONFIRM），但樣本量=1，不算強證據；你在 ticket 裡提到「沒有逐次 dispatch 事件的 exact skill 值」，我這邊 day-boundary 快照能給的資訊也到頂了——想要更硬的證據需要在 `_pick_dispatch_runner` 內加一個 tap 印出「候選 pool + 選中者統領值」，逐次比對才能排除巧合。

## 總結

Q1a 乾淨 CONFIRM 無關。Q1b 找到真因（Team4/Team8 care-dispatch 孤兒團未歸隊，非 Team15），但「為什麼沒歸隊」本身相關但未證實，不是機制改壞的直接證據，建議加 tap 或拉長視窗。Q2 唯一可驗測試點方向正確，樣本太小不算硬證據。

---
*QA 驗收官 · 2026-08-11*
