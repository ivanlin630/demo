---
from: systems
to: measurer
status: open
slice: S7-root-differential
tier: measure
topic: ★可以跑了:兩個 checkout 點已 push(573ef498 = root60 / c617556c = root120,相鄰 ⇒ delta 純粹只有根);★★你不編輯任何 production;★★★對照 B 被換掉了,而換掉的理由你該知道:ui_logic_test 那顆 production 根本不讀它 ⇒ 它是【鏡像漂移】的發現,當不了「換根會加倍的速率」對照
---

# ★①兩個點（branch `origin/feat/old-growth-forest`）
```
573ef498  commit1  17 個候選點的 tap ＋ 合成雙端對照   ← ★root = 60
c617556c  commit2  TICKS_PER_HOUR 60 → 120（只此一顆） ← ★root = 120
★兩顆相鄰 ⇒ ★★你的 delta 裡【純粹只有根】,沒有夾帶別的改動
★兩顆都不 merge。commit3(35e81df9) 把根還原,是為了後面的票長在對的根上,與你無關
```
★**fp 中性已驗**：`commit1 fp == main 基線`（逐位元）⇒ **tap 沒有動到被觀測的世界。**

# ★★②我指定的對照 B 被換掉了 —— **換得對**
```
我原指定 B = ui_logic_test.gd:77（期望 2.00×）
★而它在 _test_setup_sanity() 【函式內】：production 不讀它、換根不影響它、它也不影響世界
⇒ ★★它是【鏡像漂移】的發現,不是「換根會加倍的速率」⇒ 當不了 2.00× 的對照
```
★**改成合成雙端對照**（寫在 `sim_runner` tick 尾，語意無歧義）：
```
__CTRL_B_per_tick  每 tick 一次   ⇒ 期望 2.00×
__CTRL_A_per_day   每遊戲日一次   ⇒ 期望 1.00×
```
★★**用途不變、而且更硬**：★★★**若整批候選跑出「全部 1.00×」，A/B 仍是唯一能分開「真的沒漂」與「儀器沒開」的東西。**
⇒ **A 不是 1.00× 或 B 不是 2.00× ⇒ 先修儀器，不要報數字。**

# ★③跑法與交付（照原票）
```
seed 1337 ／ days 30 ／ 兩床 ／ 段1 只做那 17 顆（不是 92）
交付：docs/process/verdicts/S7-root-differential.measure.json
★每顆一行：常數名／file:line／per-person-day 套用次數(root60)／(root120)／比值
★★外加 A、B 兩行明標期望值 —— 它們不是結果,是【這批數字能不能讀】的前提
```
★★**誠實限照原票印**（率不是總量／解析度下限＝整數倍／刀①高召回低精度不得自行剔除）。
