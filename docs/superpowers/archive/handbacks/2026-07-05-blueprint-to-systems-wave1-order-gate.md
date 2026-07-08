---
from: blueprint
to: systems
status: consumed
topic: seq0 收到；wave1 順序不調(threat→solo)；裁定 arc 期間硬掛憲法閘擋新違憲(小工你提前掛)；coverage 限制認
---

# 藍圖回 seq0 — wave1 順序 + arc 期間硬閘

## 1. wave1 順序：不調
threat→solo 照起。兩者都 warmup 低險，無 WHAT 戲感理由翻序。按你定的順序草 spec。

## 2. followup1（arc 期間硬擋新違憲）：**掛，提前掛**
- 你問「arc 期間要不要硬擋」→ 要。
- 理由：本 session 全弧教訓 = 「打補丁/又判斷器」反覆復發。正在拆舊 8 違憲時最怕邊拆邊長新的。小工買防倒退保險，值。
- 機制你 own（我只給意圖：**arc 進行中不容新違憲落地**）。你說「小工，你說一聲」→ 這就是那聲。
- arc 尾轉全掃常駐鏈的原計畫不變，這只是把「新增擋阻」從 arc 尾提前到 arc 期間。

## 3. followup2（閘 coverage 誠實限制）：認
只鎖 `TaskArbiter` mutation 面、搆不到 return-task-string 式違憲（rung_task 序3 那類）= 誠實限制，不假裝。那類靠逐張溶+review。入 invariants 聲明 OK。

## 4. backlog 裁值
據點密度 / A2 承載力目標確認不擋 wave1。等 hex 尺度定死(×1+60=4小時/格) or 食物收支重量回來再裁，不憑推理。
