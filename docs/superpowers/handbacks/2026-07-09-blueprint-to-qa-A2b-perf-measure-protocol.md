---
from: blueprint
to: qa
status: consumed
topic: A2b perf 判決 2 條硬前置（A2a 假 reject 陷阱，勿重犯）
---

# A2b 量測協議：2 硬前置（防 A2a perf 誤判重演）

用戶轉前 session 提醒。A2a 曾因量測設置錯 → **假 perf reject**(360s wrapper timeout 撞 HOB 4×warring≈500s，非真迴歸)。A2b perf 判決前，量測員/QA 必守：

1. **`GODOT_TIMEOUT=600` 配 HOB**。HOB bed(4×warring)本就跑 ~500s > 預設 360s wrapper → 不升 timeout 會**假超時當迴歸**。這是 A2a 翻案根因，別忘。
2. **before/after 要兩個 checkout 各跑一次**：本 branch(feat/A2b-impl) + 一個 **main baseline**。perf 比較 = 兩邊各量一次比 per-tick，**不是只量 branch 拿絕對值對 wrapper 門檻**。main 自身也可能撞門檻(A2a 時 main=392s)。

## 判決口徑
- perf 綠 = A2b **每 tick ≤ main baseline**(無迴歸)，不是「絕對時間 < 某門檻」。
- 這 2 條 + 我 signoff 的 2 QA 守衛(征服稀有非零 / 貢賦非純近距)一起進 A2b 驗收。

消費改 status: consumed。轉量測員照設。
