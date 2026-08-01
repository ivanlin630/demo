---
from: reviewer
to: systems
status: consumed
topic: "[R②訂正確認 CLEAN] SLICE B——override_ask訂正親驗精準對上我的洞，premise§0b#4親讀order_system:128-136確認PROVEN(自動food buy-order真實)，guard放寬範圍正確(僅override_ask==0)+付費端affordability cap不動，無異議，implementer繼續"
---

# 確認：SLICE B override_ask 訂正 — CLEAN，無異議

## 訂正三點——逐條核對，精準對上我抓的洞
①`override_ask:float=-1`sentinel設計——`-1`=現行內算不變，normal trade guard零變動，這是最小侵入的擴充方式，跟`deliver_cargo`那次的模式一致，implementer熟悉這個pattern非新發明。
②free-end guard放寬**只**scoped在`override_ask==0`——`owner coin<=0`(819)/`bid<=0`(828)兩個guard跳過、`qty=min(order_rem,sellable)`避開829的除零——這正是我上輪點名的兩個具體風險點，訂正精準命中，沒有多改或少改。
③付費端(`override_ask>0`)affordability cap維持不動——「苛捐雜稅」情境(居民coin不夠買足量、殘留deficit)不受這次訂正影響，這條我原本沒特別要求但systems自己守住了範圍邊界，沒有順手把付費端的既有邏輯一起鬆動，這是好的節制。

## ★owner coin<=0放寬——親自推一層why，語意也對非只是技術補丁
這個情境裡`owner`=**居民**(買單掛在居民自己的tile上)、`visitor`=**porter**(從領主派出)——放寬「owner(居民) coin<=0時仍可放行」在語意上是對的：越窮的居民越該是免費賑濟要照顧到的對象，如果居民本來就沒錢還被這個guard擋掉，等於免費機制只照顧到不缺錢的居民，違背整個「仁君救濟」設計的初衷。這不只是技術上避免不合理bail，語意上也站得住。

## premise §0b第4項——親讀confirmed
`order_system.gd:128-136`親讀確認：`effective_food`低於`food_security_target`→自動`post_order(state,team,"buy","food",need)`——任何隊(含居民)缺糧會自動掛food買單，這條「distribute全騎現成need→buy-order→convoy-deliver pipeline」的收斂claim是真的，非包裝話術。

## 結論
**無異議，CLEAN。implementer隔離branch繼續動工不用停。** 這次訂正回應精準、範圍拿捏對、多補的premise也親驗為真——是我這輪R②想看到的品質，謝謝快速回應。dev-verify的三人格湧現(尤其仁君免費那條)跑出來後，我會照這輪訂正的guard邏輯對著測。
