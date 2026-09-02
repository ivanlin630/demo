---
from: systems
to: implementer
status: consumed
slice: #12 母體訂正（★我的票寫錯）＋ #35 重定框架
topic: ★★★#12 的母體是【我寫錯的】:我只寫「絕境階梯路」,而乞食的 sets ＝{survival, passive_survival} ⇒ 它也走【統一 rank】(decision_engine:286 `_need_category` 把 passive_survival 歸 survival 需求組);★而你【自己抓到母體 0 而沒寫成「引擎不選它」】—— 那個結論我會照收,然後我們兩個都會錯;★★#35 不是復發:舊修法在且有效,3 seed 顯示 25 天被 farming 佔滿 ⇒ 是【優先序】,重定框架為決策問題
---

# ★★★①#12 母體訂正 —— **錯在我的票**
```
我寫：「母體 ＝ 進入絕境階梯（survival/desperation 層）的隊 × 該窗全部 tick」
★而 options.gd:268 "乞食" 的 sets ＝ {"survival": true, "passive_survival": true}
★★decision_engine.gd:286 `_need_category`：passive_survival 成員 → 歸 "survival" 需求組（不看 affinity）
⇒ ★★★所以它【也在統一 rank 那條路上】—— 而我的票只點名了絕境階梯路 ⇒ 母體 0
```
★**正確母體（兩條都要）**：
```
①`rank_survival`（絕境階梯路）②★★統一 rank（`_decide_unified` 走的 `rank_scored`）
⇒ 兩條路【各自】報：候選裡出現幾次／贏幾次／輸給誰
⇒ ★★★而【兩條都 0】與【只有一條 0】意思完全不同 —— 分開印
```

## ★★而你做對的那件，比這一票的數字重要
> 「只監絕境階梯路量到母體 0，**差點寫成『引擎不選它』**。」

★**那個結論我會照收** —— ★★**因為它跟條目原文（「6 specimen 全程從沒選過」）一致，我不會起疑。**
★★★**然後我們兩個都會錯，而錯的東西會變成下一輪的前提。**
⇒ **這是今天第 N 次同一族：0 先問「母體在不在」再問「有沒有發生」** —— **而這次是你在下結論前自己擋住的。**

# ★★②#35 重定框架：**不是復發，是優先序**
```
★你查的：舊修法【還在且仍有效】（pop 沒被拆走、隊真的在蓋）⇒「修法失效」框架不成立
★★3 seed 逐日：25 天被 farming 佔滿（farming×3／farming×3／farming×2+mint×1），餘工期零停滯
⇒ ★★★不是「料斷」也不是純「mint 工期太長」—— 是【建設優先序】：mint 排不進去
```
★**已改寫條目**（保留你的數字，框架改成決策問題）。
★★**下一步與 #12 同一批**：**dump 建設選項的 per-option util（含贏家組成）**，
★★★**第一問一樣是「farming 贏得對不對」** —— **一個沒糧的村先蓋田可能完全 genuine，禁 crank。**

# ★③兩票合併後的母體規格（★這次寫清楚）
```
#12：乞食 —— 兩條 rank 路各自報 ｜ 母體＝該路上【乞食 applicable 的隊 × tick】
#35：建設 —— 母體＝【有 mint 需求且在蓋東西的村 × tick】；★要印「那一輪候選有哪些、各自 util」
★★兩票共同：命中 0 時照三讀法；★★★而母體本身若是 0，先報母體，不要報結論
```
