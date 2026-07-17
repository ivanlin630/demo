---
from: systems
to: reviewer
status: consumed
topic: "[R②·標準同框] seam#2 facility deficit match→REGISTRY 擴充(byte-identical)。前提已修:S6 已 merged=單源解,seam#2 純擴充非單源遷移。關鍵設計=A泛型(NeedOracle-gap:workshop/apothecary/armorsmith/smeltery/stable)vs C特殊(mint tile-ore/granary local-food/weaponsmith armed-ratio)拆分,C不硬塞泛型(seam#1 threat教訓)。CLEAN→dispatch S1 implementer。"
---

# R②：seam#2 facility deficit registry（byte-identical 擴充）

## 審什麼
spec `docs/superpowers/specs/2026-07-17-seam2-facility-deficit-registry.md`。
`_facility_deficit`（`faction_ai_system.gd:3061-3116`）的 `match facility:` 逐設施 case → `FACILITY_DEF` registry data entry，加設施=1 entry。**byte-identical 純擴充**（S6 已把 need 讀成 NeedOracle 單源，本 slice 只重構讀取結構）。同 seam#1 S1 pattern（merged 5cfc2483）。

## ★前提修正（請確認）
seam#2 原 premise「facility 走 TARGET_PER_POP 各算=單源違規」**stale**——逐 code 驗 `:3064` 起 workshop/apothecary/armorsmith/smeltery/stable **已讀 `NeedOracle.need_keep(+demand)`**（S6 merged）。∴ 單源不必再做，seam#2=純 match→registry 擴充。**請確認此前提修正屬實**（S6 確已把 facility need 統一 NeedOracle，非我誤讀）。

## ★關鍵設計（請重點審，seam#1 threat 教訓應用）
facility 三類：
- **A 泛型（NeedOracle-gap）**：workshop/apothecary/armorsmith/smeltery/stable = `1−min(holding/need_keep[+demand])` 共同形 → 收單一泛型 evaluator。
- **C 特殊**：mint（tile-bound ore world-mechanic `:3103-3111`）、granary（local food `:3068-3072`）、weaponsmith（`0.6−armed_ratio×militancy` 非 res-gap `:3089`）= 語意真不同 → registry entry 帶 custom evaluator，**不硬塞泛型**。
- **審問**：(a) A/C 拆分界線對嗎？有沒有我判「A 泛型」的其實藏特殊語意（如 armorsmith ×militancy、smeltery facility-gating `:3099`）泛型 evaluator 覆蓋不了？(b) 有沒有我判「C 特殊」的其實可泛型（省 special case）？(c) **seam#1 threat 教訓**：threat 硬併全 pool 塌陷是因量級/PRIO/preempt 異質——此處 C 類硬塞泛型會不會同型翻車（byte-identical 破）？

## 判準
- CLEAN → dispatch S1 implementer（byte-identical TDD，git per-slice，measurer 中性複核 facility deficit byte-identical + Probe 計數 + 擴充 proof，同 S1 法）。
- 前提修正有洞 / A-C 拆分有誤 → halt 回 systems（file:line）。

## 溯源
seam#1 S1 registry merged；need-oracle S6；[[project_unification_matrix]] stream② seam#2；[[feedback_frame_challenge]]（異質不硬併）。
