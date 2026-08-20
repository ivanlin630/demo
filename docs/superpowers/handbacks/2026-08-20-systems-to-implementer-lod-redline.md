---
from: systems
to: implementer
status: consumed
topic: "[dispatch ★擋考級 LOD 紅線修(個體反應層不再綁玩家位置)·spec=2026-08-20-lod-redline-person-reactions-HOW.md(含 §3 訂正+§6 定案)·R²=CLEAN(經一輪爭議:reviewer 提 ratio 應=100、我逐字反證 near pass 有 outer throttle、他撤回確認 ratio=10)·大考 HALT 至本修 merge+smoke·★根:sim_runner:156-157 reactions/cleanup=lod=LOD_NEAR 且 shape=teams;near 判定=距 player_pos<=3;headless 傳(-1,-1)→全隊 far→【無玩家=全世界零個體反應、有玩家=遠隊零個體反應】(生育/逃/暴動/叛/怠工/士氣/goal_alignment/npc goal cleanup);實證 breedgate.calls=0、11/11 隊 minor=0、零 PopMgmt·★範圍鎖定(別擴):只動 reactions+cleanup;outpost_tick(shape=state 建設/鑄幣/馬廄)與 regen(shape=regen tile 再生)【不碰 teams 陣列、本來就照跑】不在範圍;(甲)『無玩家→全隊 near』blueprint 已裁【不做】(=×10 世界節奏+全基線報廢、零憲法增益)、_get_near_teams 不動·★T1:reactions/cleanup 兩個 registry entry 的 lod 改 LOD_BOTH·★T2(靈魂):evaluate_all(state,teams,skill_sys,trials:int=1)、trials=cadence/NEAR_CADENCE(near 傳 1、far 傳 10)→【只在 breed 用真·多次試驗】:for i in range(trials): if randf()<chance → 照 near 端同一套後續處理,★團級 cap(minor_population<pop*0.25)必須【迴圈內逐次檢查】否則會突破 near 端本來會撞的上限;★禁用單抽 1-(1-p)^n(結構性封頂每窗最多 1 次=系統性低估,即使 ratio 對)·★施用範圍只有 breed 一項(R² 親驗:ReactionSystem 全檔 randf() 只有 :204 一處、其餘 flee/riot/defect/shirk/extort/produce/expand 全走決定性 _score_*+argmax 零 RNG;cleanup_goals 純狀態改寫零 RNG)→不必分類、不必判斷·GOAL_CHECK_INTERVAL=100=FAR_ZONE_INTERVAL 恰好對齊、不需處理(spec 已記)·★gate①=靈魂:rate-equivalence——同條件下 far 隊長窗(>=30 天)累積 breed/反應次數≈near 隊(±tolerance、取樣要夠),【只證有 fire 不算過】②headless(無玩家)reaction.breed>0、[PopMgmt] 出現、minor_population 不再全 0③det 三跑 byte-identical④constitution<=75+headless 0-new⑤fp intended-change(遠隊現在會跑反應→RNG 筆數與順序改變=世界真的不同,這正是修的目的)⑥★perf 實測必附:全隊都跑反應=新增成本,量 per-tick 前後差([TickPerf] 即可)【照實報】——成本大是 blueprint 已接受的紅線代價,但數字要在檯面上·worktree feat/lod-redline-reactions·完→handback to:systems·地基KEEP"
---

# dispatch：★擋考級 LOD 紅線修（個體反應層不再綁玩家位置）

spec＝`docs/superpowers/specs/2026-08-20-lod-redline-person-reactions-HOW.md`（含 §3 訂正 + §6 定案）。**R²＝CLEAN**（經一輪爭議：reviewer 提 ratio 應為 100、我逐字反證 near pass 有 outer throttle、他撤回並確認 **ratio=10**）。**大考 HALT 至本修 merge + smoke**。

**根**：`sim_runner:156-157` `reactions`/`cleanup` ＝ `lod=LOD_NEAR` **且 `shape="teams"`**；near 判定＝距 `player_pos` ≤3；headless 傳 `(-1,-1)` → 全隊 far → **無玩家＝全世界零個體反應、有玩家＝遠隊零個體反應**（生育/逃/暴動/叛/怠工/士氣/`goal_alignment`/npc goal cleanup）。實證：`breedgate.calls=0`、11/11 隊 `minor=0`、零 `[PopMgmt]`。

## ★範圍鎖定（別擴）
只動 `reactions` + `cleanup`。`outpost_tick`(shape=state：建設/鑄幣/馬廄)、`regen`(shape=regen：tile 再生) **不碰 teams 陣列、本來就照跑**，不在範圍。(甲)「無玩家→全隊 near」blueprint 已裁**不做**（＝×10 世界節奏 + 全基線報廢、零憲法增益）→ **`_get_near_teams` 不動**。

- **T1**：`reactions`/`cleanup` 兩個 registry entry 的 `lod` 改 **`LOD_BOTH`**。
- **★T2（靈魂）**：`evaluate_all(state, teams, skill_sys, trials: int = 1)`，`trials = cadence / NEAR_CADENCE`（near 傳 **1**、far 傳 **10**）→ **只在 breed 用真·多次試驗**：
  ```
  for i in range(trials):
      if randf() < chance: <照 near 端同一套後續處理>
  ```
  ★**團級 cap（`minor_population < pop*0.25`）必須在迴圈內逐次檢查**，否則會突破 near 端本來會撞到的上限。
  ★**禁用單抽 `1-(1-p)^n`**（結構性封頂＝每窗最多 1 次＝系統性低估，**即使 ratio 對**）。
- **施用範圍只有 breed 一項**（R² 親驗：`ReactionSystem` 全檔 `randf()` **只有 `:204` 一處**；flee/riot/defect/shirk/extort/produce/expand 全走決定性 `_score_*`+argmax、**零 RNG**；`cleanup_goals` 純狀態改寫、零 RNG）→ **不必分類、不必判斷**。
- `GOAL_CHECK_INTERVAL=100=FAR_ZONE_INTERVAL` **恰好對齊、不需處理**（spec 已記，因為誰動了那三個常數之一它會無聲失效）。

## gate
1. ★**rate-equivalence（靈魂）**：同條件下 far 隊長窗（≥30 天）累積 breed/反應次數 **≈ near 隊**（±tolerance、取樣要夠）。**只證「有 fire」不算過。**
2. headless（無玩家）`reaction.breed > 0`、`[PopMgmt]` 出現、`minor_population` 不再全 0。
3. det 三跑 byte-identical。4. constitution ≤75 + headless 0-new。5. **fp intended-change**（遠隊現在會跑反應 → RNG 筆數與順序改變＝世界真的不同，**這正是修的目的**）。
6. ★**perf 實測必附**：全隊都跑反應＝新增成本，量 per-tick 前後差（`[TickPerf]` 即可）**照實報**——成本大是 blueprint 已接受的紅線代價，但**數字要在檯面上**。

worktree `feat/lod-redline-reactions`。完 → handback to:systems。地基 KEEP。
