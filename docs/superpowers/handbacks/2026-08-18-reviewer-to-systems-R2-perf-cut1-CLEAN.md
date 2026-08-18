---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN] perf Phase2刀1(frontier call-scoped memo+_hex_dist static)HOW——親讀goal_resolver.gd:416-480全數citation逐字精準對得上(這輪特別準,幾乎零行號漂移):_resolve_location_prereq:420/FactionAISystem.new()於:425/find_nearest_terrain_tile:469/全圖掃for tid in state.world.tiles::474/fai._hex_dist(...):478全部精確命中;①_hex_dist純度親讀faction_ai_system.gd:3350-3353確認函式體純算術(abs(dx)+abs(dx+dy)+abs(dy))/2,零self/instance state讀寫,真的可以安全改static,確認坐實;②memo-safety親讀frontier_candidates(goal_resolver.gd:78起)確認是純讀team.goal_state的候選生成迴圈,零team.tile_pos mutation、零涉及移動執行的呼叫,call-scoped memo在單次同步function呼叫內team.tile_pos物理上不可能中途改變,byte-identical by construction的推理站得住,呼應我在perf rank_scored那輪要求的『call-scoped非跨tick』同款紀律這輪spec自己主動守住(§0『memo嚴禁跨tick』字面對齊);③無新常數確認,memo是純機制非旋鈕;④感知鐵律不動:find_nearest_terrain_tile本身已有# gate-ok標記(親讀:474確認inline comment『地理=公共知識...比照constitution_gate:41』),memo只是快取同一個已合法查詢的答案、不改查詢本身的god-view語意,合理;⑤補丁閘:memo是既有查詢的效率延伸非繞過或新平行機制;判決=CLEAN→dispatch implementer"
---

# R②判決：perf Phase2 刀1（frontier call-scoped memo + _hex_dist static）HOW — CLEAN

## citation 逐字精準——這輪幾乎零行號漂移

親讀 `goal_resolver.gd:416-480` 全數 citation：`_resolve_location_prereq:420`、`FactionAISystem.new()` 於 `:425`、`find_nearest_terrain_tile:469`、全圖掃 `for tid in state.world.tiles::474`、`fai._hex_dist(...):478`——**全部精確命中**，比這 session 前幾輪常見的 ±1 行漂移更準。

## ①`_hex_dist` 純度——親讀確認可安全 static
親讀 `faction_ai_system.gd:3350-3353` 確認函式體純算術（`(abs(dx)+abs(dx+dy)+abs(dy))/2`），零 `self`/instance state 讀寫，真的可以安全改 `static`。

## ②memo-safety——親讀 `frontier_candidates` 確認結構性安全
親讀 `frontier_candidates`（`goal_resolver.gd:78` 起）確認是純讀 `team.goal_state` 的候選生成迴圈，零 `team.tile_pos` mutation、零涉及移動執行的呼叫——call-scoped memo 在單次同步 function 呼叫內，`team.tile_pos` 物理上不可能中途改變，「byte-identical by construction」這個推理站得住。這呼應我在 perf `rank_scored` 那輪要求的「call-scoped 非跨 tick」同款紀律，這輪 spec 自己主動守住（§0「memo 嚴禁跨 tick」字面對齊，不是我這輪才要求）。

## ③無新常數
memo 是純機制非旋鈕，確認。

## ④感知鐵律不動
`find_nearest_terrain_tile` 本身已有 `# gate-ok` 標記（親讀 `:474` 確認 inline comment「地理=公共知識...比照 `constitution_gate:41`」），memo 只是快取同一個已合法查詢的答案、不改查詢本身的 god-view 語意，合理。

## ⑤補丁閘
memo 是既有查詢的效率延伸，非繞過或新平行機制。

## 判決
**CLEAN → dispatch implementer。**
