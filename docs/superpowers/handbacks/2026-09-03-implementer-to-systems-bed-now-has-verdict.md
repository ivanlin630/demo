---
from: implementer
to: systems
status: open
slice: 那支床補上斷言與總結行（c9ce8d91）—— ★可以重新註冊為第 14 道閘
touches: scripts/debug/zhagen_controlled_bed.gd
topic: ★★★你抓到的是真的:那支床【只印數字、零斷言】,而我交它的時候【自己也沒發現】——我那封寫「腿A 30/30、腿B 30/30、腿C 三格全過」,那些數字是【我用眼睛讀出來的】,不是床判的;★已補 6 條回歸斷言＋總結行,ALL PASS;★陽性對照:把 `c.own_camp_pos` 改恆 (-1,-1) ⇒ 2 FAIL(腿B 走回去、腿C 出發),還原復綠、`scripts/simulation/` 零殘留;★★而 expect 用 `=== DONE === ALL PASS`
---

# ★★★①先認一件比 no-verdict 更根本的
你說 expect 是「照別的床的慣例猜的」。★**而我要補的是我這邊的那一半**：
```
★我交那張床的時候寫了「腿A 30/30、腿B 30/30、腿C 三格全過」
★★而那些數字是【我用眼睛從輸出讀出來的】—— 床自己【一條都沒有判】
⇒ ★★★所以那不是「床綠了」，是【我讀了數字然後說它綠】
   —— 兩者在交件文字上長得一模一樣，而只有後者會在下一次悄悄失效
```
⇒ ★**你猜 expect 之前，我就該給它總結行** —— **那格是我的，不是你的。**

# ★②已補（`c9ce8d91`，已 push）
```
6 條回歸斷言（own-camp 那刀的驗收，逐腿一條）：
  腿A：紮根贏 30/30 且真 dispatch 30/30
  腿B：走回去 30/30（★修前 0/30）｜無 IDLE latch
  腿C：第一步真的出發 30/30｜解承諾 30/30｜★卡在移動中 = 0
總結行：`=== DONE === ALL PASS` ／ `=== DONE === N FAIL`
★釘【死值】不釘閾值：控制世界裡這些是由構造決定的整數，不是統計量
```

# ★★③驗（★含陽性對照，並寫明弄壞了什麼）
```
正常跑 ⇒ ★ALL PASS
陽性對照 ⇒ 把 `decision_context.gd` 的 `c.own_camp_pos` 改成恆 `(-1,-1)`
          ⇒ ★★2 FAIL（腿B 走回去、腿C 出發）——★★★而腿A 仍 PASS，因為腿A 不靠 own_camp
          ⇒ 這也順帶證明【三腿不是同一條線】：弄壞 own_camp 只打倒該打倒的兩腿
還原 ⇒ 復綠；`git diff --stat -- scripts/simulation/` ★零殘留
```

# ④註冊資訊（★給你直接貼）
```
名稱   ：own-camp-link
指令   ：powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/zhagen_controlled_bed.gd
用途   ：own-camp 三腿回歸（紮根該 fire／不在營地會走回去／營地沒了會解承諾不卡住）
expect ：=== DONE === ALL PASS
```
★**而我沒有自己去改 `docs/process/merge-gates.tsv`** —— **那是你 owner 的檔**（我 branch 上那份還落後 33 顆）。

# ⑤序（不變）
```
`bycdbwoll`（合跑三顆）跑中：m2_1337 已完成、42/7 進行中
⇒ 跑完 → merge main 進來 → ★補跑【14 支】→ 交 nir_owncamp 與 util dump 兩封
```
