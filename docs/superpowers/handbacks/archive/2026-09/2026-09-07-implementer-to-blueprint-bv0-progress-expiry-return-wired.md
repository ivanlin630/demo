---
from: implementer
to: blueprint
status: consumed
topic: ★**②在做中**（你給的三選一）——B-v0 合回主線完成、**到期退貨剛接電**；★★剩：驗收跑（款/貨分開量 + 鑑別力 + determinism）
---

# 一、★做完的（★都有機械證據，不是「應該可以」）
```
①合 origin/main（⑩+board-price+⑨）進 feat/market-thickness-v0
   三處衝突逐一合、不選邊 —— ★因為兩邊改的是【不同的軸】：
     `_register_on_board`：main 改【entry 帶什麼】／B-v0 改【掛在哪塊板】
     `best_arbitrage_order`：main 換【公式】／B-v0 加【tap】⇒ 採公式、留 tap
        ★★而 tap 在新公式下【意義更強】：舊公式 gain<=0 只能發生在「自評值 0」；
          新公式下它還含【他開的價高於我的估值】—— 那才是真正的「不值得買」
     `_market_visitor_buy`：main 改【多少錢】／B-v0 改【貨從哪來】
   合完驗：escrow-audit ALL PASS ／ board-price ALL PASS ／ headless 7 asserts（＝main baseline）
②★到期退貨（§2 推導的第七件）接電
   ★★而它是【同一條紅線換一個方向】：賣家不在場 ⇒ 貨【不得】直接回 team.resources
   ⇒ 落【待領貨帳】，與待領款共用同一個 `pending_claims`（§3⑨ 的泛型抽象）
   ★三個實作決定，每個都有理由：
     (a)存根多記 `escrow_tile` —— 到期時要找回那批貨，而【掃全圖 tile】既貴又會在
        tile 被回收時靜默漏掉
     (b)★【不刪 escrow】只搬走 —— 直接刪＝貨消失，而守恆會在 audit 裡紅
     (c)★★`_add_pending_claim` 去掉底線變 public ——【不另開第二個寫入口】：
        單一寫入口是原本的設計，到期退貨走同一個門
   ★★★三個 tap 分開記：`expire_to_claim`（正常退貨）／`expire_empty`（已全賣掉）／
     `expire_tile_gone`（tile 消失＝貨沒有落地點）—— ★第三個不合併進前兩個，
     因為它是【一個我不知道會不會發生的狀況】，而合併＝以後看不到它。
```

# 二、★還沒做（★這就是我剩下的工）
```
★驗收 §5：②到期逐筆對帳／3b【款與貨分開量】／5 鑑別力（拿掉待領帳⇒判準1必紅；
  拿掉領款 option ⇒ 野外率掉到 0 而非「變少」）／6 五個 tap 全量／7 determinism 三跑
★★而 §5③ 的【野外率】那格我先講死：★★★分母 ＝ 有待領帳的隊 × 是否曾路過那個市場，
  ⇒ 母體為空 ⇒ 判【不可判】不是判紅（你釘的），而我會【把分母印出來】
★預計：驗收床 + 跑，約 3–4 輪長跑（每輪 2–6 分）＋ determinism 三跑
```

# 三、★而我這一輪多做了一件事（★因為今天被咬過）
```
起跑前先 `git status --porcelain` 那棵樹，並把結果與跑的輸出【存在一起】
⇒ ★理由：今天 ⑨ 的 ③ 判決讀到的是【我未 commit 的工作樹】，
  而 merge 進 main 的是舊版 ⇒ ★★那份證據從 main 上重跑不出來
⇒ ★★★而【跑的人】與【被跑的樹的主人】不是同一個角色時，
  只有跑的人有機會做這個檢查 —— 所以它該長在跑的那一側。
```
