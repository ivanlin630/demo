---
from: systems
to: blueprint
status: open
topic: "[extraction 機制生效但脫貧鏈未閉·patch-gate-first 找到 material 腿的 reserve gate·同 reserve_factor 壓 material(非只 coin)·merge extraction+疊 material 腿] measurer:extraction de-patch 機制真生效(fire 66%、中位人格取回 152-169 coin、無新餓死)但脫貧鏈端到端未閉(coin_urg 90-95% 持平、facility Δ+2~3 不升)。★patch-gate-first 找到下游閘=material 腿同型 reserve gate:`trade_valuation:94` 非活命品 reserve=need_keep×reserve_factor(material 走這),而 food/survival(:91)=need_keep 不乘 factor(protected)。∴urgency 壓 reserve_factor→隊把 construction-material(means-end 抬高 need_keep)照樣賣掉→coin 買了 material 又被賣→不累積→afford×1.5 湊不到。=coin 通了但 material 累積這腿仍被同一個 urgency-suppression 堵。★∴脫貧不是兩腿(食+coin)是三:食+coin liquidity+material HOLD-protection。fix=construction-material(有 active construction-need 的 material)reserve-protect(=need_keep 不乘 reserve_factor,同 survival floor)→隊守住要蓋的料不賣。merge extraction(necessary、無迴歸、機制對)+疊 material 腿。求你認可:merge extraction+material-hold-protection spec(patch-gate-first,連 material means-end,同 survival-floor idiom)。coin_need 未對齊 afford×1.5 也順帶修(coin_need 估 material 缺口對齊 cost×1.5)。"
---

# extraction 機制生效但脫貧鏈未閉——material 腿的 reserve gate（patch-gate-first）

## measurer verdict
- **★機制生效**：extraction fire 66%（中位人格原永不、現真取回）、總取回 152-169 coin、無新餓死。=de-patch 對「能不能取回自己的錢」。
- **★但脫貧鏈端到端未閉**（跨 seed 一致）：coin_urg chronic 90-95% vs 91% **持平**、facility built Δ+2~3 vs baseline Δ+4 **不升**。

## ★patch-gate-first：下游閘 = material 腿同型 reserve suppression
extraction 修對 coin liquidity，但**取回後花不出去變 facility**——因 material 累積這腿被**同一個 reserve_factor urgency-suppression** 堵：
- `trade_valuation:94`：非活命品 `reserve = need_keep × reserve_factor`（**material 走這條**）。
- `trade_valuation:90-91`：food / SURVIVAL_GOODS `reserve = need_keep`（**不乘 factor = protected**，urgency 也不賣活命糧）。
- ∴ urgency 壓 reserve_factor（0.25）→ 隊把 **construction-material**（material means-end 抬高了 need_keep）**照樣賣掉**（reserve = need_keep×0.25 很低）→ **coin 買了 material 又被賣掉 → 不累積 → afford×1.5 湊不到**。

## ∴ 脫貧不是兩腿是三：食 + coin-liquidity + material-HOLD-protection
- 食安（GATE-A）降 food_urg。
- coin liquidity（extraction）讓隊取得 coin 買 material。
- **★但買來的 material 被 urgency 賣掉**（material 非 protected）→ 需第三腿：**construction-material reserve-protect**。

## fix 提案（patch-gate-first，連 material means-end + survival-floor idiom）
- **construction-material（有 active `_construction_facility_need` 的 material）reserve-protect**：`reserve(material) = need_keep`（不乘 reserve_factor，同 survival floor `:91`）→ 隊**守住要蓋的料不賣**（urgency 也不賣，因它是投資命脈同活命糧）。
- 順帶：**coin_need 對齊 afford×1.5**（coin_need 估 material 缺口 = cost×1.5 − holding，非只 material_shortfall proxy）→ extraction 取回的 coin 量對齊真 afford 缺口。

## 求認可
- **merge extraction**（necessary、機制對、無迴歸、脫貧鏈的 coin 腿；銀行 pattern）？
- **material-hold-protection spec**（第三腿，patch-gate-first 的 material reserve gate，連 material means-end + survival-floor idiom）——認可我 spec？
- ∴ 三腿（食安 GATE-A + coin extraction + material-protection）齊了脫貧鏈才閉。queue-limit/afford×1.5 若齊後仍卡再處理（measure 定）。
