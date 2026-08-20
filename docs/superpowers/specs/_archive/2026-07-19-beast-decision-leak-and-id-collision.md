# spec：野獸洩進決策迴圈 + id 碰撞（beast-decision-leak + id-collision）

> 層級：L2（2 關聯 root，同型「非-agent 洩進 agent 決策迴圈」）。off crisis-immunity merge 後 main（35e9ee8f）。
> 來源：crisis-immunity QA 故事稽核撿 `team=-1000000` ambition-lock 死隊 + blueprint 全 log 20x 證據。systems 裁定=野獸兩 bug。known_issues「野獸洩進 team 決策迴圈」。

## 病象
QA trace：`team=-1000000` 連 300 tick `task=建設 reason=ambition food=0`；blueprint 全 log：8 月出現 20 次，每次 `[Combat Start]`→`[Succession]晉升臨時領袖(統領0.03-0.28)`→`[Order]buy food`。一隻鹿/豬跑完整定居隊 AI。

## 兩根（file:line 坐實）

### Root 1（優先）：beast id 碰撞
- `beast_system.gd:16` `var _next_beast_id: int = -1000000`（**instance var**）。
- 所有 spawn 走 `BeastSystem.new().build_beast_team(...)`（`faction_ai:3314`/`encounter:1232`/`ambush:57`/`player_command:177`=每次 fresh 實例）→ `_next_beast_id` 每次重置 -1000000，`build_beast_team` 的 `_next_beast_id -= 1` 改即棄實例、無效。
- ∴ **每隻 beast 都拿 `team_id=-1000000`**；`create_team`（`world_state.gd:256` `teams[id]=team`）靜默覆寫 → 後 beast 覆前 beast，`combat_target=-1000000`/belief 條目懸空指向「當下那隻」。20x 復現 = 20 隻不同 beast 撞同 id。

### Root 2：野獸洩進決策迴圈
- `faction_ai_system._evaluate_all_body`：
  - loop2（`:696-731`）：beast `faction_id=-1`（`beast_system.gd:28`）→ 落 `elif team.faction_id == -1:`(`:700`) → 跑 `_evaluate_independent_strategy`（建國/ambition）+ `_evaluate_solo` + `_evaluate_independent_infrastructure`（建設）。無 `beast_kind` guard。
  - loop3（`:749-`）：`leader_id=-1` → `on_leader_death` 晉升 anon 領袖；後續 AmbitionLadder。

## 修

### Root 1：counter 移 WorldState（★禁 static var）
- **禁 `static var`**：static 跨 sim run 在同 process 不 reset → 多-run bed 非決定性（id 累積跨 run）。
- **正解**：counter 移 `WorldState`（`var next_beast_id: int = -1000000`，每 world fresh init → per-seed 決定性 + 每 beast 唯一遞減 id）。
- `build_beast_team`：`t.team_id = state.next_beast_id; state.next_beast_id -= 1`。
- 驗：連 spawn 3 beast → 3 個相異 id（非全 -1000000）。

### Root 2：beast skip 出決策迴圈
- `_evaluate_all_body` loop2 body 頂 + loop3 body 頂：`if team.beast_kind != "": continue`。
- 野獸生命週期（spawn/combat/reward/cleanup）**全在** encounter/npc_combat/beast_system，**不經** evaluate_all 決策。beast 不評 strategy/solo/infra、不晉升領袖、不跑 ambition。
- **loop3 caveat**：beast 的滅團清理由 combat cleanup（`reward_and_cleanup`/`_cleanup` erase）擁有，非 loop3 generic `_on_team_extinct`；`continue` 放 loop3 body 頂即可（beast 不該進 leader/ambition/extinct-loot 路）。若量測發現 beast husk 殘留（combat 沒清到的邊角），另評，非本 slice 主體。

## 不變量
- **非-agent 不跑 agent 決策迴圈**（決策模型「引擎=唯一的秤，感知→反應必經這隻的腦」——野獸無「腦」不該經秤）。此修 = 把戰鬥 prop 移出決策秤，**非**加 ambition-preempt 補丁（補丁閘/root 通則：de-patch）。
- **★非 crisis-override 第 6 種 stuck-task 變體**：根不是 ambition@10 沒被 preempt，是野獸不該有 task/ambition/決策。

## 驗收
- **TDD**：①id 唯一（3 beast 3 id）②beast 不進決策（spawn beast 跑 N tick evaluate_all → `current_task` 保持 beast-neutral、`leader_id` 不被晉升、無 ambition intent）③combat 生命週期完好（既有 beast 測 `headless_test.gd:2202/2231/2262/2401` 續綠）。
- **gate**：`constitution_gate` PASS（64,或合理增減——beast skip=決策路徑減，非新增引擎外指派，應不增違憲 site）。
- **headless**：0 new（baseline 3 pre-existing：p2a join weight / beg-join combat / strategic ladder）。
- **determinism**：同 seed 2 跑 byte-identical（WorldState counter per-seed 決定，非 static 跨 run）。
- **measure**：seed1337/42/4201 真隊無 regression（starve/pop/teams）——移除幻影野獸 outpost/anon-leader 消耗污染=預期改善或持平，非退化。真隊 belief 不再含 -1000000 幻影條目。

## 排序
Root 1 + Root 2 同 slice（同型「非-agent 決策」+ 同檔區）。Root 1 先（懸空 ref hazard 更基礎，可能污染 belief/combat/量測）。off main 35e9ee8f。
