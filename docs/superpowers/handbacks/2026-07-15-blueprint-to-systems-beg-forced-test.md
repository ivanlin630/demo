---
from: blueprint
to: systems
status: consumed
topic: [補·用戶提] Fix A-2(併入)確認proceed;加乞食強制樣本測(逼乞食偏好leader/情境)驗乞食是否同款幻覺(餓世界無施捨者);同款→補look-before-leap一起進A;完整驗才merge
---

# Fix A-2 proceed + 加乞食強制樣本測

## Fix A-2（併入 look-before-leap）：確認 proceed
併入=幻覺 (a) code 確診（餓世界 host feed_ok≈0 恆拒、full-or-nothing 無漸進、pop 降是餓死）。`has_acceptable_join_host`（joiner belief 估可達 host 收得起,鏡射 feed_ok 但走 `BeliefSystem.best_estimate` 非 god-view,守感知鐵律,不誤殺真投靠）＝**正確補全 A**（我 A 決定＝全求生選項 look-before-leap,這是預授權範圍）。送 R² proceed。

## ★加：乞食強制樣本測（用戶提，好方法）
乞食此世界 0 樣本測不到。用戶提「**弄個乞食極端偏好的 leader/情境逼它被選中**」→ 直接測乞食**選中後有無世界效果**（真 coin/food 從對方轉來 or 幻覺空轉）。比「查為何從不選」高效——直搗幻覺問題本體。

**請 measurer**：配一個逼乞食進候選的樣本（極端偏好乞食的人格/情境,你知道哪個 drive 驅乞食——`BEG_FLOOR_FACTOR` 等）→ jsonl 逐筆核乞食世界效果：
- 選中乞食 → **對方真轉 coin/food 來?** 還是 winner 標乞食、狀態沒動（幻覺）?

**我的預判**：乞食**很可能同款幻覺**——餓世界**沒有施捨者**（誰都缺糧,乞食對象給不出）＝跟併入 host 恆拒、買糧無賣方**同一根**（餓世界資源不流通→所有「靠別人給」的求生路都是海市蜃樓,只有「自己弄」的覓食/遷移/掠奪真能兌現）。

**若乞食也幻覺 → 補它的 look-before-leap（有可達且給得起的施捨對象才入候選）→ 併 Fix A-2 一起進 A**。若真能轉→連貫,乞食死 rung 是純 utility 權重另案。

## A 完整驗收才 merge（我的線）
A 覆蓋 = 買糧✅ + 掠奪✅ + 併入(A-2 修中) + **乞食(強制測,同款則補)**。**全求生選項驗完不留幻覺才 merge**——這才是我原 A 決定的完整範圍,也是「死前奮力求生每條路真能走」的兌現。

## 下一站
- Fix A-2 R² → impl。
- 乞食強制測 measurer 平行跑 → 同款幻覺則補 look-before-leap 併入 A-2 分支。
- 兩者齊 → 重跑（併入不幻覺 + 乞食驗完 + 連貫窮死）→ QA 複判 → 我批 merge。
