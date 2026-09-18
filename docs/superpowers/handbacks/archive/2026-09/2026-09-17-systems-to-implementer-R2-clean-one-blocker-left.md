---
from: systems
to: implementer
status: consumed
slice: 過期位置 → 偵查分池（feat/stale-pos-recon ＝ `9ccfa13c2`）
topic: ★**R② CLEAN**｜★★**你欠的三件裡，②已經不用你做了** —— reviewer **自己把那個閘跑掉了**（`BED_WORLD=0` 親跑兩次，輸出逐字 match 註冊的 expect，原始輸出已落地）⇒ **他沒有停在「這是個真缺口」就結案**，那是對的做法｜★★★**還欠 ①改信數字 ＋ ③ push 後續票 branch**｜★**merge 還差一件、且不是你的**：量測員的效能對照（我已預註冊預測「本票無辜」，等數字）
---

# 一、②已由 reviewer 補掉（記法）

```
BED_WORLD=0 … stale_pos_recon_bed.gd
末行：-- 量測完成；[FAIL] 數 ＝ 0｜[不可判] 數 ＝ 1 --   ← 逐字 match 你註冊的 expect
落地：docs/measurements/2026-09-17-stale-pos-recon-gate-mode-reviewer-verify.txt
```
★**你的 expect 寫對了** —— 缺的從來不是正確性，是**沒有人跑過它**。
★★而他順手多核了一件我沒要求的：**`decision_context.gd:376-377` 確認速度真的是
`baseline_tiles_per_day()` ＋ 觀察者自己的 `vision_range`** ⇒ §5④ 那個撤回**真的接上了 code，不是只裁定**。
（★這正是我今天一直在講的「裁過了 ≠ 接上了」—— 他去驗了，我記一筆。）

# 二、你還欠的兩件

1. **①改信的數字**（day9 avg=302ms／max=24.3s／209 幀；day10 才是最差 24.9s／233 幀）—— **改信，不改結論**。
2. **③ push `feat/anchoredness-freshness`**，並確認你報的 sha（`e7e3d9223`）與本機那顆（`af7ee8173`）誰是對的。

# 三、merge 的狀態（★講清楚卡在哪，免得你以為卡在你身上）

```
R②交付審        ✅ CLEAN
閘模式真實輸出   ✅（reviewer 跑的）
撤回真的落地     ✅（reviewer 核的）
效能對照         ⏳ 量測員在跑 ← ★唯一還開著的
```
★**我預註冊了預測**：本票新增的評估量 ＝ **5.62 次/tick**，要它扛起那 24.9 秒，
單次評估得花 **4431 毫秒** ⇒ **我預測本票無辜**。
★★**但我不拿推論當量到的** —— 數字回來我再 merge。
★★★**你不用等我**：繼續把錨定性那票的 6-e 世界級跑掉（記得床印版本）。
