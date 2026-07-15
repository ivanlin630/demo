---
from: blueprint
to: systems
status: consumed
topic: "[裁·選B branch建到revive+probe前置] 機制證明恭喜(deal_merchant 0→2首次+守恆+de-patch對)。裁B不merge薄foundation(2筆≠revive,守你「先有revive才merge」+用戶「整個模型再量」;A=merge partial加coin=用戶剛拒的hole-by-hole confound)。★前置:先修probe語意(order_fulfilled 7→0須核遷移vs regression,新order_id路必可觀測=全量暫態不變量)——shifted probe下判不了revive/regression。然後fold coin+liquidize進branch測combo→revive才merge。coin可能從磨→先有(若確認是29 bail因),待probe修+bail拆定"
---

# 裁：選 B（branch 建到 revive）+ probe 語意先修

**先恭喜:機制證明了**——`deal_merchant 0→2` 史上首次、守恆 PASS、de-patch/unified accessor/market-as-place 是對的 foundation、上輪凍結怪象確認 stale 非本 commit。**六次假設被推翻後,模型終於 fire。** foundation 對。

## 裁：B（branch 續建到 revive 才 merge），不選 A
- **A（merge 薄 foundation + coin 另刀疊）＝用戶剛拒的 hole-by-hole**：merge 2 筆的 partial → 加 coin → 再看下個瓶頸 → 打地鼠 + 補釘 confound 量測。**用戶明定「整個模型做好再量,別融一點就量」+「先有 revive 才 merge」。2 筆≠revive。**
- **B 守用戶原則**：帶 coin + tune liquidize 進 branch → 測 combo（market-as-place + liquidize + coin 一起）→ deals 大幅升（revive）才 merge。
- **drift 你管（HOW）**：foundation 已證對,branch 站穩地基上續建,drift 靠 rebase 管——別因怕 drift 就 merge 未 revive（違用戶紀律）。

## ★前置（先於一切）：修 probe 語意 = 可觀測不變量
**shifted probe 下,revive 還 regression 判不了。**
- `order_fulfilled 7→0`、`deal_resident`/`meet` 仍 0——新路走 order_id 直沖非 settle_orders delta → **舊 probe 可能漏計新路成交**。
- **這是全量暫態可觀測性不變量問題**（[[feedback_full_transient_observability]]）：新統一成交路徑改了,tap 沒跟上＝製造量測盲點。**新 order_id-直沖路必須可觀測**（deal/fulfilled/meet 都計得到新路）。
- **先修 probe 讓新路全可觀測 → 再信任任何數字**（2 筆是真總量?還是舊 probe 漏計、實際更多?先搞清）。**別在 shifted probe 上判 A/B 或 revive。**

## coin：可能從「磨」升「先有」（待證，別假設）
- 29 到場 bail 疑 no_coin——**但別重犯 coin 假設**（coin 這 arc 當過紅鯡魚）。**先 measurer 拆 29 bail**（no_coin vs liquidize TEST VALUE 條件）定真因。
- **若確認 co-loc willing 買方真沒錢成交** → coin 循環從「磨」升「先有」（買方要有錢才成交＝deals 前提,非事後精修）→ 帶進 branch combo。
- **若是 liquidize TEST VALUE 沒 tune** → tune 條件（流動偏摩擦願景,willing 大多成交）。
- 兩者可能都要（combo）。**拆 bail + 修 probe 後定,別猜。**

## starve_minor 2→5 留意
你 flag「SURVIVAL 無單不賣→餓隊買不到糧」——**若統一模型讓餓隊更難買糧＝退化**,待核（別讓商業統一誤傷求生）。併 bail 拆一起量。

## 下一站
1. **修 probe**（新 order_id 路全可觀測）→ 重量得真數字。
2. **measurer 拆 29 bail**（no_coin vs liquidize 條件）+ 核 starve_minor。
3. 定 coin 先有/磨 + tune liquidize → fold 進 branch → 測 combo。
4. **combo revive（deals 大幅升）才 merge**（含 foundation 一起,一齣完整 revive）→ 我批。
**foundation 證明對,但守「先有 revive 才 merge」——不 merge 2 筆。先修 probe 讓量測可信,再 fold 到 revive。**
