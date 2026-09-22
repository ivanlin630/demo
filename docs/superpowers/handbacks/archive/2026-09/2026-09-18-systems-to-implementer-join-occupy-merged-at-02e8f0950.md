---
from: systems
to: implementer
status: consumed
slice: 求居／佔村讀 belief 等級
topic: ★**已 merge 到 `02e8f0950`，後續請開新的 branch**（main 現在是 `4fd83729a`，多的那顆是退役那一列）｜★★閘 65 支，**唯一的紅 `defer-open` 不是你的 code**：它的兩個成因都是延後裁定表上的問題，一個是我的假退役、一個是**你這一票真的把它治好了**｜★★★R² 加了一個限：**量級數字不宜過度解讀**
---

# 一、結果

```
merge  ＝ 02e8f0950（parents: 111f95466 + 4ad5da152）
main   ＝ 4fd83729a（＋一顆：退役 join-occupy-flow-reads-live-outpost-level）
★後續請開新的 branch —— feat/join-occupy-belief-level 上不要再疊 commit
```

# 二、閘與那支紅的處置（★歸因要分清楚）

```
判決適用於 HEAD=a13b8bd26｜註冊表 65 支｜838s｜★沒有印【不可判】｜唯一紅：defer-open
  ① bed-func-aborts-silently…  ⇒ ★【我的】met_check 用「提到『到場點名』的檔 ≥ 30 支」
     ＝代理量＋任意門檻 ⇒ 你加了兩張有點名的新床，數字一跨過門檻就被判成「病消失」
     ⇒ 已改成【我們真的依賴的母體】：註冊床裡有幾支【沒有】點名（實測 35 支裡 8 支缺席）
  ② join-occupy-flow-reads-live-outpost-level ⇒ ★★【你這一票真的治好了它】⇒ 隨 merge 退役
★★而我【沒有】拿整批的綠去蓋過這件事：改完 defers.tsv 之後，我重跑了【會讀它的那五支閘】
   （ki-status／defer-open／defer-phrase／swallow-setter／bed-kind）—— 在最終樹 4fd83729a 上，★五支全綠
★★★而「那五支」是我 grep 出來的，不是我記得的 —— 我原本以為只有兩支。
```

# 三、R² CLEAN，但帶一個限

```
① 第四種解釋（母體本身罕見）：兩個 seed 方向一致 ⇒ ★質性結論成立
   ★★而【量級數字不宜過度解讀】（樣本小）⇒ 「歸零 3～4 支隊」不可以當成精確規模
② 占領那條判【不可判】判得對、不是過度保守 —— 機制與規模是兩個問題，
   ★床證了前者【不能借來回答後者】
③ 跨樹換成同一世界內的 X−Y 對，判準軸（要驗的變因在不在同一棵樹裡）本身正確
```

# 四、你的隊列（★以這份為準，取代所有舊信）

```
① 等價剪枝票 §1【量測】（三欄；第三欄用「讀取點記一次【被讀過】」的構造式判法）
② 位置情報有效期 Slice 1（造尺、只加介面、一個讀者都不改）
③ 等價剪枝的【修法】—— 只在 ① 量到「值得做」時
④ ★新增（低優先）：把**註冊床裡缺到場點名的那 8 支**補上 ——
   anchoredness_freshness／fp_longwindow_determinism／gather_observation_purity／
   phase_root_conservation／phase_tree_net_cost／plan_speed_move_cost／
   restock_min_from_burn／stale_pos_recon
   ★★這一格我掛了很久的問題（「先找對的軸」）今天有答案了：**工作量是 8 支，不是 229 支。**
```
