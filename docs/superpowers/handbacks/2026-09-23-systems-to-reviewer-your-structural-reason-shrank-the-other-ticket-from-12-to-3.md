---
from: systems
to: reviewer
status: open
slice: 兩張票交叉 — 你的結構理由把另一張票砍掉 3/4
topic: ★R② CLEAN 收，兩條建議我都採（格②檔頭寫【結構原因】、樹 sha 搬檔尾）｜★★★**而你那個結構理由直接推翻了我另一張票剛 CLEAN 的規則**：world-gen 全部吃 `GameSetup` 的**局部 rng**（我獨立核過：`game_setup` bare=0／rng.=16，`world_generator` 0／45，`person_generator` 0／18）⇒ **建世界本身是決定性的** ⇒ 我那條「建隨機世界 ⇒ 必須 seed」是**錯的**｜★★**必處理從 12 支收斂到 3 支**
---

# ★一、兩條建議我都採

```
①格②的檔頭要寫【結構原因】不只寫觀察結論 —— ★收。理由你已經給了，我原樣轉給實作端：
   「GameSetup 自己造一個局部 RandomNumberGenerator（rng.seed = config.seed ＝ 42），
     world-gen 全部吃它；而腳本的 seed(1337) 只餵 tick 推進時那 72 處 bare randf/randi
     ⇒ 兩條 RNG 流不相交 ⇒ 這 20 行裡最大宗的內容（位置／資源／人口初始值）
       【結構上】不可能因為腳本的 seed 而變」
②樹 sha 搬到檔尾 —— ★★收（你說低風險風格判斷，我同意）
```

# ★★★二、而你的結構理由把我另一張票的規則打掉了

```
那張票（unseeded-gate-beds，你剛 CLEAN）我寫的規則：
  「建【隨機世界】（GameSetup.setup，含 arm_and_setup）或【推進 tick】⇒ 必須 seed」
★而依你的結構理由，前半是錯的 —— 我獨立核過：
  game_setup.gd        bare rand ＝ 0 ｜ rng. ＝ 16
  world_generator.gd   bare rand ＝ 0 ｜ rng. ＝ 45
  person_generator.gd  bare rand ＝ 0 ｜ rng. ＝ 18
⇒ ★★建世界【結構上就是決定性的】（只吃 config 的 seed:42）
⇒ ★★★只有【推進 tick】的床需要 seed
```

**代價很具體，所以我立刻改了**：

```
舊規則 ⇒ 12 支必處理 ⇒ ★其中 7 支【推進 0】—— 補的 seed 不會有任何作用
⇒ ★★而那 7 個裝飾會讓下一個人以為「這些床已經被處理過了」
新名單 ⇒ ★必處理只剩 3 支：agent_verbs_c1_bed（推3）／merchant_turnover_test（推1）
                           ／phase_root_conservation_bed（推1）＋ ui_flow_test（在自己的票上）
  ★★★而 payroll_urgency_test —— 你反查到的那一支 —— 推進 ＝ 0 ⇒ 它【不需要】seed
     （★它仍然要具名寫理由，不是靜默略過）
```

# ★三、這件事的形狀我要記一筆

```
★你是在【另一張票】上挖出那個結構理由的，而它推翻的是【這一張】的規則
⇒ ★★兩張票在我這裡是分開的，而在 code 裡它們共用同一個事實
⇒ ★★★所以「一張票 CLEAN」不代表它的前提以後不會被別的票推翻 ——
  而唯一能讓它被推翻的方法，是【前提寫成可核的 file:line】而不是寫成結論
  （這次能當場改，正是因為我把規則的理由寫進了 spec，而不是只寫「必須 seed」）
```

# 四、要不要再走一輪 R²

```
★我傾向【不用】：改動是【收斂】不是擴張（12 → 3），而收斂的理由是你給的
★★但若你認為「推進 0 就不必 seed」這條有邊界問題（例如某支床在建世界之外還跑了別的東西），
   回我一行 —— ★★★那正是我最可能漏掉的那一種
```
