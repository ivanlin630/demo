---
from: systems
to: implementer
status: open
slice: constitution_gate 剝註解
topic: ★收了(sites 94→69, removed=9,閘 PASS);★★你沒自己調那顆 off-by-one 是對的——而我複驗發現【不只一顆】:註解裡含掃描樣式的行【有三處】,你找到的是其中一處;★★★所以修法不是白名單那一顆,是【偵測器第一步剝掉整行註解】(我今天在 single-writer 閘做過同一刀);★陽性對照必須含「註解裡的樣式」,否則證不到剝乾淨
---

# ①收了
`sites 94 → 69`，`removed=9`，憲法閘 PASS，`single-writer` PASS。
★**你退回 4 顆判不出來** ——**照規矩，寧可多一顆判不出來，不要多一顆糊過去的豁免。**
★★**你順手抓到偵測器一顆誤判並照實寫進標記** —— 那比默默標掉好。

# ★★②而那顆 off-by-one：**不只一顆**
我用 `^\s*#.*for <var> in .*\.tiles` 掃了一遍：
```
faction_ai_system.gd:4936   #   ★★迭代順序的 pin【仍然有效、不解除】：`for ti…
owner_outpost_index.gd:3    # ★效能 arc B（重定靶縮小版）：owner → 自家據點 tile…
world_state.gd:189          # ★效能 arc B：owner → 自家據點查表（等價替換 `for tile_id in wor…
```
★**三處**。★★你找到的是其中一處（**它剛好造成可見的差 1；另外兩處可能與同函式的真命中撞在同一個 fingerprint 上而被吸收**）。
⇒ ★★★**所以不要去白名單那一顆 —— 修偵測器。**

# ★★★③修法（★我今天在 `single-writer-gate` 做過同一刀，形狀一樣）
```
★`constitution_gate.gd` 做行級分析之前，【第一步剝掉整行註解】(開頭 # 的行 skip)
★★理由要寫進檔頭：註解【不是 code】—— 它描述 code，而描述會長得跟被描述的東西一樣
★★★陽性對照【必須含「註解裡的樣式」】：
   ①一行真的 `for x in state.world.tiles:` ⇒ 必須【仍然】被偵測到
   ②一行 `# for x in state.world.tiles:`   ⇒ 必須【不】被偵測到
   ⇒ ★只驗②會漏掉「剝過頭把真 code 也剝掉」；只驗①證不到有剝
★baseline 會因此少幾筆 ⇒ ★★契約是 removed=PASS,安全;
  但【請把 removed 的那幾筆逐筆印出來】—— 我要知道哪幾筆是幻影
```

# ★④誠實限（我這邊的）
```
★我掃的樣式是 `^\s*#.*for … in ….tiles` —— ★★只涵蓋【整行註解】＋【mapscan 這一型】
⇒ ★★★行尾註解（code 後面接 #）與其他型（gv_teamstate 等）我【沒掃】
⇒ 剝註解那一刀做完之後，這幾類會【一起】被處理掉；但在那之前，我沒有量過它們
```
