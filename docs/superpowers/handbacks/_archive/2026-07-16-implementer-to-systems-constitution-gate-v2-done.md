---
from: implementer
to: systems
status: consumed
topic: "[DONE·stream①] constitution_gate v2 抓全閘型(07d1d651):enumerate 93 閘(6 型)+baseline-freeze+PASS。★section-A 已知閘覆蓋全中(6/6)+v1 taskarbiter 回歸(28)。measure-first 殘留可數,待逐閘 de-patch"
---
# [DONE] constitution_gate v2（stream ① 基礎：零殘留可數機制）

branch `feat/constitution-gate-strengthen` @ `07d1d651`（已 push），base origin/main `c07c2e8c`。

## 建了什麼
`constitution_gate.gd` v2——v1 只抓 TaskArbiter task 指派，v2 加**全閘型偵測器**（掃 `scripts/simulation`，指紋 `<relpath>::<func>::<type>`）：
- **值閘**：`rng`（RNG-in-decision，randf/randi 在 decision 檔，`# gate-ok` 源碼豁免世界機制）/ `threshold`（decision func 內具名常數/字面門檻比較）/ `early_return`（if 守衛 return，bypass 秤）。
- **控制流閘**：`dispatch_entry`（rank_*/eval_* 散落入口＝真統一破口）/ `route`（uses_unified/archetype/tag/task 手派選路）。
- **回歸**：`taskarbiter`（v1 task 指派全檔仍抓）。
- **契約**：current ⊆ baseline。**added=FAIL**（新閘）、**removed=PASS**（de-patch 進度，印出）。★**不 auto-classify** legit vs violation（做不到）——enumerate 全部，legit/violation 標記由後續 de-patch 人工判（baseline 行內可加 `# gate-ok`/`# 待de-patch` 註解，gate 讀取時剝註解）。

## baseline_v2 + 跑一次
- **enumerate 93 閘**，`constitution_baseline_v2.txt` 凍結。**類型分布**：dispatch_entry **8** / threshold **22** / early_return **20** / route **10** / rng **5** / taskarbiter **28**。
- 跑：`[CONSTITUTION-GATE] PASS (sites=93, removed=0)`。

## ★驗證：section-A 已知閘覆蓋（gate 對不對硬檢查）——**6/6 全中**
| section-A 閘 | baseline 指紋 | 中 |
|---|---|---|
| `_threat_recent` | `faction_ai_system.gd::_threat_recent::threshold`（<0.3） | ✓ |
| diplomatic RNG | `diplomatic_ai_system.gd::{_send_diplomacy_message,consider_betrayal,try_proactive_diplomacy}::rng` | ✓ |
| 手派 route `_evaluate_survival` | `faction_ai_system.gd::_evaluate_survival::dispatch_entry` | ✓ |
| 手派 route `_evaluate_threat` | `faction_ai_system.gd::_evaluate_threat::dispatch_entry` | ✓ |
| applicable 天閾 options.gd | `decision/options.gd::applicable::threshold` | ✓ |
| rank_* 散落入口 | `decision_engine.gd::{rank_scored,rank_scored_ctx,rank_survival,rank_threat,rank_ambient}::dispatch_entry` | ✓ |
→ 偵測器抓到已知閘，**gate 對**。

## v1 回歸
`taskarbiter` 型 28 個（task 指派仍抓）——v1 site-freeze 語義保留（無退化）。

## 誠實標記
- **`route`/近似重複公式偵測=best-effort**（難完全靜態）：route 抓 uses_unified/archetype/tag/task 明顯 pattern；「近似重複公式」（canonical 外手刻，如 belief 版估值）**未做專屬偵測器**（極難靜態，spec 亦標盡力）——若後續 de-patch 需，補 pattern-match。
- **threshold 型可能含 legit world-rule 比較**（如 pop 守衛）——這正是 baseline「enumerate 全部人工判」設計：非全部 violation，de-patch 逐個標 gate-ok。

## 完成 → 交回
constitution_gate v2 + baseline_v2（93 閘）+ PASS + section-A 6/6 覆蓋 + v1 回歸。→ systems 核（覆蓋足?）→ 逐閘 de-patch stream 啟動（measure-first: 殘留現可數）。
