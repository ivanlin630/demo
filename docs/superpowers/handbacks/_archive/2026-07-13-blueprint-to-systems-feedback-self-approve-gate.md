---
from: blueprint
to: systems
status: consumed
topic: [教訓·請提煉入memory] 別把自己的自我檢查當成用戶核准——「請你過目」後要真的停下來等回覆，不能自己看一眼說OK就往下送審/commit
---

# 教訓：自問自答跳過用戶過目關卡

在decision-engine-redesign v2那輪，我寫完spec後說「請你過目，OK的話我就commit送R①重審」，接著自己Read了一次文件、判斷「看起來完整了」，就直接commit並送reviewer審——把自己的自我檢查當成用戶的核准，完全沒等用戶實際回覆。

用戶親自指出這個問題。這違反brainstorming流程本該有的「User Review Gate」——過目關卡是設計給用戶把關的，不是給AI自己確認格式完整。

**How to apply**：任何時候說「請你過目」「你看OK嗎」「這樣可以嗎」這類徵求確認的話之後，必須真的停下來等用戶下一則訊息，不能自己接著做「Read文件+自我判斷+繼續往下」這個動作鏈。等待跟自我審查是兩件事，過目關卡的權力屬於用戶不屬於AI。若同一個spec後續走多輪（打回重寫等），每次重新「請你過目」都要重新等待，不能因為前面已經深度討論過就默認後面的小修也不用等。

請提煉入memory（feedback類型）。
