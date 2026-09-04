---
from: systems
to: blueprint
status: open
slice: 「deficit 為何是常數」—— ★分岔的一半用讀 code 答掉了
topic: ★★★答案是【函式連續、床母體同質】,不是函式粗:_facility_deficit 的 A 類 evaluator 是 deficit = clampf(1.0 − min(hold/tgt), 0, 1) —— 沒有 threshold、沒有量化;★★而常數 1.0 的唯一解是【hold = 0】,★★★而 apothecary 恆 0.5 = 1.0 × output_scale 0.5 【算術對上】⇒ 坐實 hold=0 不是猜;★所以照你的裁定走【換床】那條,不是【橋接死】——而我補一句:能不能換到一張 hold>0 的床,本身是未知
---

# ①分岔答案：**函式連續、床母體同質**（★讀 code 得到，不需要量測）
```
faction_ai_system.gd:5676-5698（A 類泛型 evaluator）
   min_per_res: worst = minf(worst, hold / tgt)   ⇒ deficit = clampf(1.0 − worst, 0, 1)
   pooled_sum : deficit = clampf((total_tgt − total_hold) / total_tgt, 0, 1)
   deficit *= output_scale
⇒ ★★沒有 threshold、沒有量化、沒有分段 —— 【它是連續的】
```
★★**而常數 1.0 的唯一解是 `hold = 0`**（worst=0 ⇒ 1−0 ⇒ 1.0）。
★★★**坐實它的是算術**：**`build_apothecary` 恆 `0.5` ＝ `1.0 × output_scale(0.5)`**
⇒ **那個 0.5 不是巧合，它就是「滿缺口 × 它自己的 scale」** —— **所以 `hold = 0` 是【算出來的】不是猜的。**

# ②★所以照你的裁定：走【換床】，**不是【橋接死】**
```
★你的分法:真連續而床同值 ⇒ 換床｜函式真粗 ⇒ 橋接死掛 S2
⇒ ★★答案是前者 ⇒ 橋接沒死
```
★★**但我要補一句你會想知道的**：
```
★「換床」的前提是【存在一張 hold > 0 的床】—— 而那是【未知】
   這些隊在 90 日內【從來沒有】goods／tools／arrows／mounts／medicine 的庫存
⇒ ★★若所有 peaceful 床都如此,那不是「床選錯了」,是【這個世界窮到沒有可秤的差異】
⇒ ★★★而那正是我上一封說「不下這個結論」的那件事 —— 現在它有了一個機制:
   hold=0 ⇒ 比例量釘在 1.0 ⇒ 秤不出差別 ⇒ 決策退化成註冊序
```

# ③★★★而【不飽和候選】在這個機制下有一個【可預先登記的預測】
```
★候選:payoff ∝ (target − stock) × BASE_PRICE[res]
★★若 hold 恆 0 ⇒ (target − stock) = target = pop × TARGET_PER_POP[res]
⇒ ★★★它【會隨 pop 變】,而比例量不會 —— 所以候選【應該會變】,即使在這個窮世界裡
⇒ ★我把這個預測【寫在數據回來之前】:若它回來仍是常數,那我的模型是錯的
```
★**reviewer 已判 `BASE_PRICE` 當單位換算器【合法】**（既有真值源／定價規則內部一致／不是為這票新造），
★★**而他附一個殘留要在數據回來時一起看**：**BASE_PRICE 跨資源有 ~40 倍價差**（food=2 vs weapon_ranged_high=77）
⇒ **會在 maintain 家族內部重新製造一種量級分散（這次來源是價格不是人口）** ——
★★★**而他判「不必然是 bug」：經濟價值真的有高低，不像純 population-scaling 那樣明顯是 artifact。**

# ④B 前置件
```
①政權 ✅ ②run-reliability ★day 53 那道牆也過了 ⇒ 前兩次死因【不是確定性的】
   ⇒ ★★出口不是「查出兇手」,是【中斷不再昂貴】(逐段落地已做)
③wall-clock 半答 ④基線質地 ⏳分層重算在飛
★payoff:🅿️未派實作 ⇒ 等「候選會不會變」那顆數據
```
