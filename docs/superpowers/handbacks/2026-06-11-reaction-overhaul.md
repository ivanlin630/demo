# Hand Back: Reaction 職責收斂

Branch: `feat/reaction-overhaul`（base: main a17c90f）
Plan: `docs/superpowers/plans/2026-06-11-reaction-overhaul.md`（8 task 全完成）

## 實作摘要

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 加 `work_morale: float = 1.0`（[0.5,1.5]） |
| `scripts/data/person_data.gd` | 加 `last_reaction: String = ""` |
| `scripts/simulation/reaction_system.gd` | P2 改空效果＋work_morale 統計；P3 全刪；P5 糧食盈餘條件；N5 coin 守恆進 person.coin；N1/N3 solo skip＋leader 逃走 anon tier 同步＋named 離團 `_spawn_exile_or_join`；bridge 需 `ThreatAssessment` 真威脅＋反方向 move_target；per-person print diff-only |
| `scripts/simulation/resource_system.gd` | `_collect_from_tile` gain 乘 `work_morale` |
| `scripts/simulation/harvest_system.gd` | 未動（grep 確認無 team 產出路徑，只有 tile 再生） |
| `scripts/simulation/faction_ai_system.gd` | `_evaluate_survival` 加 diff-only 轉換 print（`[Survival] TeamN urgent days_left=X 逃跑→乞食`）— 驗證 survival 鏈用，非 plan 原列 |
| `scripts/debug/game_sim_multi.gd` | 加 `pop_init`/`pop_final` 欄＋每月 `[PopSample]` — 人口趨勢觀測用，非 plan 原列 |
| `scripts/debug/headless_test.gd` | 13 新測試（Task1a/1b, 2a/2b, 3, 4a/4b, 5a-d, 6a/6b）＋修 stale assert（見下） |

與 spec 差異：無。plan 外新增僅測試儀器（survival print / pop 採樣）。

**Baseline 修復**（main 上已壞，與本 feature 無關）：`_test_full_config_load` assert 卡「5 team」，
但 `config/game_sim_test.json` 已是 8 team（後來加了 5-7）。改為動態讀 config team 數。commit d47b0fc。

## 行為變化（實測數據）

- **P2/P3 水龍頭關閉**：P2 不再印 food、P3 不再生人口。經濟全靠 harvest/outpost 採集 × work_morale。
- **survival 鏈復活** ✅：multi（4 config × 21600 tick）`[Survival]` task 轉換 31,212 次 —
  乞食 為大宗（30,478 逃跑→乞食）、投靠 61、return_home 8、`[SurvivalLoot]` 遠 outpost 掠奪 path 有觸發、
  `飢餓緊急` 公庫徵用 172 次。世界確實變窮、飢餓驅動行為鏈全面啟動。
- **人口趨勢**：第 1 個月急降後即穩定（非持續崩潰）：

  | config | 初始 | 月1 | 月2 | 月3(末) |
  |---|---|---|---|---|
  | game_sim_test | 60 | 33 | 33 | 31~33 |
  | tyrant | 60 | 44 | 44 | 42~44 |
  | merchant | 48 | 21 | 21 | 21 |
  | warzone | 54 | 39 | 38 | 32~38 |

  急降主因：開局 N1/N3 離團潮＋飢餓調整。穩定後淨萎縮極慢——但 minor 不長大（known issue）下長期仍只減不增。
- **log 行數**：game_sim_test 34,945 → 12,910（Task 7 diff-only，-63%）。
  加 `[Survival]` 診斷 print 後回升至 32,049 —— 該 print 暴露 bridge↔survival task 互搶（見連動風險）。
  multi log 75,014（改前 main）→ 39,907。
- **驗證**：headless 242 OK / `=== DONE ===` / 無 SCRIPT ERROR；game_sim_test `ALL INVARIANTS PASSED (violations=0)`；
  multi 4 config 各 21600 tick 無崩潰、無 game over。

## 連動風險

- **task 仲裁 ping-pong（最大發現）**：ReactionBridge 設「逃跑」→ survival 鏈下一輪 override 成「乞食」→
  bridge 又搶回——multi 30,478 次「逃跑→乞食」、bridge print 25,786 行（65% log）。
  根源之一：solo panic team（pop=1 流亡）N1 solo skip 依 spec 不洩壓 → 永久高 stress → 永久觸發 bridge。
  屬 known_issues「task仲裁」範疇，主 session 決定仲裁優先序（建議：survival 任務列入 bridge 不可劫持清單）。
- `skill_system.gd:13` 仍有 `"P3_recruit"` 技能成長 mapping —— P3 刪除後成 dead entry，無害，可順手清。
- `person.coin` 經 N5 累積但目前無消費 sink —— 長期通膨到 named 私囊（數值小，每次上限 5）。
- 流亡 team 數量增加：named 離團自立（multi 7 次）＋ PopMgmt overflow（11 次）→ team 數膨脹來源之一。

## 待主 session 確認

- 飢餓程度：survival 大量觸發＋飢餓緊急 172 次 → config 初始糧 / harvest 參數是否要調。
- work_morale lerp 0.1 / 目標幅度 ±0.5 是否合意（測試中勤奮村 50 輪到頂 1.5）。
- 人口淨萎縮：月 1 急降幅度（-27% ~ -45%）是否可接受；minor 長大邏輯（known issue）優先級是否提升。
- task 仲裁優先序設計（survival vs reaction bridge vs strategic AI）。
- `[Survival]` 診斷 print 是否保留（它是 log 行數回升主因，但提供仲裁問題能見度）。
