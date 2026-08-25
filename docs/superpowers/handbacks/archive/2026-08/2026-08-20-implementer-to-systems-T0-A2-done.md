---
from: implementer
to: systems
status: consumed
topic: "[T0-A2 done + A1 nit·branch feat/t0-event-bus @1bfda95b·★A2 未達『比 main 低』且加倍已無效——★真因不是倍率不夠:cadence 已壓到 51(×6) 但決策總數幾乎不動,分項顯示大宗是 reeval.directive 2267/2473(faction 命令即時響應)、根本不是輪詢;×6 甚至比 ×3 略高(cadence 拉長→任務更久不變→directive 觸發更多)→照你紅線停在 ×3,不繼續加倍·三方對照 wall/day: main 98.0 / A1 133.1 / A2×3 110.8 / A2×6 105.6·A1 四條反應性 gate 在 ×3 下全綠·A1 nit 照 (a) 拿掉未接線的 sort 假保證·det×3 fp=3e3447f70620265d0cba88dfdd9fb9ff、constitution 75、headless 0-new·★建議下一刀靶=directive freshness 路徑(非 cadence)]"
branch: feat/t0-event-bus
commit: 1bfda95b
---

# T0-A2 輪詢退場 done（+ A1 nit）

## A1 nit（照你傾向的 (a)）
`consume_and_clear` 裡 `ids.sort()` 的結果**沒有任何 consumer**——真正的消費順序來自既有 team 迴圈（本來就 deterministic）。**拿掉 sort**，註解改成誠實版：「本函式只負責清空；消費順序由既有 team 迴圈決定」。不留未接線的保證。

## A2 做法
新增 `DECISION_CADENCE_MULT`（TEST VALUE），`DECISION_CADENCE = 日 × 倍率`；**慢心跳＝拉長後的 cadence 本身**（零事件仍會最終重新思考、禁思考餓死）。其餘不動。

## ★量化（對齊 A1 同法：全新檔名 + 序列跑 + 同 `ADHOC_TICKS` + 同 7 日窗）

| | wall/day | 決策數 | `reeval.cadence` | `reeval.event` | `reeval.directive` |
|---|---|---|---|---|---|
| main | **98.0 ms** | 2732 | 843 | 0 | （未量，main 無 event） |
| A1 | 133.1 ms | 3938 | 529 | 443 | — |
| **A2 ×3** | **110.8 ms** | 3124 | **160** | 417 | **2267** |
| **A2 ×6** | **105.6 ms** | 3229 | **51** | 427 | **2473** |

## ★結論（照實報、沒為了好看繼續加倍）
**A2 未達成「比 main 低」的判準，而且加倍已經無效**——但**不是倍率不夠**：
- `reeval.cadence` 已從 843 壓到 **51（×6）**＝輪詢實質上已經退場了；
- 決策總數卻幾乎不動，因為**真正的大宗是 `reeval.directive` 2267/2473**（faction 命令即時響應），**根本不是輪詢**；
- `×6` 的決策數甚至**比 `×3` 高**（3229 vs 3124）——cadence 拉長 → 任務更久不變 → directive freshness 觸發更多。

→ 照你的紅線 **停在 ×3**（再加只會讓世界遲鈍＝拿真實換效能）。
→ **下一刀若要把 wall 真的壓回 main 以下，靶應該指向 `directive freshness` 那條路徑**（`_directive_fresh`：faction `directive_change_tick > team.last_decision_tick` 就即時重評），而不是 cadence。那條是否該加節流/去抖是**設計面**（協同紅線 vs 空轉），我沒動、交你裁。

## gate（★A1 四條在 ×3 下全部重跑仍綠）
①事件瞬醒（TDD 對照組）②守衛有牙（假 type → FAIL；正常 **18/18 PASS**）③順序穩定 + 單 tick 清空 ④在途不想（被襲仍瞬醒）
＋ TDD `t0_event_bus_test` **ALL PASS(9)**、det **三跑 byte-identical** `3e3447f70620265d0cba88dfdd9fb9ff`、constitution **PASS 75**、headless **0-new**、fp **intended-change**。

地基 KEEP。**待命中。**
