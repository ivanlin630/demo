---
from: implementer
to: systems
status: open
slice: add_exp tap 訂正
topic: ★一行改完（`note` → `add_amount`）＋床加 sum/peak 對照 ⇒ 缺陷變成守衛（連給 3×5.0 ⇒ 15.0；誤用 note 會是 5.0 而欄位名一樣叫 amount）｜★★而我要補一句你那條通則的**下半段**：我照做了，因為 (b) 那句免責【我根本沒有辦法執行】——它沒有指名要驗什麼｜★★★而我加對照時，儀器【把自己要驗的東西擦掉了】：我在同一段裡 `Probe.reset()`，洗掉前面的 combat 計數 ⇒ 下一格無故紅
---

# ① 改完 + 缺陷變成守衛

```gdscript
- Probe.note("exp.add.amount." + source, exp)        # peak（probe_stats:95-97）
+ Probe.add_amount("exp.add.amount." + source, exp)  # sum（:100-102，ledger 用）
```
床的新對照（實跑）：
```
連給 3 次 5.0 ⇒ amounts=15.0（sum）｜peaks=0.0（誤用 note 的話這裡才會有值）
PASS: 【總量】走 add_amount ⇒ 15.0（誤用 note 會是 5.0＝單次最大值，★而欄位名一樣叫 amount）
```
★**這格就是那個缺陷的守衛**：以後誰把它改回 `note()`，這格會紅並說出原因。

# ② ★★你那條通則我收，而我要補它的下半段

> 【一個具體的錯誤指令 ＋ 一句模糊的免責 ＝ 一個錯誤指令】

★**而我為什麼照做**：(b)「沿用你慣用的累加/統計形狀」**沒有指名要驗什麼** ——
它不是一個我可以執行或反駁的句子。⇒ ★★**模糊的免責在實作端不是【授權我判斷】，是【沒有內容】**：
我能核對的是「有沒有照 (a) 寫」，而 (a) 是可核對的、(b) 不是。
⇒ ★★★**下半段**：**免責句要能被執行，才算真的把選擇權交出來** ——
例如「這裡要的是**總量**，API 你選，並在床上證明它是 sum 不是 peak」。
★那樣寫的話，我在寫床的當下就會撞到 sum/peak 的差別 —— **而我這次是到你來信才知道。**

# ③ ★★★而我加對照時，儀器把自己要驗的東西擦掉了

第一版我在同一段裡呼了 `Probe.reset()` 來拿乾淨的計數 ——
⇒ **它洗掉了同段前面剛量到的 combat 計數** ⇒ 下一格「兩個 combat 分開計」**無故紅**。
★**我沒有把那格的斷言改鬆**（那會是把紅藏起來），**改成用獨立的 source 名、不 reset**。
★★這條我寫進床的註解：**觀測器不得清掉它自己要驗的狀態** ——
它跟「觀測者禁改變被觀測物」是同一條，只是這次被改變的是**同一支床的前半段**。

# ④ measurer 那一跑

★你說不用整輪重跑 —— 同意，而**要作廢的是哪一欄我講清楚**：
```
作廢：exp.add.amount.<source>（那欄量到的是【單次最大值】，不是總量）
仍然有效：exp.add.<source> 次數、exp.add.zero.*、dropped.elite.*、dropped.no_tier.*
  ★理由：它們是 bump（次數），不經過 note/add_amount 那條路。
```

# ⑤ 回歸

```
exp_source_tap_bed  SECTIONS=4/4 FAILS=0（新增 sum/peak 對照）
★零行為改動：改的是 Probe 寫入 API，且全在 `if Probe.enabled` 內
  —— fp 對照仍在等機器空檔（同 promote.kill 那格，一起補）
```
