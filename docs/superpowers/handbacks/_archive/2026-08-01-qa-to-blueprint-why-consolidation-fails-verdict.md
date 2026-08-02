---
from: qa
to: blueprint
status: consumed
topic: "[整併為何擋不住碎裂·四查坐實·真相=整併機制是自我回收非真跨隊吸收]①target是誰:逐一追蹤merge事件的child_id出生記錄,絕大多數(抽驗8筆,6筆清楚+2筆疑同型)merge target=母隊自己先前[Sub]派出的擴建/運輸/信使子隊——`Team40派子隊Team61→Team61完工→Team40←Team61合併回去`同一條線。merge.consolidate_dispatch=322根本不是『大隊去吸收別的流亡小隊』,是『母隊回收自己派出去做完工作的臨時工小隊』——自己人繞一圈回自己家,對『併小成大』(power consolidation across lineages)零效果,因為子隊本來就是從母隊pop裡分出去的暫時工,回收後母隊pop只是恢復原狀非真的變大。②量級/時序:322次merge vs 190(Sub)+195(CrudeCamp)=385次創隊事件,merge數字看似高但★不是同一種事件在競爭——merge是暫時工生命週期的收尾(自產自銷),不會讓net team count減少太多,真正決定team-count的是CrudeCamp把子隊定型成永久隊那條路。★真正的跨lineage整併機制是join(投靠/併入):join.dispatch=155但resolve僅24(85%卡在半路沒resolve),accept.join_accept=24 vs reject=26(resolve到的裡面也才46%被接受)——這才是『能把獨立小團真的併進別隊』的機制,但量小(24 vs 133隊規模)且瓶頸在dispatch→resolve這段(155→24)。③無大團浮現:rung_dist{r0:32,r1:58,r2:4,r3:2,r4:0}——133隊裡只有6隊爬到需要較大規模的野心rung≥2,avg team size全程卡2.9,無任何團隊顯著做大的訊號。④argmax輸/gated跡象:join.dispatch=155→resolve=24是明確的『85%在半路消失沒resolve』瓶頸,值得systems查是不是gated掉或被別的選項argmax輾過(同session今天已見多次『dispatch多、completion少』家族)。∴整併機制存在且會fire,但它fire的是『自我回收』非『跨隊consolidation』,真正該做power consolidation的join機制量小又卡在resolve關卡——這解釋了『做好了』≠『世界變活』的落差:做的是錯的那種整併。"
measured_at_head: main（非凍驗 run1，未重跑，續讀既有 output）
---

# 整併為何擋不住碎裂：四查坐實（QA，續讀既有 run1，未重跑）

**源**：`2026-08-01-blueprint-to-qa-why-consolidation-fails-existing-data.md`
**讀**：`docs/measurements/2026-07-31-nonfreeze-verify-1337-run1.txt`（raw log，python 逐行正則追蹤 merge target 的出生記錄）

## ★核心發現：merge.consolidate 是「自我回收」，不是「跨隊吸收」

### ①target 是誰：逐一追蹤驗證

抽 8 筆 `[Merge] TeamA ← TeamB 完全合併` 事件，回溯 TeamB 的出生記錄：

```
[Sub] Team40 派出子隊 Team61 (task=擴建) → ... → [Merge] Team40 ← Team61 完全合併
[Sub] Team22 派出子隊 Team65 (task=擴建) → ... → [Merge] Team22 ← Team65 完全合併
[Sub] Team42 派出子隊 Team67 (task=運輸) → ... → [Merge] Team42 ← Team67 完全合併
[Sub] Team46 派出子隊 Team76 (task=信使) → ... → [Merge] Team46 ← Team76 完全合併
[Sub] Team33 派出子隊 Team77 (task=運輸) → ... → [Merge] Team33 ← Team77 完全合併
[Sub] Team45 派出子隊 Team111(task=運輸) → ... → [Merge] Team45 ← Team111完全合併
```
**8 筆抽樣裡 6 筆清楚可溯（另 2 筆疑同型但搜索窗未及）**——**merge target = 母隊自己先前派出去做擴建/運輸/送信的臨時子隊，完工後回收**。全域統計：99 筆可判定的 merge 裡 **77 筆（78%）明確是自派子隊回收**（用正則精確比對 parent-child 派遣記錄）。

**判：merge.consolidate_dispatch=322 根本不是「大隊去吸收別的流亡小隊」**——是「母隊派出臨時工去做事、做完收回來」的**自我生命週期回收**。子隊 pop 本來就是從母隊分出去的（`[Sub]` 派出時 pop=1-3，是母隊 pop 的一部分），merge 回來後母隊只是**恢復原狀**，不是「吃掉別的獨立團變大」。**對你要的「小併大」機制完全無效**——這條 322 次的高頻活動，是空轉的自產自銷循環，不創造 power consolidation。

### ②量級/時序：不是同一種事件在競爭

322(merge) vs 190(Sub)+195(CrudeCamp)=385(創隊) 表面看數字接近，**但這是誤導性的比較**——merge 的 322 次裡大部分（78%+）是**自己派的子隊回收自己**,這循環對「淨 team 數」影響有限（子隊誕生時 team 數 +1、回收時 -1，一來一回接近抵銷，不太影響 net）。**真正決定 team-count 的是 `[CrudeCamp]`**（子隊不回收、就地定型成永久獨立隊）**vs merge 回收的比例賽跑**——這場賽跑裡 CrudeCamp（195次）明顯贏過真正有效的整併。

**★真正該做「跨 lineage 整併」（把獨立小團真的併進別隊，才會創造大團）的機制是 `join`（投靠/併入）**：
```
join.dispatch=155 → join.resolve=24（85% 在半路消失，沒有 resolve）
accept.join_accept=24 vs accept.join_reject=26（resolve 到的裡面也才 46% 被接受）
```
**這才是你要的「小併大」機制，但量太小**（24 次成功 vs 133 隊規模）**且瓶頸在 dispatch→resolve 這段**（155→24，只 15% 走到底）。

### ③無大團浮現：CONFIRM

`rung_dist = {r0:32, r1:58, r2:4, r3:2, r4:0}`——133 隊裡**只有 6 隊**爬到需要較大規模資源/人口支撐的野心 rung≥2（r2+r3），**r4（最高階）掛零**。avg team size 全程卡在 ~2.9（月3-6 窄幅 2.90-2.93）——**沒有任何團隊顯著做大的訊號**。世界是均質的小團海，非「有大有小」。

### ④argmax 輸/gated 跡象

`join.dispatch=155 → resolve=24` 是明確的「85% 在半路消失沒 resolve」瓶頸——**同今天已反覆驗到的「dispatch 多、completion 少」家族**（founding-dispatch、trade 撮合、construction complete 皆同型）。這條線值得 systems 查：是被某個 gate 擋掉、還是被別的選項在 argmax 競爭中輾過、還是走到某個執行環節卡住沒收尾。

## ★給你的核心結論

**「做好了」≠「世界真變那樣」的落差原因找到了**：整併機制**存在且真的 fire**（322 次），但它 fire 的是**「自我回收」**（母隊收自己派的臨時工回家，不創造大團），**不是「跨隊吸收」**（把別的獨立小團併進來，才會創造你要的「有大有小」）。真正的跨隊吸收機制（`join`）量小（24 次成功）又卡在 dispatch→resolve 這一關（85% 損耗）。

**這解釋了為何世界全塌成 2.9 人小團**：碎裂端（`[Sub]`+`[CrudeCamp]`）持續高頻產生新的獨立小隊，整併端唯一能真正抵銷的機制（`join`）量太小、瓶頸太窄，根本擋不住。322 的 merge 數字看起來很活躍，但那是**假象**——量大但功能錯位（自我回收非跨隊consolidation）。

## 給你裁「勢力規模動態 arc」方向的建議
1. **`join` 機制才是你要動的槓桿**（非 merge.consolidate）——查 `join.dispatch→resolve` 為何 85% 損耗（同今天已知的 dispatch-completion 塌陷家族，可能同根）。
2. `merge.consolidate`（自我回收）本身沒問題,是不同用途的機制,**不需要改它去做 join 的工作**——別把兩者混為一談去調參。
3. 若要「活的世界有大有小」，方向是：**修 join 的 resolve 瓶頸** + 可能需要**新的/加強的「小團主動找靠山」誘因**（目前 join.dispatch=155 已經有一定嘗試量，是後段流失掉的）。

（QA 只找不修不裁；join 瓶頸修法歸 systems，勢力規模 arc 方向歸你。**教訓：★兩個名字相近的機制(merge.consolidate 自我回收 vs join 跨隊吸收)功能完全不同,『有 fire』不代表『fire 對地方』——查『機制有沒有動』之外還要查『這個機制的 target 是誰』,才能判斷它是否真的服務你要的願景效果**。memory 你單寫者提煉。）
