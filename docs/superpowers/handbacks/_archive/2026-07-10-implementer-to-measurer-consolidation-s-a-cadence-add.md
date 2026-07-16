---
from: implementer
to: measurer
status: consumed
topic: [S-A 追加] consolidate cadence gate 已加（churn/perf 修）→ 更新 worktree @477aa7c + 量 churn 指標
---

# S-A cadence gate 追加 done（@477aa7c feat/consolidation-s-a）

接前 S-A handback（`consolidation-s-a-done`）。systems profile 確認 churn（decision_context 每成員每 tick O(N) `_find_absorber`）→ 大窗跑不動。已加 cadence gate（spec §HOW-4）。

## 改
- `TeamData` +`consolidate_target_cache`/`consolidate_eval_next_tick`。
- `decision_context` 整併 target 加 **1 日 cadence gate**（快取，鏡射 SUBTEAM_CADENCE）。
- `faction_ai` +`CONSOLIDATE_CADENCE = TICK_PER_DAY*1`。
- 純節流（cache），行為/determinism 不變。

## 我驗
- `--import`/`a2c1_consolidate_bed`(fail=0)/multi-sanity(inv=0)/constitution **綠**。
- **determinism**：seed 1337 1mo 兩跑 `[bed] probe` **byte-identical**（cache 純 tick-keyed 節流，零漂移）。
- **perf**：cadence 前 seed 1337 3mo @300s **timeout 跑不完** → 加後 churn 掐掉（1mo 完成、3mo 需 GODOT_TIMEOUT≥550）。大窗現能跑。

## 量測（★用更新 worktree @477aa7c，非舊 e8d7d52）
前 handback 的 **3 硬 gate 不變**（①餵養真解非搬餓+空真守衛 ②湧現非腳本 ③side-observe 規模/annih）。**systems 追加要你也量**：
- **distinct 隊數 + 每隊重派次數**（churn vs 廣度——cadence gate 後 dispatch 應降頻，但實際 merge 成交才算真廣度）。
- **`merge.consolidate_dispatch` vs 實際 merge 成交**（`accept.merge_accept`+`join.resolve`）——dispatch 高但成交低=churn 病仍在（我單 seed 見 dispatch=198 但 merge_accept=0、join_accept=1，疑整併 TASK_MERGE 罕到 absorber 接觸）。
- 若 `consol.accept_n` 大窗仍稀 → 空真守衛 INCONCLUSIVE + 標門檻（`ABSORBER_MIN_SURVIVE_DAYS`/`ACCEPT_UTIL_THRESHOLD`/或整併接觸路本身罕觸）。

→ 你數字 to:blueprint 判。merge 閘=reviewer 對完整 S-A diff（含 cadence gate）CLEAN + 你 gate#1/#3。worktree @477aa7c。
