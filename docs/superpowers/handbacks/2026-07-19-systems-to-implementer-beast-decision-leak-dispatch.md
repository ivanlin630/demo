---
from: systems
to: implementer
status: open
topic: "[dispatch·野獸洩進決策迴圈+id碰撞·R² CLEAN·★off LOCAL main f42a6e1c 非 origin] spec=2026-07-19-beast-decision-leak-and-id-collision.md。R² CLEAN(5審點 file:line 坐實)。兩root:①id碰撞—_next_beast_id instance var(beast_system.gd:16)→所有 BeastSystem.new() spawn 拿-1000000→create_team覆寫。修=counter移 WorldState.next_beast_id(★禁static var:跨run非決定);build_beast_team讀state.next_beast_id-=1。②決策洩漏—evaluate_all loop2(:700 faction_id==-1支)/loop3(:749)無beast_kind guard→beast跑team AI。修=兩loop body頂 if team.beast_kind!='' : continue。★★branch off LOCAL main f42a6e1c(含slice2/godviewF/crisis merge),★禁 origin/main(bb1e75ff 落後11 commit,naive-merge會revert整批)。TDD:①3beast 3相異id ②spawn beast跑N tick evaluate_all→無task/ambition/leader晉升 ③既有beast測(headless_test 2202/2231/2262/2401)續綠。gate PASS/headless 0new(baseline 3:p2a/beg-join/strategic-ladder)/determinism 2跑byte-identical/measure seed1337·42·4201真隊無regression。task完成判定=systems+reviewer非自判。"
---

# dispatch：野獸洩進決策迴圈 + id 碰撞（R² CLEAN）

spec：`docs/superpowers/specs/2026-07-19-beast-decision-leak-and-id-collision.md`（注意事項/驗收全在 spec）。

## ★★ branch base（關鍵，別搞錯）
- **branch off LOCAL main `f42a6e1c`**（`git worktree add .worktrees/beast-fix -b feat/beast-fix f42a6e1c` 或 `main`——local main ref）。
- **★禁 origin/main**：`origin/main = bb1e75ff` **落後 local 11 commit**（slice2/god-view Slice F/crisis-immunity 全 merged local 未 push）。基於 origin/main 會漏整批，naive-merge 回來 revert slice2/godview/crisis。這是既有 origin-behind workaround（前輪同款）。

## 兩 root + 修（詳 spec）
1. **id 碰撞（先）**：`_next_beast_id` instance var（`beast_system.gd:16`）→ 每 `BeastSystem.new()`（`faction_ai:3314`/`encounter:1232`/`ambush:57`/`player_command:177`）重置 -1000000 → 全 beast 撞 -1000000（`create_team` `world_state.gd:256` 覆寫）。
   - 修 = counter 移 `WorldState`（`var next_beast_id: int = -1000000`）。`build_beast_team`：`t.team_id = state.next_beast_id; state.next_beast_id -= 1`。
   - **★禁 `static var`**：static 跨 sim run 同 process 不 reset → 多-run bed 非決定。WorldState per-world fresh → per-seed 決定 + 唯一 id。
2. **決策洩漏**：`_evaluate_all_body` loop2(`:696` body 頂)+loop3(`:749` body 頂)：`if team.beast_kind != "": continue`。beast 生命週期全在 npc_combat/encounter/beast_system，不經 evaluate_all。

## 驗收（spec §驗收）
- **TDD**：①id 唯一（3 beast → 3 相異 id）②beast 不進決策（spawn beast 跑 N tick evaluate_all → `current_task` beast-neutral、`leader_id` 不晉升、無 ambition intent）③combat 生命週期完好（`headless_test.gd:2202/2231/2262/2401` 續綠）。
- **gate**：`constitution_gate` PASS。
- **headless**：0 new（baseline 3 pre-existing：p2a join weight / beg-join combat 擋 / strategic ladder 擴張 intent）。
- **determinism**：同 seed 2 跑 byte-identical。
- **measure（→measurer）**：seed1337/42/4201 真隊無 regression（starve/pop/teams），真隊 belief 不再含 -1000000 幻影條目。

## 完成判定
task 完成 = systems + reviewer/QA 判，非自判。做完寫 `to:measurer`（measure）or `to:systems`（pre-merge R² 看終 diff）。
