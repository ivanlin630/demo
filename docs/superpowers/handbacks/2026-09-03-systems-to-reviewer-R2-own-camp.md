---
from: systems
to: reviewer
status: open
slice: own-camp-in-decision-model（R²）
topic: ★三個要你打的:①`own_camp_pos` 的來源我傾向【延伸 OwnerOutpostIndex】而不是在 TeamData 存一份——理由是那套已經有 epoch 失效＋shadow 對帳,而「索引與真值漂掉」正是它被造來抓的病;②讓 applicable 在【人在遠處】時也成立,會不會造出「橫跨全圖走回家」的病態(util 有沒有把距離折進去?我沒查);③營地失效走既有解承諾出口 vs 會不會跟【紮營】形成新的 churn 迴圈
---

spec：`docs/superpowers/specs/2026-09-03-own-camp-in-decision-model-HOW.md`

# ★①seam 選擇（我傾向案A，但沒有 file:line 坐實它夠用）
```
案A：延伸 `OwnerOutpostIndex`（已有 `epoch`/`shadow`/`shadow_check`）
案B：`TeamData.camp_pos`，由既有 1 寫 2 清同步
★我的理由：索引漂掉正是 shadow_check 要抓的病 ⇒ 白拿；★★而案B【沒有現成對帳】
⇒ ★★★要你打的：`OwnerOutpostIndex` 的既有結構【真的能承載第二種索引】嗎，還是會逼出爛形狀？
```

# ★★②我最不確定的一格（★請重點打這裡）
```
applicable 加上 `own_camp_pos != (-1,-1)` ⇒ ★人在【地圖另一端】時紮根也 applicable
⇒ ★★若 util 沒有把【路程】折進去，可能造出「橫跨全圖走回家」的病態
⇒ ★★★而我【沒有查】util 有沒有距離折扣 —— 這一格請你用 file:line 回我（我不猜）
★若真的沒有折扣：那不是本刀該修的東西，但本刀會【讓它現形】⇒ 要在 spec 裡先寫明
```

# ★★★③churn 迴圈
```
腿B 的「原地重紮營」順帶解釋 camp churn；而「該格已有據點」是 can_settle_here 的第二支支配子條件
⇒ ★要你打的：修好之後，【回家的隊】會不會反而在半路上一直重紮營（移動中被打斷 ⇒ 重秤 ⇒ 又紮營）？
   ★★我在 spec 的驗收②放了「走到一半營地被清掉」那一腿，但【移動中被打斷】那一格我沒有設計
```

# ④其餘
病型定名（**腦裡沒有那個念頭**）、判別法（決策路徑零讀取的結構讀）、與 camp churn 的關聯註明 —— **都在 spec 裡，有意見一起講。**
