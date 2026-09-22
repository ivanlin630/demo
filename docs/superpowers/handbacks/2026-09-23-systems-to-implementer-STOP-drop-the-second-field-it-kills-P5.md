---
from: systems
to: implementer
status: open
topic: ★★★spec 改了一個【會影響你現在正在寫的 code】的地方：**只加一個欄位 `pass_next_tick`，不要加 `pass_last_tick`**——後者會進指紋，當場打死 P5 那個等價證明｜★間距直方圖的「上次是哪顆 tick」改放 Probe 那一層｜★★這是第三條 backlog 回訪條件到期抓出來的
---

# ★★★一、動手改的那一行：欄位只加一個

我先前寫給你的是兩個欄位。**其中一個要拿掉。**

```gdscript
# scripts/data/team_data.gd
var pass_next_tick: int = 0     # ★只加這一個
# var pass_last_tick: int = 0   ← ★★★不要加（理由在下面，不是風格問題）
```

# 二、為什麼：`_last_tick` 會進指紋，而 `_next_tick` 不會

```
fp_coverage.gd:25   CADENCE_SUFFIXES = ["_eval_next_tick", "_next_tick", "_check_tick"]
分類器（fp_coverage.gd derive()）：
  _is_cadence(n) 命中        ⇒ cadence 桶 ⇒ ★不進 in_ruler ⇒ fp 看不到
  否則 sim 原始碼含 "."+n    ⇒ in_ruler   ⇒ ★★進 fp
state_fingerprint.gd:380  _derived_line() 只吐 in_ruler 那一組

⇒ `pass_next_tick` 以 `_next_tick` 結尾 ⇒ 自動歸 cadence ⇒ 尺外 ✅
⇒ `pass_last_tick` 以 `_last_tick` 結尾 ⇒ ★不在那三個字尾裡 ⇒ 會被讀到 ⇒ 進 fp ❌
```

★★★**後果**：樁關掉（`pass_stagger_enabled=false`）時，fp 也會與世代 7 不同 ——
因為多了一個欄位。⇒ **§4e 那個「把『我重構壞了』跟『錯開改變了世界』拆成兩問」的
等價證明當場失效**，而它是這張票最便宜的真相。

★**世界本身不需要那個欄位**：`CadenceStagger.next_tick(cur, cur, …)` 的 `last_eval_tick`
傳的就是 `cur`，排程不靠持久化的 last。
⇒ **間距直方圖（`pass.gap.%04d.%d`）要的「上次是哪顆 tick」放在 Probe 那一層**
（`Probe.enabled` 之下的一個 `{team_id: tick}`），不要放在 `TeamData` 上。

★★既有的 `solo_think_last_tick` 就是這個形狀，**而它已經在 fp 裡了** ——
那是既有的疣，不是這張票要修的，但**不要再多一顆**。

# ★★三、這是怎麼被抓到的（值得你知道，因為機制跟你我都有關）

`known_issues` 有一條「fp 的子層級盲區第一次有數字」，回訪條件逐字是
**「下一次有人拿 fp 當單腿證據時」**。我在 spec §4e 拿 fp 當等價證明 ⇒ **它到期**。

那一條規定：fp-identical 的宣稱一律要寫成「**fp 覆蓋範圍內無變化**」，
並**附一句「本次改動有沒有碰到排除清單裡的欄位」**。

★★★**我是去寫那一句的時候才發現寫不出來的** —— 一寫就得去查分類器，
一查就看到 `_last_tick` 不在那三個字尾裡。

⇒ **這一條 backlog 的價值不在提醒我措辭降級，在於它逼我去寫一句寫不出來的話。**

# 四、順帶：P5 的強度我也降級寫清楚了

```
TeamData    尺內 30 欄 ／ ★沒看到被讀 97 欄
HexTileData ★排除 34 欄，含 apothecary_level／mint_level 這種會影響產出的設施等級
⇒ P5 證明的是「fp 看得到的那部分沒變」，★它仍然是單腿
⇒ 另一條腿是 P7（吞吐 ±5%）與 P3（每隊次數與間距）——三格一起看才是等價
```

★本票**沒有**碰到排除清單裡的欄位：唯一新增的持久欄是 `pass_next_tick`（本來就在尺外），
其餘改的是**呼叫時機與批次**，不改任何欄位的值語意。

# 五、spec 已更新（`§4a`／`§4a-1`／`§4e`），你重抓一次

★**如果你已經把 `pass_last_tick` 寫進去了**：拿掉它比留著便宜得多 ——
留著的代價是 P5 那一格**永遠紅**，而那一格紅的時候長得像「錯開改變了世界」。
