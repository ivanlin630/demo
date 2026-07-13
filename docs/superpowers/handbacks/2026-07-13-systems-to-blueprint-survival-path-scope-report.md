---
from: systems
to: blueprint
status: consumed
topic: [範圍回報] panic釋放=小(FLEE威脅gate本身含,螺旋決策層斷);person-system stress decay=大另記arc;survival-path slice=①latch重選+②FLEE威脅gate(含panic);cadence已merge
---

# survival-path slice 範圍回報（panic 規模評估）

## panic 釋放規模 = 小（納入 #2，非另開）
評估：death spiral 的 panic 部分**不需 person-system 改動即斷**——
- **#2 FLEE 威脅 gate 本身就處理 panic**：`threat_pressure` 改「有威脅才 panic 放大」（`threat present ? threat_signal + panic×k : ~0`）。→ **安全時 FLEE→~0 不管 panic 多高**→安全隊不再被 panic 拖進 FLEE→螺旋**在決策層斷**（Team7:食足→無 threat→FLEE~0→不 spurious FLEE→續生產→不餓死）。
- 不需碰 person-system stress。這是小幅、在 `terms.gd` threat_pressure eval 內。

## person-system stress decay = 大 → 另記獨立 arc（不扛本 slice）
- 成員 stress 本身「累積不釋放」是 person-system 層（stress 影響 reaction/morale/panic 多處,非只 FLEE）。加 stress decay/上限=跨系統改動,影響 FLEE 外既有機制。
- **但本 slice 不需它**：#2 已在決策層斷 FLEE 螺旋（安全→panic 不驅 FLEE）。stress 累積仍在,但不再經 FLEE 拖死隊。
- → 記 backlog 獨立 arc（`docs/known_issues` + memory），與 person 情緒系統一起評估,非本 slice 順手扛（守你 slice 邊界告誡）。

## ∴ survival-path slice 最終範圍（請確認）
1. **survival-latch 重選**：`_evaluate_survival` 已餓+cadence 到→重跑 `_trigger_survival`(rank_survival 重選,換買糧/掠奪/併入)，非 early-return。
2. **FLEE 威脅 gate（含 in-slice panic 處理）**：`threat_pressure` 撤 T1 0.6 flat floor→隨威脅存在(無威脅→~0,panic 僅威脅時放大)。
- **不含**：person-system stress decay（另記 arc）。

## 附：cadence 已 merge（推進）
T-cad1/2 + solo tap 已 merge main（`36150c6` 後新 merge），融合閘綠（constitution PASS/headless 3 pre-existing/multi ok）。survival-path slice 建於此。①cadence 對常態隊生效已驗。

## 判斷請求
確認 slice 範圍=①+②（panic 小納 #2、stress decay 另記 arc）?確認後我出 survival-path spec→R②(審三修互擾+determinism)→dispatch→終驗(餓隊換策略+食足隊不 spurious FLEE)。
