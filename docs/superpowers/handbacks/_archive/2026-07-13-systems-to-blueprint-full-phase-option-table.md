---
from: systems
to: blueprint
status: consumed
topic: [完整phase偏置表·零跑] 4 phase→option:求糧{覓食,買糧}/成長{返家,紮營}/聚勢{外交,併入}/立國{}空;★立國phase零偏置=靠機械B-gate(接paused立國redesign);多pop成長路phase未涵蓋(征服吸收/俘虜無phase偏置)
---

# 完整 4-phase 偏置 option 表（decision_context:133-140，file:line）

| phase | 觸發（缺口） | 偏置 option（各 +MAG 0.4） | 目標關聯 |
|---|---|---|---|
| **求糧** SEEK_FOOD | food_flow_avg < 0.5 | **`覓食`, `買糧`** | 直接取食（貿易移除=裁決B,致富主表達由 intent_fit 驅） |
| **成長** GROW | pop < 8 | **`返家補給`, `紮營`** | 定居建基（間接→safety→繁殖;**非直接 pop 成長 option**） |
| **聚勢** GATHER | faction < 2 | **`外交`, `併入`** | 結盟/整併（併入=S-A 統一 join+整併） |
| **立國** ESTABLISH | 食足+人足+faction足 | **`{}` 空（零偏置）** | ★見下 |

## ★關鍵發現：立國 phase 零偏置
`_phase_option_bias(PHASE_ESTABLISH)` 落 `return {}`（:140 fall-through）——**立國 phase 不偏置任何 option**。
- 意義:隊到了立國 phase（該立國了）,計畫層**不推任何行動**→ 立國仍純靠**機械 B-gate**（faction_ai:974-980 統領/野心/readiness AND → emit 立國 goal）。
- **接 paused 立國-redesign**：這正是那個「立國無意圖層,純機械 gate」的體現在 phase 層——ESTABLISH phase 空偏置 = 計畫層沒接手立國,還等機械閘。**立國-redesign（加意圖層）該填這個空**：ESTABLISH phase 應驅動「立國傾向」進 argmax,非空手等 B-gate。
- ∴ plan-layer S1-S4 做完後,立國-redesign（加立國意圖層）是讓 ESTABLISH phase 真有作用的必要後續（已 paused 待重設計）。

## ★多 pop 成長路 phase 未涵蓋（承前訂正）
成長 phase 偏置 `{返家補給,紮營}` = 定居建基（間接繁殖路）——**但不涵蓋其他 pop 成長路**：
- **征服吸收**（打贏吸敗方 anon）：無 phase 偏置（該由武力 archetype/征服 intent 驅,非成長 phase）。
- **俘虜/流民**：無 phase 偏置。
- ∴ 成長 phase 只推「定居建基→間接繁殖」一條,武力隊「打贏長人」不走成長 phase 偏置（走征服 intent）。**這可能是設計選擇（成長=和平長人紮營、武力長人走征服）也可能是缺口**——繁殖/pop arc measure 時判(GROW 隊該不該也偏征服吸收,還是武力隊本就走征服 intent 不需 GROW 偏置)。

## 判讀
- **4 phase 表完整**（3 有偏置 + 立國空）。
- **立國 phase 空偏置 = 計畫層與立國機械 gate 的接縫未接**——立國-redesign（paused）該填。plan-layer 現只到「爬到立國 phase 門口」,跨不進（機械 B-gate 仍擋,見 established 四門）。
- **成長 phase 單推定居路**——武力/征服 pop 成長走 intent 非 phase,繁殖 arc 再判。

## 序
- 表交你。**S3 續不受影響。**
- **★flag 序**：plan-layer S1-S4 完 → **立國-redesign（填 ESTABLISH phase 空偏置=加立國意圖層）** 應接續（否則爬到立國 phase 也跨不進機械 B-gate）→ 再繁殖/pop arc。這兩個是 established>0 最後兩哩。
- 記入 [[project_established_chain]]（立國 phase 空偏置=立國-redesign 接縫）。
