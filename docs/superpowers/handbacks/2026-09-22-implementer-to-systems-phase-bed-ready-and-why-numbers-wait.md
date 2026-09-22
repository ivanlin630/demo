---
from: implementer
to: systems
status: open
slice: DIAG 票第一步 —— 床已就緒，**真數字在等 CPU 空出來**
topic: ★**第 0 步答案：既有 log 不夠**（四份 raw log 對 `FaiPhase`／`near.`／`phase_timing` 的命中數是 **0**，`phase_timing` 預設 false）⇒ 這一輪要跑｜★★**但現在不能跑**：三計數那兩臂還在燒 CPU，而**時間量測撞上另一個 Godot 行程就是垃圾**（次數不受影響、時間受影響）⇒ ★排在它後面｜★★★床的涵蓋率格**連續咬住我三次**：255.7% → 115.9% → 76.1%
---

# 一、第 0 步（★先問既有卷面）

```
zcat 四份 raw log 對 `FaiPhase|near\.|phase_timing` 的命中數：**0 / 0 / 0 / 0**
⇒ `SimRunner.phase_timing` 預設 `false`（`sim_runner.gd:173`）⇒ 那些卷面裡沒有相位欄
⇒ ★**這一題答不出來，要跑** —— 前三次都能從既有卷面答，這次不行，我照實說。
```

# 二、床（`scripts/debug/pass_tick_phase_breakdown_bed.gd` @ `80b760004`，分支 `feat/pass-phase-bed`）

```
★**不改 production code**：只把既有的 `phase_timing` 打開，dt 自己在床裡量
  ⇒ 可以跑在【乾淨的 main】上（`.worktrees/passphase`，detached 自 origin/main）
★前提驗證在解讀【之前】：床用的 60 必須 == `SimRunner.NEAR_CADENCE`，否則直接不可判
★母體守衛：pass tick < 30 判不可判 —— ★實測會咬（跑 1 天只有 24 個 pass tick）
```

# 三、★★★涵蓋率那一格連續咬住我三次（★這是我要你看的部分）

```
①**255.7%** ——我直接加總原始 tot ⇒ **父子都算了一遍**
   ★>100% 是「母體不同源」的指紋，而這一格就是為了它存在的
②**115.9%** ——扣掉巢狀之後仍超過 ⇒ 真身是 `"*multi"`：
   被多個外層呼叫的相位（`gather.*` 那 10 個），時間【已經在父親裡】
   ⇒ `PHASE_PARENT` 把它們登記成 `*multi` 正是為了「不參與減法」，而我把它們也加了
③**76.1%** ——兩者都處理後。★★★**而沒被相位蓋住的 23.9% 本身就是一格答案**
★★巢狀表我沒有自己發明：用 production 的 `PHASE_PARENT`，並同時把
  `FactionAISystem.phase_report()` 的輸出一起印（同一份資料、另一支既有的眼睛）
  —— ★第二份表從出生就開始漂，而漂掉不會紅。
```

# 四、★smoke 的形狀（★★數字不可引用：它跑在 CPU 被佔用的機器上）

```
2 天 smoke（★★★只用來驗床會不會動，**不是答案**）：
  top-1 = `unified.rank.from_solo_body` 16.2%｜top-3 = 37.8%｜相異相位 36 個（另 10 個跨父桶）
  ⇒ ★形狀看起來像你三格裡的【②幾個中等的頭】，★★但我**不下這個判**：
    ・數字受 CPU 競爭污染（pass median 0.47 秒 vs 乾淨跑的 1.2 秒）
    ・涵蓋率只有 76.1% ⇒ 還有 23.9% 沒有主詞
```

# 五、順序（★我自己排，不問）

```
①等三計數兩臂跑完（已完成 1／4）⇒ ②跑相位拆解 12 天 × 兩顆種子（乾淨 main）
⇒ ③兩份一起交
★★而三計數那一輪的卷面【不受 CPU 競爭影響】（它量的是次數）⇒ 那份數字照樣可用
```
