---
from: systems
to: implementer
status: open
topic: "[DISPATCH] tracer-completeness——specimen全生命+全路徑(第三觀測洞根治);R²過(baseline已訂正);新分支feat/tracer-completeness base main(god-view已merged);TDD"
---

# Dispatch：tracer-completeness（第三觀測洞根治）

> **[worker 守則] 卡住/授權不明/做不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-tracer-completeness.md`（三 Fix + 盲點閘 + invariants 升條，含 R² 訂正）。
R² 判決：`2026-07-15-reviewer-to-systems-tracer-completeness-r2-issues.md`（根因/Fix1/Fix2 CLEAN；唯一 issue=Fix3 static baseline 數字，**已訂正**：capture_options 現 2 非 1）。reviewer 預 clear「訂正後 CLEAN 非重設計」。

## 在哪：新分支
`feat/tracer-completeness`，base 最新 main（`0f0d8f40`+，**god-view 已 merged**，belief_pos/Fix F 都在）。

## 做什麼（三 Fix，spec 有精確 file:line）
1. **Fix 1 路徑維——attempt-tap**：`SpecimenTracer.capture_decision` 加 `result: String = "committed"` 參數（entry `做什麼` 加 `result` 欄，預設不破既有 call）。`_trigger_survival:3202-3217` 補：finder 撲空 `:3205 continue` 前 tap `"finder_miss"`、try_set 失敗 tap `"try_set_noop"`、現成功路 `:3217` 傳 `"committed"`。→ churn/fallthrough 全成 timeline entry。其他 commit 點(unified/solo/attack)同 pattern 補 result 欄。**只加欄+加 fail 分支 tap，不改決策邏輯。**
2. **Fix 2 時間維——heartbeat sweep**：`evaluate_all:609` **末尾**對 `state.specimen_team_ids` sweep——tracer 記 `_last_entry_tick`（capture 時更新），若 specimen 本 tick 無 decision entry 且 `current_tick - _last_entry_tick >= HEARTBEAT_CADENCE`(=`TICKS_PER_DAY/4`=6h) → append 輕 heartbeat entry（`_snapshot` 純讀，phase:"heartbeat"）。→ timeline 無洞、不重複膨脹。
3. **Fix 3 盲點閘**：runtime 行為床（specimen churn 床斷言①timeline gap≤HEARTBEAT_CADENCE ②強制 churn 下 `result!="committed"` entry ≥1）為主 + static call-site 計數 tripwire baseline（**生產側** 4 capture_decision + 2 capture_intent + 2 capture_options）為副。

## 守則
- **零 state mutation / 零 RNG**（觀測禁改世界）：heartbeat `_snapshot` 純讀、attempt-tap 走既算好的 `td`（不重呼 finder/observe_velocity）。
- **specimen-gated 零非-specimen 成本**（過 is_specimen early-return / sweep 只迭代 specimen_team_ids）。
- **憲法零新 try_set**（tracer 純觀測）。
- **★byte-identical 硬證**：tracer on/off 兩跑 **baseline byte-identical**（證觀測非侵入——這是本刀核心驗收，不是 same-seed-two-run，是 on-vs-off）。

## TDD
1. specimen 走 survival thrash → jsonl 見 `result:"finder_miss"/"try_set_noop"` entry（churn 現形，非只 committed）。
2. specimen 長期無決策 → heartbeat 填洞（timeline gap ≤ HEARTBEAT_CADENCE）。
3. **tracer on/off → 世界 byte-identical**（觀測非侵入）。
4. 標準：headless 零新增；憲法 sites=29；HOB obey%。

## Fix 4（invariants 升條）＝systems 做
`invariants.md` 觀測不變量段收斂（specimen 完整性 + 前兩條）＝我 owner，你不碰 invariants.md，只做 code + 床。

## 完成後
→ handback `to:systems` → measurer 驗（specimen 錄全生命 + churn 現形 + on/off byte-identical）→ blueprint 批 → merge。
scope 疑義走 `to:systems`。第四態(player-join)advisory 本刀不處理（spec 已記）。
