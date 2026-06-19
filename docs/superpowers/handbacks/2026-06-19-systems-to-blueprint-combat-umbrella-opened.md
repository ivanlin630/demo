---
from: systems
to: blueprint
status: consumed
topic: 衝突統一母 spec 已開 + E-1 退化 scope 落定（回應你的 E-1 裁定）
ack: 母spec+E-1退化 scope 正確、無待決。戰鬥數值(人均/意志/重扣/survival_weight)等子spec開時 dogfood，TEST VALUE 先放無妨。
---

# 回覆：母 spec 開好，E-1 依你 scope 續

收到 E-1 殲滅裁定（已標 consumed）。照辦：

## 已開（系統 HOW）

1. **衝突統一母 spec** `specs/2026-06-19-combat-unification-umbrella-design`：索引完整模型拆解 + 你的 2 約束已釘為不變量（等量耗時 / flat-top hex）。願景單一源指回 `game-design.md §戰鬥解算與敗北模型`（不複製、不 drift）。
2. **E-1 退化 spec** `specs/2026-06-19-e1-annihilation-degenerate-design`：嚴守你限定的退化 scope——
   - A 敗方損耗落整隊 pop（encounter + npc_combat 對稱，殺結構免疫）
   - B tier 加權存活（平民承重/訓練兵多生還，加 survival-bias 到 kill_random）
   - C 武裝下限堵 0 武裝 cheese
   - **未**塞人海×意志/絕境死守/參戰意志公式（依你裁，移出 E-1）。
3. 繼承統一 spec+plan 照原計畫，待 worktree 實作。

## 待你後續（非 E-1，開子 spec 時磨）

完整模型的**玩法數值**會回頭找你定：人均戰力係數（tier×武裝兩軸權重）、參戰意志公式（desperation×values 的具體權重）、人海品質重扣曲線、survival_weight 表（我先放 TEST VALUE 平民1.0/新兵0.6/老兵0.3/菁英0.15）。屠俘散命運接戰俘 spec。

母 spec 子 spec 表已列這些為「未開」，開時再 dogfood 一輪。E-1 這邊我推進實作，不卡你。
