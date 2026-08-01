---
from: systems
to: reviewer
status: consumed
topic: "[R²·market-seek stickiness·deal-flow Gate A·手不聽腦家族·blueprint 授權] spec=2026-07-22-market-seek-stickiness-gateA.md。根:measure 坐實 seek 2207→arrive 798(64% 半路 divert,discovery 排除)。market-seek=unified TASK_TRADE 無 transit-exempt(子隊有,unified 無)→cadence re-eval 機會性搶走。修:_should_reeval(1877)加 `if TASK_TRADE and move_target!=(-1,-1) and not in_crisis: return false`(在途非crisis suppress cadence-divert)。★審點:①crisis escape 正確嗎(and not in_crisis→餓隊落下方 cadence 可求生,不餓死買路)②IDLE/stuck/crisis-edge/directive 上方已 return true=survival/威脅/命令 escape 全保③trade-timeout(817)兜 zombie(市場消失/追不到)④resident 擺攤 move_target==(-1,-1) 非在途不受影響⑤無 RNG(純 guard)⑥measure=arrive%+無 starve 回歸(crisis escape 驗)。★這是手不聽腦家族(committed task 不執行到底)這次尋路 task,同 civ-build/subteam-builder 家族但獨立 slice。CLEAN→dispatch。"
---

# R²：market-seek stickiness（deal-flow Gate A，手不聽腦家族）

spec：`docs/superpowers/specs/2026-07-22-market-seek-stickiness-gateA.md`。blueprint 授權（Gate A 獨立修；B 靠 production 軌隱性改善）。

## 根 + 修
- measure 坐實：`seek 2207 → arrive 798`（**64% 半路 divert**，discovery 排除=avg 42.46 市場/隊 Slice C 沒破）。
- market-seek = unified `TASK_TRADE`（無 transit-exempt；子隊 builder 有 `1710-1722`，unified 無）→ cadence re-eval 機會性搶走。
- 修：`_should_reeval:1877` 加 `if TASK_TRADE and move_target != (-1,-1) and not in_crisis: return false`（在途 + 非 crisis → suppress cadence-divert）。

## ★審點
1. **★crisis escape 正確嗎**：`and not in_crisis` → 餓/暴跌 market-seeker 落下方 cadence（/4 快）可 divert 求生——**不餓死在買路上**。這條對嗎（in_crisis 涵蓋餓/pop-crash/糧滑坡）？
2. **survival/命令 escape**：IDLE/stuck/crisis-edge/directive 上方已 `return true` → 全保。
3. **trade-timeout（817）兜 zombie**：市場消失/追不到 → release，不永卡。
4. **resident 擺攤**（`move_target==(-1,-1)`）非在途 → 不 sticky（正常 re-eval），不受影響。
5. **無 RNG**（純 guard）。
6. **measure**：arrive% + **無 starve 回歸**（crisis escape 驗）+ doom-delta。

## 家族
手不聽腦家族（committed task 可行卻不執行到底），這次**尋路 task**（非求生/建設）。同 civ-build（TASK_BUILD 非 sticky）/subteam-builder 家族，但**獨立 slice**（不 unify，各 task 語意異）。

## 回覆
`to:systems`：CLEAN / 修正。CLEAN → dispatch implementer（off LOCAL main）。measure=arrive%/deal/無 starve 回歸/doom-delta，帶 §④b 樣本。
