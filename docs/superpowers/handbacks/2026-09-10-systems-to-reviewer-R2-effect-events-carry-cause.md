---
from: systems
to: reviewer
status: open
slice: 果事件帶因（用戶親測兩次揭出）
topic: R² 請審｜★母體:20 個 emit 點,params 幾乎全是「誰對誰」而沒有「為什麼」——★★而 `combat_start` 自己印的就是「宣戰」且它也沒有因 ⇒「求和沒有上游宣戰」即使有宣戰觀眾也看不到為什麼｜★★★要你審的是紀律那段:我用「只印產生端已經讀到的量」當防 spam 的閘,而我不確定它夠不夠
---

# R²：`docs/superpowers/specs/2026-09-10-effect-events-carry-cause-HOW.md`

# 已 grep 的母體

```
emit_message 產線呼叫點 20 處；params 幾乎全是 origin/target/loser/faction
唯一帶一點因的：famine_warning（帶 harvest 欄）—— ★而它正好是用戶【沒抱怨】的那個
combat_start（npc_combat_system.gd:124）印「Team X 對 Team Y 宣戰」★也沒有因
求和的因現成：decision_context:377-378 的 threat_id / threat_react
派工失敗的因現成：faction_ai_system:4625 的 margin/res/avail ＋ ★vault 是否非空（leader 在不在家）
```

# 請你審三件

1. **★★★防 spam 的閘夠不夠。** 我用的是「**只印產生端【已經讀到】的量**」＋「**一個事件一行、不另發因事件**」。
   ⇒ ★**我擔心它擋不住「因很長」** —— 例如宣戰的因有五項（ambition/martial/greed/str_ratio/caution），
   全印會讓一行變得沒人看。**請判：要不要限制成【最大貢獻項一項】，還是全印？**
   ★★而我傾向**最大項一項**（一跳到因，而不是一張表），**但那會丟掉「勢均力敵時是什麼壓過什麼」的資訊**。

2. **★「產生端沒有因」時我裁【不要發明，列進無因清單】。**
   ⇒ 請判這是不是會讓這張票**做一半**（20 個裡可能有一半沒有因）。
   ★我的立場：**做一半是對的** —— 有因的印出來就已經回答了用戶的兩個抱怨，
   而「沒有因」本身是**下一張票的輸入**（它表示決定不是在那裡做的）。

3. **★★驗收⑤（事件總數不增加）夠不夠當「沒有偷偷新增事件族」的證明。**
   ⇒ ★我擔心它**太弱**：一個實作可以既不增加總數、又把兩則事件的文字合併成一則（那也是改變）。
   **請判要不要改成【逐 type 的計數都不變】。**

# 我知道的盲區

- `TextBank.fmt` 的模板機制**我沒讀** ⇒ ★因要塞進 `TextBank` 的模板還是直接串字串，
  **我在 spec 裡沒有定**（寫成「實際欄位你查 code 定」）——★★若 `TextBank` 有既有的參數約定，
  **應該沿用它而不是另開一條**。
- 觀眾端（ticker／observer）**怎麼渲染** `params` 我沒查 ⇒ ★★★**若渲染層只挑固定幾個欄位印，
  那我加的 `cause` 可能【根本不會被顯示】** —— 而那會是「加了但沒接電」的又一個實例。

CLEAN 才 dispatch。
