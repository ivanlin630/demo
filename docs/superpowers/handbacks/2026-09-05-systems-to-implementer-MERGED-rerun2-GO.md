---
from: systems
to: implementer
status: open
slice: ★兩票已 MERGED ＋ seg1 重跑（第二輪）開跑
topic: ★兩票一起 merge、17 支全綠 306s、已 push;★★而 headless 那支我裁了:`task=建設`→`task=投靠` 【不是文字是行為】—— 那隊現在真的去投靠了 ⇒ ★★★它是【修法生效的證據】,不是迴歸;我證了失敗清單 9 條逐條對應才重錄,並把理由寫進 baseline 檔頭;★重跑 commit=e59ee54c,凍結已重建
---

# ①已 MERGED（★兩票一起，理由已講過）
```
★共位必見:同格未偵測 880 → 0;床有鑑別力(main FAIL=1／branch FAIL=0,陰性對照兩邊綠)
★★共位互動:控制床 resolve 0 → 1;★★★interaction_system.gd 【74 insertions / 0 deletions】
   ⇒ 「不新增語意只新增入口」拿到的是【機械證據】不是宣稱
★perf:near.interact 2.7–5.0ms vs near.faction_ai 0.57–2.22s ＝ 整 tick 的 0.2–0.5%
★★17 支全綠 306s｜commit e59ee54c｜凍結已重建(plan=C-seg1-RERUN-2)
```

# ★★②headless 我裁了 —— **那不是文字，是行為**
```
★差異:[g1a] 礦村未鑄幣 那條的 `task=建設` → ★★`task=投靠`
⇒ ★★★那隊【現在真的去投靠了】—— 共位互動讓 JOIN 走得通
⇒ ★所以它是【修法生效的證據】,不是迴歸
★而我照今早那條做:【證內容沒變才重錄】—— 9 條逐條對應、HARD-FAILS 仍是 3
★★理由已寫進 baseline 檔頭(★下一個人不必重新考古)
★★★而你【不自己刷 baseline】是對的:那一格是我的,而「誰能刷 baseline」本身就是一道閘
```

# ③★而你標的那個 #4 證據形狀，我要指名
```
★你寫:去重「先查後標 ⇒ 結構性 0」,而【它的證據是 dedup_prevented=928 非 0】
⇒ ★★那正是「fails=0 要配 checks>0」的正確用法:
   ★★★單看「重複 0」無法分辨【真的沒重複】與【去重根本沒跑到】—— 而 928 把它分開了
```

# ④重跑（★參數與上輪相同，只有 code 變）
```
world=peaceful_economy_regime｜seed=1337/42/7｜90 日｜★commit e59ee54c
★表頭四格照舊 ＋ ★★存活【四分】(穩定/瀕死/卡在單一迴圈/死) —— blueprint 裁的,這輪要照它填
★★★而「怎麼跟舊卷比」多一條:除了「誰在贏」不比之外,★【吃偵測的那些格也不比】
   (遭遇/威脅/施主/JOIN —— 它們的產地在【共位必見之前】)
★而 #2 的世界層數字(JOIN dispatch/resolve)★這輪順便拿 —— 那是我們一直缺的「多常發生」
★★每張跑完【立刻】四格對帳;檔名帶 run-id e59ee54c
```
