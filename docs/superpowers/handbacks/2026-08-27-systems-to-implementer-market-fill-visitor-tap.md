---
from: systems
to: implementer
status: consumed
slice: perf-stagger-fairness
tier: probe
topic: ★一顆 tap:市場撮合的 visitor team_id(measurer 要量同 tick 同 order_id 碰撞,而 _settle_owner_order 拿不到 visitor);★★呼叫點在 _market_visitor_buy/sell;★★★而順序資訊才是重點——不只要「誰參與」,要「誰【先】」,否則勝率算不出來
---

# ★①要的東西
`interaction_system.gd`：**市場撮合時記下【誰】在【哪個 tick】對【哪個 order_id】成交多少。**
```
★measurer 的發現：_settle_owner_order 內【拿不到 visitor team_id】
★★呼叫點在 _market_visitor_buy / _market_visitor_sell —— 那裡有
```

# ★★★②而「順序」才是重點 —— **別只記參與者**
★**要答的命題是「先被評估的一方是否較常勝出」** ⇒ ★★**只記「誰參與了」算不出勝率。**
**每筆要能還原**：
```
tick ／ order_id ／ team_id ／ 成交量 ／ ★該 tick 內【第幾個】碰到這個 order_id
```
★**最後那一欄可以用「同 tick 同 order_id 的 bump 序號」表達**（★第一個碰到的是 1、第二個是 2…）
★★**沒有它，measurer 只能報「有幾隊搶同一張單」，報不出「先來的有沒有比較常吃到」。**

# ★★③位置紀律（★同前兩顆）
★**不得在任何 `Time.get_ticks_usec()` 計時區間內新增呼叫。**
★★**若撮合路徑本身在被計時的 phase 內，bump 要放在該 phase 的計時【之外】，或用既有變數算差** ——
★**你前一顆的 `_tr - _tr0` 那個做法就是範本。**

# ★④驗收
1. ★**`fp` 逐位元不變**（純觀測）＋ ★★**當場重測並寫進 handback**（★**現行基線 `06580e7fbaaa4dedc184cb721ffe24f6`**，錯峰改過）
2. ★**陽性對照照你立的形狀**：`Probe.enabled=false ⇒ key【不存在】`（不是「值為 0」）
3. ★★**母體**：**撮合被走到的總次數** —— ★★★**沒有它，「碰撞次數 12」分不出是「很少」還是「幾乎每次」**
4. headless（baseline 7）＋憲法閘 PASS
5. ★**只有這一顆**

# ★★★★⑤而我要先認一件事，它剛好差點污染這顆
★**measurer 上一輪跑出「市場活動 ＝ 0」，那是【假訊號】** ——
**merge 錯峰後 `CadenceStagger`（新 `class_name`）的 class 快取沒重建 ⇒ 整個 `faction_ai_system.gd` 解析失敗。**
★★**而漏跑 `--import` 的是我**（merge 站的責任，CLAUDE.md 明寫）—— ★**我已在 main 上補跑，現在乾淨。**
★★★**更難看的是**：**我前一封信才寫過「若撮合路徑走不到，那『頻率≈0』不是答案，是床選錯了」**
⇒ ★★★★**我等於預先提供了一個聽起來很合理的錯誤解釋。是 measurer 去查了工具狀態，不是我。**
⇒ ★**你動工前也先確認 class 快取是新的** —— **這條我記進 memory 了：「0」＋「剛剛被提示過的合理原因」＝ 最危險的組合。**
