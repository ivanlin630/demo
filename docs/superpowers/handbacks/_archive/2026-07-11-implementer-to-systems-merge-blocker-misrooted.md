---
from: implementer
to: systems
status: consumed
topic: [框外挑框] TASK_MERGE 0/8333 根因非 order_target——已 wired；真根=interaction combat_target 早退 pre-empt _try_merge
---

# 停手回報：order_target 修（+parity 擴大）misrooted，未動工擴大修

兩張工單（`merge-reachability` order_target 單點 + `dispatch-parity-fix` 三路擴大）診斷 = `_decide_unified` 漏接 order_target → TASK_MERGE 0/8333。**驗證後：此前提為假**。停手回報而非疊 dead code（[[feedback_no_patch_on_settled_architecture]]/補丁閘優先查）。

## 靜態證：order_target 早已 wired（三路全接，非全漏）
`_wire_threat_task`(`faction_ai:403-406`) 無條件 `if td.has("order_target"): team.order_target_id=...` + `order_task`。**三 dispatch 路全呼它**：
- 成員 `_decide_unified` **:1537**（整併 dispatch :1497 後、return :1541 前，無 early-return 跳過）。
- 子隊 :1723、solo :1797。
∴ 工單指的「成員/子隊/solo 三路全漏 order_target」**與 code 矛盾**——整併 order_target 一直有接。

## 實證：加了也沒用（root 不在 order_target）
我先照單點工單加成員 order_target 直寫（與 :1537 重複），跑 seed 1337 3mo：
- `merge.consolidate_dispatch=53`、**`accept.merge_accept=0` 且 `accept.merge_reject=0`**、`join_accept=1`/`consol.accept_n=1`。
- `merge_accept=0` **且** `merge_reject=0` = `_absorber_accepts`/`_try_merge` **從未被呼叫**（非「呼了被拒」）→ TASK_MERGE 隊**從沒到達 absorber 接觸點**。order_target 有沒有接都一樣。
- ∴ 已 revert 該 dup（worktree 回 @477aa7c 乾淨），未動工 parity 擴大。

## 真根（結構，systems seam）
`interaction_system.gd:215-221`：`if a.combat_target != -1 or b.combat_target != -1: return` **早退**，位於 `_try_merge`(:261，same_faction 塊內) **之前**。code 自己註解 :216 已點名同型死路：「197 早退先於 247 BEG resolver。BEG/JOIN 恆設 combat_target → 恆走此路 → resolver 死路」（:219 已有 `join.arrived_no_handler` 探針）。
- absorber = 強隊常在戰鬥（combat_target!=-1）→ merger 到格 → :221 早退 → `_try_merge`(:261) 永不觸 → 0/8333。
- **JOIN 部分倖存**（join_accept=1）因 JOIN resolver(:237) 位置略前，但仍受同閘壓制；MERGE(:261) 更後 = 全滅。

## 建議（systems 裁，de-patch 非疊補丁）
把 social/merge resolver（JOIN :237 / MERGE :261）**移到 combat_target 早退(:221)之前**，或早退對 TASK_MERGE/TASK_JOIN 開例外（mirror 你們對 BEG/JOIN 死路的既有認知）。=結構 seam 修，屬 systems owner。**次要**：`interaction:216` 註解暗示這是已知 backlog，可能有既定修法。

## 現況
- worktree @477aa7c 乾淨（S-A term/餵養/accept-util/cadence 全在、驗綠）。order_target parity 擴大**未做**（無效）。
- 待你出**真 seam 修工單**（combat_target 早退 de-patch）→ 我實作 → measurer 驗 merge_accept>0。
- 附帶：`dispatch-parity-fix` 提的「求和 order_target/order_task 非-leader 漏」同樣**已 wired**（:1537/:1723/:1797），該工單一併作廢；若求和真有 never-fire 症狀請給獨立實證（探針數字），別從 order_target 推。

框外挑框：連兩張工單同一 misrooted 前提（order_target），建議下個 seam 修先給**實證漏接點**（該路無 _wire_threat_task 呼叫的 file:line）再開工。
