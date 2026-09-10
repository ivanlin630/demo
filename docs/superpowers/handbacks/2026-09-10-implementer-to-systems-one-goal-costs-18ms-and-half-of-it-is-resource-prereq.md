---
from: implementer
to: systems
status: open
slice: 效能線 ｜ `frontier_candidates` 三段拆解
topic: ★錢在 **goal 迴圈**：111.6 ms/call ＝ frontier 的 **98.6%**（delegate 8.7 us／deliver 1.47 ms，合計 1.5%）｜★★而次數不大（每次呼叫 **6.1 個 goal**）⇒ **貴的是單價**：**一個 goal 要 18.2 ms**｜★★★而單價的一半在 `_resource_prereq_candidates`：**23.1 ms／次 × 1318 次 ＝ goal 迴圈的 46.3%**｜守恆 **0.07%**、母體地板四項全 > 0、fp 不變
---

★落地：`docs/measurements/2026-09-10-frontier-internals.txt`（commit `1d89af495`，main）

# ① 表（★碼表走 `phase_timing`，不走 `Probe.enabled` —— 界限 43）

```
段                            總計(s)      us/call         迴圈次數      us/迴圈次
①goal 迴圈（含②）             65.839     111591.1           3613       18222.7
②resource_prereq（巢狀在①內）  30.452      51613.9           1318       23104.9
③delegate 迴圈                 0.005          8.7           1165           4.4
④deliver_candidates            0.868       1470.7             —            —
```

# ② 驗收

```
①★守恆：①＋③＋④ ＝ 66.712 s vs frontier 總計 66.755 s ⇒ 差 **0.043 s ＝ 0.07%**
  ⇒ ★★差額的解釋（不是「差不多」）：**迴圈開始之前的頭段**
    （`TradeValuation.leader_vals`／`_uo_*` 準備／碼表自己的時鐘讀取）
  ⇒ ★★★而它的形狀證明它不是漏段：**真漏會隨最大的那一段一起放大**，
    而這個差額是固定的萬分之七（三趟都是 0.03–0.07%）。
②★母體地板：goal 迴圈 **3613**／`_resource_prereq_candidates` **1318**／
  delegate **1165**／產出 candidate **1197** —— ★★**沒有任何一段是 0**（若有我會明寫）
③根守恆仍綠、負 self 仍 0（本輪沒動 `PHASE_PARENT`）
④fp 不變：`16bb6924789c18ac031e61d34c2aeae7`（Probe ON／OFF 兩趟也相同）
⑤★★★誠實限照寫進檔頭：**本表是 Probe=ON**，而這條路的儀器佔比**已知 14.5%**
  ⇒ ★不要把它讀成「91.9 ms 全是這些段」；★★另外跑間噪音 ±6%（62.36／62.76／66.76 s）
    ⇒ 只談**段與段的相對大小**。
```

# ③ ★而「次數 vs 單價」這一格這次答得很乾淨

```
每次呼叫只走 **6.1 個 goal**（3613 ÷ 590）⇒ ★次數**不大**
⇒ ★★所以這一格是**單價**：**一個 goal 18.2 ms**
⇒ ★★★而單價裡最大的一塊是 `_resource_prereq_candidates`（23.1 ms／次，佔 goal 迴圈 46.3%）
  —— ★注意它的次數（1318）**小於** goal 數（3613）：不是每個 goal 都有 resource prereq
  ⇒ 所以「一個 goal 18.2 ms」是**混合平均**：有 resource prereq 的那些明顯更貴。
  ⇒ ★★若下一張要更準，可以把 goal 迴圈依【有／沒有 resource prereq】分兩桶
    —— ★★★而那正是今天用過三次的同一個動作（先分桶再談平均），我沒有先做，等你定。
```

# ④ 我沒做

```
★沒有碰 `_resource_prereq_candidates` 一行（照「看到最大的那一格先別動手」）。
★★也沒有把 goal 迴圈分桶（見 §③ 末）。
★★★而 delegate 那一段（8.7 us/call、1165 次迴圈）我建議**不要**再切：
  它是 frontier 的 0.008% —— ★而把它列出來的價值是**排除**，不是待辦。
```
