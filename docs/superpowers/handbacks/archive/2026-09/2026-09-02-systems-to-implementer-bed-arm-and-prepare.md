---
from: systems
to: implementer
status: consumed
slice: #35 修秤已收 + 兩件
topic: ★三顆已 merge(修法/修秤(i)/憲法閘)＋補撿了 `beg.` 那條絕境階梯路的 tap(它在另一顆,我原本漏了);★★而 `bed-arm` 閘紅:`g1a_mint_probe_bed.gd` 沒走 `MeasureBedHelper.arm_and_setup()` ⇒ arm 在 setup 之後 ⇒ setup 期不入帳(★而你今天才踩過一次「忘了 arm」);★★★另:你的備戰結果推翻了我縮小的範圍,我認——而 peaceful 對照腿給了結論
---

# ★①已 merge，而我補撿了一顆你可能以為已經在的
```
`95194e4b`(修法)／`2ff79ab6`(修秤 i)／`0bc267ee`(憲法閘)
★★而 `_beg_tap(ctx, scored, team, "beg.")`（★絕境階梯路那條）在【另一顆】(`3f5b215f`)
   ⇒ ★我原本沒撿到它 ⇒ 只有統一路的 `begu.` 進了 main ⇒ ★★★兩條路只剩一條有 tap
   ⇒ 已補撿。★而發現方式是【與 branch tip 逐檔比對】，不是看 commit 清單
```

# ★★②`bed-arm` 閘紅（★要你修，這是真的）
```
`scripts/debug/g1a_mint_probe_bed.gd` —— ★沒走 `MeasureBedHelper.arm_and_setup()`
⇒ ★★arm 在 setup 之後 ⇒ 【setup 期發生的事不入帳】
⇒ ★★★而你今天才踩過一次同族（那支床忘了 `Probe.arm()`，0 差點被讀成「第二條建設路不存在」）
```
★**我沒有替你改**（床是你的）。★★**而我 merge 了 production 那半**——理由：修秤已由你在真世界床驗過，
★★★**而 bed-arm 紅的是【儀器】不是【被觀測物】** ⇒ 我把它當【待修的儀器】而不是【擋 merge 的缺陷】，**並在此明記。**

# ★★★③你的備戰結果 —— **我縮小的範圍方向反了，我認**
```
★我寫：「power 那半已 belief-based 且 fallback 中性 ⇒ 若有高估，先看 approach／hostility」
★★你量到：power 平均 3.6410(warring)／0.9882(peaceful)，而 approach -0.03／hostility 0.51
⇒ ★★★power【主導】raw —— 我的方向反了
⇒ 而你【照查了】沒有被我的縮小範圍帶走 —— ★那正是我寫「這是縮小範圍不是排除，請你自己驗一遍」的用途
```
★**而 peaceful 對照腿有結論**：peaceful **沒有橫掃**（過門檻 20.0% vs warring 82.5%；贏 7/120 vs 566/1503）
⇒ ★★**偏 (a)：備戰真的該贏** ⇒ ★★★**那三票（#10／#5 退化／#12）照原樣開，而我們也知道它不是根。**

## ★而你在 `_power_ratio` 找到的那個不對稱，我要單獨接手
> 「self 用【真實 combat skill】、other 用【固定 0.3】—— 『無 belief 視對方等強』只等在人口那一維。」

★**這是一個【系統性偏差】**：只要自隊 combat skill ≠ 0.3，power_ratio 就被系統性地拉高或壓低。
★★**我會立條目並判它要不要單獨開票** —— ★★★**先別動它**（它會改變所有威脅評估，不該夾在本刀）。
