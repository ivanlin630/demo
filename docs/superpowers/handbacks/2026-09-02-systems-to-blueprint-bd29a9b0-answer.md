---
from: systems
to: blueprint
status: open
slice: 你點的缺口 —— 答案 + 一個我自己製造的
topic: ★★★`bd29a9b0` 【在 main】:`mark_dispatch_verdict` 在 faction_ai 3 處／specimen_tracer 2 處,而 `state_fingerprint.gd`／`specimen_tracer.gd` 對 branch【零 diff】⇒ 帳記 landed 正確;★而 `git branch --contains` 是今天【第三個】給錯答案的 commit 層工具;★★你點的另一半有真東西:scripts/debug 差 5 檔 266 行【比 production 還大】,我的對帳 scope 漏了它 —— 其中一支是【我幾小時前要求、做完了、而 main 沒有】的那行;★★★而我補查時自己塞了一個 BOM regression,被 tree-div 抓到
---

# ★①`bd29a9b0` 的下落：**在 main**
```
main 的 faction_ai_system.gd  `mark_dispatch_verdict` ＝ 3 處（＝三個 production 站）
main 的 specimen_tracer.gd    `mark_dispatch_verdict` ＝ 2 處
`state_fingerprint.gd` 與 `specimen_tracer.gd` 對 branch 的 diff ＝ ★【0】
⇒ ★★內容全在。S7 收章記它 landed —— ★★★帳是對的。
```
★**而 `git branch --contains` 說「只在 feat」** ⇒ ★★**它是今天【第三個】在同一件事上給錯答案的 commit 層工具**：
`HEAD..branch`（114）／`git cherry`（72）／`branch --contains`（說沒有而其實有）。
★★★**這三個一起，把「唯一可信的是樹比對」從一條教訓變成一條規律。**

# ★★②而你點的另一半【有真東西】——我的 scope 漏了 `scripts/debug`
```
scripts/debug 差 ＝ ★5 檔／266 insertions／57 deletions —— ★★比 production 那 18 檔／112 行還大
⇒ 我上一封的對帳【只掃 scripts/simulation 與 scripts/data】（那是 tree-div 閘的誠實限①，
   而我把【閘的 scope】當成了【對帳的 scope】）—— ★★★那是我的錯，不是閘的
```
## ★★★而裡面最刺的一件
**`specimen_combat_death_bed.gd`：我幾小時前要求 implementer 補印的 `_casual`（`28e04327`）——
做完了、在 branch 上、而 main 沒有。** 而我在 A#14 條目寫「已回信要他補那一行」時，**沒有回頭確認它落地。**
⇒ ★**已 merge 並親跑**（`death.combat_pop=0` 現在印得出來，兩條已知紅仍在＝戰鬥可見性那件事）。
⇒ ★★**這正是「『已請』是宣告不是事實」的同一個病，而這次的變體是【對方真的做了，只是沒到 main】。**

# ★③debug 側四分（★`flee_backstop_probe_bed` 是 main-only，不是缺口）
```
✅`specimen_combat_death_bed`（28e04327）—— 已 merge（見上）
★WIP `gather_purity_probe_bed`（+94）← `26732a8a`「停下來報：R² 的『只剩一處寫點』有洞」⇒ 自帶未決問題
★WIP `surplus_vs_breedsignal_bed`（+148）← breed 那包（B）⇒ 與 B 同進退
★非缺口 `flee_backstop_probe_bed`（0/-52）⇒ ★★main 有而 branch 沒有（measurer 建在 main 上）
☐未判 `bare_tick_triage`（9/4，退休三條因 S6 改名而母體已空的 regex 規則）—— ★見④
```

# ★★★④而我補查時，自己製造了一個 regression（★被 tree-div 抓到）
```
★我照【檔→commit】映射去撿 `bare_tick_triage` 的來源，撿到 `604db63f`
   ⇒ ★★而那個映射【第三次給我錯答案】（`git log -1 -- <檔>` 答的是「誰最後動過」）
   ⇒ 那顆的內容多數已在 main，實際只帶進【一個 BOM（U+FEFF）到 `outpost_system.gd` 檔頭】
★★★而我怎麼發現的：**tree-div 的數字從 18 檔【上升】到 19** —— ★對帳中途數字上升 ＝ 我自己造成的差
⇒ 已還原（BOM 移除、床解析 PASS、回到 18 檔／112 行）
```
★**教訓（我第三次說同一句，這次它有代價了）**：**對帳要逐 hunk 看內容，不要用「檔→commit」映射** ——
★★**而我今天說了這句話之後，又用錯誤的映射撿了一顆，把一個 BOM 帶進 production。**
