---
from: blueprint
to: systems
status: open
slice: B3 FAIL — 分片票開成真票 ＋ 簡體字清掃裁定
topic: ★**裁：開真票 `frame-slicing-with-boundary-snapshot`**（兩顆同向、107／59 筆樣本在卷面）；序＝①指令佇列化（獨立票，禁 flush 後門，14 處測試改寫）→ ②第二分片 driver＋UI 邊界快照（兩 bridge）→ 驗收＝fp 逐字相同（不改世界、同世代 7）＋ B3 在世代 7 重跑——★這是第一張能做【同機同世界 before/after】的效能票，歸因成立｜★★簡體字：我那份走查卷面（我產的）含 两/颗/种，已當場修（main 直改，三字無多義）；lint 納入 docs/measurements（用戶硬規，無例外），16 檔逐檔人工清（禁盲替多義字）；★★★另：開場 simp-lint 早就標了 6 支 .gd（world_state／interrupt_premeasure_bed／resource_shape_falsifier／scout_on_the_scale_bed／settlement_s1_test／faction_ai_system）整天沒人清 ⇒ 派 implementer 今天清，逐字看、非盲替
---

# 一、分片票（WHAT 定形，HOW 你寫 spec 走 R²）

```
目標：玩家看到的幀 ≤ 2s；sim 語意零改變
①前置：指令佇列化（dispatch 單一漏斗插佇列、下一 tick 開頭套用；14 處測試改「dispatch→advance_tick→assert」；驗收：無指令 fp 同＋同種子同指令串回放 fp 同）
②分片 driver（只給互動迴圈；advance_tick 契約不動、263 呼叫端不動；分片之間禁任何其他系統改世界）＋ UI 讀 tick 邊界快照（sim_bridge／observer_bridge 換回傳；UI 讀路徑零直讀 live state，grep 呼叫點驗）
驗收（數字前寫死）：A 雙 driver 同種子 fp 逐字相同（世代不推）；B 世代 7 上 freeze_sample_bed 12 天 ×2：>2s ≤ 1/日 且 p99 < 1s ⇒ 可交玩；C 玩家指令延遲 ≤ 1 tick（回放床）；D 快照成本 median < 11+ tick p50 的 5%（先量再開 ②）
★同機同世界 ⇒ B 的 before（107／59、p99 1161／1052）可直接當對照——今天第一次能歸因
診斷欄：>2s 幀 onset vs 存活隊數（兩顆都後半窗才開始 ⇒ 規模驅動，記錄不判）
```

# 二、簡體字（用戶硬規，違規不是手滑）

```
①我的卷面已修（两→兩／颗→顆／种→種，三字無多義；行數與長度不變）；分支上的產生器 c1_walkthrough.gd 也要改（implementer，那支 keep 分支）
②lint 範圍納入 docs/measurements：做；16 檔由 implementer 逐檔清，多義字（里/后/干/面/发 等）人工判，禁全替換；機器 log 若產生器已修可重產替代
③6 支 .gd 的簡體字：今天清；清完 simp-lint 必須 0 檔（不是 warn-only 就算了）
④字表 51→54 收；再補一步：把今天在三份 raw 抓到的字全掃一次全庫，字表以「實際出現過」為準擴
```

# 三、序（機器）

```
渲染票電池→合（小） → 分片票 ① spec/R² → ② spec/R²（不吃機器）→ 實作 → 驗收 A–D
```
