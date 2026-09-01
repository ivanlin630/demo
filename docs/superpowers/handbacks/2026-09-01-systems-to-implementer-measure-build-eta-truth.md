---
from: systems
to: implementer
status: open
slice: S6-build-unit-truth
tier: probe
topic: ★一顆小的、但它擋住整個 S6:量一座 farm 工地【實際花幾個遊戲日】;★★因為 S6 那張表的「舊」欄與 code 註解差 10 倍,而我不想用推導去改一張用戶核可過的表;★★★問題只有一個:`cost.ticks` 那個單位到底是 person-hour 還是別的
---

# ★①一句話問題
```
outpost_system.gd:48 註解自述：「ticks = person-ticks（pop=1 時 ×10 = world ticks：farming 72 ≈ 3 天）」
而 S6 的表寫「農田 舊 7.2 人時」 ＝ 0.3 天
⇒ ★兩者差 10 倍,而我需要知道哪一個是真的
```

# ★★②要量什麼（★不要量代理量）
```
★量【字面量】：一座 farm 從動工到完工,經過幾個【遊戲日】
★★而 pop 必須是已知且固定的（pop=1 最乾淨,若床做不到就記下實際 pop 並照它換算）
★★★不要用 ETA 估算函式的回傳值當答案 —— 那是【估算器】,而估算器正是我們在查的東西
   ⇒ 要的是【真的跑完】的天數
```
★**床已存在**：`scripts/debug/build_eta_single_source_test.gd`（★它自述「唯一權威是 `_tick_construction` 那行 `ticks_left -= maxi(pop, 1)`」）
—— ★★**看它能不能直接回答；不能就加一段最小的 dump，不要重寫床。**

# ★★★③兩個結局都要能分辨
```
≈3 天  ⇒ 單位 = person-hour ⇒ ★S6 表的「舊」欄低估 10 倍 ⇒ 我呈 blueprint 重定基準
≈0.3 天 ⇒ ★★我的推導錯,表是對的 ⇒ S6 照原表做
★其他值 ⇒ ★★★照實報,不要往兩個預期靠 —— 第三種答案比對上其中一個更有價值
```

# ★④紀律
```
★只量不修（production 0 行）
★★把 pop、起訖 tick、TICKS_PER_DAY 現值都印出來 —— ★★★否則「3 天」這個數字三個月後沒人能複驗
★這一票很小,別擴;換根微分那條線不受影響,照你原本的順序做
```
