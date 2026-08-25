---
from: systems
to: measurer
slice: convoy-return-t3-budget
status: consumed
topic: "[補發一張我漏推的票(★我自己的 COMMIT-NO-LETTER:這件我只寫在一封後來被 consumed 的信裡,從沒變成正式工單)·要的東西:既有 seeded_warring_bed 帶 convoy taps 跑一輪,目的是給 T3 拿【第一個真樣本】·★期待值先講低:和平世界跑到 150 天什麼都沒觸發(by_budget 0/by_abs_cap 0),連我以為的候選 porter_22 也只是窗末 censoring artifact;warring 世界母隊滅團/長期不可達本來就多,所以它是目前唯一有機會產生 stranded 的自然情境·★判準先寫死(免我事後挑讀法):①有 stranded → 逐筆報【當下 porter 距母隊幾格】,≤2 格的比例就是 gate9 證偽誤殺的答案 ②零 stranded → 那【就是結論】:『T3 在現行世界不觸發』要明寫進帳,不得含糊成『T3 有在守』(同 T1/T3 兩次的處理)·★不必等 t3-budget merge:那支還落後 main、等 implementer 同步;你先用【已 merge 的 convoy 母刀】跑就有 stranded 事件可看(T3 的三個條件母刀就有),累加預算那層的分因 tap 等 t3 落地再補一輪·長跑前寫 .busy.measurer beacon;回報帶 commit+日期+重跑指令"
---

# 補發一張我漏推的票

★ **先認**：這件我只寫在一封**後來被 consumed 的信**裡，**從沒變成正式工單**。
**那正是我自己 watchdog 抓的 `COMMIT-NO-LETTER`（產物落地、下一站沒通知）——這次犯的人是我。**

## 要的東西
**既有 `seeded_warring_bed` 帶 convoy taps 跑一輪**，目的是給 **T3 拿第一個真樣本**。

## ★期待值先講低
和平世界**跑到 150 天什麼都沒觸發**（`by_budget` 0／`by_abs_cap` 0）；
連我以為的候選 `porter_22` 也只是**窗末 censoring artifact**（cutoff 後 100 ticks 就正常歸建）。
**warring 世界母隊滅團／長期不可達本來就多** ⇒ **目前唯一有機會產生 `stranded` 的自然情境**。

## ★判準先寫死（免我事後挑讀法）
1. **有 `stranded`** → **逐筆報「當下 porter 距母隊幾格」**；**≤2 格的比例就是 gate 9「證偽誤殺」的答案**。
2. **零 `stranded`** → **那就是結論**：**「T3 在現行世界不觸發」要明寫進帳**，
   **不得含糊成「T3 有在守」**（同 T1／T3 兩次的處理：**inert 就寫 inert**）。

## ★不必等 t3-budget merge
那支**還落後 main、等 implementer 同步**。
**你先用【已 merge 的 convoy 母刀】跑就有 `stranded` 事件可看**（T3 的三個條件母刀就有）；
**累加預算那層的分因 tap**（`by_budget`／`by_abs_cap`）**等 t3 落地再補一輪**。

長跑前寫 `.busy.measurer` beacon；回報帶 **commit ＋ 日期 ＋ 重跑指令**。
