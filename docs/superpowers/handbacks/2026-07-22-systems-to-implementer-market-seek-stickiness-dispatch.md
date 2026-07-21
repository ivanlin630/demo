---
from: systems
to: implementer
status: open
topic: "[dispatch·market-seek stickiness Gate A·R² CLEAN·★off LOCAL main fa10121d·behavior-sensitive] spec=2026-07-22-market-seek-stickiness-gateA.md。deal-flow Gate A(手不聽腦家族,尋路 task)。根:measure seek 2207→arrive 798(64% divert)。修:faction_ai_system.gd _should_reeval(1877),在 _directive_fresh 之後、cadence(1898)之前加 `if team.current_task==TeamData.TASK_TRADE and team.move_target!=Vector2i(-1,-1) and not in_crisis: (Probe.bump reeval.marketseek_sticky) return false`。★in_crisis 是上方已算的 var(1886),直接用。crisis/stuck/directive/IDLE 上方已 return true=survival/威脅/命令 escape 全保(reviewer 確認威脅走 _evaluate_threat 獨立路不受阻);trade-timeout(817)兜 zombie;resident 擺攤 move_target=-1 不受影響。TDD 4型(在途非crisis→false/在途crisis→落cadence/已抵達move_target=-1→正常/非TASK_TRADE→不受影響)。gate/headless 0new/determinism 2跑byte-identical 無RNG。★measure=arrive%(36%→?)+deal數+無starve回歸(crisis escape驗)+doom-delta seed1337/42+8config,帶§④b樣本Probe.bump_sample。task=systems+reviewer。做完→to:measurer。"
---

# dispatch：market-seek stickiness（deal-flow Gate A，R² CLEAN）

spec：`docs/superpowers/specs/2026-07-22-market-seek-stickiness-gateA.md`。reviewer R² **CLEAN**（全逃逸閥保留：crisis escape / 威脅 _evaluate_threat 獨立路 / trade-timeout / resident 擺攤 / 無 RNG）。deal-flow Gate A（手不聽腦家族，尋路 task）。

## ★★ branch base
- **off LOCAL main `fa10121d`**（禁 origin）。pre-push hook 已裝。

## 修（`faction_ai_system.gd:1877 _should_reeval`）
在 `_directive_fresh` 之後、cadence 檢查（`1898`）之前加：
```gdscript
# ★market-seek 在途 sticky（Gate A）：TASK_TRADE 未抵達（move_target set）+ 非 crisis → 不 cadence-divert
# （機會性重評搶走=64% 到不了市場）。crisis 落下方 cadence（survival escape）；IDLE/stuck/crisis-edge/directive
# 上方已 return true；trade-timeout（817）抓 zombie；resident 擺攤（move_target==(-1,-1)）非在途不受影響。
if team.current_task == TeamData.TASK_TRADE and team.move_target != Vector2i(-1, -1) and not in_crisis:
    if Probe.enabled: Probe.bump("reeval.marketseek_sticky")
    return false
```
- **`in_crisis`** = 上方已算的 var（`1886 var in_crisis: bool = _decision_crisis(...)`），直接用（別重算）。
- 位置：**`_directive_fresh` return true 之後、`current_tick >= decision_eval_next_tick`（cadence）之前**。

## 逃逸閥（reviewer 確認全保）
- crisis（餓/暴跌/糧滑坡）→ `not in_crisis`=false → 落 cadence（/4 快）→ 可 divert 求生（不餓死買路）。
- 威脅走 `_evaluate_threat` 獨立路（TASK_TRADE∈PREEMPTIBLE）→ 不受 sticky 阻。
- IDLE/stuck/crisis-edge/directive 上方 `return true`。
- trade-timeout（817）兜 zombie；市場拆除抵達清 move_target 再 re-eval。
- resident 擺攤 `move_target==(-1,-1)` 非在途 → 不受影響。

## 驗收
- **TDD 4 型**：①在途非 crisis → `_should_reeval`=false ②在途+crisis → 落 cadence（可 re-eval）③已抵達 move_target=-1 → 正常 ④非 TASK_TRADE → 不受影響。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG）。
- **★measure（→measurer，behavior-sensitive，帶 §④b 樣本 `Probe.bump_sample`）**：**arrive%（seek→arrive 36%→?）** + deal 數 + `reeval.marketseek_sticky` fire + **★無 starve 回歸**（crisis escape 驗，別餓死買路隊）+ doom-delta（seed1337/42）+ 8 config sanity。

## 完成判定 = systems + reviewer。做完 → to:measurer。
