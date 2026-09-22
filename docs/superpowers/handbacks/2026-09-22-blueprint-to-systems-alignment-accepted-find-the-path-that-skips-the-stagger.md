---
from: blueprint
to: systems
status: consumed
slice: 週期性 — 裁定 ＋ 下一格
topic: ★**(b) 排程對齊成立（60 tick 佔 99%，60＝一遊戲小時，資料自己給的）**｜★★修法票先不開，收；下一格＝「11+ 那些 tick 的決策者來自哪條路／哪一層」——而這是補丁閘優先查的形狀：錯開機制在跑卻仍對齊 ⇒ 最可能是【某條每小時整點掃全隊的路沒走 CadenceStagger】；預註冊三格在下｜★★★同時印尖峰 tick 的 n_deciders 分佈（median／max／佔存活隊比例）——「11+」是桶的下緣，不是數
---

# 一、(b) 成立：收。錯開已存在 ⇒ 「加錯開」不是修法，對。

# 二、下一格（預註冊，數字前；既有 tap 加層／路徑標籤，兩顆種子）

```
量：在 n_deciders ≥ 11 的 tick 上，每個決策者標【觸發路徑】（呼叫 gather 的那個 call site：faction_ai T1/T2/…、strategic、salary、reaction…）與【該路徑是否經 CadenceStagger.next_tick 排程】
    另印尖峰 tick 的 n_deciders：median／max／÷存活隊數
判：
 (i) ≥ 80% 的尖峰決策者來自同一條路，且那條路【不經】CadenceStagger（例：`if tick % TICKS_PER_HOUR == 0` 掃全隊）
     ⇒ 補丁閘形態：把那條路接回 stagger（零新旋鈕，offset 沿用 _mix(team_id)）⇒ 世界改變窗 #3、世代 7
 (ii) ≥ 80% 來自同一條路但它【經】stagger ⇒ stagger 沒散開：查 _mix 在該 cadence 下的值域（是不是恆 0 / 只有 3 個值——「相異間距只有 3 種」正是這個指紋）⇒ 修 _mix 或 offset 作用域 ⇒ 窗 #3
 (iii) 跨多層各佔一份（無一路 ≥ 50%）⇒ 你 §三的整數倍假說：層與層在 60 格子上疊 ⇒ 修法＝每層一個相位（由層 id 派生，零旋鈕）⇒ 窗 #3
 ★三格的修法都改變世界 ⇒ 都進窗 #3；差別是改哪裡與多大，數字回來再開票；驗收同一把尺（>2s 幀數／p99／median，HW-2）
```

# 三、其他線

```
指令佇列化：獨立票、自身值得（決定性），搭窗 #3 同批；分片＋快照：登 defer，門票＝窗 #3 後 >2s 仍 > 1/日
equip_mobilize 整體票、subteam-idle：序不變，在這條之後
```
