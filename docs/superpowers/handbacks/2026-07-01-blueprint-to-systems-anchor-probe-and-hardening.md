---
from: blueprint
to: systems
status: open
topic: ①指標specimen追蹤(1團+幾named,想什麼做什麼)診斷錨→行為(經濟真根,R1食物緩) ②平行P0加固+tick計時;為「終於看見emergence」鋪路
---

# 指標 specimen 追蹤 + 錨→行為診斷 + P0 加固

整合：經濟調查戳到更深問（目標錨可能有名無實）+ scaling 加固。收斂為「終於看得到 emergence」。

## 背景：我們卡在看不到 emergence
一路「機制✓/活世界戲✗」診不清，缺三地基：①錨真驅動行為 ②世界不卡死 ③看得到過程。三個補上 + 長跑帶 trace = 才第一次真看 emergence 湧不湧、卡哪。

## ① ★ 指標 specimen 追蹤（用戶指定的探針）
**指定 1 個「指標團」+ 幾個「指標 named」→ LOD-exempt 詳細 trace 其決策全程**：
- **想什麼**：這 tick/決策選的 **intent + driver（為何選）+ 參考的關鍵 belief + 秤過的候選 options（各自 util）**。
- **做什麼**：實際 action。
- **狀態**：pop / food（收支）/ rung / faction / 資源。
- = 每個指標一條**可讀的「決策 timeline」**（不是 end-state tally）。

**直接用途**：
- **診斷經濟真根（錨→行為）**：指標團 leader 的**致富/擴張 intent 到底 fire 沒、fire 了有沒有產生它命名的動作（賣貨賺錢/擴張）**。若致富沒接到日常交易 = 錨有名日常無實 = 經濟真根。
- 跟一個 climber/trader/potential-conqueror 走完一生 → 看攀爬/交易/征服**卡在哪個 tick 哪個決策**。

## ② 經濟：R1 食物 rebalance 緩，先查錨→行為
- **別急調食物**。food 給野心「牙」，但**先確認野心有牙齒接觸面（致富真驅動交易）**。
- 用指標 specimen trace **measure：致富/擴張錨驅不驅動經濟/擴張行為**。
- 若錨→行為斷（致富不驅動日常交易）= 經濟真根，修那個 wiring（比食物根）。R1 食物之後給張力（目標=獲取值得，非求生死亡）。

## ③ 平行：P0 加固（perf infra，獨立經濟設計）
scaling 評估：會爆但非重寫。P0 三項 targeted：
1. faction AI honor LOD（停止忽略 subset）。
2. tile→teams 共用空間索引（複用 sim_runner pos_map）→ 一次收多個 O(N²)→O(N)。
3. team_intel prune 進 erase_team。
- **+ #3 每-tick 計時**（tick 時長 log 帶 tick 數）+ **scaling bed 大 N seed 驗 tick-time vs N 曲線**（加固有效否）。
- 獨立於經濟設計，可即平行。**滅團潮 spike（最想看的大戲最會爆）尤其要收。**

## 收斂目標
錨 wiring 修好（若壞）+ P0 加固 + 指標 specimen trace → **長跑帶 process trace → 終於看 emergence 湧不湧、卡哪**。

## 待系統
1. **指標 specimen 追蹤**（1 團 + 幾 named，想什麼做什麼 timeline）= 先鋪，即用來 measure 錨→行為。
2. **經濟真根 = 錨→行為**（致富驅不驅動交易），指標 trace 查 → 回報。R1 食物緩。
3. **平行 P0 加固 + tick 計時 + scaling bed**。
4. #2 G3 Phase D 仍排其後。

先別調食物。指標 specimen 看「想什麼做什麼」→ 答錨真根 + 加固鋪長跑，為終於看見 emergence 收斂。
