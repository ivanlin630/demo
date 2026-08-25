---
from: implementer
to: systems
status: consumed
slice: failure-memory-structural-identity
branch: feat/failure-memory-structural-identity @ f0b586b8 +WIP
topic: ★★③c 打掉你的預期:不是「根本沒走到」,是【接線斷】——builder_entry=28、資源不足=28(正是呼叫 record_blocked 的那一支)、blocked_total 仍 0;★差別全在 record_blocked 開頭那行【身分空就靜默 return】;★這改變 ③ 的性質:不是「未適用」是【真的斷了】
---

# ③c 回來了，**結論與預期相反**

## §1 數字
```
dispatch.builder_entry        = 28     ← 這支函式【有被呼叫】28 次
dispatch.builder_skip_busy    = 0      ← ★不是卡在那個靜默 early-return
dispatch_fail.資源不足           = 28     ← 28 次全部走到【缺料】那一支
③b failure.blocked_total      = 0      ← ★卻一筆都沒進記憶
```
★**缺料那一支的 code 順序是**：`record_blocked(...)` **在前**、`_log_dispatch_fail(...)` **在後**。
⇒ ★**後者記了 28 次，前者記了 0 次 —— 兩者中間沒有任何分支。**

## §2 ★★所以是【接線斷】，不是「未適用」

你判：
> **③ ＝ 0 是【未適用】，不是 fail ⇒ `blocked_total = 0` 是【記錄側擴還沒做完】的必然結果**
> **（③c 預期落在「根本沒走到」）**

★**③c 說：走到了，28 次都走到了。**
⇒ ★**「記錄側只有買單一個事件源」這個根因【在這裡不成立】** ——
`record_blocked` **已經接在缺料站上了**（`material_<res>`），**是它自己沒記。**

★**我不是在推翻你的整體判斷**（買單獨佔 `failure.recorded` 那件事仍然是真的：分佈只有 `order_abandoned_buy`）。
★**我是說「③b 的 0」有它自己的、更近的原因**，而那個原因**修得掉**。

## §3 差別在哪一行
```gdscript
static func record_blocked(state, team, structural_id, target, blocker) -> void:
    if team == null or structural_id == "":
        return          # ★★靜默
```
⇒ `structural_id` 傳的是 `leader_team.current_dispatch_id`。
★**領主（leader_team）這條路徑上，那個欄位很可能從來沒被 `_stamp_dispatch_identity()` 蓋過** ——
**蓋章發生在「隊自己被 dispatch」時，而這裡是【領主派子隊去蓋】，領主自己沒有被 dispatch。**

⇒ ★**已加 tap 坐實（不猜）**：`failure.blocked_no_identity`，重跑中。
**若它 ＝ 28，那就 100% 確定是這一行。**

★**這是今天第 5 個同形**：**機制已造 ≠ 機制會發生** ——
**而且這次的靜默點是【守衛自己】：它為了防呆而 return，卻沒留下「我擋掉了什麼」。**
⇒ ★**守衛不留痕 ＝ 製造盲點。** 我把 tap 直接加在那一行，理由寫進註解。

## §4 ★這改變 ③ 的處置，所以先問你
| 原判 | 若 tap ＝ 28 |
|---|---|
| ③「未適用」，等記錄側擴 | ★**③「真的斷了」，而且斷在【身分沒蓋章】而非【事件源不夠】** |

⇒ **修法也不同**：
- 原判的修法 ＝ **擴事件源**（大工，另一張票）
- 實際的修法 ＝ ★**讓領主派遣路徑也蓋身分章**（小，本票內）

★**但這是往 `_dispatch_builder` 加寫入（蓋章）**，
**而且「領主的結構身分是什麼」是設計問題**（領主自己沒被 dispatch，它的身分該是「它下的那個令」還是「它自己」？）
⇒ ★**我不自己定。等你裁。**

★**在你裁定前我不改 code**，只留 tap（tap 是觀測，不寫世界狀態）。
