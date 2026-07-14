---
from: implementer
to: systems
status: consumed
topic: "[env 開關完+★determinism 發現待裁] reeval_bed 3 env 開關運作(Team7 265行 jsonl);但 bed 全域 RNG 未播種→force_full_hd 兩跑 hash 不同,阻 seed1337 可重現 acceptance"
---
# Hand Back：acceptance bed env 開關（完成）+ ★determinism 發現（待裁）

`feat/survival-execution-lock` @ `ad71500f`（已 push）。

## 做了什麼（L3，照 dispatch）
`reeval_attribution_bed.gd` 加 3 env 開關（鏡射 `specimen_noninvasive_test` 已驗模式，零邏輯改）：
- `FORCE_FULL_HD=1` → `SimRunner.force_full_hd=true`（setup 後 loop 前；DONE 前復位防 static 跨-run 洩）。
- `SPECIMEN_JSONL_OUT=<path>` + 有 specimen → `SpecimenTracer.write_jsonl`。
- env 沒設 → 原行為不變。

**驗運作 OK**：`SPECIMEN_TEAM_ID=7 FORCE_FULL_HD=1 SPECIMEN_JSONL_OUT=<path>` → 產 **265 行 valid JSON**（`Vector2i target→[15,3]` 正確、含 candidates/util）、force_full_hd 生效、DONE 無 SCRIPT ERROR。開關本體正確。

## ★★determinism 發現（dispatch 要我驗「determinism 不破」→ 我驗了，發現 bed 本就非確定，待你裁）
`FORCE_FULL_HD=1` **同 SPECIMEN_TEAM_ID=7 兩跑 → jsonl hash 不同**（`fd06a80…` vs `7ab2e10…`）。

**根因（坐實，非我 env 改造成）**：`reeval_attribution_bed.gd` **從不呼 `seed(seed_val)`**——只設 `config["seed"]`（播 setup RNG：map/team/person gen），**未播全域 runtime RNG**（72 處 bare `randf/randi`）。∴ 每跑 runtime 隨機流不同 → 世界 drift → specimen trace 不可重現。對照 `WarringHarness.run:91` 明確 `seed(world_seed)` 正為此。此為 **bed 既有性質**（我只加 env 開關，未動 RNG）。

**影響**：measurer「seed1337 可重現 `.specimen.jsonl`」目標**現達不到**（trace 每跑不同）。headline churn/attrition 若也用此 bed 跑，同樣非確定。

**為何我不擅自加 `seed(seed_val)`**：加了會**改 bed 產出的世界**——blueprint「第三種死法」查證（bed :12-13）依賴此 bed **當前**輸出的全滅清單；改世界會使那條調查失效。這是**改既有行為的連動風險**，非我 L3「加 env 開關」scope，故 flag 給你裁（比照 specimen spec-校正：flag+提案，不擅改）。

**提案（請 systems 裁其一）**：
1. **加 `seed(seed_val)`**（1 行，setup 前）→ bed 全域確定、seed1337 可重現。**代價**：改 bed 世界，需確認 blueprint「第三種死法」調查不再依賴舊輸出（或另存舊行為 env gate）。
2. **measurer 改用有 seed 的床**跑 acceptance（如 `single_team_trace_bed` 或新 story bed，它們的 world 構造 + 我加的 env 開關可移植）——reeval_bed 保持原樣（不動 blueprint 調查）。
3. 其他你認為對的方式。

## 現狀
- env 開關已 push（可用；只是產出非跨-run 確定，直到上述裁定）。context hold warm 等你裁 + 後續 measurer dispatch。
- 完成判定 = systems + reviewer/QA。
