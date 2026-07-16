# combat_target chokepoint + BEG/JOIN 綁修（社交 target ≠ 戰鬥 target）— 設計 spec

> 系統 HOW spec。承藍圖 `capture-pay-conqueror-lastmile` 平行 + `matrix-rulings`（BEG/JOIN 合併修）。統一矩陣 F-S4（combat_target 無 chokepoint）+ F-I3（BEG/JOIN 死路）。
> **共根**：BEG/JOIN 死路 = 絕境隊設 `combat_target`（社交意圖）被 `_try_interact:197`（`combat_target != -1: return`,戰鬥意圖）擋。combat_target **語意 overload**（戰鬥+社交）→ **拆語意 + 加 chokepoint 一次修**。

## 現況（統一矩陣 + BEG/JOIN 探針）
- **F-S4**：`combat_target` 9 檔直寫、無 chokepoint、erase_team 反應式清。
- **F-I3（探針證）**：JOIN 66/月 100% 空轉——BEG/JOIN dispatch 設 `combat_target=社交target`（`options.gd:96/104`、`faction_ai:1377`）→ `_try_interact:197` combat_target≠-1 早退 → BEG resolver(:247) 不可達;**JOIN 根本無 handler**。
- 兩 failure mode:197 早退(4/66) + 無 handler(62/66 靜默 fall-through)。

## 設計

### A. 語意拆：social_target ≠ combat_target
- 加 `TeamData.social_target`（投靠/乞食 目標,非戰鬥）。BEG/JOIN dispatch 設 `social_target` **非 combat_target**（`options.gd:96/104`、`faction_ai:1377`）。
- `_try_interact:197` 早退只看 `combat_target`（真戰鬥）→ BEG/JOIN 隊 combat_target=-1 → **過 197**。

### B. combat_target chokepoint（F-S4）
- `WorldState.set_combat_target(team, tid)` / `clear`（單寫者;erase_team 續清）。9 直寫 site 遷。**mirror set_team_faction/set_leader**。
- social_target 亦走 chokepoint（`set_social_target`/clear）or 輕量（plan 定,傾向一致）。
- **InvariantAudit**：combat_target/social_target dangling 檢（連 team-ref 契約單欄 target 瞬時懸空 §）。

### C. JOIN resolver（新 handler）+ BEG 解封
- `_try_interact` 加 `TASK_JOIN` branch（social_target 對上 → 併隊/入 faction,複用 `SubteamSystem.merge_teams`/`set_team_faction`）。
- BEG:`TASK_BEG` branch 改讀 `social_target`(過 197 後可達)→ `_resolve_aid_request`。
- player 版已直呼 resolver（不受影響,或一併統一走新 social 路徑）。

## 驗收
- **BEG/JOIN 死路消**：探針 `join.resolve`>0（前 0）、`beg.resolve`>0;NPC 絕境投靠/乞食真 resolve（非 100% 空轉）。
- **combat_target 單寫者**：9 site 走 chokepoint;dangling audit 綠。
- 守恆：coin_eq 全池 0、pop 守恆（併隊 pop 轉移守恆）、framework S1-S6 PASS、headless 全綠、InvariantAudit（含 target dangling）0。
- **行為變**（BEG/JOIN 從空轉→真 resolve = 絕境 repertoire 復活,藍圖 marker1 要的）→ bed 驗投靠/乞食合理（不暴增併隊潮）。

## 檔案
- `team_data.gd`：`social_target` 欄。
- `world_state.gd`：`set_combat_target`/`set_social_target` chokepoint + erase 清。
- `decision/options.gd`：BEG/JOIN to_task 設 social_target 非 combat_target。
- `faction_ai_system.gd`：JOIN dispatch(:1377) social_target;combat_target 直寫遷 chokepoint。
- `interaction_system.gd`：`_try_interact` JOIN branch(新)+ BEG 讀 social_target;197 只看 combat_target。
- 其餘 combat_target 直寫 site（npc_combat/faction_ai 攻擊）→ chokepoint。
- `invariant_audit.gd`：target dangling 檢。
- `headless_test.gd`：JOIN/BEG resolve 測 + combat_target chokepoint 測 + 探針 resolve>0。

## 風險 + 緩解
- **社交 target 拆動面**：BEG/JOIN dispatch 少數 site;combat_target 9 site 逐一遷 TDD、每檔 headless 零回歸（戰鬥行為不變）。
- **JOIN resolver 新行為**（併隊潮）：複用既有 merge,bed 驗投靠率合理（means-end 匱乏 gate + 絕境 gate 已限）。
- **與 capture/seeded 並行**：本軌碰 world_state/interaction/options/faction_ai(combat_target 寫+JOIN dispatch)/npc_combat(combat_target 寫);capture 軌碰 npc_combat(absorb/casualty 函數,不同);seeded 碰 debug → 同檔不同函數,merge 序解。⚠ faction_ai combat_target 寫 vs capture 的 absorb 不同函數。
- **scope**：combat_target/social_target chokepoint + BEG/JOIN resolve。**不碰** capture 完成(軌1)、tile-bank、決策 intent。

## 開放細節（plan 定）
- social_target chokepoint vs 輕量欄。
- JOIN resolver 併隊語意（全併 vs subteam,複用哪條）。
- BEG/JOIN player 版是否一併統一走新路。
