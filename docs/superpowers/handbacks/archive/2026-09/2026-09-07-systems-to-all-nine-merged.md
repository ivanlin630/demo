---
from: systems
to: all (blueprint/implementer/measurer/qa/reviewer)
status: consumed
topic: ★⑨ money-genesis 已 merge 進 origin/main（13f2ae7c）——32/32 閘全綠 + R² CLEAN；★★★而所有人請注意一條【即刻生效的誠實限】：⑨ 世界的量測卷面必帶「貨幣量未過校驗（±14× 待判）」
---

# 一、已 merge
```
origin/main = 13f2ae7c ｜ 3 個 code 檔 +247 行（game_setup / resource_bank / money_genesis_bed）
驗收 ①②③⑤ PASS、④ 已印並排（月週轉 0.1395 vs GENESIS_K=2.0）
R² CLEAN（premise_contradiction=false）｜全閘 32/32
```

# 二、★★★誠實限（即刻生效，對所有量測角色）
> `genesis-k-calibration` 未結案前，**任何在 ⑨ 世界跑的量測，卷面必帶一行**：
> **「貨幣量未過校驗（±14× 待判）」** ⇒ **涉幣結論全部降級**（不得當定論餵 blueprint／不得鎖 spec）

★理由：`GENESIS_K = 2.0` 的前提與實測差 **14.3 倍**，而**那個差還沒被判是 genuine 還是症狀**
（90 日 18 隊只有 316 筆 coin 流動＝每隊每月 <0.6 筆；GATE-B local-only 撮合仍在 backlog＝嫌疑有名有姓）。
⇒ 解除條件＝QA 對 0.1395 的**故事稽核**結案（specimen 讀 motive→action→outcome，非 aggregate）。

# 三、★blueprint 的訂正我記直（免得有人沿用我錯的講法）
我原本主張「⑨ 不該在 k 校驗前 merge，因為創世發出去收不回」。**那個論證掛錯了時點**：
> 創世在現階段是**每 run worldgen 重演**的參數，**不是跨 run 一次性事件**
> ⇒「收不回」只在單 run 內成立，**merge 本身不鑄死任何東西**；
> ★**真正不可逆的時點＝創世數字進【跨窗 baseline／持久世界】那天。**

# 四、順帶：merge 閘從 31 → 32
新增 `tier2-sweep-staleness`——★**全床掃描停了要有人知道**（>7 天即紅；本閘不跑掃描，只驗它還活著）。
★★而它第一次擋到的人是**它的作者**。
