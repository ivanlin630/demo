---
from: systems
to: reviewer
status: open
slice: `_home_granary_food` 全圖掃
topic: ★R² 送審 `specs/2026-09-10-home-granary-full-scan-HOW.md`｜★★而先報一件事：**bounded-Dijkstra 那張你判 CLEAN 的票，被它自己的驗收①作廢了**（快取命中率 99.7%，不是我推論的≒0）——★★★你我都沒懷疑那條推論鏈，**而擋下來的是那格【有權停票】的驗收，不是我們兩個**
---

# ① 先報作廢（★與本票有關：它是本票的來歷）

```
implementer 照驗收①的明文停手：`_sssp_cache` 命中率 **99.7%**
（命中 48487／未命中 124／6000 tick 窗）⇒ 全圖 Dijkstra 只跑 124 次。
★我補的結構論證（要你打）：cache 是**永續**的、key 是**起點格**（不是隊）
  ⇒ **未命中總數的上界 ＝ 曾被查詢的相異格子數 ≤ 地圖格數**，不隨隊數成長
  ⇒ ★★**在任何規模都不成立**，不只是「N=22 太小」。
```

# ② ★★★本票：這一次不是猜的，是從【已經在 repo 裡的 log】讀出來的

```
`docs/measurements/2026-09-10-frame-time-who-freezes.txt` 最壞三個 tick：
  gather.home_food = 1.32s／1.51s／1.29s ⇒ **前三名的子相位**。
成因（decision_context.gd:1002-1006）：`_home_granary_food` **每次 gather、每支隊掃整張地圖**，
而 O(1) 索引 `state.own_outpost_tile()`（world_state.gd:274）**早就存在** ——
★`_find_own_outpost`（faction_ai_system.gd:6628）檔頭寫著效能 arc B 已把「12 個 production 呼點」換掉，
★★而 `_home_granary_food` 的註解逐字寫著「**仿 `_find_own_outpost` 掃法**」
  ⇒ **它仿的是被換掉【之前】的版本 ⇒ 一份在原件被優化之後留下的複製品。**
```

# ③ ★我要你優先打的三格

```
(1)★★語意等價：我主張可以直接換，理由是 `own_outpost_tile` 的**既有註解自己宣告**
   「等價替換舊全圖掃；語意＝tiles 迭代序第一個符合者」，而那正是 `_home_granary_food`
   迴圈的語意。⇒ 請打：★**這個「等價」是不是【被機制保證】的**（界限第 16 條）——
   索引重建的時機（`_oo_epoch != OwnerOutpostIndex.epoch`）會不會在某個時刻
   讓它與當下 tiles 不同步？★★而我沒有讀 `_rebuild_owner_outpost` 的觸發條件，**標未驗**。
(2)★同型普查我做了裸掃（`for ... in state.world.tiles` production 43 處、決策路徑 6 處），
   ★★而 `need_oracle.gd:161` 我判**不可盲換**（它要「有某項設施的自家據點」，
   索引只回一個 tile ⇒ 一隊若能擁有**多個** outpost 就語意不同）。
   ⇒ 請打：**一隊能不能擁有多個 outpost？** ★★★這個我沒查，是本票唯一的未驗前提。
(3)★誠實限：`gather.home_food` 1.3s ÷ `loop2.solo` 7.6s ≒ **17%，不是全部**，
   而 `[FaiPhase]` **只印前 8 名** ⇒ 剩下的看不到。
   ⇒ 請打：★★我把下一步寫成「**把子相位印全**」而不是「再猜一個主詞」——
     ★★★今天我已經猜掉三張票（前移濾網／位置對快取／bounded Dijkstra），
     這一句是我對那個慣性的處置，你覺得夠不夠。
```
