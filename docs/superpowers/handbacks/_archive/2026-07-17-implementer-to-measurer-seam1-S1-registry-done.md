---
from: implementer
to: measurer
status: consumed
topic: "[seam#1 S1 交付] registry 化 applicable()+to_task() — byte-identical 純重構,驗 Probe 計數+輸出+擴充 proof。branch feat/seam1-registry HEAD 24e51cc1。三閘自驗綠(char/seeded game_sim/seeded warring 皆 0 semantic diff),請中性全量複核。"
---
# Hand Back：seam#1 S1 registry 化（byte-identical 純重構）

**branch** `feat/seam1-registry`（已 push）**HEAD `24e51cc1`**，off origin/main `1fd7b425`。

## 實作摘要
- `scripts/simulation/decision/options.gd`：`applicable()`+`to_task()` 的 per-option match/switch 分支
  折進 REGISTRY data entry `{terms, applicable:Callable, to_task:Callable}`。加 option = 加 REGISTRY 1 entry
  （本體零改，消兩平行 match）＝擴充性 proof。
  - **const→static var REGISTRY**：entry 含 Callable(lambda) 不能進 const（constant-expression 限制）。
    Dictionary 保 GDScript4 插入序 → `applicable()` 產出池順序 byte-identical。
  - **applicable()**：`for opt in REGISTRY` → 共用前置閘 → `REGISTRY[opt]["applicable"].call(ctx)`。
  - **terms_of()**：`REGISTRY.get(opt, {}).get("terms", [])`（未知→[]）。
  - **to_task()**：`REGISTRY.get(opt,{})` 空→IDLE fallback；否則 `entry["to_task"].call(state, team)`。
- `scripts/debug/seam1_registry_test.gd`（新 char bed，進 repo）：applicable 池順序 + subteam 前置閘 +
  Probe 計數（produce/occupy 分支）+ to_task 純分支 + 擴充 proof。

## caveat 逐條落實（spec/dispatch 明列）
- **caveat①（Probe byte-identical）**：applicable lambda 內嵌 `Probe.bump` 診斷副作用**逐條原位保留**
  （`produce.appl_kill_nofacility` / `occupy.ctx_hastarget` / `occupy.appl_kill_pop` /
  `occupy.appl_kill_hasbase` / `occupy.applicable`）。char bed 專測每分支 bump=1，全綠。
- **caveat②（subteam 共用前置閘 A2a）**：`if ctx.is_subteam and opt in STRATEGIC_SELFINIT_SET: continue`
  留在 `applicable()` 迭代**框架層統一套一次**（每 entry pred 之前），**非塞進各 entry pred** → 未來加 option
  不會漏套。char bed 專測（子隊 applicable 排除建設/納入歸建）全綠。
- **caveat③（S2 churn-guard 分岐）**：不在本 dispatch scope（S2）。未碰 rank_survival/rank_scored/threat/ambient。

## byte-identical 三閘自驗（★皆 0 semantic diff）
1. **char bed**：applicable 池順序 + Probe 計數 + to_task 純分支 goldens **refactor 前後完全相同**（先在
   baseline 673a0dec 驗綠 goldens 捕對，refactor 後同值+擴充 proof 全綠）。26/26 PASS。
2. **seeded game_sim_multi**（`seed(hash(cfg_name))` 量測閘）：baseline(pre-refactor 674a0dec) vs refactor
   逐行 diff = **12092 行相等，0 semantic diff**（唯一差異=468 行 `[TickPerf]` 牆鐘 µs，非語意）。
3. **seeded_warring_bed seed=1337 / 3 月**：pointwise metric diff = **`total_diffs=0`（逐點相同,零行為變）**
   （67 teams / 9 factions / 全 probe counter 含 dispatch/merge/combat/conquest 皆 identical）。
4. **constitution_gate**：**PASS**（見下 flag，sites 91→89）。
5. **full headless_test**：`=== DONE ===` 出現；殘 3 assertion=**pre-existing baseline**（zero-change 亦現，非本刀）：
   `_test_p2a_survival_terms:15529` / `_test_beg_join_social_resolve:7075` / `_test_strategic_reads_ladder:13979`。
   refactor 後**同 3 個、無新增無減少**（baseline 亦 3）。

## 連動風險 / flag（供 measurer + systems 過目）
- **★constitution_gate fingerprint relocation（給 systems，非行為變）**：gate PASS 但 `sites 91→89, removed=2`——
  移除的 2 筆 = `options.gd::applicable::threshold` + `options.gd::to_task::early_return`。**非真 de-patch**：
  那些 `>=`/`<` threshold 與 IDLE early-return 仍 byte-identical 存在，只是 registry 化把它們**搬進 lambda**→
  gate 的 by-location fingerprint 偵不到原位置 → 報 removed。behavior 零變（三閘證）。**systems 可能需 re-freeze
  constitution baseline_v2**（此 2 fingerprint 是 legit 引擎邏輯非補丁；且第 2 封 dispatch bucketB gate-ok 標
  正處理 fingerprint 待清單，此 relocation 與之相關）。
- **REGISTRY 結構變**：外部只經 `applicable()/terms_of()/to_task()/REGISTRY.keys()` 存取（grep 全掃），
  無直接 `REGISTRY[opt]` value 索引 → 零 caller 破。decision_engine 4 rank 路 + 各 bed 全綠。
- 無其他已知連動風險。

## 待確認 / 下一站
- measurer：中性全量複核 byte-identical（★spec 明列 measurer 驗收清單=**Probe 計數 byte-identical**，非只 dispatch
  結果 + 擴充 proof）。上述閘 2/3 可直接複跑（baseline dump→branch compare 機制在 `seeded_warring_bed.gd`；
  game_sim_multi 逐行 diff 排除 `[TickPerf]`）。
- 綠 → to:systems 判 merge（+ 處理 constitution baseline_v2 re-freeze）。
- **S2（survival/ambient 收斂）不在本刀**（待 systems 逐路驗 plan + R②）。
- 我 hold warm 等裁決（[DONE]/[REDO]）。第 2 封 dispatch（bucketB gate-ok 標，`to_task(options.gd)`）systems 明令
  **待 S1 merged 後**才標（避同檔 conflict）→ S1 merge 後接。

## 溯源
spec `docs/superpowers/specs/2026-07-17-seam1-control-flow-convergence.md §S1`（R② CLEAN）；
dispatch `2026-07-17-systems-to-implementer-seam1-S1-registry.md`；[[feedback_full_transient_observability]] Probe byte-identical。
