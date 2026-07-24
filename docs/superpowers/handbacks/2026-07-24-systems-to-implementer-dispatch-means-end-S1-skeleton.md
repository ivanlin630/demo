---
from: systems
to: implementer
status: open
topic: "[dispatch·means-end S1 骨架·spec HOW §10 S1+組件 A/B/G·byte-identical no-op proof(空 candidate)·★base=LOCAL main HEAD 485f9e23 非 origin/main(stale-base 鐵律,~90 commits local-ahead 含 HOW spec+material-hold 全未 push)·新 branch feat/means-end-s1-skeleton off local HEAD] R①R②(異質框外)全過,HOW spec 鎖=docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md。S1=骨架 slice,目標 byte-identical no-op proof(接線骨架就位但零行為變,因 candidate 空)。★★base 鐵律:branch off **LOCAL main HEAD(485f9e23)** 非 origin/main——本 session ~90 commits local-ahead 未 push(含此 HOW spec+material-hold merge+全 economy/god-view 工作),off origin/main 會拿舊 base 全盤皆錯;若既存 worktree 先 merge/rebase local main。修 4 塊(照 spec 組件):①TeamData 加 goal_state:Array 欄(組件 A schema:每元素 GoalInstance={goal_type:String,target=null,created_tick:int,status:String};S1 空初始[]+序列化 save/load 若有)②新 GoalRegistry(組件 B,scripts/simulation/decision/ 底下,static dict 空表結構+5 種前置 enum 常數:resource/location/manpower/facility/subgoal;S1 空 registry data)③新 GoalResolver(組件 C,scripts/simulation/decision/ 底下★路徑必 decision/=GV_FILE_RE 涵蓋 constitution_gate 看得到),static func frontier_candidates(state,team,ctx)->Array:S1 直接 return []（stub）④rank_scored_ctx(decision_engine.gd:56-91)後追加 hook:for cand in GoalResolver.frontier_candidates(state,team,ctx): scored.append(...)——S1 candidate 空=no-op(既有 argmax 零變)。TDD:①goal_state 欄存在+空初始②GoalResolver.frontier_candidates 回 []③rank hook 存在但 no-op④★determinism 2 跑 byte-identical(S1 完全 no-op vs baseline,candidate 空→hash 一致)。閘:constitution_gate PASS(新 GoalResolver/GoalRegistry 在 decision/,S1 stub 無 god-view/RNG/task 指派)+headless 0 new error+determinism 2 跑 byte-identical。完成判定=systems+reviewer(R②),★非自判。做完→to:systems(我收+驗+S1 R②)→CLEAN merge→dispatch S2。★whole-system-first:S1 只骨架,別提前塞 S2+ 邏輯(resolver 保持 stub 回 [])。generalize 標記=S1 純接線。task=systems+reviewer。"
branch: feat/means-end-s1-skeleton
---

# dispatch：means-end S1 骨架（byte-identical no-op proof）

**R①R②（異質框外）全過，HOW spec 鎖** = `docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md`。S1 = 骨架 slice：接線骨架就位、**零行為變**（candidate 空 → byte-identical）。

## ★★base 鐵律（stale-base，memory `feedback_worktree_stale_base`）
- branch **off LOCAL main HEAD（`485f9e23`）非 origin/main**。
- 本 session **~90 commits local-ahead 未 push**（含此 HOW spec + material-hold merge + 全 economy/god-view 工作）→ off origin/main **會拿舊 base 全盤皆錯**。
- 若既存 worktree：先 merge/rebase local main 拿到 HOW spec + 全工作。

## 修 4 塊（照 spec 組件 A/B/G）
1. **TeamData 加 `goal_state: Array` 欄**（組件 A）：每元素 `GoalInstance = {goal_type:String, target=null, created_tick:int, status:String}`。S1 **空初始 `[]`** + 序列化 save/load（若 TeamData 有）。
2. **新 `GoalRegistry`**（組件 B）：`scripts/simulation/decision/` 底下，static dict 空表結構 + **5 種前置 enum 常數**（`resource`/`location`/`manpower`/`facility`/`subgoal`）。S1 空 registry data。
3. **新 `GoalResolver`**（組件 C）：`scripts/simulation/decision/` 底下（★**路徑必 `decision/`** = `GV_FILE_RE` 涵蓋，constitution_gate 看得到）。`static func frontier_candidates(state, team, ctx) -> Array`：**S1 直接 `return []`（stub）**。
4. **`rank_scored_ctx`**（`decision_engine.gd:56-91`）後追加 hook：`for cand in GoalResolver.frontier_candidates(state, team, ctx): scored.append({...})`——S1 candidate 空 = **no-op**（既有 argmax 零變）。

## TDD
1. `goal_state` 欄存在 + 空初始。
2. `GoalResolver.frontier_candidates` 回 `[]`。
3. rank hook 存在但 no-op。
4. ★**determinism 2 跑 byte-identical**（S1 完全 no-op vs baseline，candidate 空 → hash 一致）。

## 閘
- **constitution_gate PASS**（新 GoalResolver/GoalRegistry 在 `decision/`，S1 stub 無 god-view/RNG/task 指派）。
- **headless 0 new error**。
- **determinism 2 跑 byte-identical**。

## 完成 + 紀律
- 完成判定 = **systems + reviewer（R②）**，★非自判。做完 → `to:systems`（我收 + 驗 + S1 R②）→ CLEAN merge → dispatch S2。
- ★**whole-system-first**：S1 **只骨架**，別提前塞 S2+ 邏輯（resolver 保持 stub 回 `[]`）。
