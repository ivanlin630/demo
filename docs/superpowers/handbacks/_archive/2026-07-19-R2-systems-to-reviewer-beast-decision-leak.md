---
from: systems
to: reviewer
status: consumed
topic: "[R² spec·野獸洩進決策迴圈+id碰撞] spec=2026-07-19-beast-decision-leak-and-id-collision.md。兩root:①id碰撞(_next_beast_id instance var非static→所有BeastSystem.new() spawn拿-1000000→create_team覆寫)修=counter移WorldState(★禁static var,跨run非決定);②決策洩漏(evaluate_all loop2:700/loop3:749無beast_kind skip→beast跑team AI)修=兩loop body頂 beast_kind!='' continue。審點:①WorldState counter真解id碰撞且per-seed決定(非static)②beast skip無誤傷combat/cleanup生命週期(那在npc_combat/encounter)③loop3 skip放頂會不會漏beast該走的extinct清理(我判combat擁有)④非ambition-preempt補丁(root非症狀)⑤determinism 2跑byte-identical可達。off main 35e9ee8f。CLEAN→dispatch implementer。"
---

# R² spec：野獸洩進決策迴圈 + id 碰撞

spec：`docs/superpowers/specs/2026-07-19-beast-decision-leak-and-id-collision.md`。off main `35e9ee8f`（crisis-immunity merged 後）。

## 背景
crisis-immunity QA 撿 `team=-1000000` ambition-lock 死隊 + blueprint 全 log 20x 證據 → systems 裁定=野獸兩 bug（id 碰撞 + 決策洩漏），已立 known_issues。此 spec 給修法，R² 審設計再 dispatch。

## 兩 root + 修（詳 spec）
1. **id 碰撞**：`_next_beast_id` instance var（`beast_system.gd:16`）→ 每 `BeastSystem.new()` 重置 -1000000 → 所有 beast 撞 -1000000（`create_team` `world_state.gd:256` 覆寫）。修=counter 移 `WorldState.next_beast_id`（**★禁 static var**：static 跨 sim run 同 process 不 reset→多-run bed 非決定；WorldState per-world fresh→per-seed 決定 + 唯一 id）。
2. **決策洩漏**：`_evaluate_all_body` loop2(`:700` faction_id==-1 支)+loop3(`:749`)無 `beast_kind` guard → beast 跑 strategy/solo/infra/leader-promote/ambition。修=兩 loop body 頂 `if team.beast_kind != "": continue`。

## R² 審點
1. **id 碰撞真解**：WorldState counter 是否真消碰撞 + 保 per-seed 決定性（非 static 的跨-run 污染）。有無別的 beast-id 生成路我漏看（grep `team_id =` in beast/encounter）。
2. **beast skip 無誤傷生命週期**：beast 移出 evaluate_all 後，spawn/combat/reward/cleanup 是否完整（那些在 `npc_combat`/`encounter`/`beast_system`，不靠 evaluate_all）。skip 會不會斷掉 beast 該有的 combat 觸發？
3. **loop3 skip 位置**：`continue` 放 loop3 body 頂 = beast 也跳過 generic `_on_team_extinct`/leader/ambition。beast 滅團清理是否確由 combat cleanup 擁有（我判是 `reward_and_cleanup`/`_cleanup`），還是有 beast 靠 loop3 extinct 的邊角路？
4. **非 ambition-preempt 補丁**：確認這是 de-patch（移非-agent 出決策秤）非在症狀（ambition@10 preemption）上補。守決策模型「非-agent 不經腦」。
5. **determinism 可達**：WorldState counter 下 2 跑 byte-identical 可成立（無殘 static/global 狀態）。

## 回覆
`to:systems` verdict：CLEAN / blocking(file:line + 修向)。CLEAN → 我 push main 35e9ee8f 到 origin + dispatch implementer worktree（避 stale-base revert，[[feedback_worktree_stale_base]]）。
