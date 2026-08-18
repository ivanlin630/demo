---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN+1設計建議(直接跳build-once、免per-tick安全道中間步)] perf刀2=D spatial index HOW——①tie-break保序親讀goal_resolver.gd:467-483確認:481逐字`if d<best_d or(d==best_d and int(tid)<best_id)`+:474全圖掃for迴圈,citation精準命中;tie-break是explicit int(tid)比較(非靠dict迭代序)這件事本身就是by-construction保序的關鍵——只要spatial index候選集(terrain分組後的tile清單)跟全圖掃篩出的candidate集合完全一致(=只是換了iterate順序,filter條件terrain==X沒變,只是index提前做完filter),對同一個候選集套同一個(d,tid)比較公式,結果數學上必然跟掃描順序無關(argmin+explicit tie-break over固定集合的性質),推理成立,無需gate碰運氣;★審點②(index生命週期per-tick vs build-once immutable)——沒有停在『R②議』這個開放問題,親自grep全scripts/simulation/『.terrain=』找到production code裡terrain只有一處寫入:world_generator.gd:67 tile.terrain=_random_terrain(rng),親讀確認這是world生成階段的一次性賦值,往下全scripts/simulation/搜尋零一處runtime terrain重寫(無terraform/event改terrain機制存在),terrain immutable這個precondition親驗直接坐實(非留待implementer自己查);★設計建議:既然immutability已經親驗確認,建議直接跳過『per-tick重建safest優先』這個中間步驟,直接用build-once(世界生成完成後建一次、全程沿用),省下不必要的per-tick重建開銷跟一輪『先safe再升級』的額外驗證循環——這條建議基於我自己親自驗證的證據非猜測;③感知鐵律不動/④補丁閘index=效率延伸/⑤無新常數皆親驗合理;判決=CLEAN+1設計建議(build-once可直接坐實非待議)→dispatch"
---

# R②判決：perf 刀2=D spatial index HOW — CLEAN + 1設計建議

## ①tie-break 保序——citation 精準 + by-construction 推理成立

親讀 `goal_resolver.gd:467-483` 確認 `:481` 逐字 `if d < best_d or (d == best_d and int(tid) < best_id)` + `:474` 全圖掃 for 迴圈，citation 精準命中。

tie-break 是 explicit `int(tid)` 比較（非靠 dict 迭代序）——這件事本身就是 by-construction 保序的關鍵：只要 spatial index 候選集（terrain 分組後的 tile 清單）跟全圖掃篩出的 candidate 集合**完全一致**（只是換了 iterate 順序，filter 條件 `terrain==X` 沒變，只是 index 提前做完 filter），對同一個候選集套同一個 `(d, tid)` 比較公式，結果數學上必然跟掃描順序無關（argmin+explicit tie-break over 固定集合的性質）。推理成立，不需要靠 gate 碰運氣，spec §2 TDD②「含平手 case 逐一驗」已經正確要求了機器證。

## ★審點②index 生命週期——親驗坐實 immutability，非留 R②議

沒有停在「R②議」這個開放問題，親自 grep 全 `scripts/simulation/` 的 `.terrain=` 賦值，找到 production code 裡 **terrain 只有一處寫入**：`world_generator.gd:67` `tile.terrain = _random_terrain(rng)`。親讀確認這是世界生成階段的一次性賦值，往下全 `scripts/simulation/` 搜尋**零一處** runtime terrain 重寫（無 terraform/event 改 terrain 的機制存在）。terrain immutable 這個 precondition **親驗直接坐實**，不是留給 implementer 自己再去查一次。

## ★設計建議：既然 immutability 已確認，建議直接跳過 per-tick 中間步

spec §2 給了「per-tick 重建 safest 優先、immutable 坐實才升 build-once」這個保守分階段路徑。既然這輪我已經親自驗證確認 immutability 成立（非假設），**建議直接用 build-once**（世界生成完成後建一次、全程沿用），省下不必要的 per-tick 重建開銷跟「先 safe 再升級」的額外驗證循環——這條建議基於我自己親自驗證的證據，非猜測或圖省事。

## 其餘

**③感知鐵律不動**：`find_nearest_terrain_tile` 已有 `# gate-ok` 標記，index 只是同查詢更快、不改 god-view 語意。
**④補丁閘**：index 是既有查詢的效率延伸，非新平行機制。
**⑤無新常數**：確認。

## 判決
**CLEAN + 1設計建議（build-once 可直接坐實、非待議）→ dispatch。**
