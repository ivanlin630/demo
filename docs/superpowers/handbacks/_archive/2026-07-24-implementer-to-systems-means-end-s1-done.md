---
from: implementer
to: systems
status: consumed
topic: "[done·means-end S1 骨架·byte-identical no-op proof 硬證·收+驗+R²請] feat/means-end-s1-skeleton e339ac4c off local main 0823b823。4 塊接線(A goal_state/B GoalRegistry/C GoalResolver stub/G rank hook)。★no-op proof:S1==baseline byte-identical(both MD5 d1071c59,stash 比對)。TDD 7/7/headless 0-new/gate 74 removed=0/determinism 2跑一致。whole-system-first:resolver 保持 stub []。完成判定=systems+reviewer R²(非自判)→請收+驗+S1 R²→CLEAN merge→dispatch S2。"
branch: feat/means-end-s1-skeleton
commit: e339ac4c
spec: docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md
---

# done：means-end S1 骨架 — byte-identical no-op proof（請 systems 收+驗+R²）

HOW spec §10 S1。統一決策框架/means-end 長程規劃 arc 開端。**S1=骨架 slice：接線就位、零行為變**。

## 4 塊接線（組件 A/B/C/G）
1. **`TeamData.goal_state:Array`**（組件 A）：team-level 遠慾望列表跨 tick 持久（GoalInstance schema
   `{goal_type,target,created_tick,status}`）。S1 空初始 `[]`。無序列化系統（TeamData 無 to_dict/from_dict）→ 僅欄位。
2. **`GoalRegistry`**（組件 B，`scripts/simulation/decision/goal_registry.gd`）：5 前置 kind 常數
   （`resource`/`location`/`manpower`/`facility`/`subgoal`）+ 空 `REGISTRY` static dict。S1 空 data。
3. **`GoalResolver`**（組件 C，`scripts/simulation/decision/goal_resolver.gd`=GV_FILE_RE 涵蓋）：
   `frontier_candidates(state,team,ctx) -> Array` **S1 stub `return []`**。零合成邏輯。
4. **`decision_engine.rank_scored_ctx`**（組件 G）：+optional `state`/`team` 參數（harness 手構 ctx 無此→null→hook skip）
   + goal frontier hook（**sort 前**，與 static option 同 argmax 池）。`rank_scored` 傳 state/team。
   S1 candidate 空 = **no-op**（既有 argmax 零變）。

## 驗（皆綠）
- TDD `means_end_s1_test` **7/7**（goal_state 空初始 / resolver stub [] / registry 5 kind + 空 REGISTRY /
  rank hook no-op：size 4==4 即使 goal_state 掛 goal → 無 goal candidate 入池）。
- headless 0-new（3 baseline）。
- **gate PASS sites=74 removed=0**（GoalResolver/GoalRegistry 在 `decision/` 被 GV_FILE_RE 涵蓋，但 S1 stub
  無 god-view/RNG/task 指派 → **0 新閘**）。
- **★byte-identical no-op proof（硬證）**：
  - determinism：S1 seed1337×2mo×2 跑 byte-identical。
  - **★S1 == baseline byte-identical**（both MD5 `d1071c59`；stash S1 changes→跑 baseline→比對=零行為變硬證，非只自洽）。

## ★whole-system-first
S1 只骨架，resolver 保持 stub `[]`；未提前塞 S2+ 邏輯（goal walk / per-kind handler / candidate util / 折現 / 護欄 = S2+）。
util 護欄（HOW §8 must-fix①：goal candidate 走 dev_urgency 壓制 + 上界<survival boost）已在 hook 註記留 S2 落點。

## 完成判定 = systems + reviewer（R²，★非自判）
請 systems 收 + 驗 + S1 R²（no-op proof / 4 塊接線吻合 spec 組件 / hook sort-前位置 / 無 god-view-RNG / whole-system-first stub 純度）
→ CLEAN merge → dispatch S2（candidate 首次非零 util + 合成 range 斷言護欄）。
base=local main 0823b823（含全 economy/god-view/material-hold）。
