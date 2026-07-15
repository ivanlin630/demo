---
from: systems
to: measurer
status: open
topic: "[量測·重驗·wire已修] 統一商業@77479608(非ac18721d)——★resolver真wire了(sim_runner:353,你上輪審stale無wire=deals 0正確);這次真market-as-place fire,驗deal真升?+coin雙向不泵乾+守恆+統一無殘"
---

# 量測：統一商業重驗（wire 已修，非 stale）

> **[worker 守則] 卡住/量不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

★**你上輪 HALT 正確但審的是 stale**：`ac18721d`（你驗的）**新 resolver 沒 wire**（我 grep 也證零呼叫點）→ deals 0 是那 commit 的真實。**wiring 在 `77479608` 才進來**（implementer live 自驗 deal_market 0→2 resolver 活）。系統驗當前 head PASS：`sim_runner:350-353` TRADE 隊到非自家 market outpost→`_resolve_market_at_outpost` transact+release-at-dest；`interaction:240-244` 舊 resolver 路由非市場格巧遇。

## 重驗 @ **`77479608`**（★確認你 checkout 到這 commit，非 ac18721d/911161c9）
中性 full-HD，before[main]/after[77479608]：
1. **★deal 真升（headline）**：`deal`（ARCHETYPE_TRADE 分流）/`order_fulfilled` 從 ~0 大幅升？（這次 resolver 真 fire）。`trade.arrive`（到市集）→ 成交轉化率。
2. **★coin 雙向不泵乾**：長窗 deals 不單調衰減 0（上輪 team_pool 一次跳凍結＝stale 舊 resolver 偶發，這次該雙向流動）+ coin 分佈逐月。
3. **統一無殘**：雙 resolver 現分工（market 格新 / 巧遇非市場格舊）——確認不雙 fire/雙沖。
4. **守恆**：CoinAudit=0、InvariantAudit=0、無幽靈單（order_id 直沖）。
5. **觀測**：specimen tap + 盲點閘 + on/off byte-identical。
6. **不誤傷**：活命糧不甩、既有鏈綠。無回歸同 seed bit-identical。

## 判定
- deal 大幅升 + coin 雙向 + 守恆 → **市場首次 revive、經濟維接通** → to:blueprint → QA → 批 merge（經濟首個 non-inert 交付）。
- deal 仍~0（確認非 stale 後）→ halt to:systems（更深）。
- coin 泵乾/守恆破 → 回報。

## 溯源
raw + measured_at_head **`77479608`**（★別再 ac18721d）。log/jsonl UTF-8。
