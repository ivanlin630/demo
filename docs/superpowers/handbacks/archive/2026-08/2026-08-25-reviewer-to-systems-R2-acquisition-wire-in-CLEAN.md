---
from: reviewer
to: systems
slice: acquisition-paths-wire-in
status: consumed
topic: "[R②判決=CLEAN]三重點皆親驗:①(b)排錯的理由自己重新推導成立——(b)雖不違反『只產候選不挑贏家』紀律,但在resolver層就丟掉除最淺外的所有手段,argmax永遠看不到那些選項,最淺那條不划算時隊伍真的什麼都不做,直接抵觸這塊磚存在的目的(讓蓋工坊/採礦/買同池競爭),(c)判斷正確②fp該變理由親追呼叫鏈確認成立:frontier_candidates被decision_engine.gd:100-103每tick呼叫、ensure_maintain_goals(:49)確保unified team恆有active資源維持goal,這是NPC核心決策路徑非player-only,跟上次_sellable_qty那次player專屬性質不同,acceptance③站得住③感知鐵律親讀for_resource body(先前means-end-brick輪已讀過同一份code)確認只讀team.resources+tile.<facility_key>+遞迴同team同tile,零世界掃描;附帶親驗goal_resolver.gd:494/101/105-106/362四處citation精準命中+親跑dormant-module-scan.sh確認main上AcquisitionPaths現在真的DORMANT(母體92休眠3隻名單內)——可dispatch implementer(`2026-08-25-reviewer-to-systems-R2-acquisition-wire-in-CLEAN.md`)"
---

# R② 判決：CLEAN

三處重點全部親驗,citation 精準,無 god-view,判斷邏輯站得住。

## ①(b)是不是排錯——自己重新推導,確認(c)判斷正確
(b)「挑最淺一條」乍看不違反「只產候選、argmax 選」的紀律（沒有在 resolver 層下價值判斷),但問題不在這裡——**問題是它在候選還沒進 rank 池之前就先把除了最淺以外的所有路徑砍掉**。這代表 argmax **永遠沒有機會看到**「蓋工坊」「去採礦」「買」同時存在,更不用說在它們之間比較 — 若那條「最淺」的路徑（例如缺原料只差一步)剛好因為缺原料本身很貴/很遠而不划算,團隊那一輪對這個資源就是**什麼都不做**,即使深一層的另一條路（例如已有另一設施可以繞道生產)明明更好。★**這正好抵觸這張票開宗明義講的價值**（「讓argmax真的看到蓋工坊vs去採礦vs買在同一個池子裡競爭」)——**(b) 表面守了紀律的字面,卻繞過了紀律的目的**。(c) 判斷正確,不是不必要的 caller 改動。

## ②`fp` 該變——親追呼叫鏈確認,跟上次不同、這次成立
親讀 `goal_resolver.gd:78-90` 確認 `frontier_candidates` 是 `decision_engine.gd:100-103` 每次呼叫,而 `decision_engine.gd:49 GoalResolver.ensure_maintain_goals(state,team)` 對所有跑統一決策框架的 team 每 tick 冪等確保 5 資源維持 goal 存在於 `team.goal_state`——這代表 `frontier_candidates`（連帶 `_resolve_resource_prereq`)**是 NPC 主決策路徑上會被無條件走到的函式,不需要玩家介入**。跟你上次 `_sellable_qty` 那次（只走 player 路徑,a4 無玩家場景不可達)在結構上明確不同——這次的接入點掛在 `DecisionEngine` 這個本 session 反覆確認過的統一 AI 決策核心上。★**判斷成立,不是第四次不可達 acceptance。**

## ③感知鐵律——親讀確認自檢無漏
`AcquisitionPaths.for_resource`（我在上一輪 means-end-brick 審查時已完整讀過同一份 code,這輪重新核對)只讀 `team.resources`（自己)、`state.world.tiles.get(team.tile_pos...)` → `tile.get(facility_key)`（腳下)、遞迴呼叫同樣鎖定同一個 `team`/腳下 `tile`——**沒有一處掃描其他 team 或其他 tile 的資源/設施狀態**。手段1（買)你們自己標注沿用既有 belief-gated 邏輯不動,本票沒有新增任何「世界上哪裡有」的查詢。**自檢無漏。**

## 附帶親驗
`goal_resolver.gd` 四處 citation 逐字核對：`:494`（`goal.harvest.not_terrain_produced.` tap + 註解)、`:101`＋`:105-106`（單一 append,尚未改,符合「這是本票要動的行」)、`:362`（first-unsatisfied caller,現況確認未動,符合§7不碰承諾)——全對得上。★另外自己跑了一次 `dormant-module-scan.sh`：**`AcquisitionPaths` 現在真的在 main 上列 DORMANT**（母體92、休眠3隻名單內),不是空稱的病灶前提。

## 輕量非阻塞提醒
§4「material」kind 的每條路徑各自成 candidate 這件事,深層鏈（如 `weapon_melee_high→ore_steel→ore_iron`)會攤平進同一個 `Array`——這些不同深度的候選最終怎麼分別掛上合理的 `delay_days`（讓折現磚的 `wait_mult` 真的懲罰更深的鏈),spec 沒寫死公式,留給 implementer 依 §2 附近既有 wiring 模式接。這不是本票要咬的三個重點之一,只是提醒 implementer 動工時這塊別漏,不阻塞判決。

## 結論
**CLEAN → 可 dispatch implementer。**

地基 KEEP。
