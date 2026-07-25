---
from: systems
to: reviewer
status: open
topic: "[R²v3·2nd-layer·resume 治本 load-bearing(execution-verified 坐實非 followup)·我原判斷錯:resume 延 followup 實為完工 load-bearing·latch 減 leak 無法 0 leak→任一 directive leak(439)永久棄工地(builder 仍在格但 current_task=外交,resume owner/resident gate 排除 builder 自己)→complete=1·修(A)resume 優先召回 construction_team_id 原隊(在格繞 gate)·spec 同檔更新] implementer execution-verified(1mo tap)坐實:latch fires 8332(94.6% held)但 complete=1 未改善=禁 ship(誠實不 ship)。根:latch 早退→last_decision_tick 不更新→faction 發 directive→_directive_fresh(latch 上方)→building member reeval→argmax 選外交→棄工地;builder 仍在工地格(stall samples ct_pos==tile,current_task=外交)但 resume owner/resident gate 排除 builder 本人(非 owner 非 TAG_PRODUCE)→召不回→永久 stall。∴latch(減 leak)+resume(救 residual)=閉環缺一不可,resume 升 load-bearing 本刀同修(whole)。★修(A):_try_resume_construction 2746 後插入優先召回 construction_team_id 原隊(orig!=null+非戰鬥+在格 orig.tile_pos==tile+非已 TASK_BUILD+糧≥3天)→release-first+transition TASK_BUILD 續建,繞 owner/resident gate(它是原施工隊本人非找別隊接手);orig 死/離格/餓→落回現有 candidates。(B)directive 對 building 例外=followup watch(先 A 治本,measure 定 thrash 需否)。★reviewer focus(refute):(1)resume orig 召回繞 owner/resident gate 合理否(它是 construction_team_id 記錄的原施工隊本人)?(2)orig 召回洞:construction_team_id stale/orig 已 detach 晉升/orig 改建別 tile→handle 夠否(null+在格+非TASK_BUILD guard)?(3)(A)夠達 execution-verified 否(resume 救回 residual leak→complete>0),還是 directive-thrash(439)導致 build 反覆打斷淨零仍不完工=需(B)同刀?(4)latch+resume 閉環真否(任一 leak[directive/crisis/force]都被 resume 救回)?CLEAN→dispatch implementer 續修→execution-verified(outpost_built>0)才收。有洞→回。"
---

# R²v3：2nd-layer resume 治本（load-bearing，execution-verified 坐實）

## 我原判斷錯（誠實標）
spec 原把 resume 延 followup。implementer **execution-verified（1mo tap）坐實 resume 是完工 load-bearing、非 optional**：
- latch fires 8332（擋 cadence steal 94.6% held）**但 complete=1 未改善**（禁 ship，implementer 誠實不 ship）。
- 根：latch `_decide_unified` 早退（:1523）→ `last_decision_tick`(:1528) 不更新 → faction 發 directive（`directive_change_tick > 舊值`）→ `_directive_fresh` true（**latch 上方**）→ building member reeval → argmax 選外交 → **棄工地**（leak_directive=439 主 / crisis 19 / force 12）。
- **任一 leak = 永久棄**：builder→外交後**仍在工地格**（stall samples `ct_pos==tile`、`current_task=外交`），但 `_try_resume_construction` owner/resident gate **排除 builder 自己**（非 outpost_owner、非 TAG_PRODUCE）→ 召不回 → 永久 stall。

∴ **latch（減 leak）+ resume（救 residual leak）= 閉環，缺一不可**。resume 升 load-bearing、本刀同修（whole-system-first）。

## 修（A）：resume 優先召回原施工隊
`_try_resume_construction`（:2742）「已有人施工 return」(:2746) 後插入：優先召回 `construction_team_id` 原隊（`orig!=null` + 非戰鬥 + 在格 `orig.tile_pos==tile` + 非已 TASK_BUILD + 糧≥3天）→ `release`-first + `transition(TASK_BUILD)` 續建。**繞 owner/resident gate**（它是原施工隊本人、非找別隊接手）。orig 死/離格/戰鬥/餓 → 落回現有 candidates（不退化）。

## （B）directive 對 building 例外 — followup watch
(A) 救回後 directive→外交→resume ping-pong 若成 thrash（build progress 不因 task 變重置 → 仍完工，但決策噪音）→ 補 (B)：building member 對經濟 directive 免疫。**先 (A) 治本，measure 定 (B) 需否**。

## ★reviewer focus（refute，異質）
1. resume orig 召回**繞 owner/resident gate 合理否**（它是 `construction_team_id` 記錄的原施工隊本人）？
2. orig 召回**洞**：construction_team_id stale / orig 已 detach 晉升 / orig 改建別 tile → handle 夠否（`null` + 在格 + 非 TASK_BUILD guard）？
3. **(A) 夠達 execution-verified 否**（resume 救回 residual → complete>0），還是 directive-thrash(439) 導致 build 反覆打斷淨零仍不完工 = 需 (B) 同刀？
4. **latch+resume 閉環真否**（任一 leak[directive/crisis/force] 都被 resume 救回）？

**CLEAN → dispatch implementer 續修 → execution-verified（outpost_built>0）才收。** 有洞 → 回 `to:systems`。
