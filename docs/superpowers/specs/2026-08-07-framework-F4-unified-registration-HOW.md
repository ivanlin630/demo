# F4 統一註冊表 HOW（②結構 operational 示範、byte-identical）

**status**: DRAFT（待 R² CLEAN → LOCK）
**track**: framework 兩硬綠 ②「可擴充」operational（加東西=動一處『註冊』部分解）
**用戶**: 拍 C（2026-08-07）=先做統一註冊表（便宜高值直解「加東西大改」痛）+ 收結構進度 → 回玩法 → 26 決策 func 走 B 漸進 Track②A backlog。
**驗收模式**: byte-identical 純結構（F0 fp 對 ce201650 baseline 27/27 = 零行為變）。**非** F1-式 fp-分化。

---

## 問題（現況：per-option 資料散 4 處）

每個 decision option 的資料散落，加一個 option 要改多處：
1. **表1 REGISTRY**（`options.gd:12`）：`{opt: {terms, applicable, to_task}}` — 已 option-keyed 統一。
2. **表2 AFFINITY**（`need_hierarchy.gd:82`）：`{opt: [5-layer 需求 affinity]}` + `_AFFINITY_UNIFORM(:113)` fallback。option-keyed。**覆蓋 24 option、缺 買料/遷移找糧**（落 uniform）。
3. **表4 OPTION_SET ×6**（散 3 檔）：option-membership 陣列 —
   - `decision_context.gd:97` STAKES_SET
   - `decision_engine.gd:134` PASSIVE_SURVIVAL_SET / `:198` THREAT_OPTION_SET / `:223` AMBIENT_OPTION_SET
   - `options.gd:383` STRATEGIC_SELFINIT_SET / `:386` SURVIVAL_OPTION_SET
   - 全 6 set 成員 **⊆ REGISTRY 鍵**（已驗、diff 空）。
4. **表3 terms.gd**（`DecisionTerms`）：**term-keyed 異軸**（term 被 REGISTRY entries 的 `terms` 欄引用、跨 option 共用）→ **不折入**（折入=category error）。留原軸。

∴ 加一個 option 現要碰 REGISTRY + AFFINITY + N 個 SET = 散落。統一 = 折 option-keyed 資料（表2+表4）進 REGISTRY entry。

---

## HOW：REGISTRY = 單一 option 註冊點

每個 `REGISTRY[opt]` entry 由 `{terms, applicable, to_task}` 擴為：
```
{terms, applicable, to_task, affinity, sets}
```
- `affinity`: `Array[5]` = 該 option 的需求層 affinity（從表2 搬入）。
- `sets`: `Dictionary` 或 6 個 bool 欄（is_survival / is_passive_survival / is_threat / is_ambient / is_strategic_selfinit / is_stakes）= 從 6 個 OPTION_SET 搬入的 membership。

查詢 API 改讀 REGISTRY（保 lookup 語意 byte-identical）：
- `NeedHierarchy.affinity_of(opt)` → `DecisionOptions.REGISTRY[opt].affinity if REGISTRY.has(opt) else _AFFINITY_UNIFORM`。
- 各 `opt in SURVIVAL_OPTION_SET` 式 query → `DecisionOptions.is_in_set(opt, "survival")`（= `REGISTRY.has(opt) and REGISTRY[opt].sets.survival`）。

---

## ★★§HOW-binding（寫死必守、byte-identical 保序 invariant）

### INV-1（AFFINITY 折入保序）
- 每 REGISTRY entry.affinity **= 現行 `AFFINITY.get(opt, _AFFINITY_UNIFORM)`**（逐 option 對現行 lookup 結果）。
- **買料 / 遷移找糧顯式設 `_AFFINITY_UNIFORM`**（[0.2×5]）= **保序、非「訂正」**。給它們語意 affinity = 行為變 = **禁**（=另 behavior slice）。
- `affinity_of(opt)` 保「非-REGISTRY opt（如 `""`）→ UNIFORM」（call site headless_test:16108 傳 REGISTRY opt、production :125/:142 傳 opt；空/未知仍 UNIFORM）。
- `main_layer_of`（讀 affinity_of）零改 → 自動繼承 byte-identical。

### INV-2（OPTION_SET 折入保序）
- 6 set 全 ⊆ REGISTRY（已驗）→ 每 entry.sets.X = **現行 `(opt in SET_X)`**（逐 option 對現行 membership）。
- 各 membership query 改 `is_in_set(opt, X)` = `REGISTRY.has(opt) and entry.sets.X`。**guard `REGISTRY.has` 保「非-REGISTRY opt 查 set → false」**（現 `opt in SET` 對非成員=false、對非-REGISTRY-opt 亦 false，guard 等價）。
- 不在任何 set 的 option（買料/歸建）→ 6 flags 全 false（= 現行 membership）。

### ★★INV-2b（design fork 釘死 = R² 必查項 resolved）——刪 const array、單源、full caller enum
**fork = (b) 刪除 6 個舊 const array**（非 (a) 保留=兩本帳假統一、違「加 option 動一處」目的）。單一真源 = `REGISTRY[opt].sets`。加 2 accessor（DecisionOptions）：
- `is_in_set(opt: String, name: String) -> bool` = `REGISTRY.has(opt) and bool(REGISTRY[opt].sets.get(name, false))` — 取代全 `opt in SET` membership。
- `options_in_set(name: String) -> Array` = REGISTRY **插入序**迭代、filter flag — 取代 `for g in SET` 迭代。
- ★**byte-identical 迭代序證**：唯一 production 迭代 = `decision_context:404 for g in STAKES_SET: if g in f.goals: append`（append 按 SET 序）。REGISTRY 插入序 **攻擊(:203)<徵收(:225)<外交(:241) = STAKES_SET 手序 ["攻擊","徵收","外交"] 完全吻合** → `options_in_set("stakes")` byte-identical。5 個 membership set order-irrelevant。

**★★full caller enum（刪 array→全 site 須改、否則 Invalid-call/Identifier-not-found 炸；F2 debug/test 教訓）**：
- **production 11**（membership→`is_in_set`；STAKES 迭代→`options_in_set`）：
  - `decision_engine.gd:75`（SURVIVAL）/`:138`（PASSIVE_SURVIVAL）/`:171`（SURVIVAL）/`:203`（THREAT）/`:228`（AMBIENT）
  - `options.gd:396`（SURVIVAL、含 `or opt=="survival"` 保留）/`:412`（SURVIVAL）/`:410`（STRATEGIC_SELFINIT）
  - `faction_ai_system.gd:4562`（SURVIVAL、★R² 抓、不在原 3-home 名單）
  - `decision_context.gd:404`（STAKES 迭代→`for g in DecisionOptions.options_in_set("stakes")`）
  - `decision_engine.gd:81`（THREAT、`opt in THREAT_OPTION_SET` boost gate）
- **debug/test 11 真 code**：`buyfood_measure.gd:88`（print `str(options_in_set("survival"))`）/`headless_test.gd:4833,5783,6512,6709,9984,11146,13069`（7 membership assert）/`starvation_lockpoint_trace_bed.gd:23`（`for opt in options_in_set("survival")`）/`survival_layer_unify_test.gd:137`/`survival_prio_fix_test.gd:67`（membership）
- **comment-only 7 處**（無 code 改、可留舊名於註解或順手更新文字）：`starvation_desperation_trace_bed:4`/`starvation_lockpoint_trace_bed:20`/`starvation_util_escalation_trace_bed:5`/`survival_single_source_test:26`/`headless_test:13037`/`rung_dissolution_check:52`/`seam1_registry_test:9`。
- ★依賴：SURVIVAL/STRATEGIC_SELFINIT 現於 options.gd、THREAT/AMBIENT/PASSIVE 現於 decision_engine.gd、STAKES 現於 decision_context.gd → accessor 統一置 DecisionOptions、跨檔 caller 改 `DecisionOptions.is_in_set(...)`。decision_engine/decision_context → DecisionOptions 單向（已驗零環）。

### INV-3（terms 軸不動）
- `terms.gd` 常數 + term eval 零改。REGISTRY 的 `terms` 欄（`[[term_id, weight_key]]`）零改。terms 是 shared 軸、不折入 option 點。

### INV-4（純結構、零 logic 改）
- applicable/to_task lambda 本體零改（含內嵌 Probe.bump 診斷副作用逐條原位保留 = 觀測 byte-identical、[[feedback_observer_no_global_rng]] 同精神）。
- 折入 = 資料搬家（表2/表4 → REGISTRY 欄）+ lookup 改讀 REGISTRY。決策計算路徑零改。

---

## 擴充性稽核（硬綠②operational 示範）

證「加東西=動一處」：
- 加一個 **mock 行為域 option**（test-only、e.g. `"__mock_ext__"`）到 REGISTRY 單一 entry（含 terms/applicable/to_task/affinity/sets）→ **machine-assert 只此一處 diff、其餘註冊表零改** = 「加 option 動一處」operational。
- constitution_gate 或新 `extensibility_gate` 掃：若加 option 需碰 >1 註冊處 → FAIL。
- ★誠實邊界（記 progress、不宣稱 no-god-object done）：本 audit 證「**註冊**部分=動一處」；但新 option 的**行為若與 5248 行決策核互動**（applicable/to_task 呼 faction_ai helper）仍需碰 faction_ai = full no-god-object 未達 = Track②A incremental backlog。

---

## 驗收（byte-identical 模式）
- **F0 fp 對 ce201650 baseline 27/27 byte-identical**（diff=0 = 零行為變證）。★命門。
- constitution_gate 綠（無新閘；折入=資料搬非新 gate）。
- headless 0-new（affinity_of/is_in_set 全 call site 更新無 Invalid-call；headless_test:16103/16108-16111 affinity 斷言仍過）。
- determinism 3-run byte-identical（純結構天然保持）。
- caller exhaustive（含 debug/test，F2 教訓）：affinity_of 3 caller（need_hierarchy:125/142 + headless_test:16103,16108-16111）；6 set 的全 membership query site（逐 set grep `in <SET>`）。

## 序
spec 自檢 → **R²（結構審：折入邊界乾淨 + INV-1~4 保序 + 依賴方向 need_hierarchy→DecisionOptions.REGISTRY 無環 + caller exhaustive）** → build（fp byte-identical 驗）→ 量測（fp diff=0 確認）→ QA 親 diff → merge = F4 收（②operational）。
- ★follow-up（另 slice、非本批）：遷移找糧/買料 uniform affinity 語意 gap（遷移找糧∈SURVIVAL_SET 卻 uniform、疑該 survival-heavy）→ measurer/blueprint 定是否給 proper affinity（=behavior slice、fp-分化-intended）。
