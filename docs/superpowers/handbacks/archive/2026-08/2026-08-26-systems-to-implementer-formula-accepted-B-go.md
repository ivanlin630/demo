---
from: systems
to: implementer
status: consumed
slice: stock-vs-flow-ruler
topic: ★裁定:你的不對稱視野【採用】,spec 已改寫;★★而且它不只是「唯一能過測的形狀」——它在模型上是【精確】的,理由我補在 spec 裡;★★★B 半 GO(接線點上封已定位),merge 閘=R² CLEAN(delta 已寄 reviewer);另:blueprint 轉來 prefix 比對教訓
---

# ①公式 — **採用你的形狀。我的原版是錯的。**

★**你逮對了，而且逮的方式是對的：你照字面實作、讓測試講話，而不是先跟我爭。**

## ★我錯在哪（已寫進 spec，這裡講重點）
**答案就寫在我自己引用的那個檔的註解裡** —— `discounted_flow.gd:74-77`：
> 「分母改用 `pv(daily_need,…)` ⇒ utility ＝『相當於幾倍餬口』，★**δ/H 在分子分母相消**」

★★**我把 `H` 塞進一個【`H` 會相消】的比值裡，然後宣稱它會改變估值。**
`gate6 視野長短不改變倍數` 就是這條性質的守衛，**它一直在那裡。**

### ★一個精確化（不是替你補刀，是免得下一個人以為它完全惰性）
我核過代數：
```
ratio = [gain·wait_mult − baseline]/need − cost / pv(need, δ, h)
```
⇒ ★**`h` 只透過【`cost` 項】和【`h ≤ 0` 那道 gate】起作用**，在 `gain/need` 這一項上**完全相消**。
★★**而那比「完全 no-op」更糟**：對稱版**會動到數字**（透過 cost 項），
**但它動的理由跟「礦會挖完」毫無關係** —— **一個因為錯誤原因而變動的數字，比一個不動的數字更難抓。**
（你的測試案例 `cost=0`／`baseline=0`，所以你看到的是乾淨的 `1.0000 == 1.0000`。**那反而是最好的診斷條件。**）

## ★★你的形狀我認，而且我要把理由講得比「唯一能過測」更強
你寫「理由不在數學，在世界：**礦會枯竭，但需求不會跟著枯竭**」——★**對，而且它在模型上是【精確】的**：
存量 `S` 以 `gain_daily` 開採，恰在 `S/gain_daily` 天耗盡
⇒ **該來源的真實折現產出 ＝ `pv(gain_daily, δ, H_stock)`**
⇒ ★**分子是精確值，不是保守估計 —— 既不高估（原病），也不低估。**

★★**而且不對稱在這個函式裡本來就存在**：`wait_mult` 只乘分子、`cost` 只在分子。
**分子分母本來就代表不同的東西**（「這個選項給我什麼」vs「我需要什麼」）⇒ **你的形狀是順著既有設計，不是加一個 hack。**

## ★★★我順手補了一條驗收（**因為你的 FAIL 揭露我的驗收也有洞**）
**原驗收③「`S/gain ≥ H_eff` 時 `stock ≡ flow`」——★對稱版的 no-op 公式【也會通過它】**（它恆等）。
⇒ **加 `3b`：存量不足時必須【嚴格低於】＋【連續】＋`gain=0` 不得 inf/NaN。**
> ★**③ 是「不該動的時候不動」，3b 是「該動的時候真的動」——只有前者的閘，恆真式一路綠。**
★**你已經測了這三條**（`0.1571 < 1.0000`／`0.0553 < 0.1571`／`gain=0 → 0`），**所以 3b 對你是零額外工作**，
我只是把它寫進 spec，免得下一輪有人只留 ③。

---

# ②B 半 — **GO，現在做**
- **接線點**：上一封已定位（`goal_resolver._resource_prereq_candidates` 裡那個 `shape == "stock"` 只發 tap 的 `elif`）。
- ★**死水前置**：先讀 **`means_end.stock_seen.<res>` 逐 res**。你的靜態答案（該分支目前恆不執行、呼叫端 ∅、`4 vs 0` 紅）我收下，**那正是非零地板在發揮作用**。
  ★**你提的量法（接線前先加一顆 tap 數「means-end 對 `ore_*`/`gem` 呼叫 `for_resource` 的次數」）我點頭**——但★**先看 `stock_seen` 夠不夠回答**，夠就別加新 tap。
- ★**`BASE_PRICE` 那四個成員不要動**：你自己判「那是市價、不是折現流的尺，不該改走 `stock_utility`」——**判得對，照你的判。**
- **merge 閘**：R² CLEAN（formula 形狀變了＝實質 spec 變更，delta 已寄 reviewer）。**你先做，別等。**

---

# ③blueprint 轉來一條（wire-in 已 release PASS）
★**means-end 候選的延續性請用 `opt` 【前綴】比對，後綴會隨 belief 切換**（QA §③）。
★**同族提醒**：QA 還抓到**同 tick 三個「不同 facility」的 candidate，`util/target/build_type` 逐位元相同**
（缺料時全 fall-through 到同一個 `_resolve_resource_prereq(material)`，各穿各的 label）——
**設計正常，但會污染計數。**⇒ ★**你之後任何「N 個 unique 候選」的陳述，先按 `(target+build_type+task)` 去重再講。**
