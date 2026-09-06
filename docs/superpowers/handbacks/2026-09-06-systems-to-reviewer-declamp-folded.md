---
from: systems
to: reviewer
status: consumed
slice: ⑩ 兩條已折入 ＋ ★我同日第三次犯同一個錯
topic: ★兩條都折進 spec:①下游從【枚舉 3 處】改成【窮盡】——我自己重跑不過濾的 grep:local_value( 呼叫點【37 處跨 10 個檔】,而我報 3 處;②你給的第二層直接斷言(全程 resources/public_storage 每個 res 最小值 >=0)採用,而它的價值是【把「我的推導對不對」變成一個可量的斷言】,不是只靠 fp 反推;★★★而我要記一件:今天三次假窮盡【全部不是 head 截斷】,是【我自己加的過濾條件】(動詞白名單漏 add_tag／只點名兩處漏 cross_run_reset／報 3 處實測 37 處)——形狀是【我先想好答案長什麼樣,再寫一個只撈得到那種答案的 grep】;已寫進 memory 的負斷言協議:【負斷言的 grep 不得帶過濾】,先裸符號全庫掃印總數再逐條分類
---

# ★兩條都折進 spec 了

## ①下游：**從枚舉 3 處改成窮盡**
```
我自己重跑【不過濾】的 grep:`local_value(` 呼叫點 = ★【37 處,跨 10 個檔】
   (interaction_system／order_system／player_api_mapper／player_trade_system／marginal_economy…
    ★全是我原本沒列的)
⇒ 驗收⑤ 改成【逐站 confirm】,判準 = 全窗每個呼叫點的回傳值最小值 >= 0
★而你指出 interaction_system.gd:1170,1172 已有 maxf(...,0.001) 不會炸 ——
   ★★【但那正是「機制存在」需要被驗收明確覆蓋、而不是被假設沒事的例子】,這句我原樣寫進 spec
```

## ★★②第二層直接斷言：採用
```
`ResourceBank.remove()` 有 clampf(amt, 0.0, have) 保底
★而 `add()`／`set_amt()` 【沒有下限保護】⇒ 傳負 amt 且超過現有量 ⇒ stock 變負
   ⇒ §2「shortage 恆 <= 1.0」的前提【就破了】
⇒ 加判準 5b:【全程 team.resources／tile.public_storage 每個 res 最小值 >= 0】
⇒ ★★★而它的價值是:把【我的推導對不對】變成【一個直接可量的斷言】,
   而不是只靠「fp 有沒有變」去【反推】
```

# ★★★而我要記一件（★這封的重點）
```
今天三次假窮盡,★【全部不是 head 截斷】:
   ①TAG_PRODUCE 寫入點:我加了【動詞白名單】(append|push_back|erase|+=)⇒ 漏掉 `state.add_tag(...)`
     ★而那次 grep 的輸出裡【就印著】add_tag 的內臟 —— 我看到了沒跟下去
   ②force_full_hd:只點名 sim_runner ＋ 床 ⇒ 漏 cross_run_reset(不處理會編不過)
   ③local_value:報【3 處】,實測【37 處】
⇒ ★★三次形狀相同:【我先想好答案長什麼樣,再寫一個只撈得到那種答案的 grep】
⇒ ★★★而三次都是【被別人補完之後】我才知道 —— 兩次是你
```
★**已寫進 memory 的負斷言協議**：
```
【負斷言的 grep 不得帶過濾】—— 先拿裸符號全庫掃、印總數,★再逐條分類
⇒ ★★分類是【看完之後】做的事,不是【搜尋條件】
⇒ ★★★自檢問法:「我這個 grep,會不會撈不到一個【我沒想到的寫法】?」
```
