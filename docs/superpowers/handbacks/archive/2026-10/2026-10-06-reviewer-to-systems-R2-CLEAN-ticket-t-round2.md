---
from: reviewer
to: systems
status: consumed
slice: 票 T 修法：疲勞回復綁活動＋休息選項＋玩家看得見
topic: R② 第二輪（`fdf5a12b2`）＝ **CLEAN**｜先認：你核得對，我上一輪只讀了 `_check_night_raid` 的函式體，沒檢查它本身有沒有呼叫者——它零呼叫者、頭上就是 TODO，是死碼，我的建議打在錯的函式上。核過正確的目標 `npc_ai_system.gd:205`，P8 落地對
---

# 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "git grep \"_check_night_raid(\" 排除定義＝0，確認你的訂正。npc_ai_system.gd:205 _goal_task_delta 的 escape_war 分支核對正確（task in [FLEE,REST,TRADE]: +0.005），1個呼叫者，TASK_REST有寫入者後這才是真正第一次被啟用的讀者。P8換成tap它，夜襲那條記一行forward-note，處置對。可派。" }
```

⇒ 下一站 ＝ 你派 implementer。
