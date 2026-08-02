---
from: systems
to: implementer
status: consumed
topic: "[dispatch·低優先於 S1] Bucket B-legit inline gate-ok 標(源碼註,comment-only 零行為)。R② CLEAN 含 1 限制:_evaluate_independent_strategy::threshold 只標 :1158 envoy-timeout,禁碰 :1212/1217/1219(AMBITION/EXPAND=序5 defer)。to_task(options.gd)待 S1 merged 後標(避同檔 conflict)。標完跑 constitution_gate 確認這些 fingerprint 掉出待清單、B-facility/B2/threat 續留。"
---

# Bucket B-legit inline gate-ok 標（comment-only，零行為）

## 機制（★別改 baseline txt）
標 legit = **在該原始碼行內加 inline `# gate-ok: <理由>`**（constitution_gate.gd:115-116 掃 inline 標讓命中消失）。**改 `constitution_baseline_v2.txt` 的註無效**（純裝飾）。fingerprint=`file::func::type` 粒度→**同函式同 type 的所有命中行都要標，該把 key 才消失**。詳 [[reference_constitution_gate_marking]]。
- comment-only，零行為變 → 無需 TDD 行為測；驗收=跑 constitution_gate 前後對比待清單。
- 行號 advisory（investigator 讀當前碼，可能微移）→ **標前逐行核對條件符合描述再標**。

## 標清單（GUARD ::early_return — 標函式內全部 guard 行）
`diplomatic_ai_system.gd`：
- `_calc_diplomacy_score` :86（`if self_leader == null: return`）
`faction_ai_system.gd`：
- `_consider_extraction` :2235/:2236/:2238（treasury≤0 / player / leader null）
- `_evaluate_infrastructure` :2885/:2886/:2888/:2890/:2949（null/combat/player/empty loc）
- `_evaluate_independent_infrastructure` :2864/:2865/:2867/:2869/:2871/:2873（combat/player/null/no-pos/no-outpost/empty pick）
- `_evaluate_new_outpost_location` :2759（`candidates.is_empty()`）← **只標 early_return；:2722/:2757 threshold=B-facility 禁標**
- `_evaluate_outpost_residency` :526/:529（cadence throttle / null）
- `_evaluate_owner_contact` :3757/:3760/:3765（非resident/無owner/last_tick=-1）
- `_evaluate_storage_visit` :2382/:2383（非自家outpost/public empty）
- `_trigger_defection_evaluation` :3727（null）
- `_trigger_survival` :3306/:3318（null / means-end 自救豁免）
- `_evaluate_independent_strategy` **::early_return** :1144/:1148/:1149/:1151/:1156-1165/:1167-1172/:1193（player/parent/combat/null/envoy-in-flight/subjugate-in-flight/defer-prosperity，全 guard）

## 標清單（world-mechanic ::threshold — 各函式唯一命中）
`faction_ai_system.gd`：
- `_evaluate_infrastructure` :2897（`outpost_level >= 3`=level cap）
- `_evaluate_outpost_takeover` :3634（OUTPOST_TAKEOVER_DAYS 占領 timer）
- `_evaluate_owner_contact` :3768（CONTACT_TIMEOUT_DAYS cadence）
- `_pick_outpost_type` :2834（`tools >= 3.0` 材料需求）
- `_decide_unified` :1579（DISPATCH_DIST_THRESHOLD=probe bookkeeping 非決策）
- `_evaluate_storage_visit` :2394（`needed * 2.0` 庫存 housekeeping）

## ★限制（R② 抓 over-mark，違反=藏殘留）
- `_evaluate_independent_strategy` **::threshold**：**只標 `:1158`**（envoy timeout `> pp.timeout`，latch-timeout legit）。**禁碰 `:1212`(EXPAND_MIN_POP 未審)/`:1217`/`:1219`(AMBITION_FOUND_MIN=B2 照妖鏡序5 defer)**——留無標，讓此 fingerprint 續出現在待清單=正確追蹤。
- `to_task`（`decision/options.gd`）：**跳過完全**——seam#1 S1 已 merged，registry 化把 `to_task::early_return` fingerprint relocate 進 lambda **已移除**（baseline_v2 re-freeze 89），無此命中可標。本 slice 只做 faction_ai_system.gd + diplomatic_ai_system.gd 上列項。

## 驗收
標完跑 `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd`，確認：
- 上列 GUARD/world-mechanic fingerprint **掉出 current 待清單**。
- `_evaluate_independent_strategy::threshold` **仍在**待清單（因 AMBITION 未標）。
- B-facility / B2 / threat 控制流閘 **仍在**（本 slice 不碰）。
- 若某 fingerprint 沒掉=有漏標行（回報 systems 補）。
handback 回 to:systems（哪些 fingerprint 清了/剩幾閘）。

## 優先序
**低於 seam#1 S1**（S1 先做先 merge）。本 slice comment-only 不急，S1 後再做。

## 溯源
R② `2026-07-17-reviewer-to-systems-bucketb-r2-verdict.md`（CLEAN+1限制）；investigator 條件表；`54-triage.md` B-legit；[[reference_constitution_gate_marking]]。
