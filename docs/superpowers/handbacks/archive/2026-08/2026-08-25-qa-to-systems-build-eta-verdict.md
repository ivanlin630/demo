---
from: qa
to: systems
slice: build-eta-single-source
status: consumed
topic: "[QA故事稽核:build-eta-single-source]★『branch多保住1個outpost』這題判不了——這輪specimen只有branch沒main對照,且branch裡三隻有建設/紮根活動的隊(team8=新增那個已confirmed、team15=委任乾淨但軌跡短、team22=全新讀到的案例)都是本輪新root嘗試,沒有一隻是『day0既有outpost撐過近乎放棄關頭』的profile,誠實列出這是缺口非我沒查;★意外收穫:team22是完整、乾淨的『放棄』故事——紮根委任成功後被迎戰(戰鬥)打斷,重新紮根連續7次試探全輸給買糧(食物壓力太大顧不上紮根)、投靠被拒、最終流浪覓食/逃跑,對camp.abandoned=24這個高棄置率世界提供一個真實可讀的案例;root.won_argmax大降(5→1)但完工持平的推測性關聯我沒有額外證據能坐實或推翻,誠實列未查"
---

# QA 故事稽核：build-eta-single-source — 正式判決

## ★「branch 多保住 1 個 outpost」＝ **判不了，缺 main 側對照 + 缺 day0 既有 outpost 隊的軌跡**

這輪只寄了 branch 的 specimen，**沒有 main baseline 的 specimen 可以對照**——而 measurer 要驗的正是「main 流失了但 branch 保住的那個 outpost」，這需要能看到 main 側該隊當時的動作序列（是不是真的走到棄置門檻但 branch 因為 persist.hold 變寬鬆而撐過去）。

我逐一查了 branch specimen 裡三隻有「建設/紮根」活動的隊（**team8/team15/team22**）——**全部都是這輪新的紮根嘗試（新 outpost），不是「day0 既有 outpost 撐過近乎放棄關頭」的那種 profile**。「保住的那個 outpost」照 measurer 判讀屬於 day0 既有的 11 個之一，我沒有辦法從這批 branch-only specimen 裡指認出是哪一隊、更看不到它在 main 上原本會怎麼放棄。**這條判不了，缺口在資料範圍不在我沒查**——若要驗，需要 main 側同 seed 的 specimen（含 day0 outpost owner 的 team_id），用兩趟法先跑 main 找出「day0 有 outpost、day90 沒了」的那隊 team_id，再對 branch 同 id 抽樣比對。

## ★意外收穫：team22 是一個完整、乾淨的「放棄」故事

雖然答不了 measurer 的題，但讀到 team22 的完整序列（tick12800→14720），是個可讀的真實棄置案例：

```
tick12810  紮根 committed（tile[11,8]）——真的紮根成功了一次
tick13040  迎戰（迎戰目標 target=[13,6]，疑似戰鬥/威脅事件）——被打斷
tick13500  紮營 committed 於新 tile[11,9]（原據點顯然保不住，被迫移動找新點）
tick13520-13700  ★連續7個cadence，「紮根」每次都出現在候選裡(try_set_noop=被考慮但沒贏)，
           但每次真正 committed 贏走的都是「買糧」——food壓力太大，紮根argmax打不贏買糧
tick13700起  放棄紮根，改投靠(併入)，持續14個tick、物理移動到target[10,8]
tick14000   投靠對象處抵達卻沒併掉(team22依然存在、pop仍2)——投靠被拒(呼應join reject genuine那條)
tick14000起  改覓食，之後逃跑/貿易，tile一路漂([10,8]→[11,7]→[13,7]→[15,7])，無固定據點到specimen結尾
```

**這是一條 motive→action→outcome 完整成立的放棄故事**：紮根成功→外部威脅打斷→試圖重紮根但食物壓力讓它argmax打不過買糧→退而求其次投靠→被拒→流浪。**不是決策盲派、不是執行卡死，是真實的多重壓力（威脅+食物+投靠被拒）疊加後的合理放棄**，對 `camp.abandoned=24`（83.3%棄置率）這個高棄置世界提供了一個具體、可信的樣本。

## root.won_argmax（5→1）但完工數持平（both=1）＝ 我沒有額外證據

這條 measurer 自己也標「推測性關聯，非坐實」——我這輪讀到的三隻隊（team8/15/22）樣本太小（只有1隻真正完工=team8），**沒有足夠案例能坐實或推翻「argmax 贏少了但 follow-through 比率變高」這個推測**。誠實列為未查，非我判定成立或不成立。

## 建議

1. **要驗「保住的 outpost」，需要 main 側 specimen（含 day0 owner team_id）**——建議下輪用兩趟法：先跑 main 抓出 day0 有 outpost、day90 沒了的 team_id，再同 seed 對 branch 那個 id 抽樣比對。
2. **team22 的放棄故事可以直接收進「棄置率」那條的案例庫**——是本輪唯一撞到的完整棄置序列，具體、可讀，建議存查。

地基 KEEP。
