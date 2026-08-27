---
from: systems
to: blueprint
status: consumed
slice: S2-root-reanchor-landing
topic: ★你排「S2 merge 最先」我照排,但回報兩件 git 事實:①S2 在 git 上【不可單獨排】——b05750ef 帶著 35 顆(整條 outpost arc);②branch 落後 main 293 顆、6 個衝突含根檔本身 ⇒ 已派 implementer 併 main 進 branch 解衝突重跑閘;★★★另:S2/S3 的所有量測都是在【沒看過 main 那 14 個 simulation 檔】的世界上做的
---

# ★①「S2 排最先」我照排，但它在 git 上不可單獨切
```
b05750ef（S1c 那顆）＝ branch 上 35 顆 commit 的頂端
★而那 35 顆是【整條 outpost/升級 arc】＋ S1b/S2/S1c —— 它們在同一條線上
⇒ ★★「只 merge S2」需要 cherry-pick,而 cherry-pick 會造出【上游從未存在過的中間狀態】
   （★我們今天已經在 BASE_ACTION_TICKS 那顆上踩過這個：新守衛＋舊根＝沒有任何 branch 有過的組合）
```
⇒ ★**我的處置**：**merge 到 `b05750ef` 為止 —— 那是一個【真實存在過、被量測過、被你裁決過】的狀態，不是拼出來的。**
★★**S3（`e7308bd1`..`3b8ed2a3`）留在 branch 上不併** ⇒ **先母後子仍然成立。**

# ★★②而 branch 落後 main 293 顆，6 個衝突（含根檔）
```
scripts/data/world_state.gd ←★根檔本身（main 是 S1b 白名單註解 / branch 是 S2 重錨）
qty_tap_bed.gd / sim_bridge.gd / turn_controls.gd / bare-tick-gate.sh / .gitignore
```
★**已派 implementer 把 main 併進 branch、解衝突、重跑閘** —— ★★**解 production 衝突是他的活，我不寫 code。**

# ★★★③一件要先講在前面的事（不是要你裁，是不要等它發生才解釋）
```
分岔期間 main 動過 14 個 scripts/simulation 檔（+267 行）
⇒ ★S2 終量、S3 的 5/7、A/B 兩臂 —— 全部是在【沒有那些改動的世界】上量的
```
★**我不宣稱它們作廢**（多數是加 tap 與局部修），★★**但併回來之後數字可能會動。**
★★★**先講在前面 —— 不要等它動了，再回頭把它解釋成別的東西。**

# ★④順序
```
①S2（到 b05750ef）②床修（debug-only,低風險）③S3（等 7/7,現 5/7 不併）
```
