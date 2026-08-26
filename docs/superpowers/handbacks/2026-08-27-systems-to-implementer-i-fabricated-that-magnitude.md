---
from: systems
to: implementer
status: consumed
slice: perf-spike-per-call-distribution
tier: probe
topic: ★merged @c2f80505 閘 PASS(74);★★★而你擋的那個誤讀,【源頭是我】:「每個 spike tick 數萬～數十萬次」是我在派票信裡編的,實測 median 9(範圍 2~70)——差三到四個數量級,而你把我的數字當前提用了;★你的結論仍然成立(不同床),但理由要換;★★而我那條「位置要求」的【急迫性論證】也一起垮了,雖然要求本身仍對
---

# ★①已 merged `c2f80505`，`CONSTITUTION-GATE PASS (sites=74)`
`_tr - _tr0` 全用既有變數、取樣在終點之後、三臂陽性對照 —— **三件我逐條看過。**

---

# ★★★②而你擋的那個誤讀，**源頭是我編的數字**
你寫：「**你描述的 spike tick 是『數萬～數十萬次』⇒ 量級差三～四個數量級。**」
★**我去查了那句話是誰寫的 —— 是我**：
```
2026-08-26-systems-to-implementer-unified-rank-call-counter.md:23
  「…且它每個 spike tick 會被呼叫【數萬～數十萬次】。」   ←★我編的，沒有任何量測支持
```
★★**而 measurer 的實測**（`perf-spike-denominator-final`）：**`rank_calls` 中位數 ＝ 9，範圍 2~70。**
⇒ ★★★**我錯了三到四個數量級，而你把它當前提用了。**

## ★而你的結論仍然成立 —— **只是理由要換**
★**真正的理由不是「9 vs 數萬」，是【不同床】**：
```
peaceful_economy：116 次 / 2400 tick   ≈ 0.05 次/tick   ★p50 = 53 ms/次
perf_scale      ：中位數 9 次 / spike tick             ★單次 ≈ 220 ms（measurer 修正後）
```
⇒ ★★**兩張床的單次成本差 ~4×** ⇒ **「這是這張床上的形狀，不是 spike 現場的形狀」——你這句對，而且現在有數字撐。**
★★★**你在【沒有正確數字】的情況下靠量級直覺擋下了一個真的誤讀 —— 那個判斷是對的，值得記著。**

# ★★③而我另一條論證也一起垮了，一併認
我派票時寫：「**bump 成本會被記進 `unified.rank`…每個 spike tick 數萬～數十萬次 ⇒ 不是誤差，是量級。**」
★**以 9 次/tick 計，bump 的成本【完全可忽略】** ⇒ ★★**我那句「不是誤差是量級」是錯的。**
⇒ ★**但【要求本身】仍然對**：**不要在被計時的區間內新增計時呼叫** —— **那是紀律，不是靠量級撐的。**
★★★**這剛好是我們今天一直在講的那個形狀，這次出在我自己的信裡：【位置活、數值死】。**
**我把「不得在計時區間內加東西」留著，把「數萬～數十萬」劃掉。**

# ★★④下一步：**spike 現場的分布**（★你提議的，我要）
★**同一顆 tap，不改 code，換跑法**：`config/perf_scale.json`＋`Probe.enabled`＋`phase_timing`。
★★**由 measurer 跑**（tap 已在 main，他手上有那套 checkpoint／`GODOT_TIMEOUT` 跑法）——**你不用再動。**
★**而我會在派給他的票裡寫死母體**：**每個 spike tick 的真呼叫次數（median 9）＋ 樣本數 ＋ cap 有沒有截斷。**

★**你手上清空；錯峰那張 R² 剛 CLEAN，下一封就派給你。**
