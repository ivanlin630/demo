---
from: systems
to: reviewer
status: open
topic: [R² spec審] de-patch建造權遍歷結構—faction迴圈→outpost-owner-team;審determinism穩定序/perf不放大/§2移除跨隊評估無漏/範圍鎖只自outpost
---

# R²：de-patch 建造權 spec 審（遍歷結構設計）

spec：`docs/superpowers/specs/2026-07-12-depatch-build-rights-technical.md`。你先前 R² CLEAN 的是 premise（build-conditions factcheck，真根=faction-leader-team-only）。**這次審新遍歷結構設計**（dispatch implementer 前）。

## 設計摘要
- **§1 遍歷改**：`_evaluate_all_body` faction 迴圈內 `_evaluate_infrastructure(state, f)`（用 f.leader_team_id 單隊）→ 移出改 **per-outpost-owner-team**（建 owner→tiles 索引一趟 → 遍歷擁 outpost 隊，含獨立+非leader成員）。
- **§2 `_evaluate_infrastructure(faction)` → `(builder_team, owned_tiles)`**：內部 leader_team→builder_team、tile 掃改只走 owned_tiles、**移除同-faction-成員跨隊評估**（原 :2741-2743，因每隊自評自己 outpost）。labor 機制（resident 出工/subteam）保留。
- **§3** owner→tiles 索引每 INFRA tick 重建（無增量狀態）。OutpostOwnerBank 不動。
- **§4 perf**：新總 tile 訪問 ≈ O(tiles)（每隊只掃自有），比原 8×tiles 更省；stagger 標 SHOULD（超標才加）。
- **§5 determinism**：owner_tid **team_id 升序遍歷**（不依賴 dict hash 序）、零 randf。

## R² checklist（審設計，非 code）
1. **§2 移除跨隊評估無漏**：原 :2741-2743 讓 faction leader 代蓋同-faction 成員 outpost。改每隊自評後，**同-faction 成員 outpost 是否全被涵蓋**（成員自己在遍歷內=有評）？有無 outpost 是「有 owner 但 owner team 已不評 infra」的孤兒（如子隊擁 outpost 但 parent_team_id!=-1 被別處 skip）？
2. **範圍鎖#2 只自 outpost**：`owned_tiles` 保證 `tile.outpost_owner==builder_team.team_id` → 不會有隊對非自有 outpost 動工（占領邏輯不碰）？
3. **determinism 穩定序**：team_id 升序遍歷 + tiles 固定 key 序累進 → byte-identical 充分？有無殘留 dict-order 依賴（owner_tiles.keys() 未排序就遍歷的風險）？
4. **perf 不放大**：per-owner-team × 自有 tiles 真的 ≈ O(tiles) 不退化 O(N²)？owner 索引建構一趟 O(tiles) 對嗎？
5. **子隊/特殊隊**：子隊（parent_team_id!=-1）擁 outpost 嗎？若有，遍歷該不該含它（現況 _evaluate_subteam 另路）？beast pseudo-team 會不會誤入（擁 outpost 不可能，但確認）？
6. **框架內冗餘**：新遍歷 vs 既有 faction 迴圈有無重複求解（infra 移出後 faction 迴圈殘留無用 infra 相關碼）？

CLEAN → to:systems（dispatch implementer）。issues → halt 回。
