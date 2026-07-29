---
from: implementer
to: systems
status: consumed
topic: "[done·observer-no-global-RNG 靜態閘·請 R²·★flag 既有 observability_gate ① drift] feat/observer-rng-freeze-gate f79bd8ac off main 7620b605。observability_gate ③ RNG scan(observe-pure marker 檔禁 7 向量+逃生口)+constitution_gate RNG_RE 擴 4 新向量+3 核心檔 marker。驗:observer_rng_gate_test 14/14(7 向量+逃生口+pick_random 照抓)+constitution 74 removed=0(未變 sites)+headless 0-new(sim 未動)。★flag:observability_gate ① capture_decision 9<baseline 10=既有 drift(prior merge 移 tap,非本 slice)→systems 判復原 tap 或 ratify baseline。純靜態零 RNG determinism 無關。"
branch: feat/observer-rng-freeze-gate
commit: f79bd8ac
base: 7620b605 (local main HEAD)
spec: docs/superpowers/specs/2026-07-29-observer-rng-freeze-gate-HOW.md §2/§2a/§2b
---

# done：observer-no-global-RNG 靜態閘（請 R²）

第 4 次血證後機器化（[[feedback_observer_no_global_rng]]，人工記性擋不住）。純靜態掃描閘、零 runtime/世界改動。

## 做（spec §2/§2a/§2b）
1. **`observability_gate.gd` ③ RNG scan**：掃 `scripts/debug/` 全 `.gd`，只對含 `# @observe-pure` marker 檔跑 7 類 global-RNG 向量檢查：
   - **函式型**（`RNG_FUNC_RE`）：`randf/randi/randf_range/randi_range/randfn/randomize/seed` + **負向 lookbehind 逃生口**（`(?<![\w.])`→`rng.randf(` 本地實例放行；bare 抓）。
   - **方法型**（`RNG_METHOD_RE`）：`.pick_random/.shuffle` **照抓**（無本地版，不吃逃生口=血證 2）。
   - `seed`：裸括號 `seed(` 抓（全域重播種）；`rng.seed = x` property 賦值（無括號）不抓。
   - **marker-missing WARN**（非阻斷）：檔名含 tracer/probe/dump/specimen/observ 但無 marker → 提醒複查。
2. **`constitution_gate.gd` `RNG_RE` 擴全 4 新向量**（pick_random/shuffle/randfn/seed）——兩閘 vector 集一致。
3. **核心 3 檔 `# @observe-pure` marker**：`specimen_dump_helper`/`specimen_tracer`/`probe_stats`（`*_bed`/`*_harness` 不加=seeded 合法）。

## 驗（RNG 軸全綠）
- `observer_rng_gate_test` **14/14**：7 向量命中（bare randf/randi/randfn/randf_range/seed/randomize + arr.pick_random/shuffle）+ 逃生口不誤報（rng.randf/`_local_rng.randi_range`/`rng.seed = x`/RNG.new 宣告）+ 一般算術不誤報。
- `constitution_gate` **PASS 74 removed=0**（RNG_RE 擴未變 sites=sim 決策檔本無 pick_random/shuffle/seed/randfn）。
- headless **0-new**（sim 未動=純 gate/marker/test 檔）。
- 純靜態零 RNG → determinism 無關（spec §4；sim 未動）。

## ★flag（非本 slice，systems 判）
`observability_gate` **① `capture_decision` 9 < baseline 10** = **既有 baseline drift**（prior merge 移了一 SpecimenTracer.capture_decision tap；我 slice 沒碰 capture_decision，純加 ③ RNG 軸）。→ systems 判：**復原該 tap**（若 coverage 該保）**或 ratify 移除+更新 `observability_baseline.txt` 到 9**。我**不逕改 baseline**（避藏真 coverage regression；baseline 系 systems-owned 如 constitution_baseline）。與 RNG 軸正交。

## 待
systems R²（★異質：逃生口 regex 真擋真放、pick_random 不吃逃生口對、constitution baseline 一致、① drift 判）→ 解 ① drift → observability_gate 全綠 → merge-gate 接入（orchestrator merge 前跑）。framework 閘 measurer/QA 無需（非世界行為）。
