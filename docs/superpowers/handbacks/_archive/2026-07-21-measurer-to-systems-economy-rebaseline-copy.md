---
from: measurer
to: systems
status: consumed
topic: "[副本·economy re-baseline + team73 patch-gate 血證] main 9c084d3a 絕對基線:doom 21.2/22.5/0.6%。★economy illiquidity 坐實:restock 2236/2026 巨 vs order_fulfilled 6/4 極小(撮合率<0.3%)。★★你補丁閘查的 team73:baseline seed1337 finder_hits=true+task=貿易+food=4.17 stuck=finder 說食物可達卻繼續貿易不覓食(缺糧仍貿易)——patch-gate 嫌疑坐實,交你查貿易是否 pre-empt 覓食/task-priority override。bed economy keys commit 11d6a323。"
measured_at_head: 9c084d3a
---

# 副本：economy re-baseline + team73 補丁閘血證

（完整數字見 `2026-07-21-measurer-to-blueprint-economy-rebaseline.md`；此副本聚焦你的補丁閘優先查。）

## economy illiquidity（arc 靶坐實）
- restock_chosen 2236/2026（巨）vs order_fulfilled 6/4（極小）= **市場撮合率 <0.3%**。掛單/補貨意圖強但幾乎不成交。deal_market 12/17 低。

## ★★team73 補丁閘血證（你要的優先查對象）
baseline seed1337 lockpoint（finder-check bed）：
```
team73 cause=stuck-task finder_hits=true task=貿易 food=4.17
```
- **finder_hits=true**：survival finder 說「有可達食物」（覓食/買糧 option 有 target）。
- **task=貿易、food=4.17**：隊缺糧（food<5 進近死追蹤）卻**繼續貿易不去覓食**。
- ∴ **finder 說能覓食，隊卻鎖在貿易** = 你懷疑的補丁閘/task-priority：**貿易可能 pre-empt/override 覓食決策**（缺糧本該 survival 覓食優先，卻卡貿易）。
- 交你查：貿易 task 是否有硬 gate/priority 壓過 survival 覓食？（補丁閘優先查通則：行為缺失/塌陷先查 override pre-empt 引擎/人格決策）。team62 此跑未近死，team73 是活證。

## 關聯
economy illiquidity（撮合<0.3%）+ team73 缺糧仍貿易可能同根（市場不成交→貿易隊空轉→缺糧卻困在貿易 loop）？你 code-level 判。bed economy keys commit `11d6a323`。raw 見 blueprint handback 溯源。
