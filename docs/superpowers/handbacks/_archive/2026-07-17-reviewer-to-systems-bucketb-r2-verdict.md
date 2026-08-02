---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict] Bucket B gate-ok 批標：CLEAN，但抓到1個真 over-mark 風險（fingerprint 粒度陷阱）——apply 標時 _evaluate_independent_strategy::threshold 禁整函式 inline 標，只准標 envoy-timeout 那行。"
---

# R② 判決：Bucket B gate-ok 批標 — CLEAN with 1 required scoping constraint

## 核實方法
先讀 `scripts/debug/constitution_gate.gd` 確認偵測器機制：fingerprint key = `<file>::<func>::<type>`（`_scan_file` 的 `out["%s::%s::threshold"...]=true`），**同函式同類型的所有命中行收斂成同一把 key**（非逐行）。`_load_baseline()` 對 baseline txt 的 `#` 後綴純剝離做文件比對，**baseline 檔內的 `# gate-ok: 說明` 純文件用途，不影響 gate pass/fail**；真正讓某命中「消失於 current」的唯一機制是**在該行原始碼行內加 inline `# gate-ok`**（`_scan_file:115-116`）。這代表：若某函式的 `::threshold` fingerprint 底下混了「這行合法／那行還沒判」兩種命中，inline 標記時**選錯行**就會靜默把還沒判的命中也一併從 current 清掉（fingerprint 整把消失，不會再被列出）——這正是本批 systems 自己提防的「over-mark 藏殘留」風險，且是本專案偵測器架構的結構性陷阱（非本批獨有，值得記進 known_issues 供未來各批注意）。

## 逐項核實（file:line）
**GUARD 類全數核實乾淨**：
- `_consider_extraction`（faction_ai_system.gd:2235-2238 treasury≤0/player/leader null）＝GUARD，`:2242 extract_score>0.4`＝獨立 threshold fingerprint，**未在本批 B-legit 列表內**（doc 明確只寫「(treasury≤0/player/null)」）→ 確認沒把 B2 候選閾順手標掉，systems 自查通過。
- `_evaluate_infrastructure`（:2884-2891 null/combat/player guard）／`:2897 outpost_level>=3`＝該函式**唯一**符合 THRESHOLD_RE 的命中（其餘 :2914-2915 用 `!=`/`==` 不匹配 regex）→ 純 level cap，無 collision，legit。
- `_evaluate_storage_visit`（:2382-2383 guard）／`:2394 needed*2.0`＝該函式唯一 threshold 命中，純資源進出 housekeeping（非人格加權選項選擇）→ 同意 world-mechanic 分類。
- `_evaluate_owner_contact`（:3760-3766 guard）／`:3768 CONTACT_TIMEOUT_DAYS`＝該函式唯一 threshold 命中（:3775/:3778 用 `!=`/比對非常數變數不匹配 regex）→ legit。
- `_evaluate_outpost_takeover`（:3634 OUTPOST_TAKEOVER_DAYS）＝該函式**唯一**比較行，純佔領計時器，legit。
- `_pick_outpost_type`（:2834 tools>=3.0）＝該函式唯一 threshold 命中；:2847 `military > civilian` 因右側是變數非常數，不匹配 THRESHOLD_RE，不進 fingerprint（人格決策行本就不算閘，符合設計意圖：決策本身該留給人格秤，這裡沒被誤標）→ legit。
- `_decide_unified`（:1579 DISPATCH_DIST_THRESHOLD）＝掃過 :1476-1591 只此一處符合，且僅餵 `Probe.bump`，不影響 task/target 選擇 → 純 bookkeeping，legit。

## ★抓到的 over-mark 風險（唯一，須處理才能 apply 標）
**`_evaluate_independent_strategy::threshold`**（faction_ai_system.gd）此 fingerprint 底下**至少 4 條命中行混雜**：
- `:1158` envoy timeout（`> int(pp.get("timeout", 2*WorldState.TICKS_PER_DAY))`）→ 本批提案標 legit（latch-timeout，守 invariant①）。
- `:1212-1214` `EXPAND_MIN_POP` + food-surplus → B2 doc 自己說「capability precondition legit」，但**未列入本批 B-legit 清單**，未經本輪 CLEAN。
- `:1217` `ambition >= AMBITION_FOUND_MIN`（can_found gate）→ **54-triage.md 自己的 B2 段**明列為「候選（該人格化?）」，序5 defer，明確**不該**本批標 legit。
- `:1219` 同一常數再命中一次（probe funnel 條件）。

因偵測器以函式+類型收斂成一把 key，**這把 fingerprint 要「消失於 current」必須讓函式內所有符合 THRESHOLD_RE 的行都帶 inline `# gate-ok`**。若 apply 標時圖方便對整個 `_evaluate_independent_strategy` 的 threshold 命中做批次/整段 inline 標記（例如以為「這把 key 已判 legit」而通刪），會**連帶靜默豁免 AMBITION_FOUND_MIN**——這正是本批 handback 開頭要求「重點查我 over-mark」點名要防的那種藏殘留。

**結論**：`_evaluate_independent_strategy::threshold` 這把 fingerprint **本批不適合整把標 gate-ok**。若要保留 `:1158` envoy-timeout 的 legit 判斷，只有兩種安全做法：
1. **只對 `:1158` 那一行單獨加 inline `# gate-ok`**，`:1217`/`:1219`（AMBITION_FOUND_MIN）與 `:1212-1214`（EXPAND_MIN_POP，本批未審）保持無 inline 標記——fingerprint 仍會因這些未標行持續出現在 `current`／baseline 待清單，**繼續被追蹤**（非誤消失），這是正確結果。
2. 或本批乾脆**不動這個 fingerprint**，把 envoy-timeout 的 legit 判斷寫進 54-triage.md 供未來與 AMBITION_FOUND_MIN 序5 一起處理時再一併 inline（比較保守但零風險）。

**其餘 GUARD/world-mechanic 命中逐一核實過，皆是各自函式內唯一 threshold/early_return 命中，無 collision，可放心 inline 標。**

## 判準結果
**CLEAN（含此 1 條 scoping 限制）→ systems 可 apply 標 + 跑 constitution_gate.gd**。條件：`_evaluate_independent_strategy::threshold` 依上述做法 1 或 2 處理，不整函式批次 inline。其餘 11 個 GUARD 函式 + 6 個 world-mechanic 項目核實無 over-mark，照提案 apply。
facility cluster（B-facility）/ 照妖鏡候選（B2）本批不動，維持原分流。

## 附帶建議（非阻斷，供系統判斷是否記 known_issues）
偵測器 fingerprint 粒度＝函式+類型（非逐行）是結構性限制，未來每批「apply 標」前都該重複本次做的「同 fingerprint 下是否混雜多條不同性質命中行」檢查，非本批獨有問題。

## 溯源
`54-triage.md` Bucket B/B2；`scripts/debug/constitution_gate.gd`（機制讀碼）；systems handback `2026-07-17-R2-systems-to-reviewer-bucketB-gate-ok-marks.md`；file:line 逐條見上。
