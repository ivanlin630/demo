---
from: systems
to: implementer
status: consumed
topic: "[實作·observer-no-global-RNG靜態閘·spec=2026-07-29-observer-rng-freeze-gate-HOW.md(R²CLEAN+必補已訂進§2a:7類向量含randfn/seed)·observability_gate.gd加第③檢查:observe-pure marker檔禁7類global-RNG向量(randf/randi/randf_range/randi_range/randfn/randomize/seed+pick_random/shuffle)+local-seeded逃生口(識別字.前綴放行,但pick_random/shuffle照抓+seed裸括號抓rng.seed=賦值不抓)+同步補constitution_gate RNG_RE全4新向量+marker-missing非阻斷WARN·核心3檔seed marker(specimen_dump_helper/specimen_tracer/probe_stats)·純靜態零RNG] observe-RNG靜態閘。7類向量。核心3檔加marker。反例測7向量+逃生口。"
branch: feat/observer-rng-freeze-gate
---

# 實作：observer-no-global-RNG 靜態閘

R² CLEAN + 必補（向量 5→7 加 `randfn`/`seed`）已訂進 spec §2a。純靜態掃描閘、零 runtime、零世界改動。

## spec
`docs/superpowers/specs/2026-07-29-observer-rng-freeze-gate-HOW.md`（讀它，R² 訂正版）。

## scope
1. **`observability_gate.gd` 加第③檢查**（§2）：掃 `res://scripts/debug/` 全 `.gd`，**只對含 `# @observe-pure` marker 的檔**跑向量檢查。
2. **7 類 global-RNG 向量**（§2a）：`randf`/`randi`/`randf_range`/`randi_range`/`randfn`/`randomize`/`seed`（bare）+ `.pick_random`/`.shuffle`。
3. **local-seeded 逃生口**（§2b）：識別字 `.` 前綴（`rng.randf(`）放行；**但 `pick_random`/`shuffle` 照抓**（無本地版）、**`seed` 裸括號 `seed(` 抓 / `rng.seed = x` property 賦值無括號不抓**。
4. **核心 3 檔 seed `# @observe-pure` marker**：`specimen_dump_helper.gd`、`specimen_tracer.gd`、`probe_stats.gd`（純觀測、現況零 RNG）。★`*_bed`/`*_harness` **不加**（seeded 合法）。
5. **同步補 `constitution_gate.gd` `RNG_RE`**：加全 4 新向量（`pick_random`/`shuffle`/`randfn`/`seed`）——R² 要求兩閘 vector 集一致（決策檔零容忍、零風險）。★補後 constitution_gate 重跑須仍 PASS（sites 數可能因新 regex 命中既有 sim 檔而變——若命中，查是不是真 RNG-in-decision 洩漏、更新 baseline；若 sim 決策檔本就無這些向量則 sites 不變）。
6. **marker-missing 非阻斷 WARN**（§2d）：`scripts/debug/` 檔名含 tracer/probe/dump/specimen/observ 但無 marker → 印 WARN 不 FAIL。

## ★TDD + 驗
- 正例：核心 3 檔（strided/零 RNG）→ PASS。
- 反例（紅→綠）：observe-pure 檔塞 `arr.pick_random()`/bare `randf()`/`randfn(0,1)`/bare `seed(123)` → 各 FAIL 命中該行；塞 `rng.randf()`/`rng.seed = 123` → **不** FAIL（逃生口）。
- marker 隔離：`scaling_bed.gd`（`rng.randi()` seeded、無 marker）→ 不掃、不誤報。
- WARN 測：檔名含觀測詞無 marker → WARN 非 FAIL。
- 閘自身零 RNG。**★constitution_gate 補 RNG_RE 後重跑仍 PASS（sites 記錄變化，如變→查真偽+更新 baseline）**。headless 0-new。

## 交付
handback `to:systems` → R²（複審實作：逃生口 regex 真擋真放、7 向量齊、constitution_gate baseline 一致）→ merge-gate 接入（orchestrator merge 前跑 observability_gate）。★純 framework 閘，measurer/QA 無需（非世界行為）。正交 arc，roadmap fork PAUSE 期做。
