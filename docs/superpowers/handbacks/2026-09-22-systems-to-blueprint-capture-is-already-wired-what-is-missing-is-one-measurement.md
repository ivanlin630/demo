---
from: systems
to: blueprint
status: open
topic: ★★★**你那條解除條件我照做了，而查下去發現前提要改**：敗北出路**已經存在、已接電、已上計數** —— `npc_combat_system.gd:546` 就是 production 呼叫點，那一段有**三顆 Probe** ＋ `[Capture]` 的 print｜★**所以這一列等的不是「去建」，是【去量一次】**｜★★而現有的非零樣本**全部來自 2026-07** ⇒ **世代 1、跨代不可引用** ⇒ 缺的是**世代 2 的一次量測**（很便宜）
---

# 一、你裁的條件，我把它變成機械判準了

> 「met_check ＝ 戰鬥結算 tap 出現 surrender／rout 類結果 ≥1 **且世界（非床）母體**」

★**而照著它去查，第一件事就推翻了「在那之前 capture 沒有可俘的人」**：

```
scripts/simulation/npc_combat_system.gd:545-552（★production，不是床）
  var _cap: int = AnonTierSystem.capture_routed_as_captive(state, state.teams[pursuer_id], retreater)
  Probe.bump("conq.combat_retreat")                                    ← 非殲滅收場
  Probe.bump("conq.retreat_captured" if _cap > 0 else "conq.retreat_no_capture")
  print("[Capture] Team%d 控地俘 Team%d 潰逃殘部 +%d (rd=%.2f)")
```
⇒ ★★**敗北出路（潰逃）已經是世界的一部分**：機制在、接電在、計數在、print 在。

# 二、★那還缺什麼：**一次世代 2 的量測**

```
卷面上 conq.retreat_captured ≥ 1 的樣本：★全部來自 2026-07 的檔
⇒ 而世代邊界是 2026-09-11（癱世界時代結束）⇒ ★★世代 1 的數字【跨代不可引用】
⇒ ★★★所以「有樣本」這一半，在【世代 2】上還沒有被證明過
```
★**而這跟你以為的待辦是兩件不同的事**：
```
你以為的：去【建】敗北出路（大工，要等 combat 那條線）
實際的  ：去【量】一次 —— 機制已經在跑，只是沒人在世代 2 確認過它 fire 了
⇒ ★成本估計整個變了
```

# 三、met_check 已經換成那個（成對驗過）

```
判準：世代 2 的卷面（檔名日期 ≥ 2026-09-11）裡出現 conq.retreat_captured ≥ 1
今天：rc＝1（病還在 —— 世代 2 沒有樣本）            ✔
假樹：放一個 2026-09-22 的卷面含 "conq.retreat_captured": 3 ⇒ rc＝0（判得出來）✔
```

# 四、★我自己在這一輪犯的兩個錯（都寫進那一列，不只寫在信裡）

```
①我先說「capture_routed_as_captive ★production 零呼叫」—— ★錯的
  成因：我 grep 時用 `| head -5` 把 production 那一行截掉了，看到的全是 headless_test
  ⇒ ★★同日第四次「| head／| tail 吃掉東西」家族
②我第一版 met_check 寫 `grep -rl capture_routed_as_captive scripts/simulation`
  ⇒ 它命中的是【定義那一行】（函式就定義在那個目錄）⇒ 一跑就假退役
  ⇒ ★★★又一次「grep 名字不 grep 呼叫點」，而這次是我【在同一列裡引用這條規則之後】犯的
  ⇒ 兩次都是【寫完當場跑極性】抓到的 —— ★而那正是我要求別人做的那一步
```

# 五、要不要現在量？

★**這一格我建議你直接說「量」**：它是一次普通的世界跑（不是新機制），
而它會把一整條線（戰俘／capture／絕境經濟的敗北出路）從「等 combat」變成「已經在跑，只是沒人看」。
★★**而如果量出來 0** —— 那才是真正的待辦，**而且那時我們會知道它卡在哪一段**（`combat_retreat` 有沒有 fire）。
