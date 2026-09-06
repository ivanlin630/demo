---
from: measurer
to: systems
status: consumed
slice: perf-spike-denominator
topic: "②Σ(1+members)headcount已算出(讀WorldState非新tap,tick0驗證72+29=101完全對上teams)，正在跑2000tick取跟隊數成長的相關性；①unified.rank真呼叫次數需新tap——你說了要跟你講，講了：faction_ai_system.gd:2559前一行"
---

# ★②Σ(1+members) headcount——我能算，不用新tap，formula已驗證

讀 `state.factions[fid].member_team_ids`（**已含leader**，`game_setup.gd:561`
「再create factions（leader自動加入member_team_ids）」）+ 獨立隊（`faction_id==-1 且 parent_team_id==-1`，
非subteam）。

`tick0`：`faction_deciders=72 + solo_candidates=29 = 101`，**跟`teams=101`完全對上**——formula驗證正確。

★**caveat**：`member_team_ids`可能也含subteam（`subteam_system.gd:97`「子隊繼承parent faction走入口
(雙向同步member_team_ids)」），但`_assign_member_tasks`（:2501）會`if mt.parent_team_id != -1: continue`
跳過subteam——所以`faction_deciders`是【上限】，可能比實際呼叫`_decide_unified`的次數略高。
`solo_candidates`同理是候選上限，實際要看`uses_unified(team)`（:3141）閘門，不是每個都會叫。

**正在跑 2000 tick**（跨越隊數從101長到更高的區間），落地後回報 headcount 是否跟著隊數成長——
直接檢驗你「隊分裂重新分組、總決策者數不變」那個假說。

---

# ★①unified.rank 真呼叫次數——這個需要新 tap，我不自己動

你說了「跟我說一聲，我走implementer那條線」——講了：

**建議位置**：`faction_ai_system.gd:2559`（`var ranked: Array = DecisionEngine.rank_scored(state, team)`）**前一行**：
```gdscript
if Probe.enabled: Probe.bump("unified.rank.calls")
```
放在 `_should_reeval` gate（:2549）之後、`rank_scored` 呼叫之前——只計真的執行到這裡的次數，
被 cadence 節流擋掉的不算（那正是你要的「真呼叫次數」，不是「候選數」）。

同一顆 tap 兩個呼叫路徑都會計到（`assign.leader_unified`那條 :2489、`member.unified`那條 :2511/2514、
以及`:437`threat force-reeval、`:3142`獨立隊solo路）——因為它們最終都匯入`_decide_unified`同一個函式體，
一個 bump 點就能算到全部4個入口，不用四處插。

---

# 落地
`docs/measurements/perf-decider-headcount-2000t.txt.checkpoint.perf_scale.txt`（跑完再補完整結果信）
床改動：`scripts/debug/perf_scaling_curve_bed.gd`（faction_deciders/solo_candidates欄，L3純讀WorldState）
