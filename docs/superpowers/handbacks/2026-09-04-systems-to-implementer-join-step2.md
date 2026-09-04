---
from: systems
to: implementer
status: open
slice: 併入根因【第二步】—— ★而第一步的判讀表是我寫錯的
topic: ★你讀 tap 的【定義】而不是只用它的名字 —— 而那正是我漏做的:我引用 join.dispatch 時只確認它【存在】,沒確認它【數的是什麼】(它在任一方是 JOIN 隊時就 bump,不要求對方是目標)⇒ ★★我的三分支判讀表因此選不出來,那筆算我的,已入帳;★★★而現有數字已經指向一個方向:80 個 committed 意圖 → 只有 7 次「遇到任何人」→ 0 次 resolve、5 次 timeout ⇒ 漏斗【非常早就塌了】,而缺的判別量是【有沒有遇到它的目標】
---

# ①我的判讀表寫錯了（★先講清楚是誰的）
```
★我寫「dispatch = 0 ⇒ 從沒相遇／> 0 而沒併成 ⇒ 對象對不上」
⇒ ★★而 join.dispatch 在【任一方是 JOIN 隊】時就 bump,不要求對方是它的目標
⇒ ★★★所以 7 與 0 沒有矛盾:那 7 次可能全是【遇到不相干的隊】,不觸發 handler 是【正確行為】
★通則已入帳:寫判讀表時,每一格要附【那個量的 bump 條件】,不是只附名字與行號
```

# ★★②而現有數字已經指向一個方向（★而我不下結論，只說它指向哪）
```
optpool.win.併入 = 80 ｜ join.dispatch = 7 ｜ join.resolve = 0
arrived_no_handler = 0 ｜ abort_ghost = 0 ｜ ★join.timeout = 5
⇒ ★80 個 committed 意圖 → 只有 7 次「遇到任何人」→ 0 次 resolve
⇒ ★★漏斗【非常早就塌了】—— 而【不是】塌在 resolver(arrived_no_handler = 0 說它沒被叫到過)
```

# ★★★③第二步：**缺的判別量是「有沒有遇到它的目標」**
```
★要的(★儀器改動,現在解凍中 ⇒ 可做):
   ①`join.meet_target`  —— 相遇【且】對方 == social_target（★這才是我原本以為 dispatch 在數的）
   ②`join.meet_other`   —— 相遇【但】對方 != social_target（★★兩者相加 == 現有的 dispatch,可對帳）
★★而更前面那一段也要:
   ③每個 JOIN 隊【每日】與目標的距離 —— ★是不是在縮短?
      ⇒ ★★★而 team13 是 pop=1 的餓死邊緣隊:它可能【根本走不動】
        ⇒ 若距離全程不變 ⇒ 病在移動層(而不是相遇層)
   ④`join.timeout = 5` 那五次:★timeout 前距離縮短了嗎?
★而判讀:
   ①meet_target = 0 而距離【沒縮短】 ⇒ ★走不動 ⇒ 病在移動/體力/糧食門檻
   ②meet_target = 0 而距離【有縮短但沒到】⇒ ★★太遠/太慢 vs 窗太短 ⇒ 病在速度或目標選擇
   ③★★★meet_target > 0 而 resolve = 0 ⇒ 病在 resolver 的條件 ⇒ 那才回到我原本的第二分支
   ④以上都不是 ⇒ 照原樣報,不歸類
```

# ④紀律
```
★①②相加要 == 現有 dispatch（★對帳,否則新 tap 自己就有洞）
★★③是【逐日】不是總量:距離要看【軌跡】不是平均
★★★而這是儀器改動 ⇒ 不改世界;現在解凍中,merge 走正常流程
```
