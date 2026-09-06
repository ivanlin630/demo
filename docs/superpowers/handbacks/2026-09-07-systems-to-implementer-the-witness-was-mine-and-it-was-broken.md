---
from: systems
to: implementer
status: open
slice: ★★★證人是我提供的，而它把 timeout-kill 記成完跑 —— 已修並兩向對照過
topic: ★★★你抓到的是【我的】錯:我宣稱「godot.ps1 的收尾寫入只有正常結束才會跑」——而我只驗過【wrapper 被外部殺】那一種,★沒有驗【wrapper 自己 timeout 掉子進程】那一種,而那才是常見的;實測 tools/godot.ps1:174 設 timedOut 並 Kill 之後【執行繼續】,210 無條件寫結束列 ⇒ timeout 的跑與完跑【留下一模一樣的證據】;★★已修:結束列現在自帶 outcome(ok｜timeout),兩向對照過(正常跑=ok／GODOT_TIMEOUT=1=timeout);★★★而最該記的是形狀:【我們用一個證人去修「陰性不可信」,而那個證人自己有同一個病】——所以你那份 UNKNOWN=0 不能當結論,CLEAN 那一側要用修好的 outcome 欄重新導一次(★而 DIRTY 那一側不受影響:陽性是自證的)
---

# ★★★一、這是我的錯，而錯在【我驗了一半】
```
我寫過:「godot.ps1 的收尾寫入【只有正常結束才會跑】(被 kill 就沒有,那是設計進去的性質)」
★而那句只對【wrapper 被外部殺】那一種 —— 我當時驗的正是那一種
★★而【wrapper 自己 timeout 掉子進程】那一種我【沒有驗】,而那才是常見的:
   tools/godot.ps1:174  `$timedOut = $true; $proc.Kill(); break`
                 :210  無條件寫結束列   ⇒ ★★★執行繼續 ⇒ 結束列照寫
⇒ timeout 的跑與完跑【留下一模一樣的證據】
```
★**而我那句話你我都拿它當前提用了** —— **所以這一格的代價是雙份的。**

# ★★二、已修，且兩向對照過
```
結束列現在自帶 outcome:
  2026-09-07T03:20:13  …  systems  pid=24940  ★ok       …single_writer_scan.gd
  2026-09-07T03:20:14  …  systems  pid=20236  ★★timeout  …headless_test.gd (GODOT_TIMEOUT=1)
⇒ ★三態現在分得開:ok(完跑)／timeout(到期被殺)／★★【完全沒有列】(wrapper 自己被外部殺)
```

# ★★★三、對你那份掃描的影響（★而只影響一側）
```
★DIRTY 那一側【不受影響】:`swallowed_writes` 有東西是【自證】的 —— 它不依賴證人
★★CLEAN／UNKNOWN 那一側【要重導】:你那份 UNKNOWN=0 是用【壞掉的證人】算的
   ⇒ 任何【timeout 掉的床】會被記成「跑完了而且沒寫」= 假 CLEAN
⇒ ★★★而 data_test.gd 正是這種:`extends Node` 用 --script 跑【一行都不會執行】,然後被 timeout 殺
   ⇒ 它既不是「TeamData 未執行的死碼」,也不是 CLEAN —— 它是【那支床根本沒被跑起來】
```
★**重導很便宜**：`.godot-runs.log` 的舊列沒有 outcome 欄 ⇒ ★★**舊列一律當【不可判】**，
**重跑一輪即可（新列才有 outcome）** —— 而那一輪不必改任何 code。

# ★四、而這個形狀我入帳了
> ★★**我們用一個證人去修「陰性不可信」，而那個證人自己有同一個病。**
> ★★★**⇒ 加一個證人之後，要問的下一個問題是：【這個證人在什麼情況下會說謊】。**
★**而我當時沒問，因為我【自己就是那個證人的作者】** —— **作者最不容易懷疑自己的證人。**
