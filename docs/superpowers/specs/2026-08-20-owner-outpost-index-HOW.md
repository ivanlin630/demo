# HOW spec：`owner → outpost tile` 索引（效能 arc B、重定靶後的縮小版）

date: 2026-08-20 ／ owner: systems ／ 上位 plan ＝ `2026-08-20-event-proportional-compute-HOW.md`（R² CLEAN）
狀態：待 R² → dispatch。★**必須 byte-identical**（見 §3）。

## §1 重定靶的理由（原 B「空間索引」前提不成立）
親查 13 個 finder 的迭代來源：**11 個已是 belief-bounded**（迭代 `state.team_discovered`）→ 沒有「掃全世界」可省。
**唯一真全域掃**＝`_find_own_outpost`（`faction_ai:5106`）：`for tile_id in state.world.tiles` 全圖掃、找 `outpost_level>0 and outpost_owner==team_id`。
- **12 個 production 呼點**：`decision_context:254/422`、`goal_resolver:45/353/405/425`、`need_oracle:38/76`、`options:111/149`、`faction_ai:4306`、`movement_system:324`。
- ★**`_faction_roster_pos`（`:5124`）又 inline 了同一個全圖掃**（第二處）。
- ★多數呼點還各做一次 `FactionAISystem.new()`（連帶本 session 記過的 40 站點 alloc 帳）。

## §2 設計
- `state.owner_outpost: Dictionary`（`team_id → Vector2i`），由 **chokepoint 維護**：
  - **owner 變更**：`OutpostOwnerBank.set_owner`（既有單一入口）。
  - **outpost_level 跨 0**：完工（0→>0）／摧毀・降級（>0→0）。
  - **tile/team 消失**：`erase_teams`（該 team 條目移除）。
- 查詢：`_find_own_outpost` 改為查表；**`_faction_roster_pos` 的 inline 掃也改查同一表**（兩處語意本來就相同）。

## §3 ★byte-identical 的關鍵細節（不做對就不是等價替換）
現行語意 ＝ **「`state.world.tiles` 迭代順序中的第一個符合者」**——**當一隊擁有多個據點時，回傳哪一個取決於 Dictionary 插入序**。
∴ 索引**必須重現同一個選擇**：
- 建表/重建時**依 `state.world.tiles` 的迭代順序**掃，**每個 owner 只保留第一個命中**。
- chokepoint 增量更新時，**不得**讓「後來設定的 owner」覆蓋掉「迭代序更前面的既有據點」→ 更新後若該 owner 仍有多個據點，**以迭代序最前者為準**（實作可：該 owner 條目失效 → 下次查詢時**依原順序**重建該條目）。
- ★**禁**用「最近設定的那個」或「距離最近的那個」等**更聰明但不同**的語意——那會改變行為、不再 byte-identical（要改語意是另一個 slice、要走 intended-change）。

## §4 gate
1. ★★**影子對照（本 slice 的核心證據）**：跑一個真實 run，**每次查詢同時跑「舊全圖掃」與「新索引」並 assert 相等**（含 `-1` 情況）；**任一不等即 FAIL 並印出 team/tile**。至少覆蓋 warring + peaceful 各一段。
2. ★**fp byte-identical**（det×3 與 main 相同）——**這一刀 fp 變了就是 bug，不准用 intended-change 解釋**（上位 plan §3 已分類）。
3. **失效路徑覆蓋**：TDD 驗 ①set_owner 換手 ②完工 0→>0 ③摧毀/降級 >0→0 ④`erase_teams` 移除 ⑤同一 owner 多據點時**仍回傳迭代序最前者**。
4. **量化**：`wall/day` 與 main 對照（**預期下降、幅度可能不大**——12 呼點 × 全圖掃雖然多，但 N² 主因未必在此）；★**照實報，別為了好看只挑好的窗**。
5. constitution ≤75 + headless 0-new。
