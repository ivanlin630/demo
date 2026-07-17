---
from: implementer
to: measurer
status: consumed
topic: "[threat-oracle S1.5 交付·行為變小] (a)_power_ratio god-view fix(無belief fallback other.population→self_pop,虛張生效)(b)ctx.perceived_power_ratio 曝(≠threat_react)。branch feat/threat-oracle-s1.5 HEAD fd801ecd off origin/main@e0198666。char RED→GREEN/gate 65 removed=0/headless 同3 baseline。★非 byte-identical:無belief窗口 threat 評估變保守——請中性驗虛張生效+首接觸保守+has-belief路徑不變+seeded delta 合理。"
---
# Hand Back：threat-oracle S1.5 god-view fix + perceived_power_ratio（行為變小）

**branch** `feat/threat-oracle-s1.5`（已 push）**HEAD `fd801ecd`**，off origin/main `e0198666`。

## 實作摘要
- **(a) `threat_assessment.gd::_power_ratio`**：無 belief fallback `int(intel.get("population_est", other.population))` → **`self_team.population`**（無 belief=視對方等強，禁讀 god-view 真 pop→破虛張）。鏡射 `invariants.md:171-173` / diplomatic `_get_pop_est` fallback=self_pop 模式。
- **(b) `decision_context.gd`**：加 `var perceived_power_ratio: float = 0.0` 欄 + gather 時（threat_id≠-1）算 `ThreatAssessment._power_ratio(state, team, threat_target)`。**★≠threat_react**（threat_react=approach+hostility+power blend；此=純 other_power/self_power），供 S2 winnable，禁拿 threat_react 當 proxy（finding2 誤用防）。無 caller 用前=該欄 byte-identical。
- `scripts/debug/threat_oracle_s15_test.gd`（新 char bed）：(a) 無 belief→self_pop + 非 god-view；(b) perceived_power_ratio==直算 + ≠threat_react。

## ★byte-identical? 否——行為變（小，限無-belief 分支）
- **(a) 首接觸敵隊（無 belief claim）那 tick**：`_power_ratio` 從讀真 pop→self_pop→threat_react 微變（首接觸威脅評估變保守/中性）。**非 byte-identical**（預期）。
- **has-belief 路徑不變**（fix 只動 `intel.get(...)` 的 **fallback** 分支；有 population_est claim 時走同路）→ 結構性 byte-identical。
- **(b) 純加 ctx 欄**（無 caller）= byte-identical。

## 自驗
- **char bed RED→GREEN**：baseline (a) ratio=30.0（god-view 洩 other.pop=100）→ fix 後 3.0（self_pop=10，虛張生效）；(b) perceived_power_ratio=3.27==直算,≠threat_react=1.82。全綠。
- **constitution_gate PASS sites=65 removed=0**（threat_assessment 非 decision-file；decision_context 的加欄/賦值非 rng/threshold/route→零新 fingerprint）。
- **full headless**：`=== DONE ===`；殘 3 assertion=pre-existing baseline（同名同行 15529/7075/13979，**無新增無減少**）→ 行為變未回歸測試套件。
- import parse clean。

## 待確認 / 下一站（★measurer 行為驗證，非 byte-identical）
- **虛張/偽裝在無 belief 窗口生效**：隱藏/偽裝隊首接觸 threat 評估不再洩真 pop（視等強）。
- **首接觸 threat 評估變保守**（self_pop 視角）。
- **has-belief 路徑不變**（有 population_est claim → 同 baseline）。
- **seeded delta 合理**：seeded warring 有 belief 路徑 byte-identical、無 belief 路徑行為變——請記 delta 判合理（非大回歸；god-view 移除是 invariants 正朝向）。
- 綠 → to:systems 判 merge（systems merge 時補 `invariants.md:173` 已修名單 +1）。**S2（util winnable 重設計）待 S1.5 merged 後另 dispatch**（winnable 立在乾淨 perceived_power 上）。

## 溯源
dispatch `2026-07-17-systems-to-implementer-threat-oracle-S1.5-godview-fix.md`；threat-oracle R② CLEAN；spec §S1.5；`invariants.md:165-173` 信息域不變量；`threat_assessment.gd:37-45`。
