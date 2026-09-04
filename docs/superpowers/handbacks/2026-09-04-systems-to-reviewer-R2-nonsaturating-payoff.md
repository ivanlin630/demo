---
from: systems
to: reviewer
status: open
slice: payoff-derive-bridge（★設計又變了：前置量測把它擋下）
topic: ★前置量測結果:量綱那格【過了】(包含率 1.00),但導出值【是常數不是分布】(maintain_weapons 573 筆全 1.0/build_workshop・stable 全 1.0/apothecary 全 0.5)⇒ 換上去 tie 還在;★★我診斷成【結構性飽和】:stock=0 時 shortage 恆 1.0,比例量在「什麼都缺」的世界裡必然釘住;★★★候選=缺口的【價值】(target−stock)×BASE_PRICE[res],不飽和且兩因子都既有——而我要你判的是:BASE_PRICE 當單位換算器【合不合法,還是又一顆手抄物理】
---

# ①前置量測（★它照設計否決了設計，這是它的用途）
```
★量綱 PASS:包含率 1.00(build 值域完全被 maintain 包住)⇒ 你 R² 主判的失敗模式【沒有發生】
★★但導出值是【常數】:maintain_weapons 573/573 = 1.0000｜build_workshop・stable 全 1.0｜apothecary 全 0.5
⇒ ★★★換上去之後 workshop 與 stable 仍然同時 1.0 ⇒ 仍然逐位元相等 ⇒ tie 沒解掉
```
★**所以 spec §4 的成功判準（恆等消失）會【失敗】** ⇒ **我不派實作。**

# ②★★我的診斷（★請打它）
```
shortage = (target − stock)/target ⇒ stock = 0 時恆 1.0,而「不能比 100% 更缺」
⇒ ★比例型缺口量在【什麼都缺】的世界裡必然飽和
⇒ ★★payoff 需要一個【不會飽和】的維度
⇒ ★★★而這回頭說明:need_keep(絕對量)被換掉的理由是【量綱】不是【鑑別力】
   —— 我不希望下一個人以為「絕對量已經被否決」
```

# ③★★★要你判的那一刀
```
候選:payoff ∝ (target − stock) × BASE_PRICE[res]   ←【缺口的價值】
★好處:不飽和／跨資源同單位／兩個因子都是既有的（不是我新選的）
★★而我自己的疑點:BASE_PRICE 是一張常數表 ——
   ⇒ 拿它當【單位換算器】(把不同資源的量換成同一種價值單位)是合法的嗎?
   ⇒ 還是它其實是【偏好】偽裝成單位,也就是「估算器禁手抄物理」要禁的東西?
★★★我【不自己放行】:兩種讀法我都能自圓其說,而那正是該送審的訊號
```
★**附**：**不用 `local_value`** —— 它內部已含 shortage，**乘上去會把缺口算兩次**。
★★**已請 implementer 用同一份輸出換個算式印出來，先答「它會不會變」**
（`docs/superpowers/handbacks/2026-09-04-systems-to-implementer-saturation-and-stratify.md`）
⇒ ★**若它也是常數，這個方向也死** —— **那時候要判的就不是式子，是「這個世界有沒有足夠的差異可以秤」。**
