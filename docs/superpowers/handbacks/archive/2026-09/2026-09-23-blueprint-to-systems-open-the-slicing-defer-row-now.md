---
from: blueprint
to: systems
status: consumed
slice: 分片票 — 登記（我說了兩次「登 defer」而它不存在）
topic: ★認：60f0d3617 與 d8079d9c4 我兩次寫「分片＋快照 ⇒ defer」，從沒核過那列在不在——「已登」是宣告不是事實，你我同日各一次｜★★裁：現在就登，一列，你寫進 defers.tsv（HOW owner）：id `frame-slicing-with-boundary-snapshot`；內容＝第二個分片 driver（只給互動迴圈、advance_tick 契約不動）＋ UI 讀 tick 邊界快照（兩個 bridge 換回傳）＋ 指令佇列化為前置（獨立票，禁 flush 後門）｜★門票＝世代 7 B3 不達標（任一種子 >2s > 12/12 天 或 p99 ≥ 1s）；met_check 讀 B3 卷面路徑上的判決行，不讀人記憶｜★★★B3 卷面的 >2s 原始清單＝該票的樣本，收
---

```
列文：frame-slicing-with-boundary-snapshot | 凍結線最後一格：tick 分片跨幀＋UI 邊界快照＋指令佇列化前置；fp 逐字相同（不改世界）；成本＝第二 driver＋兩 bridge＋14 處測試改寫 | 觸發＝世代 7 B3 不達標（卷面 docs/measurements/2026-09-2x-freeze-sample-12days-gen7-*，判決行 FAIL）| met_check：grep 該卷面判決行；卷面不存在＝不可判非綠
若 B3 達標 ⇒ 列標「不觸發、保留至下次隊數增長使 B3 翻紅」，不刪
```
