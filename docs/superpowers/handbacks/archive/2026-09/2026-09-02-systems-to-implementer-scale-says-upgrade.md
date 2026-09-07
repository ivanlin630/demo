---
from: systems
to: implementer
status: consumed
slice: 讓秤能說「升級」（#35 修秤 (i)）
topic: ★R② 過,兩條 issues 都採納:(a)同分【明寫決定性 tie-break：偏好成本低者】(資訊已存在)／(b)afford 做【第四道 pre-filter】,沿用既有三道模式非新機制;★★而我補一格 reviewer 沒提的:加了 afford pre-filter 之後,失敗模式會從【選了但付不起】變成【什麼都沒選】—— 兩者在漏斗上長得不一樣,必須分開命名,否則我們會以為病好了
---

# ★①形狀（★三處，都在 `_pick_facility`）
```
①★候選集合納「既有設施升一級」：`:5164` 那道 `已有設施 → continue` 不再一律跳過
   —— ★★與新建【同秤】（藍圖：不是 fallback、不是走廊）
   ★★★而秤【不必改】：`_facility_score` 對等級零參照（reviewer 已複驗），
      它評的是「我想不想在這裡有這座設施」，而 `_facility_deficit` 本來就在問「我缺多少」
②★同分 tie-break【明寫、決定性】：★★偏好【成本低者】（reviewer：該資訊已存在，不必新算）
   ⇒ ★★★不要留給 argmax 的偶然順序 —— 那會變成「看起來隨機」的行為
③★afford 做【第四道 pre-filter】：★★沿用選擇迴圈裡既有三道 pre-filter 的同一個模式（非新機制）
```

# ★★②而我補一格 reviewer 沒提的（★這是驗收的重點）
```
★加了 afford pre-filter 之後，【失敗模式會搬家】：
   舊：選了 → 下游 `reject_cannot_afford` 擋   ⇒ ★漏斗上看得到「選到了但付不起」
   新：pre-filter 就篩掉 → ★★【什麼都沒選】     ⇒ 漏斗上變成 `pick_empty`
⇒ ★★★而 `pick_empty` 已經有別的成因（slot 滿／沒有夠分的候選）
   ⇒ 若混在同一個桶，我們會看到「empty 變多」而【不知道是哪一種】
⇒ ★必須新開一個具名桶：`pick_empty.all_unaffordable`（★★名字只宣稱判準本身）
   ⇒ ★★★否則我們會以為病好了（reject_cannot_afford 歸零），而其實只是換了個地方卡住
```

# ★③驗收
```
①★自救活過來：`pick.farming` 從 0/3605 變非 0 ——★★而要同時印【選到之後付不付得起】
②★★g1a 保持通：mint 仍蓋得成（★不能為了救 farming 又把 mint 擠掉）
③★★★三個桶要分開印：`reject_cannot_afford`（應大幅下降）／`pick_empty.all_unaffordable`（新，可能上升）
   ／`pick_empty` 其餘成因（★不該因本刀而變）
   ⇒ ★而三者【加總】與本刀前的總數要對得起來 —— 對不起來就是有東西掉了
④餓隊床：餓死不該出現；★若出現，那仍是【證據】：秤缺急迫項 ⇒ 回報，★★禁開走廊、禁調 SURVIVAL_CRUSH 數值
⑤`fp` 會變 ⇒ 差在哪要說得出來；★升級 vs 新建各被選幾次分開印
```

# ④不動的
`:595/:598` 那兩個【寫死名字】的升級呼叫 ＝ **(ii)**，★**已具名掛「規模經濟 R① 開場」觸發**
（★★理由：那本質是【升級估值】——「第二座田值多少」是規模經濟的地盤）⇒ **本刀不碰。**
