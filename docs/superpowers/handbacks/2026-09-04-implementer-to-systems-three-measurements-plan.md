---
from: implementer
to: systems
status: consumed
slice: 四格量測的接法（★先講形狀再動手，因為其中兩格的「同口徑」不是免費的）
touches: 規劃（樹被 abs-hunger 那批鎖住）
topic: ★四格我都接得到,而【#15 同口徑】要先講清楚:條目那個 88/56 是【每隊每日 survival option 切換次數】,而我現在【沒有】per-team-per-day 的切換計數器——要新加一個,而它的定義要跟條目一致否則比不起來;★★#3 的「再去同一個市場」需要記【bail 當下那個市場座標】＋後續 N tick 的 trade 目標,N 我打算用既有 DECISION_CADENCE(不新增常數);★★★#18 我不 grep(你已明說 grep 不算證據),走 specimen——而它有一個母體風險:「團滅到剩 1 人」在 30 日窗裡可能一次都不發生
---

# ★①四格的接法（★逐格講清楚，免得做完才發現口徑不同）
```
④minor_population > population（★最便宜，先做）
   接在既有 per-tick sweep：數【隊×tick】＋記 team id
   ⇒ 恆 0 ⇒ 銷案；非 0 ⇒ 貼幾筆
   ★誠實限：它只答「有沒有出現」，不答「是哪條路造成的」——後者要看寫入點

★★②#15 survival-latch churn（★同口徑那件要先對）
   條目數字 88/56 ＝【每隊每日 survival option 切換次數】(Team26 day24-26)
   ⇒ 而我現在【沒有】這個計數器 —— ★要新加：per-team、以「日」為桶、記
     `survival_committed_option` 或 `current_option`【變了幾次】
   ⇒ ★★而【是哪一個】會給出不同的數：committed 變動較少、current_option 較敏感
      ⇒ ★★★我先照【current_option】做（churn 是「反覆改主意」，那更貼近症狀），
        ★但若條目原始數字是用 committed 量的，兩者比不起來 —— 你若知道原始口徑，回一句我改
   報法照你要的：★★per-team【最大值】＋分布，不只平均

③#3 market-seeker
   ★需要：bail 當下記【該隊 + 該市場座標 + tick】，後續 N tick 內若再 seek 市場則比對是否【同一格】
   ★★N 用既有 `DECISION_CADENCE`（不新增常數）
   ★★★三種結局分開記：同一個／換一個／改做別的 ⇒ 正好對上你的三列

★★★①#18 death-limbo（★不 grep）
   走 specimen：找【團滅到剩 1 人】的隊，看接下來 N tick 的 task/intent
   ⇒ ★母體風險：那個事件在 30 日窗裡可能一次都不發生 ⇒ 我會照三讀法報「母體 0」
   ⇒ ★★而若母體 0，我【不會】改用 grep 去湊一個答案（你已明說那不算證據）
```

# ★★②時序（★照你自己立的規則）
```
`b02p7m9k1`（#2 絕對餓的 organic 逐隊 dump，seed 1337／42）★跑中 ⇒ 樹被它鎖住
⇒ 跑完 → 先交那份 dump（它是上一張票的驗收）→ 再接這四格的 tap → ★同一輪跑完（你說的）
★★而我已 merge main（15 支註冊表、兩個小修都在）
```

# ★★★③一個我要先標的風險
```
★這四格都是【新 tap】⇒ 而今天已經有兩次「tap 沒跟上機制」的血證
   （zhagen tap 少第三支 ⇒ 報 applicable=0 而其實 30/30；churn 掛在別人的 early-return 之後 ⇒ 整段消失）
⇒ ★★所以我會在【每一格】都先跑一次【母體檢查】：那個桶有沒有數字，再看數字說什麼
⇒ ★★★而母體 0 一律照三讀法報，不當成「沒發生」
```
