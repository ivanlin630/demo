# Audit：決策讀別隊真值（感知鐵律違規盤點）

> 用戶令（`groundtruth-audit-dispatch`）。**唯讀 audit，先盤不修**。決策模型「感知腳」接線脊椎第一步。界線：讀自己真值=OK，違規僅「評估別隊隱藏狀態」。

## (A) 違規點表

### ❌ 真值違規（hard，多為快修）
| file:line | 讀啥 | 該讀啥 |
|---|---|---|
| `threat_assessment.gd:44` | belief-miss fallback 掉 `other.population` 真值（threat 計算） | 無 belief→回 0/skip，勿 fallback god pop |
| `faction_ai:1979` `_nearest_independent` | 任意曾見隊 `faction_id != -1` 真值（獨立否=隱藏 affil；供攻擊/外交 target） | belief faction_id(tier2 有)+has_belief gate |
| `faction_ai:1968` `_has_independent` | 同上（gate 用真值 faction_id） | 同上 |
| `faction_ai:1930-35` `_find_trade_target` | 查裸鍵 `"population"`/`"food"`/`"material"`——belief 只存 `*_est`→**恆 miss→default**（貿易估價瞎，看不見對方庫存） | 改用 `*_est` 鍵 |
| belief `combat_skill_est`/`power_est` | **完全無寫端**——threat `_power_ratio` 明文「無 combat skill→用 0.3 baseline」→敵戰力=死 `pop_est×0.3`，技能全隱形 | 新增 belief 戰力欄 + 寫端 + threat 讀 |

### ⚠ 系統性（最大單點）：位置 god-view
`team_discovered`=**累積曾見**（`vision_system:78-79` append-only 無 erase）。所有 ctx/options `state.teams[x].tile_pos` 讀**現時真值位** → 對曾見-但脫視隊=位置 god-view。
- 散落：ctx.gd:130/136/144/150/158/188/197/210/213/236；options.gd to_task:145/151/175/182/187/192。
- **正解模式 code 內已存**（`_refresh_attack_pursuit` faction_ai:273、`_commit_conquest_attack:291` 用 `best_estimate.tile_pos` fallback）→ ctx/options 沒接。
- 修=ctx/options target-pos 讀 `best_estimate(...).get("tile_pos")` last-known，非 live。

### ⚠ 灰：faction_id 早濾（同派排除）
`find_prosperity_prey:188`/`_find_occupy_target:3150`/`_find_strong_neighbor:3205`/`_find_aid_target:3231` 早濾 `t.faction_id==team.faction_id`（排同派）讀真值 faction。**scoring 已 belief**（模範 find_prosperity_prey:212-238 明文禁讀 prey.faction_id 改 belief），但**早濾用真值**。輕度（同派多已知；但嚴格是真值）。

### ✅ 已乾淨（模範）
`find_prosperity_prey`（belief pop/armed/richness + calc_armed 自己）、`_find_weakest_prey`/`_find_occupy_target`/`_find_strong_neighbor`/`_find_aid_target`（has_belief gate + `*_est`）、threat other_power=belief pop_est、known_reputations/feud=已知關係、所有讀自己狀態。

## (B) belief 缺欄位

belief `value` 現有（依接觸階）：
- **遠 vision(tier0)**：`population_est` `tile_pos` `last_tick` `tier`（**只 2 實欄**）
- **近 vision(tier1)**：+`resource_scale`（0-3 粗估）
- **交手(tier2, interaction:827-839)**：+`food_est` `material_est` `coin_est` `goods_est` `armed_est` `faction_id` `tags` `current_task`

| 欄 | 誰要 | 狀態 |
|---|---|---|
| population_est/tile_pos | 全 finder+threat | ✅任何接觸 |
| armed_est | prosperity/occupy/threat | ⚠僅 tier2；遠 vision 缺→fallback pop_est |
| food_est | weakest tiebreak/aid(必需)/richness | ⚠僅 tier2；遠缺→aid skip |
| faction_id | prosperity 戰爭成本 | ⚠僅 tier2；遠缺→恆 OWN_UNKNOWN |
| coin/material/goods_est | richness | ⚠僅 tier2 |
| **combat_skill_est/power_est** | threat power_ratio | ❌**完全無寫端**（硬編 0.3） |
| 裸鍵 population/food/material | `_find_trade_target` | ❌belief 只 `*_est`→恆 miss |

## 系統評估（工量 sizing，供藍圖排脊椎）
- **快修（小，S）**：trade finder 鍵改 `*_est`（1930）、threat:44 fallback 去 god pop、faction_id 早濾改 belief（4 finder）。≈ 各 1-數行。
- **系統性（中，M）**：位置 god-view——ctx/options target-pos 全改 best_estimate last-known（模式已存，~18 散落點）。
- **新欄位（中，M）**：combat_skill/power_est belief 欄——加 belief 寫端（交手時記戰力估）+ threat 讀（撤硬編 0.3）。牽 belief schema + 誘殺(S4 假情報)語意。
- **belief 深度（大，L，roadmap）**：遠 vision 只 pop——armed/food/faction 僅交手可知=**設計特徵非 bug**（遠看不清=感知鐵律要的迷霧）。但決策 fallback 品質（缺 armed→pop_est 代）=可調。**情報捏造維度**（藍圖 roadmap）在此層。

**先盤不修**（用戶令）。交藍圖排：快修可 arc 尾順手；系統性/新欄=決策模型接線脊椎正題，另軌。
