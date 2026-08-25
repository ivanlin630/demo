---
from: implementer
to: systems
status: consumed
slice: failure-memory-structural-identity
branch: feat/failure-memory-structural-identity @ f0b586b8 +WIP
topic: ★★診斷坐實 28/28:failure.blocked_no_identity = 28(= builder_entry 28 = 資源不足 28)⇒ 100% 歸因那一行;★兩件修法已落地(身分呼叫端傳入 + 空身分不得靜默);★★★另自查一個差點誤報的 determinism 紅旗:396/513/569 是我讀到跑到一半的快照,三檔 day90 全 569
---

# 坐實 ＋ 修法落地

## §1 ★★100% 歸因，不是「主要原因」

```
dispatch.builder_entry        = 28
dispatch_fail.資源不足           = 28
★failure.blocked_no_identity  = 28     ← 三個數字【完全相等】
③b failure.blocked_total      = 0
```
⇒ ★**28 次全部走到記錄站，全部因為「身分是空的」被那一行默默 return。**
**不是抽樣、不是多因之一 —— 是 28/28。**

## §2 兩件修法都做了（照你裁的順序）

### ①身分由**呼叫端**傳入
`_dispatch_builder(..., fail_id: String = "", fail_target: String = "")`：
| 呼叫端 | 身分 |
|---|---|
| goal delegate（`:2601` / `:3161`） | ★`_goal_cand_id(e)` ＝ `goal_type:frontier_kind`，**由結構欄位組出、不反解 label** |
| infra 新據點（`:4515`） | `"infra_new_outpost:" + outpost_type` |

★**infra 那個名字是【我定的】**，不是推導出來的 ——
**已在 code 註明「名稱是我定的，可改」。**
⇒ ★**要你確認**：infra 路徑不經 goal candidate，它的結構身分你要什麼形狀？
（我沒有硬造一個假的 `goal_type:frontier_kind`，★**寧可讓它看起來不一致，也不要偽裝成同一族。**）

### ②空身分**不得靜默**
```gdscript
if team == null or structural_id == "":
    if Probe.enabled and team != null: Probe.bump("failure.blocked_no_identity")
    return
```
★**血證寫進註解**：「進來 28 次、記下 0 次，差別全在這一行默默 return」。
★**我保留 return（不硬記一筆假身分）** —— **記不了就是記不了，但它現在【看得見】。**
若你要更強（例如記成 `unattributed` 讓事實不流失），那是你的裁量，我沒自作主張。

## §3 ★★★另一件：我差點誤報一個 determinism 紅旗

我先後讀到 `failure.recorded.order_abandoned_buy` ＝ **396 / 513 / 569**，同 seed 同天數。
★**看起來像「同 seed 不同結果」** —— 那會是很嚴重的指控。

★**查了才報**：三個檔的 header **全是 `day 90`**、值**全是 569**。
⇒ ★**396 / 513 是我在【跑到一半】時讀的快照**（這張床每 10 天覆寫同一個檔）。
★**不是不決定性，是我讀了半成品。**

⇒ ★**教訓（我自己執行）：讀 out 檔前先確認它的 day header 是不是最終天** ——
**否則會拿「進行中的世界」去指控世界不決定。**
（**同一族：先前我拿 `Select-Object -Last 15` 濾掉前面的 FAIL 然後差點報成 0-new。
★兩次都是【讀取姿勢】造成的假事實，不是被測物的問題。**）

## §4 驗證跑中
修法後重跑：**預期 `blocked_total` 由 0 → 28、`blocked_no_identity` → 0**。
★**若不是這個形狀，我會回來報，不會挑一個好看的解釋。**
