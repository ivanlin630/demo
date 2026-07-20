---
from: systems
to: implementer
status: consumed
topic: "[dispatch·transition-arbiter-bypass·HIGH·R² v3 CLEAN·★off LOCAL main 68db7b15] spec=2026-07-19-transition-arbiter-bypass.md(v2 release-first,R² 三輪 CLEAN)。root:TaskArbiter.transition 無條件 raw 覆寫繞 arbiter=手不聽腦後門,team16 凍死。修兩部:①transition 加三 guard(combat lock/crisis-免疫/emergency-respect task_priority≥PRIO_THREAT 70 且 new<現任→return)=擋外部 stomp;②resolution caller 改 release-first(先 release→IDLE@0 過 guard 再 set):beggar-restore×3(interaction:1249/player_command:1017/sim_runner:259,★release 前存 move_target set 後還原,否則 previous_task 失目的地)、settle(interaction:1264/1289)、zombie-revive(faction_ai:2646)。defection(3884 等待新領主)+outpost build×6 保 guarded transition(現任<70 不受影響,measure 確認)。★★branch off LOCAL main 68db7b15(含 crisis/beast/hook/bed 全批),★禁 origin(8c88dd00 落後30)。TDD 7 型(beggar-restore move_target 還原/defection stomp 擋/settle/zombie/非-emergency 不破/combat/免疫)。逐13 caller measure 不破。gate/headless 0new/determinism/measure seed1337 team16 不凍死。task 完成=systems+reviewer 非自判。"
---

# dispatch：transition-arbiter-bypass（HIGH，R² 三輪 CLEAN）

spec：`docs/superpowers/specs/2026-07-19-transition-arbiter-bypass.md`（v2 release-first；注意事項/驗收全在 spec）。R² 三輪 CLEAN（v1 blanket guard 誤傷 → v2 release-first → v3 move_target 補）。

## ★★ branch base（關鍵）
- **branch off LOCAL main `68db7b15`**（`git worktree add .worktrees/transition-bypass -b feat/transition-arbiter-bypass 68db7b15` 或 `main`）。
- **★禁 origin/main**（`8c88dd00` 落後 local **30 commit**：crisis/beast/hook/bed 全批未 push）。基於 origin 會漏整批 naive-merge revert。
- **★注意 pre-push hook 已裝**：你 push branch 時起兩閘（constitution 恆跑 + verification branch-scoped fast-exit）。constitution 應 PASS；verification 無 measure.json 時 fast-exit。FAIL 擋 push（`--no-verify` 繞過須系統認可）。

## 修（兩部，詳 spec）
### Part 1：transition 加三 guard（`task_arbiter.gd` transition）
```gdscript
if team.combat_target != -1: return                       # combat lock
if new_task == team.crisis_released_task and team.crisis_released_task != "" \
        and state.world.current_tick < team.crisis_released_until: return   # crisis-免疫
if team.task_priority >= PRIO_THREAT and priority < team.task_priority: return   # emergency-respect
```
擋外部 in-place stomp（team16 defection@AMBIENT vs survival@80）。

### Part 2：resolution caller → release-first
先 `release(team)`（→IDLE@0，無 guard=引擎正當 emergency 退場）→ 再 set 新 task（post-release 過 guard）：
- **beggar-restore ×3**（`interaction:1249`/`player_command:1017`/`sim_runner:259`）：★**move_target 存/還**——`saved := team.move_target` → `release` → `try_set(..., saved, DISPATCH)`（帶 move_target）或 set 後 `team.move_target = saved`。否則 restore 的 previous_task 失目的地（reviewer R²v2 抓）。
- **settle**（`interaction:1264/1289`）：release → transition「生產」@AMBIENT（settle 隨後本就重設 move_target）。
- **zombie-revive**（`faction_ai:2646`）：release → set BUILD（現任若 RETURN_HOME@80）。

### Part 3：保 guarded transition（不改）
- defection（`faction_ai:3884` 等待新領主@AMBIENT）：guard 擋 stomp=team16 修，合原「AMBIENT 可被高層蓋」意圖。
- outpost build ×6（`outpost:384/406/447/461/566/602`）：現任常<70，guard 不 fire → **measure 確認**無 caller 現任≥70（若有→歸 Part 2）。

## 不變量（spec 有，你順手加 invariants.md 或回報我加）
in-place 轉換不得 stomp active emergency（≥THREAT）；**配套句**：emergency 自身 resolution 退場走 release（→re-rank）非靠 transition 降級。

## 驗收（spec §驗收，7 TDD）
①beggar-restore（release-first + **move_target 還原非-1** + previous_task 不失）②defection stomp survival@80 被擋 survival 留 ③settle from survival 態一致 ④zombie-revive ⑤非-emergency 轉換不破 ⑥combat lock ⑦crisis-免疫。**逐 13 caller measure 不破**。gate PASS / headless 0 new(baseline 3) / determinism 2跑 byte-identical / measure seed1337 team16 不凍死（broken 3→減）+ beggar/settle/zombie 不退化 + 42/4201 無 regression。**team64/68 idle-latch 看是否一併解（記錄，沒解=另案）**。

## 完成判定
= systems + reviewer/QA，非自判。做完寫 `to:systems`（pre-merge R² 看終 diff）or `to:measurer`（measure）。
