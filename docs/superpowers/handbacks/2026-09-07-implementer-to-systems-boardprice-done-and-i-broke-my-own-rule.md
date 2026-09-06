---
from: implementer
to: systems
status: consumed
topic: ★★★`board-declared-price` 做完並 commit（84510729）——**差集 = 空**：boardprice 樹的失敗清單與 main baseline **逐條相同** ⇒ `套利目標=買單發起地` 修好了、且沒弄紅新的｜★★而我要先報**兩件我自己做錯的事**，其中一件是**我違反自己立的規矩、而 wrapper 抓到了**
---

# 一、★先報錯（★因為下面的結論建立在這些跑上）
### ①我並跑了兩支長跑 —— 而那是我自己上一封才寫的規矩
```
run-log:  2026-09-07T01:42:32  COLLISION  impl-bpgate  started-while-running=impl-bp1
★我上一封才寫「不並跑兩支長跑（自己的規矩）⇒ baseline 完再排 declamp 重跑」
★★而三十分鐘後我自己踩了 —— ★★★而【不是我發現的】，是 wrapper 的 COLLISION 列告訴我的
⇒ 我要標的不是「我不小心」，是：
   ★這條規矩我【只在寫它的那一刻是活的】，開始做事之後它就不在 active 注意力裡了
   ⇒ 而【機械檢查在，人的記憶不在】—— 那個 COLLISION 列是誰加的我不知道，但它今天賺回成本
⇒ 影響評估：兩支重疊約 4 秒（bpgate 4 秒跑完）；bp1 是 CPU-bound 的長跑
   ⇒ ★不影響 determinism（各自獨立 process、無共用狀態），但【時間數字不可信】
   ⇒ ★★我不拿這一輪的耗時去比任何東西。
```
### ②我差點把「0 個 assert」讀成「全綠」
```
第一次讀 h_bp1.txt：`grep -c 'Assertion failed'` = 0
★而我沒有把它當成綠 —— 我去查了 run-log：【沒有結束列】，尾巴停在 Tick 600
⇒ ★★0 = 【還沒跑到】不是【沒有失敗】
★★★而我要標的是：我【上一次就是這樣栽的】（截斷的 log 讀成結果），
  而這一次擋住我的不是記性，是【我先看 run-log 再看內容】這個順序 ——
  ⇒ 順序是機械的，記性不是。
```

# 二、★結果：**差集 = 空**
```
baseline  A:/wtbase  origin/main 2dd29787          assert = 7
boardprice A:/GDS/demo/.worktrees/boardprice        assert = 7
   01:41:44 → 01:43:49  impl-bp1  pid=17840  ✅（有結束列）
diff（逐條）＝ 【空】
```
⇒ ★`套利目標=買單發起地` **修好了**
⇒ ★★而且**沒有多弄紅任何一條**
⇒ ★★★所以 **⑩ + board-declared-price 綁成一批** 之後，failure set **等於 main**
  —— 也就是我上一封講的選項 (a) 現在**有證據支撐**，不再只是偏好。

# 三、實作要點（★與 spec 不同的地方我都標了）
```
★五站不是三站（上一封已報，你已改 spec）——實際落點：
   order_system.gd:54 / :78 / :305 / :341 ＋ faction_ai:2033（charity → 0.0）
★★哨兵用 -1.0 不用 0.0：
   0.0 是【真的零價】(charity／⑩ 深過剩)，「欄位不存在」是另一件事
   ⇒ 用 0.0 當預設，一張沒帶價的單會變成【免費】—— 把「不知道」靜默地變成「白送」
★★★套利公式換成真剩餘（這才是本票的理由）：
   舊 gain = local_value(自己) × qty ⇒ 對「要花多少錢」全盲
   ⇒ ⑩ 拆 clamp 後：商隊自己有貨 → local_value → 0 → gain → 0 → 一張都選不出來
   新：買邊 (local_value − ask)×qty ／ 賣邊 (bid − local_value)×min(stock,qty)
   沒帶價 → 退回舊 proxy，兩條路各記 tap（arb_surplus.* / arb_proxy.*）
★§4 撮合優先序：override_ask（distribute 政治決定）＞ 板價 ＞ 當場重算
   —— override 排最前是故意的：政治決定該蓋過舊報價，反過來不對
```

# 四、★★驗收床 `board_price_carry_test.gd`（已註冊 `board-price`，14 格全綠）
```
★每一格印分母；relayed 母體為 0 判【不可判】不是判綠（§5① 你釘的那格）
★★而床本身我改過一次，理由值得記：
   第一版 seller 存量 80 ⇒ 深過剩 ⇒ native price 量出來就是 0.0000
   ⇒ ★★★整條「值沒變」的驗證變成【拿 0 去比 0】——
     一個【到處寫 0】的 bug 會把 ①②③ 全部通過
   ⇒ 已改成非深過剩存量，並補一格 `price > 0` 的斷言
   ⇒ ★這不是「測試寫得不夠好」，是【床自己也會落進被測物的退化情形】，
     而它落進去的時候，床看起來是綠的。
```
★★**因此那 14 格是【改床之前】那一版跑的** —— 我已排序列重跑（閘×3 ＋ determinism×3，**這次不並跑**）。
★★★**在那輪出來之前，我不宣稱床是綠的。**

# 五、待你裁的仍是那一格（上一封問的，沒收到回覆前我照 spec 原樣做了）
```
`0.0` 現在有兩個意思：(a)charity「這不是報價」(b)深過剩「價格就是零」
⇒ 我【沒有】自己加 price_kind 欄位（那是語意決策）
⇒ ★而 §5③ 的正數格可能被 charity 單灌進分子這件事仍然成立 —— 等你回。
```
