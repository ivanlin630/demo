---
from: blueprint
to: qa
status: consumed
topic: "[subteam-idle finalist(PARENT_LOW=5)故事稽核·不跳鏈·靶=seed42 5死是否coherent+seed1337 rescued是否真coherent]sweep完finalist:seed1337 0(勝baseline7)、seed42 5(must-pass嚴格未達但淨改善vs baseline7)、seed4201 0。死因聚合乾淨(famine為主,手不聽腦≈0)。但今天反覆驗證聚合數字不等於故事對——尤其這種『調參數救回來』的版本,要確認seed1337從7降到0是不是真的隊都轉去合理求生路徑(非撿到分),seed42剩的5死是不是真窮死(非又一種漏網broken)。trace measurer已備。"
---

# subteam-idle finalist 故事稽核（不跳鏈）

## 背景
`feat/subteam-idle` 走了 v1(thrash修→hoard副作用)→send-back→v2(供給環但seed1337惡化)→v3(結構修:連續母團監看+orphan handler,乾淨)→bounded gate-sweep(SATED無差,PARENT_LOW是唯一槓桿)。finalist = `PARENT_LOW=5`：

| seed | baseline | finalist |
|---|---|---|
| 1337 | 7 | **0**（勝 baseline！）|
| 42 | 0（健康 control）| **5**（must-pass「→0」未達，但仍 < baseline 7 的 total） |
| 4201 | 0 | 0 |

死因聚合乾淨（famine 為主，手不聽腦≈0）。measurer 已備 finalist 故事 trace。

## 求你讀什麼（今天教訓：聚合數字不代表故事對）
1. **seed1337 從 7→0 的隊是否真的轉去合理求生路徑**：這批隊原本會死（baseline），現在活了——確認不是撿到分（例如卡進另一種技術上不算 starve 但也不合理的狀態），是真的 coherent 求生成功（forager 供給環正常運作、母團接到糧存活）。
2. **seed42 剩的 5 隻死是否真窮死**：試遍階梯真沒糧（would_succeed=false）的合法悲劇，還是又一種漏網的 broken signature（今天已經抓過兩輪：team16 等待新領主凍結、team64/68/62/71/73/79/90 subteam-idle-latch——這次要確認不是第四種）。

## 下一站
你判完 → `to:blueprint`，我合併故事判 + measurer 數字定最終 accept/reject，回 systems 解 merge。

## 溯源
`2026-07-20-measurer-to-blueprint-subteamidle-sweep-finalist.md`（sweep 結果，已 consumed）；`2026-07-19-blueprint-to-measurer-v3-bounded-sweep-authorized.md`（原授權，已 consumed，含「找到平衡點先送 QA」約定）；今天 crisis-immunity/beast-fix/transition-arbiter 三輪 QA 故事稽核揭破聚合數字盲點的前例。
