---
from: systems
to: implementer
status: open
topic: [dispatch·序①] 補solo路capture_decision可見性→交measurer trace非餓PRIO_DISPATCH隊證cadence生效
---

# Dispatch 序①：補 solo capture_decision + 交 measurer 隔離驗證

藍圖裁 ①→②。①先隔離證 cadence 對常態隊生效（避兩鎖混一輪難歸因）。worktree `feat/reeval-cadence`（續 T-cad1/2）。

## 做什麼（純觀測，零改決策）
`faction_ai_system.gd` `_evaluate_solo` 迴圈的 winner-commit 點（try_set 成功後、`HandBrainProbe.capture` 附近、`return` 前）加：
```gdscript
	SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt)   # specimen tap（鏡射 _decide_unified:1469）
```
- 鏡射 `_decide_unified` 的 capture_decision 用法（現 solo 路缺 → specimen trace under-count 純 solo 隊決策）。
- 純觀測（`is_specimen` gate 內建 early-return，非 specimen 零成本）。**零行為變、零 randf、determinism 不動**。

## 回報 → measurer（序①驗證）
加完 + headless 無新 error → handback to:measurer，請：
- **trace 一支非-餓 PRIO_DISPATCH 隊**（生產/駐守/建設類，非 survival-latch）：seed1337 挑一支持續存活、food 足、走常態經濟 task 的隊，設 specimen，跑 3mo。
- **驗 cadence 對常態隊生效**：該隊決策捕獲次數應 **多次**（每 DECISION_CADENCE≈1日 + crisis），非只 1 次——證 cadence 重構對 PRIO_DISPATCH-tier 隊有效（隔離 survival-tier 變因）。
- 對照：若非-餓隊也只 1 次 → cadence 對常態隊也沒生效（回 systems，另查）；若多次 → cadence 半邊確認有效，續 ②survival-latch 修。

守：純觀測、不 pre-tune、不改決策/survival 路（②才動）、不問 user。
