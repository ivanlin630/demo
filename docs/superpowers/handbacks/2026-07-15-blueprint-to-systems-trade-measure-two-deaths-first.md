---
from: blueprint
to: systems
status: consumed
topic: "[貿易·先量再spec] B願景鎖定(貿易該有threat韌性)但修向待證——兩死法都沒坐實:①387半路掉因是推的非traced(逐merchant追真掉因:切threat?過期?timeout?目標消失?)②meet_nodeal12/14全黑(patch-gate-first挖到場為何不成交)。兩死法量級+真根都確認才spec,別修錯層第6次"
---

# 貿易 binding：先量兩個死法真因，再 spec（用戶定「先量」）

用戶選 **B 願景**（貿易該對 threat 有韌性），但**先量再 spec**——我這 arc 錯 5 次，這回還有兩個沒坐實的洞，別急著修。

## 情境（漏斗數字翻成故事，對齊我倆理解）
商隊「阿商」6 個月想做 404 次生意（dispatch 404）：
- **死法一（387 死這，96%）**：上路後半路放棄，只 17 次真到目的地（arrive 4.2%）。
- **死法二（到了 12/14 談崩，86%）**：拚死走到了，站對方門口卻不成交。
- 結局：404 念頭 → ~2 筆成交。商業=死。

## 兩死法都沒坐實（別重犯 overclaim）

### 死法一：387 掉因是「推」的，不是 traced
trace 只看到「387 個沒到」，**沒證** 387 是切去 threat/flee task。系統是**從常數推**（`PRIO_THREAT 70 > TASK_TRADE 50` → 「應該」被 override）。**這正是我這 arc 一直犯的：從 code 規則推機制，沒 trace 實際掉因。**
- **要量**：逐 merchant specimen 追 387（或抽樣）**離開 trade 的實際那一 tick 發生什麼**——task 切成 threat？訂單過期？目標村消失？路被擋 timeout？**掉因分佈**（threat X%／過期 Y%／其他 Z%），別只一個假設。

### 死法二：meet_nodeal 12/14 全黑（可能是更深 binding）
arrive 17 → 成交 ~2，到場 86% 談崩。**系統自己說「待挖」= 沒 root。**
- **要量+挖**：到場那 12 次**為何不成交**——對方非 settled 移走了？供需窗口已變？price 對不上？兩隊差一格 co-location 沒真重疊？patch-gate-first 挖 `_attempt_trade_direction`／settle 那站。

## 為何先量：單修一層救不活（算給你看）
```
404 → 17   死法一 (96%)   掉因=推的
17  → ~2   死法二 (86%)   全黑
```
- 只修死法一（threat 韌性）→ 404 全到 × 14% 成交率 = ~57 deal（若 nodeal 不變仍瘸）。
- 只修死法二 → 17 × 100% = 17 deal。
- **∴ 兩層都是真 binding，得都坐實。若真因偏死法二（到場不成交=transfer/站位 bug），給商隊壯膽（B 韌性）沒用——到得了照樣空手回，修錯層第 6 次。**

## 授權範圍（先量，不 spec）
1. **量死法一掉因分佈**（measurer merchant specimen，387 離開 trade 的真 tick 因）——坐實「threat 韌性」真是那 96% 的解。
2. **量+挖死法二 meet_nodeal**（patch-gate-first `_attempt_trade_direction`/settle）——到場不成交真根 + 佔比。
3. **line 252 accessor**：正交、code 已確定 valid，**可先收不等量**（你上封提的，收全第 3 讀點）。

## 下一站
兩死法真因+量級都坐實 → 回我 → 我定修向（B 韌性修死法一 + 死法二真根修法）→ 系統 spec（含 line252 收全）→ reviewer R② → impl → measurer 中性 full-HD（arrive% 升 + deal 真發生 + coin 三池動）→ 我批。
**B 願景鎖定不動；修法待兩死法坐實。先量再修——這次別再從規則推劇情。**
