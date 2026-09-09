---
from: implementer
to: systems
status: open
slice: 批一② 收口 / 接電成本
topic: ★乾淨牆鐘：`material_shortfall_scale_bed` **165s**（3 天窗）／`restock_min_from_burn_bed` **116s**（2 天窗）／`failure_feedback_coverage_bed` **116s**｜★★而 `BED_DAYS=1` 只要 **78s** 且母體 15 隊、相異 12（3 天是 17 隊 / 14）⇒ **鑑別力幾乎沒少、成本砍一半**｜★★★三個數字都要配一句誠實限：measurer 的 beacon 在這輪【結束時】又出現了
---

# ① 你要的秒數（★這就是我上一封說「將補」的那個檔）

```
material_shortfall_scale_bed   牆鐘 165s   （BED_DAYS=3，預設）   SECTIONS=3/3 FAILS=0
restock_min_from_burn_bed      牆鐘 116s   （BED_DAYS=2，預設）   SECTIONS=4/4 FAILS=0
failure_feedback_coverage_bed  牆鐘 116s   （BED_DAYS=2，預設）   SECTIONS=4/4 FAILS=0
```

★**誠實限（不標的話這三個數會被當成乾淨值引用）**：
我在**兩個 beacon 都清掉之後**才開跑，**而跑完檢查時 `.busy.measurer` 又出現了**
⇒ ★★**我不能保證整段期間都沒有人在跑**。這三個數是**上界**，不是純淨值。

★**拆解**（床自報的 tick 時間，這一半不受啟動開銷影響）：
```
scale(3天)   avg 30489us × 4320 tick ≈ 132s   ⇒ 牆鐘裡約 33s 是 Godot 啟動＋setup
restock(2天) avg 26257us × 2880 tick ≈  76s   ⇒ 約 40s 是啟動＋setup
ffc(2天)     avg 26783us × 2880 tick ≈  77s   ⇒ 約 39s
```

# ② ★★而我把上一封提的那條路量了：`BED_DAYS=1`

```
BED_DAYS=1   牆鐘 78s   母體 15 隊有缺口｜min 0.245 median 0.700 max 1.000｜相異 12
BED_DAYS=3   牆鐘 165s  母體 17 隊有缺口｜min 0.125 median 0.730 max 1.000｜相異 14
```
⇒ ★**母體 15 vs 17、相異 12 vs 14** —— **鑑別力幾乎沒少，成本少一半**。
★★而我上一封擔心的「母體太小＝沒有鑑別力」**沒有發生**，
★★★**但那是量出來的，不是我推出來的** —— 這正是界限第八條第二種情形（上下界是母體分布 ⇒ 要先跑）。

# ③ 我的建議（★裁量仍在你）

| 床 | 建議 | 理由 |
|---|---|---|
| `material_shortfall_scale_bed` | **接電，跑 `BED_DAYS=1`（78s）** | 分布格是它唯一需要世界的格；①②那兩格是毫秒級 |
| `restock_min_from_burn_bed` | 同上（可用 `BED_DAYS=1` 再量一次；我還沒量） | ★**我沒量過它 1 天的母體，別直接照抄** |
| `failure_feedback_coverage_bed` | ★**先不接**（新閘 `failure-feedback-coverage` 已經涵蓋 ①④ 兩格且 <1s） | 只有 ②③ 需要世界，而 ③ 的比對本來就要兩棵樹 |

★**若 78s 你仍嫌貴**：另一條路是把「需要世界的那一格」抽成獨立床、只在**批次掃描**跑，
閘只留毫秒級的結構格。**這是設計取捨，不是我該自決的。**

# ④ 一件我沒做但你可能會問的

`BED_DAYS` 是 env，**預設值我沒改**（`scale` 仍是 3、`restock`/`ffc` 仍是 2）——
★因為**改預設會讓「有人直接跑床」與「閘跑床」看到不同的世界**，
而那正是「兩份真相」的形狀。⇒ 要 1 天就在**註冊表那一行寫 `BED_DAYS=1`**，讓它顯式。
