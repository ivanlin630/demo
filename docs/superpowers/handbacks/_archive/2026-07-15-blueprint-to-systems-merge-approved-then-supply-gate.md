---
from: blueprint
to: systems
status: consumed
topic: "[merge授權·用戶定A+閘] 用戶拍merge貿易foundation+coin(機制證明+coin雙向+守恆,blocker移到生產子系統故revise「revive才merge」)。閘:①reviewer R②必過(大框:market-as-place+accessor統一+de-patch+coin多層)②probe語意先核(order_fulfilled 7→0=遷移非regression,新order_id路可觀測=全量暫態不變量)③誠實merge標「機制+coin通,供給sell_no_surplus待生產arc」。然後patch-gate-first供給牆(真沒surplus vs gate擋賣單如SURVIVAL無單不賣/餘量門檻)→定決定2甲(建surplus經濟)/乙(接受薄貿易)。coin確認從磨升先有"
---

# merge 授權（用戶定 A）+ 三閘 + 供給 patch-gate-first

用戶拍 **merge 貿易 foundation+coin**（決定 1＝A）。理由對齊：機制證明對（deal_merchant 首次非零）+ coin 雙向流 -99.9% + 守恆 PASS,**revive-blocker 已移到「生產」子系統（sell_no_surplus）——「revive 才 merge」對「貿易層沒通」成立,現貿易層通了故 revise,避正確大 refactor 爛 branch drift。**

## merge 三閘（過了才 merge，別直收）
1. **reviewer R② 必過**：大框結構重構（market-as-place + accessor 統一 + de-patch + coin 多層），spec/設計對齊審 CLEAN 才 merge。**這是每 slice 必過的閘,大框更要。**
2. **probe 語意先核**：`order_fulfilled 7→0` 須核是**遷移非 regression**（新路走 order_id 直沖非 settle_orders delta → 舊 probe 可能漏計）。**新 order_id-直沖路必須可觀測**（deal/fulfilled/meet 計得到新路）＝全量暫態可觀測性不變量。**核清無真 regression + 新路可觀測,才 merge。**
3. **誠實 merge 標**：commit/handback 明標「**貿易機制通 + coin 通（私囊鎖治對）;供給側 sell_no_surplus 待生產 arc**」——不吹市場已 revive（deals 仍低）。

## coin 定位確認：從「磨」升「先有」
coin combo 大勝證實 coin **是 deals 前提非事後精修**（no_coin -99.9% 才讓機制真跑）→ coin 循環正式列「先有」,已在 branch,隨 foundation 一起 merge。

## 供給 patch-gate-first（決定 2 的前置，先查再定）
`sell_no_surplus 51.7%`＝訪客到市場沒貨賣。**別假設「世界稀缺」——先 patch-gate-first：**
- **是 gate 擋賣單?**（你 flag 的 `SURVIVAL 無單不賣` + starve_minor 2→5;或餘量保留門檻太高 → 有貨但不掛賣單）→ **de-patch**（決策交人格秤,別硬 gate），供給可能就冒出來。
- **還是真沒 surplus?**（producer 產能=自用即耗,根本無餘糧 / TRADE 隊無 inventory chicken-egg）→ 這是**真經濟實質稀缺** → 升藍圖決定 2（甲建 surplus 經濟 vs 乙接受薄貿易）。
- **先查是哪個,別逐層盲剝**（~10 層已夠深,患 rabbithole）。gate→你 de-patch;真稀缺→回我+用戶定甲/乙。

## 下一站
1. reviewer R② 審貿易 foundation → CLEAN
2. 核 probe 語意（無 regression + 新路可觀測）
3. **merge foundation+coin**（誠實標供給待）
4. **patch-gate-first 供給牆**（gate vs 真稀缺）→ gate 則 de-patch;真稀缺則回我+用戶定決定 2
**貿易 arc 落地,供給 arc 開查。coin 收線大勝。**
