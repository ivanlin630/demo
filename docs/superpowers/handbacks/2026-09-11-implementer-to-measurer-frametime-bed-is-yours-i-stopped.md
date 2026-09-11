---
from: implementer
to: measurer
status: consumed
cc: systems
slice: 單幀 ｜ ★交接宣告（不是「我觀察到機器空了」）
topic: ★★★**`frame_time_who_freezes_bed` 從現在起歸你獨占 —— 我停了，而且不會再開新輪**（systems 裁）｜★我這邊**沒有任何 Godot 在跑**（上一趨 90 天 ON 被 OS 以低記憶體殺掉，我沒有重開）｜★★而我在那支床上改過**兩行輸出**（fp ＋ `>2 秒幀數`），已進 main（④b `ae339be5f`）—— **你重跑時會看到它們，不是你的世界變了**
---

# ① 現況（★可驗證的事實，不是「我覺得停了」）

```
①我起的兩個 Godot（`12528` 90 天 ON／`22948`）**已不存在**：
  前者我自己殺掉（我改了 `loop3.misc` 的父相位登記語意，那一趨的數字會出負 self ⇒ 作廢）
  後者是接著排的那一輪，被 OS 以**低記憶體**殺掉。
②★**我不會再開 `frame_time_who_freezes_bed`** —— 這支床歸你。
③★★我手上的票是【commit 優先序隨需求】＋它的前置量測（`interrupt_premeasure_bed`）
  ⇒ 我還會跑那一支，它是 30 天窗、**不量時間**（母體是 task/food 狀態）。
  ⇒ ★若你要一趟**完全乾淨**的機器，跟我說一聲，我等你跑完再排。
```

# ② ★你重跑時會看到的兩行（★是我加的，不是世界變了）

```
`scripts/debug/frame_time_who_freezes_bed.gd` 尾端多兩行：
  `★fp(phase_timing=ON/OFF) = <hash>`      ← ★★儀器有沒有改世界，要兩趟對照才算數
  `★★終線計數（永遠開著、不吃 phase_timing）：>2秒幀數=N / M tick`
⇒ ★★★而第二行的來源是 `SimRunner.frames_over_budget/frames_total`（永遠開著），
  **不是** `phase_timing` 的產物 ⇒ 你的 OFF 趟**一樣印得出來**。
```

# ③ ★我沒跑完的那件，交回給你（★含它的坑）

```
`loop3.misc` 切成 `misc.equip_mobilize`／`misc.mounts`／`misc.ambient` ＋ 殘量 —— **code 已在 main**。
★★而我踩過一個坑，寫給你免得重踩：**父相位必須涵蓋整段，不能只累殘量** ——
  `phase_report` 會把兒子的 tot 從父親身上減掉 ⇒ 只累殘量的話父親的 self 會是**負的**。
  已修（`faction_ai_system` 記一支 `_t3_misc0` 當整段起點）。
```
