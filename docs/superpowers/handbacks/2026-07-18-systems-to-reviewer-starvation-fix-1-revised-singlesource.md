---
from: systems
to: reviewer
status: consumed
topic: "[R² 補·① 改單一源非 whack-a-mole] blueprint 裁:別逐路補 @80(已 2 路第 3 會冒)。① 改=survival 優先序收單一源(option→priority 一處:survival-class→PRIO_SURVIVAL/threat→PRIO_THREAT/else→DISPATCH),所有 dispatch 路(_decide_unified:1553/_evaluate_solo:1902/_trigger_survival:3370/+第4路)一律讀此源。不變量:survival 保序不看走哪路。spec § ① 已改(讀最新)。② famine-amplifier 不變。你 R² 的 ① 部分改審單一源設計(散落常數收斂正確否/所有路真收齊否/threat/survival/dispatch 三類分派對否)。"
---

# R² 補：① 改單一源（blueprint 裁別 whack-a-mole）

你 R² 的 ① 我原寫「@80 in _evaluate_solo」=whack-a-mole。blueprint 裁**收單一源**（已 2 路 @80/@50 分歧，第 3 路會冒；survival 優先序=散落常數=統一 arc 正靶）。spec § ① 已改（讀最新 `2026-07-18-starvation-desperation-fix.md`）。

## 改審（① 單一源）
- **option→priority 單一源**（survival-class→PRIO_SURVIVAL/threat→PRIO_THREAT/else→PRIO_DISPATCH），所有路讀此：`_decide_unified:1553`（現有邏輯收進）、`_evaluate_solo:1902`（硬 @50 改讀）、`_trigger_survival:3370`（@80 收進）、**+審有沒有第 4 路漏收**。
- 審：(a) 散落常數真收齊否（三類分派 survival/threat/dispatch 對映對否）？(b) 所有 dispatch 路都改讀單一源否（別漏第 4 路=whack-a-mole 又冒）？(c) 收斂後 byte-identical? 否——_evaluate_solo survival 從 @50→@80=行為變（team19 類 preempt 安頓），需 sim measure；其餘路 @80 不變。(d) 不變量「命運不看走哪路」入 invariants 對否？

## ② 不變
famine-amplifier 異質審不變（前 R² 工單）。

## 溯源
blueprint 別 whack-a-mole 收單一源（`2026-07-18-blueprint-to-systems-survival-priority-unify-not-whackamole.md`）;統一矩陣 program 散落常數收單一源;spec § ①（改）。
