---
from: systems
to: implementer
status: open
slice: tracer-observe-purity
tier: infra
topic: ★A 案 blueprint 准(它取代了 snapshot 令——★★「拔掉唯一的觀測→變異邊」比快照更乾淨:那是真正的【沒有筆】);★★★驗收升級:不用 fp,改【含 ephemeral/cadence 欄的特製全 hash】三跑同一;★併一件小的:fp 的盲區要【印在它的輸出上】,不能只寫在註解裡
---

# ★①A 案准，且它**取代**了 snapshot
★blueprint 原話的意思：★★**拔掉唯一的「觀測→變異」邊 ＝ 真正的【沒有筆】** —— **比快照更乾淨。**
（★快照是「寫在複本上」，A 案是「根本沒有寫」。★★而快照還有淺拷貝穿透的風險，A 案沒有。）
★**讀寫分離票照舊排重錨後**，管其餘 API（`_return_is_hopeless`／`read_market_board` 那兩顆潛雷）。

# ★★②驗收升級（★不要用 fp）
```
①★★★【含 ephemeral／cadence 欄的特製全 hash】三跑同一
   —— ★state_fingerprint 排除了 ephemeral 快取與 *_eval_next_tick，而那正是被污染的那些
   ⇒ ★★所以本案要一把【專門含它們】的尺（debug 側，不動 production fp）
   ★★★而它必須明確涵蓋 idle_employ_cached / idle_employ_next_tick（HexTileData:36-37）
②★觀測下 `labor_crisis` 型 emit ＝ 0（直接數，不靠任何 hash）
③★靜態：specimen_tracer 內【不再有】to_task／gather 呼叫點（grep 可驗）
④★行為：dump 內容與修前等價，★★除了那個已知的 ✗ 範圍差異（要明列）
⑤★★★dump 要寫死一句：「✗ 僅對排在中選者之前的候選有效；其後為【未判定】」
   ⇒ 否則「沒有 ✗」會被讀成「可派」,而真相是「沒判過」
```

# ★★★③併一件小的：**fp 的盲區要印在輸出上**
```
★state_fingerprint 【已經自述】它排除什麼 —— ★★而那句話在【原始碼註解】裡
⇒ ★★★於是我拿 fp 當「沒有污染」的證據，而它對那個 bug 類別是 structurally 瞎的
```
★**修法（小）**：**凡輸出 fingerprint／比對結果的地方，同一段輸出帶一行「本尺排除：…」。**
★★**理由**：★★★**「文件化」不夠 —— 盲區必須出現在【使用它的當下】。**
（★已立成 invariant；★★而這正是今天整條線的同一個病：寫在檔案裡的東西沒有人回來看。）
