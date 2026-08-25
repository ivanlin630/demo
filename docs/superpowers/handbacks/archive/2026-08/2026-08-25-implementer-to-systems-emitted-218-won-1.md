---
from: implementer
to: systems
status: consumed
slice: acquisition-paths-wire-in
topic: ★★★你怕的那格幾乎命中:peaceful 床 emitted=218 / won_argmax=【1】——接上了、有產出、但 218 個候選只贏過 1 次;★warring 床【兩次都沒產出檔案】,我當成要查的事實不是「跑了沒事」,debug 跑中
---

# `emitted` ／ `won_argmax` 那一對 —— **先給 peaceful，warring 在查**

## §1 ★★★數字（`peaceful_economy` 30d，本 branch）
```
means_end.candidates_emitted           = 218   (weapon_melee_low 128 / tools 90)
★means_end.won_argmax                  = 1
means_end.no_means                     = 0
means_end.cycle_detected               = 0
```
⇒ ★★**你要我分開報的那一對，分出來的正是你怕的形狀**：
**接上了（`dormant-scan` 3→2）、有產出（218）、但【幾乎從不改變結果】（贏 1 次）。**

★**我不現在解釋它為什麼輸** —— **那需要 per-option util dump，而「決策問題先 dump per-option util」是既有規則**。
★**我只確認一件事實**：**`1` 不是 `0`** ⇒ **這條路徑【可以】贏，不是結構上不可能贏。**
（★**若是 `0`，那才要懷疑是不是根本進不了 rank 池。**）

## §2 ★對閘③的意義（我不自己判，交判準對照）
照我先前寫死的表：
| `emitted` | `won_argmax` | `fp` | 判 |
|---|---|---|---|
| ★**218** | ★**1** | **未變** | ★**「接上且能贏，但贏得極少」** —— **fp 未變與此【一致】**（a4 是 warring，且贏 1 次未必落在 a4 的 1000 tick 內）|

★**但我不宣告閘③通過** —— **它要的是 a4 那床的 fp 變，而我手上還沒有 warring 的 tap 數字。**

## §3 ★★warring 床**兩次都沒產出檔案** —— 我當成要查的事實
**第一次**：task 完成、無錯誤、**但 `PERF_OUT` 檔不存在**。
**第二次**（帶 `won_argmax` 那輪）：**同樣沒有。**
★**「跑完了、沒報錯、但沒有輸出」不是「跑了沒事」** —— **它跟今天那幾種 0 是同一族。**
⇒ ★**已用 10 天、全量捕捉 stdout 重跑，要看它到底走到哪一步。**

★**在拿到 warring 數字之前，我不會說閘③「不可達」也不會說它「通過」。**

## §4 其餘閘
| 閘 | 結果 |
|---|---|
| ①TDD 分得開 | ✅ `["facility"] vs ["material"]` |
| ②dormant | ✅ **branch 上 3→2**（★**merge 後要在 main 再驗一次才是最終證據** —— 你的訂正我收下）|
| ③fp | ⏳ **等 warring tap** |
| ④不退化 | ⏳ **待跑**（`emitted.food/material` 對照）|
| ⑤陽性對照 | ✅ 內建於① |
| ⑥exact path | ✅ 已給 |
| headless／憲法／det×3 | ✅ baseline 0-new／PASS(74)／`5c1fa2fc` ×3 |
