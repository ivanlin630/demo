---
from: systems
to: implementer
status: open
slice: 解承諾那一刀 —— ★R² issues 已吸收，可以做
topic: ★我自撞的風險 reviewer 查掉了(11 個 option 逐一核對,沒有「抵達後才 applicable」的)⇒ 不需要豁免條款;★★而 reviewer 指出的真問題是【side effect 不同】:STALLED 會設 cooldown 而新規則不設,可能耦合成 thrashing;★★★我的處置是【加偵測器不加常數】:恆 0 就不必為它加 cooldown,非 0 再談而且有數字
---

# ★①做什麼
```
committed 的 option 若【當下不 applicable】⇒ 走既有出口 `survival_committed_option = ""`
   ＋ `Probe.bump("survival.release_not_applicable")`（★per-option 記，別只記總數）
★通用：不綁紮營（★★覓食那 2 筆就是證據）
★★執行順序：排在 `_detect_survival_stall` 【之後】（免同 tick 重複處理）
★★★不設 cooldown —— 理由見下
```

# ★★②為什麼不設 cooldown（★reviewer 建議二選一，我選了另一條）
```
★若 option 是真的不 applicable，擋它無害；
★★而它【重新 applicable】時（例：營地衰敗 ⇒ 紮營又該可以了），cooldown 會擋掉一個【正確的】選擇
⇒ ★★★所以我加【偵測器】：`survival.release_recommit_same`
   ＝ 解承諾後 N tick 內又承諾【同一個】option 的次數（N 用既有 STALL_EXCLUDE_WINDOW，不新增常數）
   恆 0 ⇒ 那個病不存在；非 0 ⇒ ★那時再談 cooldown，而且是拿著數字談
```
★**通則（我會寫進流程）**：**不要為了一個【沒有量到的病】先加一個【要調的常數】—— 先加偵測器。**

# ★★★③驗收（★判讀表在 spec §⑤，這裡重申三條硬的）
```
①那 10 筆 ⇒ 【0】（同床同 seed 同天數，母體與命中同印）
②`not_in_ranked` 應同步下降 —— ★若沒降，先查【解承諾有沒有 fire】（看 Probe 桶），不要先怪別的
③★★陽性對照：把解承諾停掉 ⇒ 那 10 筆必須回來，並寫明【你弄壞了什麼】
＋★★★`survival.release_recommit_same` 一併報（★它是這一刀自帶的抖動偵測器）
```

# ④序
排在 `churn 分桶（含 idx≡scan 等價證明）` 與 `peaceful 判別` 之後 —— ★**不要插隊**。
