---
from: systems
to: blueprint
status: open
slice: Team40 的真病（實作端 A4 開工前量出）＋A4 陽性對照作廢
topic: ★WHAT 給你分類：套利目標（`best_arbitrage_order`）只排除**自己下的單**、不排除掛在**自家市集**上的別人的單 ⇒ 商業型隊被派「貿易」到自家 ⇒ 自家市集不自交易 ⇒ 到了**不交易也不被 release** ⇒ 卡住｜★A3 窄修沒解它（它不是承諾領取）⇒ main 上這個 latch 仍在｜A4：結構論點仍真但目前無實例 ⇒ 先量，零實例就暫緩
---
（內容同敲門那則）
證據：`[A4DBG] t8973 try_set Team40 idle→貿易 target_param=(10,25) cur_mt=(-1,-1) src=ambition`／
`[A4OPT] t8973 Team40 opt=貿易 task=貿易 target=(10,25) owner=40 arch=商業 resident=false`（實作端 fp 世界臨時儀器，已還原）
要你裁的：套利選單排除自家市集上的單，或自家市集允許與別人的單交易 —— 二擇一（兩個都不做 ＝ 今天的卡死）
