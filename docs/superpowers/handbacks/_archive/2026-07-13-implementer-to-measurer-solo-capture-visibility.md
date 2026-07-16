---
from: implementer
to: measurer
status: consumed
topic: 序① solo capture_decision 可見性交付 — branch feat/reeval-cadence已push,請trace非餓PRIO_DISPATCH隊證cadence生效
---
# Hand Back: 序① solo capture_decision 可見性

branch `feat/reeval-cadence`（已 push，續 T-cad1/2 同 branch）。純觀測零行為變。

## 實作摘要
- `faction_ai_system.gd` `_evaluate_solo` winner-commit 點（`try_set` 成功 + `HandBrainProbe.capture` 後、`return` 前）加 `SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt)`——鏡射 `_decide_unified:1469` 用法。
- 補 solo 路 specimen trace under-count（純 solo 隊決策原缺此 tap → specimen 少算 solo 決策）。
- 純觀測（`is_specimen` gate 內建 early-return，非 specimen 零成本）。

## 我方自驗
- headless **0 新增 SCRIPT ERROR**（3 pre-existing 同 baseline）。
- **determinism byte-identical**（1337×1mo 兩跑 cmp；warring bed 無 specimen → capture_decision early-return → 零 state mutation）。

## 請你（序①隔離驗證，藍圖裁 ①→②）
- **trace 一支非-餓 PRIO_DISPATCH 隊**（生產/駐守/建設類，非 survival-latch）：seed1337 挑一支持續存活、food 足、走常態經濟 task 的隊，設 specimen，跑 3mo。
- **驗 cadence 對常態隊生效**：該隊 `capture_decision` 次數應 **多次**（每 DECISION_CADENCE≈1日 + crisis），非只 1 次 → 證 cadence 重構對 PRIO_DISPATCH-tier 隊有效（隔離 survival-tier 變因）。
- **對照**：非-餓隊也只 1 次 → cadence 對常態隊也沒生效（回 systems 另查）；多次 → cadence 半邊確認有效，續 ②survival-latch 修。

## 註
- 連動風險：無（純觀測，specimen-gated 零 mutation）。
- 此 tap 補上後 solo 隊 specimen trace 才完整（原只 _decide_unified 路有，純 solo 路缺）。
