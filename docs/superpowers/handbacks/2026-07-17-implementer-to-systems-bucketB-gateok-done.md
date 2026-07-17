---
from: implementer
to: systems
status: consumed
topic: "[bucketB done] B-legit inline gate-ok 標 comment-only 零行為。constitution_gate PASS sites=89→72 removed=17(11 early_return guard + 6 world-mechanic/probe threshold)。STAY 保留:indep_strategy::threshold(AMBITION/B2)/new_outpost::threshold(B-facility)/extraction::threshold(real decision)。★dispatch 行號多處 advisory-偏,已按實際 detector-hit 校正(逐條列)。branch feat/bucketb-gateok HEAD f4ac3ee6。"
---
# Hand Back：Bucket B-legit inline gate-ok 標（comment-only 零行為）

**branch** `feat/bucketb-gateok`（已 push）**HEAD `f4ac3ee6`**，off origin/main（含 S1 merge `5cfc2483` + re-freeze `6633315e`）。

## 結果（★驗收=constitution_gate 前後對比）
- **PASS，sites 89→72，removed=17**（無 added=零新閘）。import clean（comment-only 無 parse error）。
- **removed 17 = 完全吻合 dispatch 意圖**：
  - **early_return guard ×11**：`_calc_diplomacy_score`(diplo) / `_consider_extraction` / `_evaluate_independent_infrastructure` / `_evaluate_independent_strategy` / `_evaluate_infrastructure` / `_evaluate_new_outpost_location` / `_evaluate_outpost_residency` / `_evaluate_owner_contact` / `_evaluate_storage_visit` / `_trigger_defection_evaluation` / `_trigger_survival`。
  - **world-mechanic/probe threshold ×6**：`_evaluate_infrastructure`(level cap ≥3) / `_evaluate_outpost_takeover`(OUTPOST_TAKEOVER_DAYS) / `_evaluate_owner_contact`(CONTACT_TIMEOUT_DAYS) / `_pick_outpost_type`(礦脈存在→civilian pull) / `_decide_unified`(probe bookkeeping ×2 行) / `_evaluate_storage_visit`(正量 housekeeping ×2 行)。
- **★STAY 保留（R② 抓 over-mark，逐條核不碰）**：
  - `_evaluate_independent_strategy::threshold`（1217/1219 `AMBITION_FOUND_MIN`=B2 照妖鏡序5 defer）→ **仍在待清單** ✓
  - `_evaluate_new_outpost_location::threshold`（2735/2736/2750/2756/2757 B-facility 選址評分）→ **仍在** ✓
  - `_consider_extraction::threshold`（2242 `extract_score > 0.4` real decision，dispatch 未列）→ **仍在** ✓

## ★dispatch 行號 advisory-偏（逐條校正——按實際 constitution_gate detector-hit 標，非 dispatch 字面行）
dispatch 行號模型與**當前 origin/main 的 gate 實際 detector-hit** 多處不符（advisory，我逐行核對條件+按 gate 真命中標）。關鍵校正供你更新記錄：
- **`_evaluate_owner_contact::early_return`**：dispatch 列 3757/3760/3765，實際**只 3757 是 single-line `if:return`**（3760/3765/3768 return 在下一行=multi-line，不入 EARLY_RETURN_RE `^\s*if.*:\s*return`）。標 3757 即 drop key。
- **`_evaluate_infrastructure::early_return`**：dispatch 列 …/2890/2949；2890 是 multi-line（return 在 2891），非 hit。實際 hits=2885/2886/2888/2949，全標。
- **`_evaluate_independent_strategy::early_return`**：dispatch 列 1156-1165/1167-1172/1193 皆 multi-line guard（非 single-line hit）；實際 single-line hits=1144/1148/1149/1151，全標即 drop。**dispatch 的 ::threshold「只標 1158 envoy-timeout」**：1158 `> int(pp.get("timeout",…))` RHS 小寫→**非 THRESHOLD_RE 命中**（無效標）；真 threshold hits=1217/1219（AMBITION，STAY），故此 fingerprint 正確保留、我未動 1158。
- **`_pick_outpost_type::threshold`**：dispatch 述「tools >= 3.0 :2834」，但 2834 是 `var`-assign 無 if/and/or 關鍵字→**非命中**；實際命中=**2845 `if ore > 0.0`**（礦脈存在→貪婪加 civilian 分，S4.4 已人格化=world-mechanic）。標 2845 drop。
- **`_evaluate_storage_visit::threshold`**：dispatch 述 :2394 `needed*2.0`，但 `> needed*2.0` RHS 小寫→非命中；實際命中=**2391 `take>0.0` + 2398 `deposit>0.0`**（正量 housekeeping），兩行皆標。
- **`_decide_unified::threshold`**：dispatch 述「唯一命中 :1579」，實際**2 命中**=1550 `elif _fd < 6.0`(merge_appl food bucket probe) + 1579 `> DISPATCH_DIST_THRESHOLD`(probe)。兩行皆 probe bookkeeping，皆標→drop（否則單標 1579 不掉）。
- 其餘 early guard（residency/consider_extraction/indep_infra/defection/survival/storage/new_outpost）行號吻合，直標。

## 連動風險
- comment-only，**零行為**（無 code 邏輯變）→ 無回歸風險。未跑 headless/game_sim（dispatch line 12 明示 comment-only 免行為測）；跑 import 確認 parse clean。
- **baseline_v2 re-freeze 建議**：本 slice 後 current=72。你若要讓待清單反映（避免 removed=17 每跑常駐），可 re-freeze baseline_v2→72（同 S1 post-merge re-freeze 89 的作法）。我未動 baseline_v2.txt（owner=你 + dispatch line 10 明示改 txt 註無效）。

## 待確認 / 下一站
- 你複核 removed-17 清單 + STAY-3 是否符預期；行號校正是否需回投 investigator 條件表/`reference_constitution_gate_marking`。
- merge 時序：本 branch 只碰 faction_ai_system.gd + diplomatic_ai_system.gd，與 seam#2 S1（_facility_deficit，同檔 faction_ai_system.gd?）**可能同檔**——見下。
- **★同檔 conflict 預警**：我正接 **seam#2 S1**（`_facility_deficit` registry 化）。若 `_facility_deficit` 在 `faction_ai_system.gd`，本 bucketB commit 改了同檔→兩 branch merge 有 conflict 風險。建議 merge 時序：bucketB 先 merge（小 comment-only）→ seam#2 rebase，或反之你裁。我 seam#2 worktree 另開 off origin/main（尚未含本 bucketB commit）。

## 溯源
dispatch `2026-07-17-systems-to-implementer-bucketB-inline-gateok-marks.md`；R② `bucketb-r2-verdict`（CLEAN+1限制 AMBITION）；[[reference_constitution_gate_marking]]。
