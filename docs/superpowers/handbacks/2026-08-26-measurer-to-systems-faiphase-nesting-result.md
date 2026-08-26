---
from: measurer
to: systems
status: open
slice: perf-spike-inside
topic: "巢狀關係查清楚：至少4~5層深(loop1.factions⊇loop1.assign_tasks⊇assign.leader_unified/members⊇unified.rank⊇gather.*)，file:line坐實非猜；機制本身不記親子關係(誠實限)；組成在early/mid/late穩定不變，同一批label從頭到尾主導"
---

# ★機制本身不記巢狀關係——這是我讀 call graph 推出來的

`_fai_pht`/`_fai_pht_s`（`faction_ai_system.gd:684-693`）只是 flat Dictionary 累加（label→us），
**沒有 parent/child metadata**。巢狀關係不是機制告訴我的，是我讀 code 手動推出來的。

---

# ★★★巢狀地圖（file:line 坐實）

```
loop1.factions(:760)                              ← 整個per-faction迴圈總時長
 └─ loop1.assign_tasks(:736)                       ← 幾乎=loop1.factions全部(差<0.1%)
     └─ assign.leader_unified(:2490) 呼叫 _decide_unified(leader)
     └─ assign.members(:2492) 呼叫 _assign_member_tasks()
         └─ member.unified(:2512) 每個member各呼叫一次 _decide_unified
             └─ unified.rank(:2561) = DecisionEngine.rank_scored()
                 └─ gather.*(decision_context.gd) ← 獨立_tg鏈，比unified.rank更深一層
```

**至少4~5層深**。`unified.rank` 每個 team（leader+每個member）都跑一次，是被呼叫次數最多的葉層之一；
`gather.*` 更深一層。兩者都被 `loop1.factions` 重複計了好幾層。

---

# ★對「加總14.6M > total 7.0M」的解釋

不是取樣或印錯——**是同一段工作被不同深度的 label 各記一次**。
某個 team 的 `unified.rank` 那段時間，同時貢獻進 `loop1.factions`、`loop1.assign_tasks`、
`assign.leader_unified`(或`member.unified`)、`unified.rank` 本身——4個 bucket。
★**加總=雙/三/四重計數，不能拿來對帳，只能當「指向哪個方向」的線索。**

---

# ★組成穩定性——early/mid/late 完全一樣

取自 radius24（長窗票）跑出的 419 筆 `[FaiPhase]`，抽 tick10/20/30（早）、1940/1950/1960（中）、
3820/3830/3840（晚）：

**同一組 label（`loop1.assign_tasks`／`unified.rank`／`gather.*`／`assign.leader_unified`）
從頭到尾都是主導者**，不是「開局特殊、後期換了別的東西」。只有絕對量隨 tick 波動。

---

# 落地
`docs/process/verdicts/perf-faiphase-nesting.measure.json`
raw：`docs/measurements/perf-faiphase-all419-radius24.txt`（全部419筆，非只留console）
