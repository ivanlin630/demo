---
from: systems
to: measurer
status: open
topic: "[量測·經濟revive①刀真章] 成交條件液化@b0cdf624——★deals大幅回升?(resident路willing大多成交)+摩擦人格質感+活命糧不甩+守恆;數字tune到blueprint「willing大多成交」"
---

# 量測：市場成交條件液化（經濟 revive ①刀真章）

> **[worker 守則] 卡住/量不到/授權不明 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

branch `feat/market-liquidize` @ **`b0cdf624`**（base 最新 main）。systems 驗 diff PASS：SURVIVAL_GOODS(food+medicine)保 survival floor 不液化、非活命品 reserve 液化(RESERVE_BASE 0.6+人格 clamp)、ask/bid 人格化(急鬆手/貪守價)+SPREAD_TOL 0.05。TDD 9 綠+守恆+byte-identical、headless 3+3、sites=29。

## 這是經濟 revive 第①刀（5 層 measured 後首攻真 binding）
真根＝成交條件牆（deals=3 vs WOULD_TRADE 560，reserve==target 耦合+flat 死常數+ask 貼 bid）。液化＝流動為底、摩擦人格質感。**驗市場首次成交。**

## 要驗（★中性 full-HD，before[main]/after[branch] 對比）
1. **★deals 大幅回升（headline）**：`trade.deal`/`deal_resident` 從 **3** 大幅升（resident 路 willing 對成交，merchant 路 co-locate 待第②刀故仍 arb_hit~0 正常）。WOULD_TRADE→實際 deal 對齊率升。
2. **摩擦人格質感**：談崩變**少數 + 人格可讀**——貪婪賣方守價談崩 vs 急/絕境鬆手成交（specimen 差異）。非「無腦全成交」也非「全死牆」。
3. **★活命糧不甩**：絕境隊 food/medicine 不因液化甩到餓死/病死（reserve survival floor 保）——**驗絕境隊沒賣光活命糧**。
4. **★守恆**：CoinAudit delta=0、InvariantAudit=0。
5. **無回歸**：同 seed 兩跑 bit-identical、憲法 sites=29、headless 零新增。
6. **tune 空間**：deals 若回升不夠（液化不足）or 過頭（無腦全成交無摩擦）→ 回報數字，systems tune TEST VALUE（RESERVE_BASE/SPREAD_TOL/人格 K）到 blueprint「willing 大多成交、摩擦少數質感」。

## 判定
- deals 大幅回升 + 摩擦質感 + 活命糧不甩 + 守恆 → **成交牆破、resident 市場首次活** → handback `to:blueprint`（deals 前後 + 摩擦分布 + 活命糧安全 + 守恆）→ QA → blueprint 批 merge → 第②刀 merchant 完成 trade。
- deals 仍~0（液化沒接對 or 更深牆）→ halt `to:systems`（貼數字）。
- 活命糧被甩（絕境餓死/病死升）or 守恆破 → 硬 halt。

## 下游
數字一封信 `to:blueprint`。溯源 raw + measured_at_head `b0cdf624`。log/jsonl UTF-8。**注**：merchant 路仍死屬預期（第②刀），本刀只驗 resident 路成交條件液化。
