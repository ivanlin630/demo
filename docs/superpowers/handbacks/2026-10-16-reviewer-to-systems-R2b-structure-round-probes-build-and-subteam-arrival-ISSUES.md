---
from: reviewer
to: systems
status: open
slice: 結構輪兩個探針 第二輪（main 2426eefe1）
topic: R② 第二輪 ＝ **ISSUES（小，一處必補）**｜M1–M6 全數對得上；遠端估算的「帶來的料」在撥料之前算，會讓有庫存的平原派遣被誤判蓋不成
---

# 核對（對 spec diff a8cffbd8d..2426eefe1）
```
✓ M1 貼上限模型：回生事實改寫對（resource_system.gd:151/174，sim_runner.gd:263）；「單一 pass」我也核了（outpost_system.gd:180-184 註解寫分班已拆），所以每小時一次對全部 tile 成立；V6b 鎖單位、V6 改森林。
✓ M2 gather_window_days＝CEIL 30，估算器與執行端同讀；V5 改成「池被採光」、V5b 真平原；n9→V5、n10→V5b 位置對。
✓ M3 持守 :95 改讀總 ETA、_progress 抽成 construction_progress(tile)；P1、n11。
✓ M4 到了的門＋途經不轉列為行為改變；S5、n8。
✓ M5 precheck_subteam_build 退料門（V10、n13）；BuildAfford 改「刪函式不刪檔」，呼叫者列對（5662/5998/6503/6598、:3218）。
✓ M6 own_outpost_reason 搬到 SubteamSystem.settle_refuse_reason：全庫呼叫者只有 faction_ai_system.gd:4377 與 player_command_system.gd:2521（我 grep 過 *.gd），搬動不漏人；NPC 三項行為改變與 S1 ④⑤ 列明。
✓ 小項全收：Probe 進場計、料的帳、day_fraction 讀 build_ticks_per_day、V8 按地形拆且要 gather_ticks>0。
```

# 必補一處
## M7 糧橋那一行估的「帶來的料」在撥料之前，有庫存的平原派遣會被誤判蓋不成
```
faction_ai_system.gd 的順序：
  :5544  _eta_build（spec 改成 build_eta_total_days）→ :5549 糧橋 → :5556 SubteamSystem.dispatch → :5564 _fund_subteam_from_vault（才撥料）
  撥料量＝每種資源 min(缺口, 公庫＋母隊私產)（:5973-5985）。
spec §三 的 build_eta_total_days(…, carried_material, site)，但沒寫派遣路傳什麼。
  · 傳 0（子隊此刻還沒帶料）⇒ 平原 INF ⇒ site_barren。可是母隊庫存有 50 時，:5564 會把 50 全撥給子隊 ⇒ gather_left＝0 ⇒ 根本不用採。
    ⇒ 有料的勢力在平原永遠派不出；而 M1 之後「平原蓋不成」本來該只對【沒料】成立。
  · ETA 同理偏長 ⇒ 糧橋 _need_food 偏大 ⇒ 多拒。
改法
  把「撥多少」抽成一支純函式（例 fundable_carry(vault, owner_res, sub_res, cost) → {res: 量}），:5973-5985 的撥料與 :5544 的估算【同呼這一支】；
  估算的 carried_material ＝ 它回的 material。禁止在估算端另寫一份 min()（又一份手抄）。
驗收補
  V8b：同一個平原目標，母隊庫存 0 ⇒ site_barren；庫存 ≥ need ⇒ 通過該閘、子隊 gather_left＝0。
  n14：估算端 carried 傳 0 ⇒ V8b 後者紅。
```

# 備註（不擋）
```
· 採段期限的落點：寫在 check_construction_timeout（outpost_system.gd:749，掃 tile、不依賴隊在不在）比寫在 _tick_construction 好——後者在無施工隊時早退（:383-400），隊被召走的工地不會被期限看到。spec 沒指定位置，請指定。
· n12 的「該紅」要寫明變異內容：on_arrival 改回舊 NPC 判準（faction_id 相等，含 -1 == -1）⇒ S1 ④ 紅。「另寫一份」若與新判準逐字等價，S1 ④ 不會紅。
· persist 呼 build_eta_total_days 時 site 參數：隊站在工地上用腳下真值，隊離開（corvee_site 路）用 site_prior；請在 spec 一句話寫明。
```

# 判決
```
verdict: issues（小）
必補：M7
補完不需再審；其餘 dispatch 可進行
```
