---
from: measurer
to: qa
status: consumed
topic: "[持守統一specimen真落地·exact path+已驗檔存在] main(持守統一Slice1-4 merged,a741e677)seed1337/42 3mo。★exact檔路徑(已ls/wc驗證存在,非猜)：A:\\GDS\\demo\\docs\\measurements\\2026-07-28-persistence-specimen-1337.jsonl(8382 entries,9.5MB)+...-42.jsonl(8916 entries,10.5MB)。specimen_team_ids=[0,4,9,14,19,24,29,34,39,44]兩seed同(SPECIMEN_SAMPLE_N=10既有中性strided法)。新增3處temp欄位(已revert,main clean)：狀態.persist_strength/狀態.current_task/狀態.is_progressive_hold(讀team.persist_strength/current_task/是否在TaskArbiter.PROGRESSIVE_HOLD_TASKS)+leader_traits補義氣(stick/flex輸入之一)。另抓persist.hold(committed被搶擋)聚合+樣本(seed1337 118次全部落地入CONSTRUCT_SAMPLE_KEYS,seed42另計)於2026-07-28-persistence-aggregate-{1337,42}.json的.probe_samples.\"persist.hold\"。→回to:blueprint(四查逐tick故事稽核)。"
measured_at_head: "main a741e677（持守統一 Slice1-4 merged，直接跑主 dir，非 worktree）"
seeds: "1337 + 42（各 3mo，皆完整跑滿無 SCRIPT ERROR）"
---

# 持守統一 specimen 真落地 → QA（exact path + 已驗存在）

工單延續 `2026-07-28-systems-to-measurer-persistence-story-specimen-for-QA.md` + `2026-07-28-systems-to-measurer-REDISPATCH-specimen-land-cite-path.md`（皆已消費）。**這次每個檔案跑完後我親自 `ls -la`+`wc -l` 驗證存在+entry 數對得上 log 才寫這封信**（吸取上兩次 market-sticky/construction-latch 的 worktree 路徑錯位教訓——這次直接在 main dir 跑，未用 `--path`，全程無 worktree 介入）。

## 檔案（已驗證存在）
- `A:\GDS\demo\docs\measurements\2026-07-28-persistence-specimen-1337.jsonl`（**8382 entries**，9.5MB）
- `A:\GDS\demo\docs\measurements\2026-07-28-persistence-specimen-42.jsonl`（**8916 entries**，10.5MB）
- 聚合對照：`docs/measurements/2026-07-28-persistence-aggregate-{1337,42}.json`（`.probe`/`.probe_samples`）
- `specimen_team_ids=[0, 4, 9, 14, 19, 24, 29, 34, 39, 44]`（兩 seed 同，`SPECIMEN_SAMPLE_N=10` 既有中性 strided 法，非 ad-hoc pick_random）

## 資料結構（本輪新增欄位，供你讀時對應四查）
- **`狀態.persist_strength`**（float, ∈[0, 0.3]）+ **`狀態.current_task`** + **`狀態.is_progressive_hold`**（bool，是否在 `TaskArbiter.PROGRESSIVE_HOLD_TASKS`）——對應 ①人格持守/committed 狀態。
- **`狀態.leader_traits.義氣`**（補進既有 慎重/貪婪/野心/好戰/求生欲）——`persist_strength` 的 `stick`(慎重+義氣) / `flex`(貪婪+野心) 輸入完整可對照。
- **聚合 `.probe_samples."persist.hold"`**（seed1337 118 筆全部入樣，未被 cap-300 截斷）：每筆 `{team_id, tick, blocked_new_task, held_task, persist_strength, priority}`——對應 ④committed 被搶真閉。已看到 team45 反覆在 tick 5860→6160（每 60 tick 一次）被「貿易」搶「建設」擋下，`persist_strength` 穩定 0.209——這種連續多筆同隊同值的樣本正是你要驗「單點門檻非硬鎖」的素材（去 specimen jsonl 找 team45 同期 entries，看它自己的決策循環有沒有正常繼續跑）。

## 你要判什麼（四查，逐 tick）
1. **人格持守 committed**：固執/恆心（慎重+義氣高）隊 `persist_strength` 是否確實較高、committed 動作黏著較久；務實/機會（貪婪+野心高）隊是否較快轉向。
2. **背水一戰真湧現**：偏執/狂信（低慎重+高好戰）隊危機下主動反應（迎戰/死守），非凍死呆住——讀 `想什麼.candidates` 裡 `迎戰`/`survival` 誰贏、`狀態.leader_traits` 對照。
3. **故事裡真不凍**：`persist.hold` 樣本裡被擋的隊（`blocked_new_task` 那個決策者），下個 tick 是否照常再評（去 jsonl 找該 team_id 後續 entries），committed 隊自己是否照跑決策直到完成/釋放。
4. **committed 被搶真閉**：committed builder 被搶時，`try_set` 真的擋下、施工續——`is_progressive_hold=true` 期間 `current_task` 是否穩定未變。

## 溯源
raw 聚合見上列 json。temp 探針（`specimen_tracer.gd` `_snapshot` 補 3 欄位 + 義氣、`task_arbiter.gd` persist.hold 處加 `bump_sample`、`warring_harness.gd` `CONSTRUCT_SAMPLE_KEYS` 補 `persist.hold` + `SpecimenDumpHelper` wiring）**已 revert，3 檔 clean，main dir 直接跑無 worktree 介入**。determinism：本輪為求時效單跑（非三跑驗證）；若你判讀時懷疑數字非確定性產物，可再開一輪三跑驗證。你判完 → `to:blueprint`（四查故事稽核結果，release-pass 判斷）。
