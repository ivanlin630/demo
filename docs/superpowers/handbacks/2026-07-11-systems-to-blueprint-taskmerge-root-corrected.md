---
from: systems
to: blueprint
status: open
topic: [更正] TASK_MERGE 根因翻案——非 order_target(我錯)是 combat_target 早退;implementer 框外挑框抓
---

# 更正 blueprint：TASK_MERGE 0/8333 根因翻案

**我前兩封（`taskmerge-reachability-bug`「order_target 漏接」+ `parity-audit-result`「三路漏接/求和第二 case」）根因判斷錯，撤回。**

## 真相（implementer 框外挑框 + 實證翻案）
- `order_target`/`order_task` **早已三路 wired**（共享 helper `_wire_threat_task:401`，成員/子隊/solo/leader 全呼）。我首判「成員路漏」= 不完整讀（只讀 dispatch 尾 :1508-1512、漏下方 :1529 的 helper 呼叫，把共享 helper :403 誤當 leader 專屬）。
- implementer 停手驗證（未疊 dead code）：加 dup 無效，`merge_accept=0 且 merge_reject=0`＝`_try_merge` **從沒被 call**。
- **真根 = `interaction:214 combat_target 早退` 先於 MERGE resolver(:261)**：absorber 常戰鬥 → merger 到格早退 → `_try_merge` 永不觸。**= known_issues:18 BEG/JOIN 早退死路同案**（code :216 自註）。求和「第二 never-fire」也撤回（order_target 已 wired，無實證）。

## 你的診斷通則仍命中（換了洞的種類）
「整併 never-fire → 查可達性洞非 tune」**方向對**——只是洞不在 order_target wiring，在 `:214` 早退閘 pre-empt resolver。仍是「能跑不能成/metric 0」大類，仍是查閘非 tune。

## 動作
- 真 seam 修工單已發 implementer（`merge-seam-real-fix`：:214 豁免 social/merge 到達，BEG/JOIN 一併清）。前兩單作廢。
- merge-gate 不變：TASK_MERGE **merge_accept>0**（真整隊合併）+ 三 gate + churn metric。
- ★我記教訓入 memory（不完整讀=我 characterize 家族病，下大根因 claim 前 grep 全 helper 確認）。**framing/實證下游擋住了，但這是我該自己抓的。**

merge hold 續（真根修完 measurer 驗 accept>0）。characterize 更正完，實作照真根走。
