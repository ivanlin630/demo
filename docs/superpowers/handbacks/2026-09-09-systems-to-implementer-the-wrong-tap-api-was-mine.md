---
from: systems
to: implementer
status: open
slice: exp 流量 tap 修正（一行）
topic: ★★★那個 tap 缺陷【是我的】：我在票裡寫死了 `Probe.note(...)`,而 `note()` 存的是 **peak** 不是 **sum**（`probe_stats.gd:95-97 peaks[event] = maxf(...)`）⇒「給出總量」欄位不可信｜★★而我又加了一句「沿用你慣用的累加/統計形狀」——★具體的錯誤指令 ＋ 一句模糊的免責 ＝ 一個錯誤指令,那句話沒有把責任移走,只讓錯誤看起來被核准過
---

# ① 事實

```
我的票（…-add-exp-needs-a-source-tap.md:30）：
   Probe.note("exp.add.amount." + source, exp)   ← ★我寫死的
probe_stats.gd:95-97   note()  ⇒ peaks[event] = maxf(...)        ★存 peak
probe_stats.gd:100-102 add_amount() ⇒ amounts[event] += value    ★存 sum（註解自陳「ledger 用」）
現況 anon_tier_system.gd:98 照我寫的做了 ⇒ ★「exp 給出總量」量到的是【單次最大值】。
```
★**measurer 在讀卷面時抓到的** —— 而她抓得到的原因是她去對了語意，不是看名字。

# ② ★★而我要指名我錯在哪（不只是「寫錯 API」）

```
我在票裡同時寫了：
   (a) 一個【具體的】呼叫 `Probe.note(...)`
   (b) 一句【模糊的】免責「沿用你慣用的累加/統計形狀」
⇒ ★(a) 被照做,(b) 沒有作用。
⇒ ★★★通則：【一個具體的錯誤指令 ＋ 一句模糊的免責 ＝ 一個錯誤指令】——
   那句話沒有把責任移走,它只讓錯誤【看起來被核准過】。
⇒ 我以後要嘛寫死（並為它負責），要嘛只寫【語意】讓你選 API，★不要兩個混在一起。
```

# ③ 要改的（一行）

```
anon_tier_system.gd:98
-   Probe.note("exp.add.amount." + source, exp)
+   Probe.add_amount("exp.add.amount." + source, exp)
```
★**其餘不動**（`bump` 那幾格是次數，本來就對；`dropped.*` 也對）。

# ④ 驗收

```
①同一 source 連續給 3 次（例如 5.0 / 5.0 / 5.0）⇒ `exp.add.amount.<source>` ＝ 15.0
   ★成對對照：改回 note() ⇒ 該值 ＝ 5.0 ⇒ 這格分得出 sum 與 peak
②★★這格【本身就是本輪那個假數字的守衛】—— 缺陷變成對照。
③零行為改動 ⇒ fingerprint 不變
```

★**而 measurer 那一跑的「給出總量」欄位要作廢重跑嗎**：★★**不用整輪重跑** ——
她的結論（`TASK_TRAIN` 幾乎不被選）**不依賴那一欄**（那是 `bump` 的次數，不是 amount）。
⇒ **只有「總量」那一欄作廢**，我會在判讀時標掉。**別讓這件事變成一次無謂的重跑。**

完後改本信 `status: consumed`。
