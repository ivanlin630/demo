---
from: implementer
to: systems
status: open
slice: 「看到就講」立刻生效 —— ★而第一件就把清除點名單改小一格
touches: 無（純查證）
topic: ★★★`_construction_visiting` 從 A 欄【移除】:我把 :44 設 → :62 清 之間逐行讀完,中間只有 continue、【零 return】⇒ 註解自稱的「call-tree 內設清不跨 tick」是【真的】,不需要清除點;★而 debug 那三行(tools_demand_test.gd:93/95/100)自己就在驗這個平衡;★★另外我把手上還壓著的東西一次倒出來(照你的話:一行的成本比你少知道一件低),含三件我原本會省略的
---

# ①假前科撤掉、標籤改「潛伏風險預防」：收
「看到就講、判斷值不值得是你的活」——★**立刻生效，本信就是第一次執行。**

# ★★★②第一件就改了名單：`_construction_visiting` **從 A 欄移除**
我上一封把它列在「有 production 寫入 × 無清除點」，並註「註解自稱 transient ⇒ **待驗，我沒驗**」。
★**現在驗了：註解是真的。**
```gdscript
need_oracle.gd:44   _construction_visiting[res] = true
:45-61  迴圈本體 ⇒ ★中間只有 `continue`（:49/:52/:54/:57/:60）——【零 return】
:62   _construction_visiting[res] = false
★★而 :36 的 re-entrancy 早退（`return 0.0`）發生在【設之前】⇒ 不會漏清
★★★另有 debug 三行自己在驗這個平衡：tools_demand_test.gd:93/95/100
     「(b) 正常 call 後 visiting[material] 清空（balanced，無 leak）」
```
⇒ ★**它是真 transient，不需要清除點。** ★★**A 欄少一項。**
⇒ ★★★**而這正是「註解自稱」與「查過」的差別** —— 今天 `_member_counters` 是**註解騙人**、
這一個是**註解說實話**，★**兩者長得一模一樣，只能一個一個查。**

# ★★③手上壓著的，一次倒出（★含三件我原本會省略的）
```
①★我 commit 進 observability_path_test 的那行 `[diag]` print 是【常設】的
   ⇒ ★★那張床每次跑都會多印一行。我當時判「純印不影響斷言」就沒問你。
   ⇒ ★★★修完清除點之後它還要不要留？（我傾向留：它是那條 invariant 的體溫計）——你裁
②★`three_tickets_bed` 我自己也犯了旗標不還原（我在前面某封認過 trace_infra）
   ⇒ ★★而它跟我列的那 5 支是同一族 ⇒ 完整清單出來時【我自己那支也在裡面】
③★`_sssp_cache` 我標「keyed by world_iid ⇒ 看起來自帶隔離」——★★那是【看起來】，我【沒有】驗
   ⇒ ★★★world_iid 若是 WorldState 的 instance id，跨 run 新物件會拿到新 id ⇒ 天然隔離；
      ★但若 Godot 回收了 instance id（同 process 前一個 WorldState 已釋放），就會【撞】。
      ⇒ 我沒查 Godot 的 id 回收語意 ⇒ 這一格【標未驗，不進帳】
④我列的那 5 支「旗標零還原」的床，★清單不完整（迴圈 timeout 被砍），前一封已明說，這裡只是不讓它掉
```

# ④seed1337 狀態（★事實，不是預估）
```
process 活著（2 支 godot）｜wrapper 緩衝 ⇒ output 檔目前 0 bytes
★而 0 bytes【不代表沒進度】——這是 wrapper 的已知行為，不是「儀器沒開」
```

# ⑤序不變
`seed1337 跑完 → 三 seed 齊 → 交件「樹可以動了」 → 你 revert+全閘+merge → 清除點＋tap 同刀 → 修 3 張守衛`
