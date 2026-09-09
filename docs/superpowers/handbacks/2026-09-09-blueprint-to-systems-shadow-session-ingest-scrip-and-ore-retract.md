---
from: blueprint
to: systems
status: consumed
slice: 影子藍圖兩顆 commit 收編(c6a48383/96988f70)
topic: ★正藍圖已審+canon 已同步(意圖帳「貨幣四幕+軍票」row 改寫);給你四件:①關 defers `ore-depletion-counter`(前提不成立)+該列觸發 grep 對現況盲(`depletion`≠`harvest_deplete` 子字串=守衛母體沒驗同型)②礦枯竭量測票(qty.harvest_taken.ore_gold 累計 vs worldgen 初始總量,90/180 天採掉幾成)排空檔③軍票 HOW 待查一格:交易回覆有無「部分接受+餘額」形狀④兩個我審出的地雷,進未來軍票 spec 的必守格
---

# ①defers 收尾

`ore-depletion-counter` 關(證據 resource_system.gd:458+184+faction_ai:5207,影子場已三驗,
我今天獨立讀 code 同結論)。★該列觸發檢查 `git grep 'depletion\|remaining_yield'` 對現況盲
——真 reason 字串是 `harvest_deplete`。守衛輸入母體沒驗證家族第 N 例,修 grep 或直接關列。

# ②礦枯竭量測票(排空檔,非急)

gain∝current=指數衰減永不精確歸零⇒「三幕能否在可玩時距走到錢荒」是量測題非設計題:
`qty.harvest_taken.ore_gold` 累計 vs worldgen 初始總量+`g1.mint` 何時停。90/180 天窗。

# ③軍票 HOW 待查(影子場標的,轉正式)

現行交易回覆有沒有「部分接受+餘額」形狀(還債 offer 的「餘 70」訊息依賴它)?二元收/拒的話
賒帳形狀§9 的前提缺一塊——只查不做。

# ④我審出的兩個地雷(未來軍票 spec 必守格)

```
a. trust 查表禁 default 常數 fallback:trust[NPC][票] 是 belief 欄位⇒三態
   (有值/過期/從未觀察),未知=不通過=拒收(誠實第三態)。
   ★禁 Dictionary.get(key, 0.5) 式中等預設——今天貧婪 typo 案(恆 0.5 三個月沒人發現)
   同族,value-key-gate 的正典比對應涵蓋票 trust 鍵。
b. 發行者「收回自票再花出去」的記帳:錨≡1 使回收=銷毀,但若發行者收回後重新支付,
   必須記成新發行(issued++),否則稽核式 issued==redeemed+outstanding+defunct 兩頭都對
   但 outstanding 實際被低估。spec 時把「re-spend=再發行」寫死。
```

# 審查結論(備查)

96988f70 十條裁定憲法全過:trust=belief 非 god-view/印票走秤禁公式/匿名防呆/
資產配念頭三件套齊(腦欄位=trust belief、秤 option=印票+用票付、床四格都能紅)。
c6a48383=誠實自撤,與我今日獨立驗證一致。canon 同步完(意圖帳 row 改寫,本 commit)。
