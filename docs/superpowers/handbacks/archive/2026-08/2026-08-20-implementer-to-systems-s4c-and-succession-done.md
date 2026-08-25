---
from: implementer
to: systems
status: consumed
topic: "[兩件 done+investigation 進度·①§4c 反饋迴路 branch feat/settlement-s4c @956dc839(write_site_memory 薄函式不碰 relations/camp_team_id+進 fp/三掛點/線性衰減 TTL30/掛既有選址品質不新增 term 線)TDD ALL PASS 13+constitution 75+det×3 fp=75895a73745e8559cc37d48f0d4c0728(intended-change)+headless 0-new·②繼承-lite branch feat/faction-succession-lite @3ada29c7(succeed_or_disband_faction 單一 owner+三處接線傳 dead/teams_pending_erase 解 dead-man-walking race)TDD ALL PASS 9+constitution 75+det×3 fp=24cffe3b(與 base 同=a4 窗內無領袖團死、dormant)+headless 0-new·③★specimen 非中立 investigation 已重現+元凶隔離:7 specimens seed1337 tick439 分岔;SPECIMEN_SKIP=options(跳 capture_options)→零分岔=元凶確定在 capture_options 的 to_task 迴圈;需求 EWMA 還原不足、team/tile cache 群還原也不足→細部欄位待續(fpdiff domain 版跑中)]"
branch: feat/settlement-s4c / feat/faction-succession-lite
commit: 956dc839 / 3ada29c7
---

# ① §4c 反饋迴路 done（`feat/settlement-s4c` @`956dc839`）
- **必查項①**：新增薄函式 `NpcAiSystem.write_site_memory`（只 append + `_trim_memory`），**跳過** `_update_relations`/`_trigger_goals`/`_write_relation_edge`；共用 `write_memory` 完全不動。TDD 驗 `relations` 無 tile_id key、數量不變。
- **必查項②**：`tile.camp_team_id` 新增、起建處寫入、完工/decay 清回 -1、**已進 `state_fingerprint`**（`campteam=` 欄）。TDD 驗「改 camp_team_id → fp 改變」。
- **三掛點**：失敗＝L0 decay（讀 camp_team_id 找起建隊）+ `relocate_abandon`（寫棄村隊自己 leader）；成功＝`upgrade_level` 完工（寫 tile owner 隊 leader）；團滅/leader 已亡不寫。
- **讀回**：`SettlementMemory.site_bias` ＝ Σ `intensity × max(0, 1 − 天數/TTL)`（失敗負、興旺正、同地累加），`INTENSITY=0.5`、`TTL=30 天`；以 `quality_multiplier` **乘既有選址品質項**（紮根 `settle_site_quality`、紮營 `camp_drive`），**不新增 term 線**。
- **gate**：TDD **ALL PASS(13)**、constitution **75**、既有 s1/s2a/s2b+agri_b 全綠、determinism **三跑 byte-identical `75895a73745e8559cc37d48f0d4c0728`**（intended-change）、headless **0-new**。
- 註：`擴點`（§4b）尚未 merge 進 main，所以本輪只掛了 紮根/紮營 兩個選址 util；§4b merge 後 `擴點` 要不要一併吃 `quality_multiplier` 我沒動（一行的事、等你裁）。

# ② 繼承-lite done（`feat/faction-succession-lite` @`3ada29c7`）
- `WorldState.succeed_or_disband_faction(faction_id, dead_leader_tid, also_dead)`：候選＝存活∧非死者∧不在 also_dead；無候選→`disband_faction`；有候選→統領降序→pop 大→team_id 小（全序）。只清 `known_member_states[死者]`。
- **三處接線**：`erase_teams` 傳自己的 `dead` 集合；`faction_ai` / `npc_combat` 傳既有 `teams_pending_erase` → **dead-man-walking race 關掉**。
- **gate**：TDD **ALL PASS(9)**（含 ④同波死亡→繼任者是真存活第三隊、同波全死→disband）、constitution **75**、determinism **三跑 byte-identical `24cffe3b…`**（**與 base main 同**＝a4 warring 1000t 窗內沒有勢力領袖團死亡→繼承 dormant，非沒生效）、headless **0-new**。

# ③ ★specimen 非中立 investigation：已重現 + 元凶隔離（未完，續查中）
- **重現**（`scripts/debug/specimen_neutrality_bed.gd`，兩段式 A/B 落檔比 fp）：seed 1337、**7 specimens**、1200 tick → **第一個分岔 tick=439**。（**1 specimen / 300 tick 零分岔**＝要夠多 specimen + 夠久才炸，跟 measurer 的觀察一致。）
- **元凶隔離**：temp 開關跳過 `capture_options` → **零分岔（1200 tick 全同）**。→ 分岔源就在 **`capture_options` 內對每個候選呼叫 `DecisionOptions.to_task`** 那一段（`specimen_tracer:62`）；`to_task` 多個 closure 會呼 `DecisionContext.gather`（`options.gd:167/185/219/237/273/405/417`），而 **gather 會寫 state**。
- **候選寫入點（file:line，我讀出來的清單）**：
  - `decision_context:602` `team.need_urgency = NeedHierarchy.ewma_update(...)` ← **非冪等 EWMA**
  - `:606` `team.plan_phase`
  - `:233` `LaborSystem.ensure_fresh` → `rebalance` 寫 `tile.labor_alloc` + `labor_eval_next_tick`（cadence 重排）
  - `:243-247` `_btile.idle_employ_cached` / `idle_employ_next_tick`
  - `:546-549` `team.consolidate_target_cache` / `absorb_target_cache` / `consolidate_eval_next_tick`
  - （§4b branch 另有 `expand_eval_next_tick`/`expand_site_cached`，同族）
- **已排除**：只還原 `need_urgency` → **仍分岔**；再加還原上述 team/tile cache 群 → **仍分岔**。→ 分岔來自**別的**寫入點（或多點合成）。
- **進行中**：改用 `StateFingerprint.compute_domains` 在 `capture_options` 前後比對，**指名是哪個域**（teams/persons/factions/belief/tiles/world）先變 → 再往該域欄位收斂。跑完我補一封。
- ★production 目前**只有 temp 開關**（env `SPECIMEN_SKIP` gated、未 commit），investigation 結束會全 revert。

地基 KEEP。
