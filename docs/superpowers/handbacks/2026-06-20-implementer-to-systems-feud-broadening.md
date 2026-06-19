---
from: implementer
to: systems
status: open
date: 2026-06-20
feature: feud-broadening (A 類 feud 放寬)
---

# Hand Back: A 類 feud 放寬

## 實作摘要
plan `2026-06-20-feud-broadening.md` 全 Task 完成。改檔：
- `scripts/simulation/npc_ai_system.gd`：新增 `form_feud`（severity×個性 gate，唯一形成點）+ `spread_feud`（滅族 faction 餘部繼承）static + `FEUD_*` const；`_activate_goal` 轉 static；`_write_relation_edge` 的 betrayal/looted/extorted 分支改走 `form_feud`（`Probe.bump("g2.feud_formed")` 移進 form_feud，不雙計）。
- `scripts/simulation/npc_combat_system.gd`：`_end_combat` loot 迴圈後接 `spread_feud`（滅團=massacre 級、倖存=looted 級）；`_try_subjugate` 在 `set_team_faction` **前**接 `form_feud(loser_leader)` + `spread_feud`（subjugated 級）。
- `scripts/simulation/encounter_system.gd`：`_massacre_residents` 在 `erase_team` 前接 `spread_feud`（massacre 級）。
- `scripts/debug/headless_test.gd`：新增 `_test_feud_gate` / `_test_feud_spread`（含經 `_massacre_residents` 真路徑整合）；既有 `_test_g2a_memory_writes_edges` 對齊 gate（受害者 義氣 0.9 使 looted 跨閾，未放寬 gate）。

與 spec 無差異。零新資料結構、不碰資源/coin/pop/守恆。

## 驗證結果

### 單測（headless）全綠
- `feud gate OK`：高義氣+massacre→結仇；寬厚+例行劫掠→放下；perp==self→false。
- `feud spread OK (餘部 intensity=0.64)`：massacre×spread 0.6 × 餘部 factor → 餘部 leader 繼承。
- `feud massacre wiring OK`：經 `_massacre_residents` 真路徑，erase 前餘部得仇。
- `=== DONE ===`、無 `SCRIPT ERROR`、所有守恆測試 OK（投靠守恆整合/Bug10 屠村守恆/mint）、InvariantAudit population/faction/subteam OK（= coin_eq 含義之審計皆 0）。

### world_sim 重量（2 年 / d720，seed 77）—— ⚠ 無法驗證 feud 量
跑通無 SCRIPT ERROR，`[ProbeSummary]` 正常印。但：
- `g2.feud_formed` = **0**（probe 不出現），所有 team 全程 `feud0`、`vendetta=-1`。
- **根因（measure-first）**：本 run **零戰鬥**——`[Combat End]`=0、`[Massacre]`=0、`主服(subjugate)`=0、encounter=0。5 隊（多定居/武力）2 年內從未交手。
- 即 `feud_formed=0` **非 gate 太嚴**，而是**無侵害事件可觸發**。gate/severity/spread 值無從由本 run 評斷。

## 連動風險
- `vendetta_target`（G2d 脫軌 reader）未改；feud 變多時自然餵更多脫軌——但本 run 無 feud 故無脫軌增量可觀察。
- subjugate 接線：現況 `_try_subjugate` 守衛 `loser.faction_id != -1 → return`，故 spread 對 loser 自身 faction(-1) 無餘部=不傳（獨立團被吞無餘部，spec 已預期）。`form_feud(loser_leader)` 是主效果；spread 接線保留供未來 loser 有 faction 時自動生效。
- 無已知守恆/崩潰風險。

## 待主 session 確認（建議）
1. **world_sim 驗不到 feud = 場景無戰**：seed 77 太和平，無法當 feud 放寬的重量閘。建議系統/藍圖：
   - (a) 換更具衝突的 seed/scenario 跑 feud 重量；或
   - (b) 先看「為何 5 隊 2 年零交手」——這本身可能是更上游的問題（武力 archetype 隊 rung 爬到 3-4 卻不開戰），非本 plan 範圍，呈報藍圖。
2. **TEST VALUE 暫不調**：FEUD_MIN=0.30 / severity 階梯 / SPREAD 0.6 在無 feud 量數據下不動，待有戰鬥的重量 run 後再校。
3. 單測證明 gate/severity/spread/三 call site 接線邏輯正確；缺的只是「有戰鬥的世界」來觀察湧現量與噪音。
