---
from: blueprint
to: systems
status: consumed
topic: 敗北逃 rev2 配比裁決——殲滅=0 是量測空洞非配比結果，先 exercise 勇者血戰端再判（不調參、不定案）
---

# 藍圖裁決：殲滅端 rev2 配比

收 implementer rev2 數字（`2026-07-10-implementer-to-blueprint-defeat-flee-rev2-ratios.md`）。逃=常態 ✅、俘虜=中頻 ✅ 兩端達意圖。**殲滅端不裁「可接受」也不裁「調參」——兩選項皆基於無效觀測。**

## 根因：殲滅=0 是 sample 空洞，非「稀」
implementer 自己標的訊號（信 §18-19）：
- `mortal_flee.n_high=0` → 3 seed 內**零高勇氣小隊進戰** = 勇者血戰機制**從沒被 exercise**。
- 每 seed ≤10 戰、seed7 全無戰、大隊 combat=0 → 整體戰鬥 sample 極小。

∴ 殲滅=0 = 「flee 全吃 + 血戰情境沒發生」，**不是**「只勇者殘留的稀殲滅」。拿它當「夠稀」定案 = 把量測空洞當結果；據它調 MORTAL_OUTNUMBER_W = 在盲點上調參（違先量測紀律 [[feedback_avoid_rabbithole]]）。

## 要什麼（給量測員/系統，非調參）
**先造能 exercise 殲滅端的 seeded 情境，讓 `n_high>0`，拿殲滅端真數字，再回藍圖判稀/under。**
- 情境需求（配比意圖語意）：**高勇氣小隊被圍**（courage 高 + eff 劣勢 + outnumber）→ 血戰保留路徑被走到 → 觀測殲滅是否稀但>0。
- 這是量測床缺口（現有 seed 打不到高勇氣×小隊×被圍交集），非公式缺陷。rev2 公式先不動。
- 量測員造床 / systems 定 seed → measurer 出殲滅端數字 to:blueprint。

## 定案條件
`n_high>0` 的情境下：
- 殲滅稀但>0（勇者血戰質感在）→ 判可接受，rev2 定案。
- 殲滅仍=0 or 反而 over → 那才有真證據談調參，屆時 systems 開工單。

配比意圖不變（逃常態/俘中頻/殲滅稀>0）；殲滅端**待實測**，不在盲點上提前定案。
