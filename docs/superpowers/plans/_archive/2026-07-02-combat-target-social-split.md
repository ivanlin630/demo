# Plan — combat_target chokepoint + BEG/JOIN 綁修

> spec = `specs/2026-07-02-combat-target-social-split-design.md`。
> 前置：headless 基準 PASS + BEG/JOIN 探針 baseline(join.resolve=0)記下。

## Task 1 — social_target 拆 + chokepoint（TDD）
- `team_data.gd`：加 `social_target`。
- `world_state.gd`：`set_combat_target`/`clear` + `set_social_target`/`clear` chokepoint（erase 清）。mirror set_leader。
- **測**：chokepoint set/clear、erase 清、dangling 不留。
- **DoD**：兩 chokepoint 綠。

## Task 2 — BEG/JOIN dispatch 改 social_target
- `decision/options.gd:96/104`(JOIN/BEG to_task)、`faction_ai:1377`(JOIN)：設 `social_target` 非 combat_target。
- **測**：BEG/JOIN 隊 combat_target=-1、social_target=目標。
- **DoD**：BEG/JOIN 不再設 combat_target(過 197 前置)。

## Task 3 — JOIN resolver + BEG 解封
- `interaction_system._try_interact`:197 早退只看 combat_target(不變,BEG/JOIN 現過);加 `TASK_JOIN` branch(social_target 對上→併隊/入 faction,複用 merge_teams/set_team_faction);BEG branch 讀 social_target。
- **測**：NPC JOIN→resolve(併隊)、BEG→resolve(aid);探針 join.resolve>0/beg.resolve>0。
- **DoD**：BEG/JOIN 死路消、resolve 真跑。

## Task 4 — combat_target 直寫遷 chokepoint
- 9 直寫 site(npc_combat/faction_ai 攻擊/…)→ set_combat_target。逐檔 headless 零回歸(戰鬥不變)。
- `invariant_audit`：combat_target/social_target dangling 檢。
- **DoD**：combat_target 單寫者、dangling audit 綠、戰鬥零回歸。

## Task 5 — 活世界 + 守恆
- warring seed：NPC 絕境投靠/乞食真 resolve(join.resolve>0)、不暴增併隊潮(投靠率合理)。
- headless PASS≥基準、coin_eq(全池)0、pop 守恆(併隊轉移)、framework S1-S6 PASS、InvariantAudit(含 target dangling)0。
- **DoD**：BEG/JOIN 復活合理 + 守恆綠。

## 不碰（scope + 並行 guard）
- capture 完成(軌1,npc_combat absorb/casualty 函數)、tile-bank、決策 intent。**只碰 team_data(social_target)/world_state(chokepoint)/options(BEG/JOIN dispatch)/interaction(resolver+197)/faction_ai+npc_combat(combat_target field 寫)/invariant_audit**。

## 完成
- handback：combat_target/social_target chokepoint + BEG/JOIN resolve 復活(join.resolve 0→N)+ 併隊率合理 + 守恆。F-S4+F-I3 收。
- ⚠ 與 capture 軌並行同觸 npc_combat 不同函數(combat_target 寫 vs absorb)→ 系統 merge 序解。
