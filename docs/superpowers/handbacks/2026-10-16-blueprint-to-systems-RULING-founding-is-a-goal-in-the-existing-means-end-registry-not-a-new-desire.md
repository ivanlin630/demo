---
from: blueprint
to: systems
status: consumed
slice: 結構輪之後一張（新票）：開點登進既有長程目標表
topic: 回 Q-founding-desire-across-ticks-for-buy-then-go：要，但不是新慾望——開點＝07-24 means-end 目標表的一列（前置＝材料、地點），跨日持有與拆鏈都現成；沒自家據點的隊也要跑目標迴圈
---

# 用戶裁（2026-10-16）
用戶問「之前不是規劃作過了嗎 長期計畫那 part」。查了：是。

# 事實
- 2026-07-24 `long-range-planning-means-end`：`GoalRegistry` 宣告式前置（resource／location／manpower／facility／subgoal），`GoalResolver` walk 前置鏈，把「先補前置」的候選 `append_array` 進同一個 rank 池（`goal_resolver.gd:300-320`）；`team.goal_state` 持久、cadence 評估（`team_data.gd:191/384`）。
- 表上登的：5 種資源維持＋8 座設施發展（`goal_registry.gd:14-37`）。
- **開點不在表上**：今天是 `options.gd:59/73/130` 的 `settle_fit` 當場秤當場走的選項；S5 只是把 build/settle 型候選再包一層「派子隊做」。
- **沒自家據點的隊整個目標迴圈不跑**（`goal_resolver.gd:88`，自己註解寫著「不在清單裡的 goal 全落這個歸宿」）。最需要開點的正是這種隊。

# WHAT
1. **開點＝目標表一列**（`found_outpost` 之類，名字你定）：前置 ＝ 材料（成本表那筆，走既有 resource 前置 ⇒ 求解器現成的「買／採／守料」候選）＋ 地點（走既有 location 前置／選址秤，乙的採料天數項在這裡讀）。payoff 走折現未來流那行（禁 TEST VALUE 長住）。
2. **跨日持有**＝既有 `goal_state`，不另做「慾望」欄；承諾生命週期那行照舊（唯二出口：重派成任務／引擎解承諾）。
3. **沒自家據點的隊也跑目標迴圈**：:88 那個早返回對「開點」是補丁閘，退場；其他需要據點的目標照原規則不掛。
4. 現有的「當場秤當場走」四條路：**收斂成同一列目標的執行端**，不留兩套（結構輪「一動詞一身體」同方向）。帶得夠料的隊前置即滿 ⇒ 當天出發，行為不退化。
5. 別讓每隊都守 50 料：需求只從「已掛上的開點目標」來（§三之三的「承諾那一座」擴成「掛上的那一座」），掛不掛由 payoff 秤。

# 排程
結構輪之後一張（你提的位置，同意）。本票（§三之三）照現寫送審、派工，不等它。

# 已記
意圖帳「建點一個動詞、L1 要材料」行補 ★開點登進既有長程目標表；板結構輪探針行加一句；今日記一行。Q 信已消費。

# 自檢
- WHAT＝「用既有計畫層，不開新慾望系統」「開點是目標表一列」「沒據點也跑迴圈」；goal 名、payoff 公式、前置怎麼對到成本表＝HOW。
- 前提 file:line 坐實：goal_registry 登了什麼、goal_resolver:88 早返回、options.gd settle_fit 三處。
