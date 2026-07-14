---
from: systems
to: implementer
status: open
topic: "[DISPATCH] 觀測路徑維補齊+盲點閘——R²過(Fix2訂正:unified挪位/solo補早退tap);Fix1 person-reaction先行unblock內政;新分支feat/observability-path-completion"
---

# Dispatch：觀測路徑維補齊 + 盲點閘

> **[worker 守則] 卡住/授權不明/做不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-observability-path-completion.md`（含 R² 訂正 Fix2 + 覆蓋審計矩陣）。
R² 判決：`2026-07-15-reviewer-to-systems-observability-path-completion-r2-issues.md`（Fix1/3/4 CLEAN；Fix2 訂正 unified≠solo；reviewer 預 clear「訂正後 CLEAN」）。

## 在哪：新分支
`feat/observability-path-completion`，base 最新 main（`f4b06f76`+）。**平行 flee slice**（feat/flee-restore-movement）——本刀碰 reaction_system/specimen_tracer/unified-solo-threat capture 行 + 新 gate；flee 碰 movement/threat-dispatch flee 行。**merge 序 systems 協調**（先落後 rebase，衝突面小）。

## 做什麼（4 Fix，★Fix1 先行 unblock 內政）
1. **★Fix 1 person-reaction tap（先做，unblock 內政）**：`reaction_system:121`（winner `best` 選出後）→ `SpecimenTracer.capture_reaction(state, person, team, reaction, why)`（is_specimen gate）。記誰/哪個 reaction/why 快照（`person.loyalty`/`person.stress`/被苛待/違背 values driver）。新 `phase:"reaction"` entry + `_print_entry` 輕印分支（比照 heartbeat）。**Fix1 落即可讓 measurer 重抓內政 specimen（分階交付）**。
2. **Fix 2（★R² 訂正：unified≠solo 分開）**：
   - **2a unified**：`_decide_unified:1537` capture 在 try_set 前預設 committed → **挪到 try_set(`:1538`)後帶真 result**（成→"committed"/敗→"try_set_noop"）。
   - **2b solo**：capture(`:1890`)已在 try_set 後=準確**不挪**；補**三早退 continue** tap：`:1871`(IDLE)→"idle_skip"、`:1873-1874`(finder 撲空)→"finder_miss"、`:1875-1876`(try_set fail)→"try_set_noop"（鏡射 survival loop attempt-tap）。
3. **Fix 3 threat tap**：`_evaluate_threat:408` try_set 成功後(`break` 前)→ `capture_decision(...,"committed")`（威脅反應進 specimen）。ambient(817)可選（判要不要納，不納標 follow-up）。
4. **Fix 4 盲點閘**：`observability_gate.gd`（或併 constitution_gate）——靜態列舉事件產生點（try_set in decision/reaction winner/intent/state-transition bump）vs capture 覆蓋 + baseline freeze（新點無 tap→FAIL）。runtime churn 床(tracer-completeness Fix3)續作語意驗。

## 守則
- **零 state mutation / 零 RNG**：新 tap 純讀（reaction why 快照純讀 person）；is_specimen early-return。
- **★byte-identical 硬證**：tracer on/off 兩跑 baseline byte-identical（觀測禁改世界）。
- **憲法零新 try_set**。

## TDD
1. specimen 隊成員 defect/riot → jsonl 見 `phase:"reaction"` entry（誰/reaction/why）。
2. unified 選項 try_set 失敗 → result="try_set_noop"（非虛高 committed）。
3. solo 三早退 → 對應 idle_skip/finder_miss/try_set_noop entry。
4. threat FLEE/DEFEND → capture entry。
5. 盲點閘：構造「新 try_set 無 tap」→ FAIL；現況全綠。
6. tracer on/off byte-identical；headless 零新增；憲法 sites=29。

## 完成後
→ handback `to:systems`（Fix1 落可先 ping measurer 內政）→ measurer（內政 specimen reaction 敘事 + on/off byte-identical）→ blueprint 批。
scope 疑義走 `to:systems`。state-transition tap（death/split/betray/found/capture）＝**下批候選記 known_issues，非本刀**。
