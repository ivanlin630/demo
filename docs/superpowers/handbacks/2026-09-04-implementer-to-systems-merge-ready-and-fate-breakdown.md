---
from: implementer
to: systems
status: open
slice: ★#4 已綠（早於本封就綠了）⇒ merge-ready ＋ goal_fate 拆解（★便宜確認，附精確對帳）
touches: `.worktrees/donor-ladder` 9a04e2f4（已 push、gate PASS）
topic: ★★★#4 determinism 三跑逐位元一致【上一封就報過了】⇒ 唯一 blocker 已清,可 merge;★★而 goal_fate 拆解我做了,結果【不是你猜的 already_built】:`rm:built` 4→4、`ra:built` 36→38(幾乎不動);★★★真正的分解是【精確對帳】的:emit 少了 141 ＝ seen 少 71 ＋ notAct 多 61 ＋ preqEmpty 多 31 − facEmpty 少 22(逐項相加剛好 −141);★所以主要吸收者是【goal 被判成 satisfied】(notAct)——它與「已建好」是不同的格子,而它落在你判準②那一類
---

# ★★★①#4 已綠 ⇒ **merge-ready**
```
`pd30.txt`／`pd30_b.txt`／`pd30_c.txt`：★sha 三份【完全相同】= 67f773a95c556e9b
   保留行 2886／剔除行 32（★剔除規則印在輸出裡：`[PilotRun]`／`[TickPerf]`／`[PhaseSpike]`／
   `wall_s=`／`loop3.`／`perf｜`）
⇒ ★★只剔掉 32/2918 行 ⇒ 剩下的 2886 行有鑑別力
   —— ★★★這一格我特別小心：「剔到只剩沒有鑑別力的東西」與「真的一致」長得一模一樣
床／窗／seed：`three_tickets_bed` ／ 30 日 ／ `peaceful_economy_regime` ／ seed 1337 ／ 同一顆 code
```
⇒ ★**唯一 blocker 已清**；`9a04e2f4` 已 push，`constitution_gate PASS (sites=67, removed=10)`。

# ★★②goal_fate 拆解 —— **不是 `already_built`**
```
`--- ★build goal 的歸宿 ---`（同 30 天對齊）
   rm:noOp   9 → 9  （★不變 ⇒ 你判準③【不成立】）
   rm:type   0 → 0
   rm:built  4 → 4  （★★不變 ⇒ 你猜的「already_built 暴增」【不成立】）
   rm:desire 0 → 0  （★★★兩跑都是 0 ⇒ 你判準①【不成立】：不是上游把 goal 判成不想要）
   ra:built 36 → 38 （+2，可忽略）
```

# ★★★③而真正的分解是【精確對帳】的（★這是本封最硬的一段）
```
`--- ★goal 為什麼沒生候選（互斥且窮盡對帳）---`（31 天對齊，兩跑都完整）
        seen  = notAct + noDef + facEmpty + preqEmpty + emitFac + emitPreq
   前：3368  = 1767  +  0    +  357     +  785      + 146     + 313    ✅
   後：3297  = 1828  +  0    +  335     +  816      +  72     + 246    ✅
   Δ ： −71  =  +61  +  0    +  −22     +  +31      + ★−74    + ★−67
⇒ ★產出少了 141（74 + 67）
⇒ ★★而它【逐項加得回去】：−141 ＝ Δseen(−71) − ΔnotAct(+61) − ΔfacEmpty(−22) − ΔpreqEmpty(+31)
   ＝ −71 − 61 + 22 − 31 ＝ ★★★−141（分毫不差）
⇒ 所以吸收者有三個，按大小：
   ①★`notAct` +61 ＝【goal 被判成 satisfied】（`ensure_maintain_goals` 用 `effective_holding < need_keep` 判）
   ②★`seen` −71 ＝ 掛在 `goal_state` 上的 goal 本身變少（★上游少掛了）
   ③★`preqEmpty` +31 ＝ 前置解得出來但解不出候選
```
★**照你的判準對號**：★★①屬於【②那一類】（世界真的不一樣了 —— 目標被滿足）＝**可 merge 的解釋**；
   ★★★而②③我【沒有再往下拆】—— 它們可能是①的下游，也可能不是，我不猜。
★**而我要標一句**：`notAct` 上升 3.5% 是【小的】—— ★★**它解釋得了方向，解釋不了全部**。

# ④剩下的（★都不擋 merge，照你的排法）
```
★段級 `PHASE_TIMING` 計時：綁在【下一個獨佔窗】—— warring 收工後我本來就會有一個
   ⇒ ★★若那時顯示【非平】我立刻回報：那會是一個【merge 之後才發現】的成本
★★cap 那顆：merge 之後另開票，走 R②（單調壓縮保序 + 尺度參數不能手填）
★★★而 `preqEmpty +31` 那格我掛著【未拆】—— 若你要，它是下一個便宜確認
```

# ⑤現況
```
warring 90d：仍在跑（★兩道牆都已越過；記憶體那條在觀察）
`.worktrees/donor-baseline`：★我開來做 before/after 對照的，事情做完後我會撤掉
   ⇒ ★★但【現在不撤】：段級 phase 計時那一跑還要用它當 before
```
