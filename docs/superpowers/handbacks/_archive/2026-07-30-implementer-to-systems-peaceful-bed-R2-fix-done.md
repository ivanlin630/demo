---
from: implementer
to: systems
status: consumed
topic: "[done·R² 必補①·static-clear·1 行] feat/peaceful-economy-bed 4b3506c4。_print_team_stories 開頭補 FactionAISystem._a2b_remote_tribute_payers.clear()(對齊 WarringHarness.run:119,雙 run 防跨 run 污染)。驗:liveness ALL PASS + bed 6mo exit0，4 問數不變(construct.start=14/complete_upgrade_facility=6/order_placed=1833/foodflow.update=4594)——static-clear 不改數,保機制乾淨(非巧合)。→measurer 可落地。"
branch: feat/peaceful-economy-bed
commit: 4b3506c4
base: 613d763d (local main HEAD)
---

# done：R² 必補①（static-clear，1 行）

照補。`peaceful_economy_bed.gd:_print_team_stories` 開頭補：
```gdscript
FactionAISystem._a2b_remote_tribute_payers.clear()   # ★R²:對齊 WarringHarness.run:119(A2b 貢賦 ledger 每 run 重置)——雙 run 防跨 run 殘留污染
```
對齊 `WarringHarness.run:119`。bed 第一次 run 走 harness（已 clear），第二次 inline story-run 未清此 static → 跨 run 殘留污染風險（`interaction_system:607-609` 真讀此 static 當貢賦閘）。此 config 巧合沒 fire ≠ 機制保證乾淨（systems:別讓巧合頂替=Step0 僥倖心態）。1 行 clear 保雙 run 對齊。

## 驗
- **liveness ALL PASS**（fixture LIVE）。
- **bed 6mo exit0**，4 問數**不變**：construct.start=14 / complete_build=0 / complete_upgrade_facility=6 / order_placed=1833 / order_fulfilled=0 / foodflow.update=4594 / persist.hold=14 → static-clear 不改數（本 config 本就沒 fire A2b 貢賦），保機制乾淨非巧合。
- 零 sim 改（bed debug 內清 static，非 sim 行為）；零 RNG（@observe-pure）。

## 待
systems R² 收（1 行照補）→ **measurer 落地**（跑 → 產權威 4 問數 → `docs/measurements/` 標 exact path）→ QA 故事稽核 → blueprint 裁分支。
