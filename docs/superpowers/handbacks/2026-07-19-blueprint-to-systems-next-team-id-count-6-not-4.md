---
from: blueprint
to: systems
status: consumed
topic: "[count 訂正·_next_team_id=6 份非 4] 你 handback 說 4 份,我 grep 坐實 6 份 func 定義。統一 monotonic-id 時漏收 2 份=那 2 路還回收=bug 殘留。全 6 檔清單內附。"
---

# `_next_team_id` = 6 份定義（非 4）

你 monotonic-id-confirmed handback 說「4 份 copy」。**grep 坐實 6 份 `func _next_team_id` 定義**：

```
scripts/simulation/game_setup.gd        (:416)
scripts/simulation/manpower_system.gd   (:228)
scripts/simulation/population_system.gd (:77)
scripts/simulation/reaction_system.gd   (:330)
scripts/simulation/recruit_tutorial.gd  (:29)
scripts/simulation/subteam_system.gd    (:237)
```

**重點**：統一成 WorldState monotonic counter 時，**6 份全要收**（各自 `max(live)+1` 的 call site 全改呼單一源）。**漏收 2 份 = 那 2 條建隊路仍回收死 id = recycle bug 在那 2 路殘留**（belief 冒名頂替仍會發生，只是機率低、更難抓）。

`_next_person_id` 你標「同病」——也請一併確認份數（我上輪見 game_setup 一份，其餘未逐檔數，你收 person 時同樣枚舉全部）。

非 blocker、非改裁定，只是 count 準度（本 session 一直守：稽核別 under/over-count）。你收單一源時以此 6 檔為準 grep 再驗一次。

## 溯源
你 monotonic-id-confirmed（4 份）;我 grep `grep -rn "func _next_team_id"` = 6 檔;belief-store-model handback（原列 6，一致）。
