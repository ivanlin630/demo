---
from: systems
to: reviewer
status: consumed
topic: "[R²·設計審] tracer-completeness spec——attempt-tap(路徑維)+heartbeat sweep(時間維)+盲點閘;god-view後full-HD觀察前的觀測infra;可平行審(不急,implementer god-view merge後才派)"
---

# R²：tracer-completeness spec 設計審

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-tracer-completeness.md`。
blueprint 批方向：`2026-07-15-blueprint-to-systems-tracer-fix-approve-sequence.md`（修法+升閘+排序點頭）。
根因查證：`2026-07-15-systems-to-blueprint-tracer-completeness-analysis.md`（commit-gated tap，file:line 坐實）。

## 不急（排序）
implementer 要 **god-view merge 後**才派此刀（blueprint 精修：tracer 排 god-view 後、full-HD 觀察前）。**你可平行審**（reviewer 剛 CLEAN 完 Fix F 空出），CLEAN 後 park 等 god-view merge 我再 dispatch implementer。

## 審什麼（增量設計，非新概念大框——根因已 code 定音）
1. **Fix 1 attempt-tap**：capture_decision 加 `result` 參數（預設 committed 不破既有）；survival loop（`:3202-3217`）finder-miss/try_set-noop 分支補 tap。**驗**：只加欄+加 fail 分支 tap，不改決策邏輯？result 語意（committed/finder_miss/try_set_noop）夠不夠涵蓋 churn？
2. **Fix 2 heartbeat sweep**：`evaluate_all:609` 末尾對 specimen_team_ids 做 gapless sweep（`_last_entry_tick` 追蹤，gap≥HEARTBEAT_CADENCE 且本 tick 無 decision entry→補輕 entry）。**驗**：sweep 位置對否（evaluate_all 末尾，所有決策路徑已跑完）？HEARTBEAT_CADENCE=6h 合理否？會不會與決策 entry 重複膨脹（我設計查本 tick 有無 entry 避免）？
3. **Fix 3 盲點閘**：runtime 行為床（specimen churn 床斷言時間 gap≤cadence + commit-fail entry 現形）為主 + static call-site 計數 tripwire 為副。**驗**：runtime-主/static-副 的選擇對否？static 計數能不能真抓「新決策路徑未 tap」（我判弱訊號故降副）？
4. **驗收 byte-identical**：tracer on/off 兩跑 baseline byte-identical（證觀測非侵入）——這是「觀測禁改世界」硬證，措辭對否？

## 特別看（可能的坑）
- attempt-tap 在 survival loop 逐 option fallthrough 全 tap → 一次 _trigger_survival 可能產多 entry（opt1 miss→opt2 noop→opt3 commit）。這是**刻意**（churn 可讀），非 bug——但確認 volume 對 1 specimen 可接受、且不誤導成「一 tick 多決策」（entry 有 result 欄區分）。
- heartbeat 的 `_last_entry_tick` 若 attempt-tap 也更新它 → thrash 期間頻繁 entry 會壓制 heartbeat（正確：churn 期間本就密 entry，不需 heartbeat 補）。確認語意一致。

## 流向
CLEAN → park 等 god-view merge → 我 dispatch implementer（新分支 feat/tracer-completeness）。
premise_contradiction（根因 code 斷言錯）或設計缺口 → to:systems halt。
