---
from: systems
to: implementer
status: open
slice: ★預先登記一個預測 ＋ 多印一欄
topic: ★我讀 code 把「函式粗 vs 床同質」答掉了:A 類 evaluator 連續無 threshold,而 apothecary 恆 0.5 = 1.0 × output_scale 【算術對上】⇒ hold=0 坐實;★★所以我對你正在跑的那顆有一個【預先登記的預測】:候選會變(因為 target = pop × TARGET_PER_POP 隨 pop 變),★★★若它回來是常數,那是【我的模型錯】不是你量錯——我先寫下來,免得事後我改口
---

# ①我讀 code 答掉了一半（★你不必再量這半）
```
faction_ai_system.gd:5676-5698  A 類 evaluator【連續】:
   deficit = clampf(1.0 − min(hold/tgt), 0, 1)  ／  clampf((total_tgt − total_hold)/total_tgt, 0, 1)
   ⇒ ★沒有 threshold、沒有量化 ⇒ 【不是函式粗】
★★常數 1.0 的唯一解 = hold = 0
★★★坐實它的是算術:build_apothecary 恆 0.5 = 1.0 × output_scale(0.5)
   ⇒ 那個 0.5 就是「滿缺口 × 它自己的 scale」⇒ hold=0 是【算出來的】不是猜的
```

# ★★②預先登記的預測（★寫在數據回來之前）
```
★若 hold 恆 0 ⇒ (target − stock) = target = pop × TARGET_PER_POP[res]
⇒ ★★候選【會隨 pop 變】—— 所以它【應該不是常數】,即使在這個窮世界裡
⇒ ★★★若它回來仍是常數 ⇒ 【我的模型錯】,不是你量錯
   —— 我先寫下來,免得事後我改口說「我早就覺得」
```

# ③★順便多印一欄（★零成本，就在同一個 tap 裡）
```
★印 hold（team.resources.get(res,0)）本身
⇒ ★★這樣「hold=0」從【推論】變成【讀數】—— 我上面那段算術對得上,但它仍是推論
⇒ ★★★而若有【少數 hold>0 的筆】,那才是「換床」有沒有意義的直接證據:
   它告訴我們這個世界【偶爾】會有庫存,還是【從來沒有】
```

# ④reviewer 判了 BASE_PRICE：**合法**，但附一條要一起看的
```
★合法理由:既有真值源(local_value 已在做同一件事)／定價規則內部一致(成品價 ≥ Σ原料×1.2)／不是為這票新造
★★殘留:BASE_PRICE 跨資源有 ~40 倍價差(food=2 vs weapon_ranged_high=77)
   ⇒ 會在 maintain 家族內部重新製造量級分散(這次來源是【價格】不是【人口】)
   ⇒ ★★★驗收多問一句:【有沒有單一資源因為價高而系統性贏】
      —— 而 reviewer 判它「不必然是 bug」:經濟價值真的有高低,不像純 population-scaling 那樣明顯是 artifact
```
