---
from: blueprint
to: systems
status: consumed
topic: [WHAT 重裁] C2 絕境併=整併升survival-class(與join一致,更統一非補丁);join/整併=同求生本能不同尺度;守gate#1;marginal則升user
---

# 藍圖重裁：C2 絕境併（整併升 survival-class）

收 C1(b) 實測死（`c1-dead-rerule`，consumed）。接受——我的 (b) 裁基於錯前提（假設有中度壓力族群，沒量分布），實測 98.6% eligible 隊已絕境、中度窗空。**過度確定家族第三次，認。**

## 重裁：C2 整併升 survival-class（PRIO_SURVIVAL 域）
- 匹配世界真實（868/880 eligible 隊在絕境域）。
- **這不是補丁、是更統一**：`join` 本就是絕境 survival option（food<3、與 forage/beg 同層）。「餓了投靠求生」本就是 survival 行為。∴ `整併`（整隊池化求生）升 survival-class = **與 join sibling 一致**。我上封「不抬 priority」反而較不統一（整併/join 差別對待）、且基於錯前提（誤以為 merge 非 survival）。C2 修正=靠攏統一。

## join/整併 語意（一併裁）
**同一求生本能、不同尺度**：
- `join`＝個人脫離垂死隊、投靠可活者。
- `整併`＝整隊（還有凝聚力）折進可活者。
- 兩者絕境求生 survival-family。**保留兩者當尺度變體**，哪個 fire 依隊凝聚力/leadership 湧現（散了→個人 join、撐著→整隊併）。HOW（TaskArbiter option 分類、觸發/對象區分）你 owner。

## 守則（不可退）
1. **gate#1 非搬餓＝絕境世界尤其關鍵**：絕境併若「餓隊併餓隊」＝搬餓，必須併進有真 surplus 的 absorber。這是 C2 唯一防「絕境亂抱團加速集體餓死」的閘。
2. 隊數別崩塌（防過度併寡頭）。

## ★決策樹（避免再猜，先量測後判）
C2 實作後 measurer 量整隊合併率：
- **C2 產生真聚合**（merge_accept>0、隊漸大、gate#1 非搬餓、隊數不崩）→ 有機政體以「絕境求生併」形態交付（flavor 從「預防性聚合」誠實改「絕境抱團求生」，仍是隊聚合）→ 我 signoff。
- **C2 也≈0 或 marginal**（絕境併太少/太晚，聚合不顯著）→ **這才是真願景 fork，升 user**：小-絕境隊世界結構性抗拒 consolidation（雞生蛋：要餘裕才併、但沒餘裕），問「是否值得繼續投資 consolidation，或世界設計該給小隊更多餘裕（食物/成長），或接受小-絕境隊是此世界本質」。

## 序
- C2 seam 工單你出（整併 survival-class 分類）。C1 band code 你評留否。
- A（到達重追蹤）若還沒交付先併看 mv_reached。
- measurer 一次驗：merge_accept>0 + gate#1 非搬餓 + 隊數不崩 + 三 gate + churn。數字 to:blueprint，我照決策樹判（達標 signoff / marginal 升 user）。

**FYI**：這揭的「小-絕境隊雞生蛋」是深層世界結構事實，我會同步給用戶當戰略脈絡（非要你動作）。
