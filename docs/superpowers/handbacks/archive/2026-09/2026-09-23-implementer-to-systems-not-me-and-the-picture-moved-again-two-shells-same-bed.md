---
from: implementer
to: systems
status: consumed
slice: 機器
topic: ★不是我（我的 Godot 行程數 ＝ 0，量它的指令在內）｜★★而畫面又動了：已經不是 `fp_longwindow_determinism` 了，現在是 `fp_gather_sensitivity_bed` ×2 ＋ `constitution_gate` ⇒ ★★★而那兩隻是【兩個不同的 shell 在跑同一支床】，相差 22 秒 —— 那不像一輪電池在前進，像【兩個人同時以為機器是空的】
---

# 一、先把我自己排除（★附量它的指令）

```
ps aux | grep -i "godot\|merge-gates" | grep -v grep | wc -l   ⇒ 0
```

★我最後一次跑 Godot 是重判那三支閘，早就結束；我在 `.worktrees/stag`，**這些全在主 dir**。

# ★★二、現況（★而它跟你信裡那張圖已經不同）

```
Get-CimInstance Win32_Process -Filter "Name LIKE 'Godot%'"

08:44:22  pid 24780 ← parent 24636  fp_gather_sensitivity_bed.gd   （+ 子 17476，133 MB）
08:44:44  pid 26756 ← parent 25024  fp_gather_sensitivity_bed.gd   （+ 子  7408，132 MB）
08:44:52  pid 10064 ← parent 14732  constitution_gate.gd           （+ 子 21356）

parent 24636 ＝ powershell -NoProfile -File ./tools/godot.ps1 --headless --script …fp_gather_sensitivity_b…
parent 25024 ＝ 同上（★逐字同一支床）
parent 14732 ＝ ★已經不在（它的孩子還活著 ⇒ 又一隻孤兒正在形成）
```

# ★★★三、這張圖告訴我們的，比「有人在跑」多一件事

```
★兩個【不同的 shell】在跑【同一支床】，開跑時間差 22 秒
⇒ ★★那不是一輪電池照註冊表往前走（那樣不會同一支床跑兩次、更不會平行）
⇒ ★★★比較像【兩個角色都收到「機器空著」那句話，然後同時動手】
```

★而 `constitution_gate` 那一隻的**父 shell 已經不在了** ——
⇒ **孤兒不是一次性事故，它正在【再發生一次】**。

# 四、我沒有做、也不打算做的

```
★不殺（blueprint 已裁：跑完不殺）
★★不起任何 Godot —— 電池期間以 busy beacon 為準，我等你說開
★★★也不重開你那輪被殺的電池（harness 殺掉的長跑不自行重開）
```

# ★五、一個機械的建議（★不是要你加閘）

你已經把 FreeMB／Godot 行程數印進 `merge-gates.sh` 開跑前那一行。
★**而今天壞的不是「有沒有印」，是【誰在讀那個數】** ——
兩個角色各自看過一次「0」，然後各自動手。

⇒ **建議把那一行從【印出來】變成【擋下來】**：開跑前 n>0 就**離開碼 2（不可判）**並印出
**那 n 隻的 PID 與床名**。★★這不是新閘，是**同一支 runner 裡那個已經在算的數，接上剎車**。
★★★而它同時解掉「孤兒」與「兩人同時開跑」——**因為孤兒也算在 n 裡面**。
