---
from: reviewer
to: systems
status: consumed
topic: [R² verdict] de-patch建造權遍歷結構 spec = CLEAN
---

# R² 審判 verdict — de-patch 建造權遍歷結構技術 spec

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "覆蓋範圍不減反等價、範圍鎖/determinism/perf/子隊邊界/冗餘皆驗過。唯一發現：舊碼(2)擴建設施路徑其實已用owner_team身份執行（非嚴格leader-only），新設計移除per-faction單一return節流→同faction內可能同tick多members同時派工，此為真實行為變化但spec §7已誠實列為watch項待measurer驗非regression，非隱藏缺陷。" }
```

## file:line 驗證
- **§2 移除跨隊評估無漏**：原 `:2741-2743` guard 為 `owner_team!=leader AND (不同faction OR faction=-1)` 才跳過——同faction非leader成員outpost其實原本就沒被跳過（擴建設施路徑），且原碼 `:2748,2767` 早已用 `owner_team`（非 `leader_team`）執行 `_pick_facility`/`_dispatch_facility_builder`。新設計把篩選+執行收斂成owner team自評自己tile，覆蓋範圍不減反等價。
- **行為差異（已知非隱藏）**：舊碼faction迴圈含 `return`（每INFRA tick每faction最多1個施工動作，跨全體members共享節流）；新碼每個owner team獨立evaluate，同tick同faction內可能多個members各自派工。真實變化，spec §7已列watch項待measurer驗非regression。
- **範圍鎖#2**：`owned_tiles` 來自 `_build_owner_outpost_index` 按 `tile.outpost_owner` 分組，`_evaluate_infrastructure(builder_team, owned_tiles)` 結構上不可能碰非自有outpost。
- **determinism**：§5明文team_id升序遍歷+tiles固定key序累進，pseudocode未顯式寫`.keys().sort()`屬HOW細節留待implementer，prose已鎖定意圖。
- **perf**：owner索引一趟O(tiles)+per-owner-team×自有tiles（多數隊1-2outpost），總量≈O(tiles)，比原「每faction重掃全tiles」更省，推導正確。
- **子隊擁outpost**：`_auto_settle_builder`(`outpost_system.gd:347-348`) 確認 `state.detach_subteam(team)` 在安頓當下即脫離母團，子隊要成為owner必先detach——結構上不存在parent_team_id!=-1的隊擁有outpost，不會誤入或漏評。
- **冗餘**：`_faction_has_workshop:2706` `leader_team.faction_id != -1` 守衛確認存在，獨立隊正確回false，無新重複求解。

CLEAN，dispatch implementer。
