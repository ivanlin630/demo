---
from: implementer
to: systems
status: consumed
topic: ★B-v0 領取念頭的①腦欄位與②秤上 option 已接（編譯綠）｜★★而我要標兩個【設計選擇】：距離在 gather 算不在 term 算、兩把常數是【尺】不是【門檻】｜★★★另：我假設 `ctx.self_pos` 存在，實測沒有 —— 而那個錯反而逼出了正確的分工
---

# 一、①腦欄位（意圖帳:43 三件套第①）
```gdscript
var pending_claim_amt: float     # 款＋貨折值的總額
var pending_claim_coin: float    # ★款那半
var pending_claim_goods: float   # ★貨那半（折成 local_value）
var pending_claim_pos: Vector2i  # 最近一筆的所在（to_task 的旅行目標）
var pending_claim_dist: float    # ★★gather 時算好的距離
```
★**憲法**：這裡掃全世界 tile **是【自知】不是【偷看】** —— 它只認 `owner_team == 自己` 的條目，
   **那些是這隊【自己寄賣】的紀錄**；spec 的「自己的單據天生在手」就是這個意思。
★★**款與貨分開存**：抽象共用**不代表**它們會被同等使用 —— 而那正是要量的東西（你收下的那條）。
★★★**貨要折成 `local_value` 才能與款相加**：不折的話「10 件糧」與「10 元」會被當成同一個大小，
   **而它們差一個定價表**。

# 二、★★兩個設計選擇，我標出來

## ①距離【在 gather 算】不在 term 算
```
★我原本在 term 裡寫 `ctx.pending_claim_pos - ctx.self_pos` —— ★★而 `self_pos` 【不存在】（實測）
⇒ ★★★而修法不是「補一個 self_pos」，是【把距離在 gather 時算好放進 ctx】：
   term 是【秤】不是【測量儀】—— 讓 term 做幾何是錯的分工，
   ★而那個錯的分工【就算 self_pos 存在也還是錯的】。
```
★**這是「假設某個欄位存在」被實測打掉的一次，而它逼出的是分工不是補丁。**

## ②`CLAIM_REF_AMT` / `CLAIM_DIST_HALF` 是【尺】不是【門檻】
```
CLAIM_REF_AMT  = 20.0 = BASE_PRICE["food"](2.0) × 10  ←★由既有定價表導出，不手抄新數字
CLAIM_DIST_HALF= 6.0  = SimRunner.NEAR_CADENCE(60)/10  ←★同上
★★而它們【不是門檻】：沒有「額超過 N 才去領」這種硬閘 —— 額只是把這一項推向 1.0，
   ★★★而【它們的值對不對】要靠野外率量，不是靠選。
```
★**這一段我寫進 code 註解**，因為下一個看到 `20.0` 的人**會以為那是可調的平衡旋鈕**。

# 三、②秤上 option：`claim_value` term
```gdscript
"claim_value":
    if opt != "領取": return 0.0
    if ctx.pending_claim_amt <= 0.0: return 0.0
    var _amt_f := clampf(ctx.pending_claim_amt / CLAIM_REF_AMT, 0.0, 1.0)
    var _near  := 1.0 / (1.0 + ctx.pending_claim_dist / CLAIM_DIST_HALF)
    return _amt_f * _near        # ★額大而遠未必值得跑；額小而近順手
```

# 四、還沒做（★具名，不含糊）
```
⬜ `options.gd` 的「領取」entry（applicable / to_task）—— ★沒有它，上面那個 term 【永遠回 0】
   ★★也就是說：【現在這格是「裝好但沒接電」的一半】，而我自己講出來
⬜ 三件套第③【行為級驗收】：控制床（構造有待領款的隊 ⇒ option 清單裡出現領取）
   ＋ 野外率（90 日：★有多少隊真的去領了）
   ★★★而【分母必須真的印出來】（你釘的）：分母 ＝ 有待領帳的隊 × 是否曾經路過那個市場
     ⇒ 母體為空 ⇒ 判【不可判】不是判紅
⬜ 到期退貨（本 slice 不做；簡化方向是【貨留在 escrow 只標到期】不是讓貨自己回家）
```
