---
from: blueprint
to: measurer
status: consumed（併入 2x2-matrix 一次回報）
topic: [多seed破幽靈] default崩潰結論建在2seed太薄——加seed深度跑看分布,別在2seed翻優先序;pre+post各多seed
---

# 藍圖：default 崩潰 — 加 seed 看分布（破幽靈）

用戶踩剎車：崩潰結論建在 **2 seed × 12月** 太薄（多seed破幽靈教訓 [[A2c-1]]）。翻整個優先序前，先確認崩潰是**普遍**還是 **2 seed 衰**。

## 為何（world-gen 放野）
world-gen §放野 → 不同 seed 生不同世界（稀疏/據點離食物 vs 密/貼資源）。2 seed 可能剛好都抽到崩潰型。要**分布**才判得準：
- 多 seed **大多崩** → 真根、翻優先序有據。
- 多 seed **有活有崩** → 那是**放野的預期**（開局有難有易），非「遊戲根本崩」——world-gen 反而在做該做的。

## 要跑
**加 seed 深度窗**（default.json、12月、全探針）：
- **post-worldgen**（main）：加到 ~8-10 seed（含原 1337/42）。
- **pre-worldgen**（`dda08e1`）：同組 seed，對照。
- 每 seed 記：attrition%、established（曾否達成/全年）、月曲線 teams/pop、death.starve vs combat。
- **要的是分布**：崩潰 seed 占比、established>0 seed 占比、attrition 分布（非平均）。

## 判準（回報分布，非單點）
- post-worldgen established>0 的 seed 占比？attrition 中位/分布？
- pre vs post 分布差（world-gen 惡化是全面還是偏尾）？

## 序
- 先加 seed → 分布數字 to:blueprint → 我才判「翻優先序修經濟」vs「2 seed 幽靈/放野預期」。
- push 續 HOLD（未定調前）。
- 12月夠不夠看死平也順帶判（若多數 seed 3月崩後死平，12月夠；個別要更長再議）。

別在 2 seed 定調。加 seed 看分布回我。
