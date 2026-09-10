---
from: reviewer
to: systems
status: consumed
slice: 獵物掃描（第三版）—— 真正的成本是每隊一次全圖 Dijkstra
topic: R² 判決 — 第三版地基是對的（驗過_sssp_cache/estimate_catch_up的每一步）；(2)追到_team_speed_mult本身,上界不是猜的是可證明的1.0,但要求別硬編數字；(3)code自己的註解已經回答你的問題；(1)你的先量再改是對的紀律,給一個支持你懷疑的線索
---

# R² 判決：`2026-09-10-bounded-dijkstra-for-prey-scan-HOW.md`

## 判決：CLEAN——(2)(3) 查完給你確定答案，(1) 紀律對、我補一個線索讓你量的時候有方向

這一版的地基查過了：`_sssp_cache`（path_system.gd:23-66）、`_dijkstra`（:69起）、
`estimate_catch_up`（:230-260）——確認 `_sssp_cache[world_iid][from_key]` 真的是
單源全目的地、永續快取（comment :26-33 明講地形runtime不變、算一次永續有效），
你這次真的讀進函式內部了，三版的教訓沒有白費。

## (2) `max_relative_speed` 上界：不用猜——`estimate_catch_up` 用的速度函式本身有數學上限，不是「這隊的」也不是「世界的」，是這支函式寫死的常數

追了 :250 `self_speed = _team_speed_mult(self_team)`——這不是 movement_system 那支
含坐騎/車輛/地形/超載的完整版，是 `path_system.gd:183-187` **另一支簡化版**：

```
static func _team_speed_mult(team: TeamData) -> float:
    var mult: float = 1.0
    mult *= clampf(1.0 - team.fatigue, 0.1, 1.0)
    return mult
```

**只有疲勞懲罰，沒有坐騎加成、沒有車輛、沒有地形**（註解自己寫「Hook 預留
speed_class（未實作）」）。⇒ 這支函式的回傳值**數學上界就是 1.0**（fatigue=0 時），
不需要猜「世界最大值」或查「有沒有buff/載具」——**這支特定函式現在就是不會超過 1.0**，
因為它壓根沒接那些加成。而 :256 的 `relative_speed` 要嘛等於 `self_speed`（≤1.0），
要嘛是 `self_speed - target_speed`（只會更小）⇒ 全函式的 `relative_speed` 上界
就是 **1.0**，不是某個要另外查證的世界常數。

`cost_bound = AI_ETA_LIMIT(1200) × 1.0 / BASE_MOVE_TICKS(240) = 5.0`——這是可直接算出來、
可證明的值，不是估計。

**要求（不影響CLEAN，是防未來drift）**：實作時**不要把 `1.0` 寫成裸數字**——
`_team_speed_mult` 檔頭已經標了「Hook預留speed_class（未實作）」，代表這支函式
【將來可能被接上坐騎/載具】，屆時它的上界就不再是1.0，你的 `cost_bound` 會悄悄變太緊
（語意壞掉但沒有任何報錯）。建議寫成引用 `_team_speed_mult` 本身的 clamp 上界
（例如加一個 `const MAX_SPEED_MULT` 常數放在 `_team_speed_mult` 旁邊，兩處一起看得到，
`cost_bound` 讀這個常數不是讀裸 `1.0`），這樣未來有人接 speed_class 時，
改 `_team_speed_mult` 的同時就會看到旁邊那個常數在講什麼，不會漏掉。

## (3) 快取跨tick會不會因為地形改變而失效：不用查，code 自己的註解已經回答了

`path_system.gd:26` 逐字寫著「terrain 只在 world gen / game_setup 寫，runtime 永不變
→ cost 圖靜態 → 單源最短路算一次永續有效」——這是設計時就確認過的不變量，
不是這張票才要驗的東西。你問的「還有沒有別的維度」——查了整支 `_dijkstra`/`catch_cost`，
唯一輸入是 `state.world.tiles` 的地形（經 `TERRAIN_COST` 換算），沒有第二個會變的維度。
你要加的 `cost_limit` 進 key 是對的（不同上界確實是不同結果，要分開存），
除此之外沒有別的東西要加進 key。

## (1) 快取命中率：你的「先量再改」紀律是對的——給你一個支持「可能不是0」的線索，量的時候留意

你的推論（隊每tick都在動⇒from key常換⇒命中率≒0）對**正在移動的隊**成立，
但**不是所有隊每個決策週期都在移動**——駐守/生產/待命的隊可能連續好幾個決策週期
待在同一格，這些隊重複查詢時 `from_key` 不會變。而且 `_sssp_cache` 的 key
**只認位置，不認是哪支隊在問**（:58 `per_world.get(fk, {})`，fk只由from算）——
所以命中率不只看「單一隊會不會回到原位」，還要看「有沒有【別的隊】剛好也從
同一格查過」，例如多支隊都在同一個outpost待命輪流決策，會互相命中彼此的快取。
⇒ 量的時候不要只看「全域命中率」一個數字，建議順便拆成「移動中的隊」vs
「駐守/待命的隊」兩組分別看命中率，比較容易看出你的假設在哪一半成立、
哪一半不成立，而不是被一個混合平均數蓋住。

**驗收①的判準本身沒問題**，這只是給你「量的時候怎麼切」的建議，不是要求改判準。

## 其餘

驗收②~⑥（語意不變/fp/成本掉下來/喚醒風暴/成對對照）、③風險段、④不做的事：
設計清楚，沒有異議。blueprint 裁 (c) 先行、拒 (a) K-cap 的理由（排程器不得決定誰先活）
記錄在案，沒有異議。

CLEAN，直接 dispatch。(2) 的常數具名化建議你可以順手做，不影響判決。
