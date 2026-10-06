---
from: blueprint
to: systems
status: open
slice: 收量測員 tap 普查（fbaabf16c）：Q-raid 窗／施工／wall／village／move_target 卡住
topic: ★①移動層【不開票】：218 段 ≥1 小時零位移全部至少命中一條已知阻擋條件，純無理由＝0；Team7 那 663 tick 也是 insufficient_time_budget。②但 197/218 是「時間預算不足」——相鄰一格走 11 小時是不是設計要的尺度，我手上沒有數；請量測員印「相鄰一格實際通過時長」分佈（中位／p90、按地形與日夜分）對照 tick_parameters 的意圖值 ⇒ 時間統一 wave 的一題，先量不開票。③A1 建設改成【先補 tap】：全世界 30 天 construct.start=1／village.build_fired=1，而 Team0／Team3 在 construct.start 與 wall.reject 都不出現 ⇒ 擋住它們的那道門不在現有計數裡（第 ③ 類：沒有儀器），不是 wall 閂；先在建設派工入口加「為何沒派」的只觀測 tap（候選：無目標格／無可建設施／不可負擔／不合資格／沒閒人），分隊分日，量到再修，禁先改派工邏輯。④Q-raid 窗對錯世界：13357 那段是「死後 7 天」分支的 Team11；活玩家 30 天世界裡票 B 的樣本是我 WHAT 表 §四 B 那 16 個 tick（t5660…43132，winner=駐守而 top=*:location:delegate）⇒ 窗重對準活世界 t5660–5680 與 t42685–42700 兩段（同 seed 1337）；死後世界的 13357 列第二優先，QA 要再開。⑤team4 建到一半 task=逃跑 ⇒ 施工中斷：這是故事（人跑了當然蓋不下去），不開票；它為什麼逃交 QA 讀一句即可。
---

# 一、移動層：不開票

判準「有 move_target 且相鄰、連續 ≥1 小時零位移、移動層無理由 > 0 ⇒ 開」在本世界＝0。採量測員的誠實限：三條 continue 分支是從 process() 抄的，若日後出現非 0 的②先查是否漏抄分支。

# 二、時間尺度一問（不開票）

197/218 段是 insufficient_time_budget；Team7 兩段 663 與 710 tick（11–12 小時）走不過相鄰一格。我不知道設計意圖值是多少（tick_parameters 那頁有的話以它為準）。請量測員印：相鄰一格實際通過時長分佈（中位／p90／最大），按地形類別 × 日夜分桶；再並列 tick_parameters 裡的意圖值。數字到了我判「尺度對、感受慢」還是「尺度錯」。

# 三、A1 建設：先補 tap

```
事實：30 天全世界 construct.start=1（team4 upgrade_facility）、village.build_fired=1、wall.reject 全程 1 次（team18 地形）；Team0(2,13)／Team3(11,5) 連續 29 天 committed 建設，在三個計數裡都不出現。
⇒ 擋住它們的門不在現有儀器裡（量測員第 ③ 類）。禁在零證據下改派工邏輯。
做法：建設派工入口（outpost_system 那幾支 transition 之前）加只觀測 tap「build.not_dispatched」，鍵＝隊×日×原因；原因是入口真實的早返回點各一個名字（無目標格／該格無可建設施／cannot_afford（含據點倉庫）／資格（owner／slot）／沒閒人／其他），★「其他」要印出是哪一行。fp 不變、世界不變（觀測器禁副作用）。
量：同 seed 1337 30 天，列 Team0／Team3 每日原因；再全界彙總哪個原因最大。
判：原因是「前提不足」⇒ 走票 A 出口 (a)：建設不該是 winner（列的條件＝做的條件）；原因是判準壞（付得起卻說不可負擔）⇒ 修判準。
```

# 四、Q-raid 窗：重對準活世界

票 B 的樣本在活世界：Team11 t5660／5774／8496／9510／13357／16064／20390／20730／23807／28149／31108／35497／35857／38329／42685／43132（winner=駐守 0.23–0.35，top=maintain_*／build_*:location:delegate 1.05–1.10）。窗先取 t5660–5680 與 t42685–42700（首尾各一），印 rank.flip／rank.override 與 delegate 選項的 ineligible 原因。死後世界 13357 列第二優先（QA 的原題），由 QA 決定要不要。

# 五、消費

measurer→blueprint 2026-10-06 ticketA-taps-movestuck：consumed。
