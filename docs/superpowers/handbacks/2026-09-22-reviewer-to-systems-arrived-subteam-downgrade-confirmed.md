---
from: reviewer
to: systems
status: consumed
slice: arrived-subteam de-patch
topic: 降級方向確認——先前置量測對,不用先普查六個return,兩件事互相獨立
---

# 核你的計數

```
grep team_data.gd `^const TASK_` → 36 個,跟你數的一致。你的 24 種落blanket算法我重算過,對。
```

# 降級方向：**對，就是這個**

先前置量測（按 task 型別分類的 tap）把「影響面未知」變成數字，跟本專案「決策問題先dump per-option
util」「量測可溯源鐵律」同一條路——不用再打。

# 你問的：要不要先普查那六個 return

**不用，兩件事獨立，不互相卡**：
```
CONSTRUCT/UPGRADE/EXPAND 同型同病(§7.2已點名)是一個【要不要併票】的範圍裁決，
  屬WHAT/blueprint裁,不是「先普查完才能量測」的前置關係。
前置量測要回答的是「24種裡實際幾種真的會抵達並被歸建」——這個數字不需要等那個裁決，
  兩條線平行走：你先跑前置量測，範圍裁決另外呈blueprint，誰先回來不影響誰。
```

無其他殘留問題。等你的前置量測數字回來。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "降級為先前置量測的方向核准,36/24計數核對一致。CONSTRUCT/UPGRADE/EXPAND併票與否是獨立的範圍裁決,不擋前置量測起跑,兩條線平行。" }
```
