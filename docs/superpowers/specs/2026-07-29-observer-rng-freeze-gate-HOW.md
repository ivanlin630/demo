---
type: spec
owner: systems
topic: observer-no-global-RNG 靜態閘（observability_gate 擴 RNG 軸）HOW
status: ready-for-R2
---

# HOW spec：observer-no-global-RNG 靜態閘

> **動機**：`feedback_observer_no_global_rng` 已憲法級（觀測路徑禁耗 global RNG，否則觀測改被觀測物），但**4 次血證**（LOD→randf / SpecimenDumpHelper pick_random / tracer-family / measurer ad-hoc pick_random）證**人工記性擋不住**。blueprint 多次點名「機器擋、別靠人工記性」。現況**無靜態閘覆蓋此軸**：
> - `constitution_gate.gd`：`SCAN_DIR=res://scripts/simulation` 只掃決策檔、`RNG_RE=\b(randf|randi|randomize)\s*\(` **漏 `pick_random`/`shuffle`**（正是最新兩次血證向量），且**不掃 `scripts/debug/`**（觀測工具住處）。
> - `observability_gate.gd`：只管 **tap coverage**（capture 點≥baseline，`feedback_full_transient_observability` 軸），非 RNG 軸。
> - `observability_path_test.gd:_test_tracer_onoff_byte_identical`：runtime 語意保證**但只覆蓋 runtime exercise 到的路徑**——血證根教訓＝leak 躲在 harness 沒跑到的路徑。∴需**靜態閘補未 exercise 路徑**。

## 1. scope（單 slice，最小）
在 **`observability_gate.gd` 加第③檢查：observe-context 檔內禁 global-RNG 向量**。runtime byte-identical 測續作語意驗（互補：靜態抓覆蓋、runtime 抓語意）。

## 2. 機制

### 2a. global-RNG 向量集（擴 constitution 的 3 個 → 5 類）
偵測**耗 global RNG** 的呼叫（determinism 殺手）：
- `\brandf\s*\(` / `\brandi\s*\(` / `\brandf_range\s*\(` / `\brandi_range\s*\(` / `\brandomize\s*\(`（bare global）
- **`\.pick_random\s*\(`**（Array/Dictionary 方法，用 global RNG）★新
- **`\.shuffle\s*\(`**（同上）★新

### 2b. ★local-seeded 逃生口（避 false-positive）
`var rng := RandomNumberGenerator.new()` 後 `rng.randf()`/`rng.randi()` 是**確定性本地**（seeded bed 合法，如 `scaling_bed`/`warring_harness`）——**非** global RNG，不擋。
- 判別：向量前綴是**識別字 `.`**（`rng.randf(`、`_local_rng.randi(`）＝本地實例呼叫 → **放行**；bare（行首或非識別字前綴，如 ` randf(`、`=randf(`、`(randf(`）＝global → **抓**。
- ★`pick_random`/`shuffle` 例外：Array/Dict 的 `.pick_random()`/`.shuffle()` **一律用 global RNG**（GDScript 無本地版），故前綴為 `.` 也**照抓**（不吃逃生口）。血證 2 就是 `arr.pick_random()`。

### 2c. observe-context 範圍（marker 慣例，避中央清單腐化）
observe-pure 檔在**檔頭加 marker 註**：`# @observe-pure`（自我文件化、新觀測 helper 加 marker 即自動納管、無中央清單維護）。
- 閘掃 `res://scripts/debug/` 全 `.gd`，**只對含 `# @observe-pure` 的檔**跑 2a/2b 向量檢查。
- **核心 3 檔 seed marker**（本 slice 加）：`specimen_dump_helper.gd`、`specimen_tracer.gd`、`probe_stats.gd`（純觀測、零 RNG 正當理由）。★`*_bed`/`*_harness`（seeded 世界建構）**不加 marker**＝不納管（它們合法 seeded RNG）。
- ★**同時**：`constitution_gate.gd` 的 `RNG_RE` 補 `pick_random`/`shuffle`（決策檔本就禁任何 RNG，純增益零風險，順手補 vector 集一致）。

## 3. 契約 + 輸出
- observe-pure 檔含任一 global-RNG 向量（過 2b 逃生口判別）→ **FAIL**，印 `[OBSERVABILITY-GATE] FAIL: <file>:<line> observe-pure 檔耗 global RNG: <matched>`。
- 零命中 → 既有 PASS 行加 `rng_scan=<N檔>`。
- merge-gate：接入既有 `observability_gate.gd` 執行（orchestrator merge 前跑同 constitution_gate）。

## 4. TDD + 驗
- **正例**：核心 3 檔現況（strided/零 RNG）→ PASS。
- **反例（紅→綠）**：測 fixture 在 observe-pure 檔塞 `arr.pick_random()` → FAIL 命中該行；塞 bare `randf()` → FAIL；塞 `rng.randf()`（本地 seeded）→ **不** FAIL（逃生口）。
- **marker 隔離**：`scaling_bed.gd`（`rng.randi()` seeded、無 marker）→ 不掃、不誤報。
- 閘自身零 RNG、determinism 無關（純靜態掃）。headless 0-new + constitution_gate 74 不變。

## 5. 憲法對齊
- 純靜態掃（零 runtime、零世界改動、零 RNG）。互補 runtime byte-identical（靜態抓覆蓋盲區、runtime 抓語意）。marker 慣例＝可延伸非硬清單。連 [[feedback_observer_no_global_rng]]（第 4 次血證後機器化）+ [[feedback_full_transient_observability]]（同 observability_gate 家族、正交軸）。

## 6. 交付
→ R²（★異質：2b 逃生口 regex 邊界會不會漏/誤報、marker 慣例 vs 中央清單、pick_random 不吃逃生口對否、`\.pick_random` 是否漏 map/reduce 等其他 global-RNG 向量）→ implementer → merge-gate 接入 → measurer 無需（純靜態）→ QA 無需（framework 閘、非世界行為）。
