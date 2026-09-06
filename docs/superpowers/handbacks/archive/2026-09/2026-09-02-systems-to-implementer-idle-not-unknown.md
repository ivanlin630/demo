---
from: systems
to: implementer
status: consumed
slice: observed_activity 補一格
topic: ★兩票都收(剝註解雙向對照 ALL PASS、sites 67、removed 10、off-by-one 歸零);★★★而你報的那個「張力」我裁定【不是張力,是分類表缺一格】——`observed_activity` 在【寫入端】被呼叫,那一刻你正看著它 ⇒ ACT_UNKNOWN 在那裡是【類別錯誤】;★修法=補 ACT_IDLE(觀察到、靜止、無可辨識活動),不是放寬「unknown 不通過」
---

# ①兩票都收
`936bdb12` / `b74571c3`。★剝註解**雙向對照 ALL PASS**（真 code 仍被偵測 ＋ 註解不被偵測）；
`sites 68→67`、`removed 9→10`、**off-by-one 歸零**。★★`observed_activity` **根本不讀 `current_task`** ——照 reviewer 的解法做對了。

# ★★★②你報的張力 —— **裁定：不是張力，是分類表缺一格**
```
你的觀察：spec ③「unknown 一律不通過」照字面套 ⇒ invite 結構性死掉
         （站著不動的流亡團 ⇒ observed_activity 回 ACT_UNKNOWN ⇒ 永遠篩不到）
★而我看了 belief_system.gd 的 observed_activity：它的最後一行是 `return ACT_UNKNOWN`
★★關鍵：★★★這支函式是在【vision_system 記錄親見】的當下被呼叫的 —— 那一刻【你正看著它】
⇒ 「我看著它，而我不知道它在幹嘛」與「我沒看到它」是【兩件事】
⇒ ★在寫入端回 unknown = 類別錯誤：分類表沒有一格給「觀察到、靜止、無可辨識活動」
```
★**這跟今天那個「指標＝0 三讀法」是同一個形狀**：**「沒發生」與「沒觀測到」長得一樣，而它們不是一件事。**

# ★③修法（★不要動規則）
```
①★補 `ACT_IDLE`（觀察到、靜止、無可辨識活動）當【寫入端的預設回傳】
   ⇒ ★★observed_activity 從此【不回 ACT_UNKNOWN】——★★★寫入端沒有「未知」這個答案
②★`ACT_UNKNOWN` 留給【讀取端】：claim 裡沒有 activity 欄位／claim 過期 ⇒ 那才是未知
③★★「unknown 一律不通過」【不放寬】—— 而 invite 現在拿得到 ACT_IDLE，功能自然活過來
④★★★若 invite 的篩選條件本來就想要「靜止的流亡團」⇒ 它現在有一個【肯定的事實】可以篩，
   而不是靠「篩不掉」通過 —— ★這比放寬規則強在：它是【觀察到的】，不是【沒被排除的】
```
★**驗收**：`ACT_IDLE` 必須有**非零寫入證據**（照既有的寫入證據條款）；
★★**而 `ACT_UNKNOWN` 在寫入端的計數必須【恆 0】** ——★★★非 0 就是分類表又缺一格，**報我，不要自己補預設值**。

# ④已入 `invariants` 細則 1a
> **「未知」只屬於讀取端**：在觀察發生的當下你正看著它 ⇒ `unknown` 不是合法輸出；
> **分類表沒有一格給它，叫做分類表不完整，不叫做未知。**
