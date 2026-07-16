---
from: systems
to: implementer
status: open
topic: "[DISPATCH·stream①基礎·constitution_gate v2] 建強化 constitution_gate 抓全閘型(現只抓TaskArbiter task指派)=零殘留+真統一證明機制。偵測器:值閘(RNG-in-decision randf/randi/override early-return在_pick_/_decide_/_evaluate_/applicable/硬門檻具名常數比較)+控制流閘(手派return-gate路由如if uses_unified return/散落入口rank_*/近似重複公式)。baseline-freeze:enumerate全閘→baseline(違憲標# 待de-patch)→current⊆baseline added=FAIL removed=de-patch進度。★驗證:baseline須含section-A已知閘(_threat_recent/diplomatic RNG/手派route等)=偵測器對。measure-first:先建gate讓殘留可數再殲滅。worktree feat/constitution-gate-strengthen@origin/main。禁AskUserQuestion"
---

# [DISPATCH] constitution_gate v2（stream ① 基礎：零殘留+真統一證明機制）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

框架驗收=真統一+零殘留+可擴充三位一體（用戶硬驗收）。**stream ① 先建強化 gate 讓殘留可數（measure-first）再殲滅。** 你建 `constitution_gate` v2。

## 工作區
worktree `.worktrees/constitution-gate-strengthen`，branch `feat/constitution-gate-strengthen`（origin/main `c07c2e8c`）。改 `scripts/debug/constitution_gate.gd`（現只掃 `TaskArbiter.(transition|try_set)`）+ 產 v2 baseline。

## 建什麼：constitution_gate v2 抓全閘型
現只抓 task 指派。**加偵測器抓（掃 `scripts/simulation`，指紋 `<relpath>::<func>::<type>`）**：
### 值閘
- **RNG-in-decision**：`randf|randi|randomize` 出現在 decision 路徑檔（`faction_ai_system`/`decision/*`/`diplomatic*`），排除明允世界機制點（如 combat 擲骰=世界物理，用 allowlist 或 `# gate-ok:` 註解豁免）。
- **override early-return**：decision 函式（`_pick_*`/`_decide_*`/`_evaluate_*`/`applicable`/`_facility_*`）裡引擎 rank/argmax **前**的 early `return`（bypass 秤）。
- **硬門檻**：decision 函式裡具名常數門檻比較（`< DESPERATION_DAYS`/`< X`/`> MARGIN` 等）。
### 控制流閘（★真統一破口）
- **手派 return-gate 路由**：`if uses_unified: return` / 按隊型/tag/context 手動選 decision 路徑（如 `_evaluate_survival`/`_evaluate_threat` 的路由）。
- **散落入口**：同決策多入口（`rank_survival`/`rank_threat`/`rank_scored`/`rank_ambient` 多 dispatch 點）。
- **近似重複公式**：canonical 外手刻版（如估值 belief 版 `faction_ai:2092-2096`）——這條**盡力偵測**（難完全靜態，抓明顯重複 pattern）。

## baseline-freeze（歧義由 de-patch 進度處理，非 auto-classify）
1. **enumerate 全閘型 → 產 `constitution_baseline_v2.txt`**（每個閘指紋一行，違憲的標 `# 待de-patch`；world-rule 合法的標 `# gate-ok:<理由>`）。
2. **契約**：current ⊆ baseline。added=FAIL（新閘）。removed=PASS（de-patch 進度，印出）。
3. **綠 = baseline 全 `# gate-ok` 或空**（=零殘留：剩的全是 marked-legit world-rule）。
4. **別 auto-classify world-rule vs behavior-gate**（做不到）——enumerate 全部，legit/violation 標記由後續 de-patch 逐個人工判。

## ★驗證（gate 對不對的硬檢查）
產出的 baseline **須含 section-A 已知閘**（`_threat_recent` faction_ai:3125 / diplomatic RNG `:124` / 手派 route `_evaluate_survival:3187`/`_evaluate_threat:396` / applicable 天閾 options.gd:93+ / establish is_military :3285 …）。**若偵測器漏抓已知閘 → 偵測器不夠,補**。handback 附「baseline 抓到幾個閘 + 是否涵蓋 section-A 清單」。

## 完成 → 交回
constitution_gate v2 + baseline_v2（enumerate 全閘）+ 跑一次（印 sites 數）→ handback topic 含 `[DONE]` `to:systems`（附 baseline 閘數 + section-A 覆蓋核對 + 現行 gate 回歸[舊 task 指派仍抓]）→ systems 核（覆蓋 section-A?）→ 逐閘 de-patch stream 啟動。
