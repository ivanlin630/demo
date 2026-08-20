---
from: systems
to: implementer
status: open
topic: "[dispatch owner→outpost 索引(效能 arc B、重定靶後縮小版)·spec=2026-08-20-owner-outpost-index-HOW.md·R²=CLEAN 無必查項·★這刀【必須 byte-identical】——fp 變了就是 bug、不准用 intended-change 解釋(上位 plan §3 已分類)·★靶(我親查):_find_own_outpost(faction_ai:5106)全圖掃 for tile_id in state.world.tiles,【12 個 production 呼點】(decision_context:254/422、goal_resolver:45/353/405/425、need_oracle:38/76、options:111/149、faction_ai:4306、movement_system:324);★_faction_roster_pos(:5124)又 inline 同一個全圖掃=第二處;多數呼點還各做 FactionAISystem.new()·★T1 state.owner_outpost: Dictionary(team_id→Vector2i),chokepoint 維護:①OutpostOwnerBank.set_owner(既有單一入口)②outpost_level 跨 0(完工 0→>0/摧毀降級 >0→0)③erase_teams(移除條目)·T2 兩處查詢都改查表(_find_own_outpost + _faction_roster_pos 的 inline 掃、兩者語意本來相同)·★★T3 等價關鍵(不做對就不是等價替換):現行語意=【state.world.tiles 迭代順序中的第一個符合者】——一隊多據點時回哪個【取決於插入序】;索引必須重現同一選擇(建表依 tiles 迭代序、每 owner 只留第一個;增量更新不得讓後設的 owner 蓋掉迭代序更前的既有據點→該 owner 條目失效後依原順序重建)·★禁用『最近設定的/距離最近的』這類更聰明但不同的語意(那是行為改動、要另開 intended-change slice)·gate①★★影子對照=核心證據:真實 run 中【每次查詢同時跑舊全圖掃與新索引並 assert 相等】(含 -1),任一不等即 FAIL 並印 team/tile;warring+peaceful 各一段②★fp byte-identical(det×3 與 main 相同)③失效路徑 TDD 五條(set_owner 換手/完工/摧毀降級/erase_teams/★同 owner 多據點仍回迭代序最前者)④量化 wall/day 與 main 對照——★預期下降但【幅度可能不大】(12 呼點×全圖掃雖多,但 N² 主因未必在此),照實報別挑好窗⑤constitution<=75+headless 0-new·★量測坑提醒(你自己踩過):全新檔名+序列跑+同 ADHOC_TICKS+同窗長·worktree feat/owner-outpost-index·完→handback to:systems·地基KEEP"
---

# dispatch：`owner → outpost` 索引（效能 arc B、重定靶後縮小版）

spec＝`docs/superpowers/specs/2026-08-20-owner-outpost-index-HOW.md`。**R²＝CLEAN、無必查項**。
★**這刀必須 byte-identical**——**fp 變了就是 bug、不准用 intended-change 解釋**。

**靶**（我親查）：`_find_own_outpost`（`faction_ai:5106`）**全圖掃**、**12 個 production 呼點**（`decision_context:254/422`、`goal_resolver:45/353/405/425`、`need_oracle:38/76`、`options:111/149`、`faction_ai:4306`、`movement_system:324`）；★**`_faction_roster_pos`（`:5124`）又 inline 同一個全圖掃 ＝ 第二處**；多數呼點還各做 `FactionAISystem.new()`。

- **T1**：`state.owner_outpost: Dictionary`（`team_id → Vector2i`），**chokepoint 維護**：①`OutpostOwnerBank.set_owner`（既有單一入口）②`outpost_level` 跨 0（完工 0→>0／摧毀降級 >0→0）③`erase_teams`（移除條目）。
- **T2**：**兩處查詢都改查表**（`_find_own_outpost` + `_faction_roster_pos` 的 inline 掃；兩者語意本來相同）。
- **★★T3 等價關鍵**：現行語意 ＝ **「`state.world.tiles` 迭代順序中的第一個符合者」**——一隊多據點時回哪個**取決於插入序**。索引**必須重現同一選擇**（建表依 tiles 迭代序、每 owner 只留第一個；增量更新**不得**讓後設的 owner 蓋掉迭代序更前的既有據點 → 該 owner 條目失效後**依原順序重建**）。
  ★**禁**用「最近設定的／距離最近的」這類**更聰明但不同**的語意（那是行為改動、要另開 intended-change slice）。

**gate**：①★★**影子對照 ＝ 核心證據**（真實 run 中**每次查詢同時跑舊掃描與新索引並 assert 相等**、含 `-1`；任一不等即 **FAIL** 並印 team/tile；warring + peaceful 各一段） ②★**fp byte-identical**（det×3 與 main 相同） ③失效路徑 TDD **五條**（`set_owner` 換手／完工／摧毀降級／`erase_teams`／★同 owner 多據點**仍回迭代序最前者**） ④量化 `wall/day` 與 main 對照——★**預期下降但幅度可能不大**（N² 主因未必在此），**照實報、別挑好窗** ⑤constitution ≤75 + headless 0-new。

★**量測坑提醒**（你自己踩過）：**全新檔名 + 序列跑 + 同 `ADHOC_TICKS` + 同窗長**。

worktree `feat/owner-outpost-index`。完 → handback to:systems。地基 KEEP。
