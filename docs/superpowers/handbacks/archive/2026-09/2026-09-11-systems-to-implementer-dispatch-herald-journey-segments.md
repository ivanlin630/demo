---
from: systems
to: implementer
status: consumed
slice: 信使旅程切段 ｜ ★DISPATCH（blueprint 裁：sim 線第一序）
topic: ★spec：`docs/superpowers/specs/2026-09-11-herald-journey-segments-HOW.md`｜★★★**「門鈴」格我已坐實到行號**：送達的唯一入口是 **pairwise 相遇**（`interaction_system.gd:390-393` ＋ `:421-425`，★全庫只有 4 個呼叫點）⇒ **抵達目標格 ≠ 送達，要與那支目標隊本身相遇**｜★★而由此生出一個**我不敢自己下結論的負斷言**：**跨派系且 `task_reason != "envoy_proposal"` 的信使，可能沒有任何送達分支** —— ★**別拿我的 grep 當結論，用逐筆資料證實或推翻它**
---

# ① 順序（★手上那張先收）

```
①**先收完**「優先序隨需求」：**逃跑 +39 的下游** ＋ **幀數 321→518 歸因**
②**再**做這張。★而 blueprint 已裁它是 **sim 線第一序**，所以別再排第三件事進來。
```

# ② 這張票的形狀（★一句話）

```
**只量，不修** —— 產出是**那 44 趟死在哪裡**，不是一個更好看的百分比。
```

# ③ ★★★我幫你先做掉的那一段（★而它同時是一個要你打的靶）

```
`interaction_system.gd:385`   if same_faction:
                 :390-393       TASK_HERALD + order_target_id 相符 → `_deliver_order`
                 :421-425     TASK_HERALD + reason=="envoy_proposal" + 相符 → `_deliver_envoy_proposal`
★`_deliver_order`／`_deliver_envoy_proposal` 的呼叫點**全庫共 4 個，全在上面**。
⇒ ★★**推論（待驗）**：同派系走前者、跨派系只有 envoy 提案走後者
  ⇒ **跨派系的非 envoy 信使沒有第三條路**。
⇒ ★★★**這是負斷言，而我只讀了 code** —— 我們這兩天已經被「讀出來的機制」打過兩次臉
  （我指錯分支、你撤回「覓食從不結束」）⇒ **用逐筆資料判它**，別繼承我的話。
```

# ④ 兩個一定要單獨成格的數

```
①**抵達了但沒相遇**幾次 ⇒ ★求居案剛演過「**到了 4 次、領主見到 0 次**」——同族要一眼看得出來
②**跨派系非 envoy 的信使**有幾趟 ⇒ ★★若它們的送達恆為 0 ⇒ **結構上送不到**
  ⇒ ★★★那不是「效率低」，那是**一整類訊息從來沒有出口**。
```
