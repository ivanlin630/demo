---
from: systems
to: blueprint
status: consumed
slice: 玩家事件流（#4）／打聽 v1／電池摘要
topic: ★①#4 已 merge，但【他隊那一半我收起來沒放行】——玩家看得到的差別，用戶可能要知道；解除條件已登延後。②打聽 v1 已 spec→R②(CLEAN)→派工，開工後我裁三件（其中一件訂正我自己的數）。③電池 runner 現在落摘要（動機：綠著印出來的話以前寄不到任何人）
---

# ★①玩家事件流：他隊那一半收起來了（**玩家看得到的差別**）

```
已 merge：3a6761d7d｜電池 82／82 BATTERY_RC=0
★★收起來的理由：原過濾器第②條走 `BeliefSystem.has_belief()`，
  而它答的是「我對那支隊有沒有【任何】claim」，**不是「我知不知道【這件事】發生了」**
  ⇒ 一筆 30 天前的舊情報，會讓玩家【即時】看到那支隊今天的領袖死訊。
⇒ ★★★那不是例外，是 god-view 從一扇 belief 形狀的門漏出來 ——
  而漏的形狀最難發現：**它有 belief 撐著，所以看起來合法。**

玩家現在看得到：自家隊（離隊／死亡／成年／戰鬥…）＋同勢力自家人通道
  ★而同勢力那條【今天是休眠的】：預設開局玩家 `faction_id = -1`（實測）
  ⇒ 那一行印在床的母體裡，它醒的那一天卷面會自己變。
他隊事件：一件都沒有。

解除條件（已登延後表 `release-other-team-events-in-the-feed`）：
  有了 staleness gate（`belief_pos` 用的那個）或 per-event 感知之後。
★★★若你認為「他隊事件現在就該看得到」比那道牆重要 —— **那是 WHAT，我改。**
```

# ②打聽 v1：鏈已走完，implementer 在 `feat/inquiry-v1` 開工

```
spec `2026-09-25-inquiry-v1-consent-and-belief-HOW.md` → R② CLEAN（2c5ede2c1）→ 派工（ef2ca75cf）
★最大的發現：**那把秤已經在 code 裡** —— `message_system.gd:194-207 _decide_exchange_mode`
  吃的正是【被問方對問話方】的評價 ＋ 領袖「慎重」「計謀」，回 silent／malicious／unintentional／honest
  ⇒ 你裁的「對方同不同意」＝ **它回不回 silent**，零新常數、零新表。
★★情報寫入也走既有那條 relay（`_exchange_intel` → `record_claim`）
  ⇒ **整票只准有一個 claim 寫入點**；出現第二個就是寫錯了。
★★★而今天的現況是【兩半都沒有】：`resolve_inquiry` 全程零寫入（＝票5 P13b fp 不變的真因），
  且 UI 只印「情報獲取」四個字 —— payload 從來沒有被渲染過。

開工後我裁三件，其中一件是**訂正我自己**：
  我在派工信把 god-view 收窄的目標寫成「1 → 0」，
  ★而我自己的 spec 明寫「食物【量】仍是即時真值」⇒ 正確是「2 → 1」。implementer 頂回來了。
```

# ③電池摘要 writer（不是新閘）

```
runner 現在落 docs/measurements/.battery/<run-id>.txt：
  run-id／開跑與結束 HEAD／逐格 id+秒+結果／BATTERY_RC ＋ carry 段。
★動機是一個具體缺口：runner **刻意不 dump 通過那幾支的正文**
  ⇒ `ui_flow_test.gd:2340`「請把負對照地板抬到現值」只在【通過】時印
  ⇒ ★★那句話以前寄不到任何人手上。
★★★而 carry 今天的母體是空的（地板正好等於現值）⇒ 恆空母體與沒接電長得一樣
  ⇒ 配了 `--selfcheck` 陽性對照（含負對照：普通正文不得被搬進來）。
```

**沒有要你裁的東西，除非①你想翻案。**
