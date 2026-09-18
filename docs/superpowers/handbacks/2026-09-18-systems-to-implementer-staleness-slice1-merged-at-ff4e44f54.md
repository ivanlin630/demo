---
from: systems
to: implementer
status: consumed
slice: 位置 belief 過期線物理化 Slice 1
topic: ★**已 merge 到 `ff4e44f54`，後續請開新的 branch**｜★★閘 **65 支全綠／843s**，判決綁 `HEAD=88e69461d`，沒有印【不可判】｜★★★**R² 用探針挖到一個你我都沒看到的洞**：`tolerance_tiles` 的「忘了傳＝跑不動」**只罩靜態呼叫點** —— 裝進 `Callable` 動態呼叫再少傳參，**不報錯，是整個 process 卡死到逾時**
---

# 一、結果

```
main ＝ ff4e44f54（已 push）｜閘：65 支全綠／843s｜判決綁 HEAD=88e69461d
★後續請開新的 branch —— feat/belief-staleness-physical 上不要再疊 commit
```

# 二、★★★那個洞（已登 defer，不在本票修）

```
靜態呼叫少一參     ⇒ parse error ⇒ ★整支腳本連載入都失敗
                    ★★而 godot.ps1 自己的血證寫著：這種失敗長得像【卡住】不像【紅】
                    ⇒ 這正是【不該】把「寫一個壞呼叫」塞進共用床的鐵證（你的判斷對）
★★★Callable 動態呼叫少一參 ⇒ 不報錯，【整個 process 卡死到逾時】
                    ⇒ 引擎 metadata（default_args=0）完全罩不到這條路
```
⇒ ★**「必填、無預設值」是一個【只對靜態呼叫成立】的保證**，
而動態那條的失敗形狀是**逾時 ＝ 最難歸因的那一種**。
⇒ 已登 `defers.tsv::required-arg-guarantee-does-not-cover-callable-invocation`，
★★**開票的第一格我也寫了**：全庫有沒有人用 `Callable`／`call(`／`callv(` 呼帶必填參數的介面。

# 三、★R² 對那個「3」的打法，跟我以為的不一樣

```
我以為的風險：★那個 3 會過期（訊息對不上）
他指出的風險：★★1-f-② 的迴圈【只查點名的三個檔，不查全庫】⇒ 清單保證
   ⇒ 他全庫 grep 過：今天真的只有 3 個 —— ★★★而「今天是對的」與「它會繼續是對的」是兩件事
```
⇒ 已登 `defers.tsv::ttl-borrow-check-scans-a-list-not-the-repo`（修法：那個迴圈改成全庫掃，**而分母仍要印**）。
★**這一格排在 Slice 2 一起做**，不要現在回頭改。

# 四、★他核 1-e 的方式值得記

他**沒有只信你報告裡的 fp**：他自己 `diff` 過 —— `belief_system.gd` **純新增**、三處呼叫端**逐字換名值不變**
⇒ ★★**兩個獨立的證據指向同一個結論**（你的 fp ＋ 他的 diff），**而它們的血統不同**。

# 五、★我自己攔下的一格（寫給你看，因為它是同一個病）

我本來要在 merge **之前**把上面兩列 defer 登進表 ——
★寫完當場發現：**它們的 met_check 錨在【這一票才會出現的檔案／符號】上**
⇒ **在 merge 之前會被判成「病消失」** ⇒ ★★**那會是今天第四次假退役，而且是我自己造的**。
⇒ 通則：**新 defer 的 met_check 若錨在這一票才會出現的東西上，必須 merge 之後才登記。**

# 六、你下一張

**②掃一次、多段共用**（`one-pass-shared-scan`，spec 已 R² CLEAN）。
★**前提格先跑**：三支函式的迴圈體**剝註解後**若出現任何 `break`／迴圈內 `return` ⇒ **停下來回報，不要改判準**。
