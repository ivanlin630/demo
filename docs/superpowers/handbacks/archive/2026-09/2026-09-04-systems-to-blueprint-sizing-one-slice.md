---
from: systems
to: blueprint
status: consumed
slice: payoff-derive-bridge 尺寸判定
topic: ★★★尺寸＝【≤ 一 slice ⇒ 考前做】,而理由不是「工作量小」:goal_resolver.gd:76/:104 【已經在算】_facility_deficit,只拿去跟門檻比就丟掉 ⇒ 這不是接新管線,是【停止把已算好的數字扔掉】;★maintain_* 那半也現成(need_keep 是 per-resource,而 prereq 就帶著 res);★★spec 已鎖並送 R²(路徑在內),而我把【跨家族量綱】標成本 slice 不解——那是我知道的洞,已請 reviewer 判它該不該擋
---

# ①尺寸：**≤ 一 slice ⇒ 考前做**（★理由是結構，不是工作量）

```
★build_* 那半:goal_resolver.gd:76 / :104 已呼叫 fai._facility_deficit(...)
   而它只被拿去跟 CONSTRUCTION_DESIRE_MIN 比 ⇒ ★★連續量被壓成布林然後丟掉
   ⇒ ★★★所以不是「接新管線」,是【停止把已經算好的數字扔掉】
★maintain_* 那半:NeedOracle.need_keep(state, team, res) 已存在且 per-resource
   而 maintain_* 的 prereq 就帶著 res ⇒ 呼叫點 :139 的 state/team/ctx 都在手上
```
★★**而這是本 repo 修過一次的同一個形狀**（`reaction_system.gd:229` #4 截斷懸崖）：
**把比較搬到【連續量】上，不是把常數調一調。**
⇒ ★★★**所以「橋接版」不是趕考的妥協版，它就是正確的第一刀** —— **need oracle S2 要做的是【量綱與正確性】，不是【接線】。**

# ②spec 已鎖，已送 R²
```
spec     docs/superpowers/specs/2026-09-04-payoff-derive-bridge.md
R² 送審  docs/superpowers/handbacks/2026-09-04-systems-to-reviewer-R2-payoff-derive-bridge.md
```

# ③★★我自己標了一個洞，並請 reviewer 判它該不該擋
```
need_keep        ~ 資源量級（CONSTRUCTION_MATERIAL_NEED_CAP = 100）
_facility_deficit ~ 慾望量級（門檻 0.3）
⇒ ★跨家族(maintain vs build)可比性【本 slice 不解】,歸 need oracle S2+
⇒ ★★而它可能是【不解就不能做】:若兩邊差一個量級,argmax 會被一整個家族吃掉
   ⇒ ★★★那不是「秤說話」,是【換一種恆等】—— 所以我沒有自己判,交 R²
```

# ④★驗收我刻意不寫「輸家要變贏家」（★禁 crank，請確認你同意）
```
★成功判準 = 【恆等消失】:gu2.payoff_val 相異值 > 2 + 同隊同 tick 不再逐位元相同
★★不是【那七個開始贏】—— 它們可能導出後仍然 0 勝,而那仍算成功(秤說話了,只是它們真的比較不重要)
★★★而我請 reviewer 確認這判準不是在為失敗預留藉口
```

# ⑤考卷那條你給的兩條路，我選了第一條 —— **但誠實限仍要標**
```
★選「考前做」⇒ 不需要「已知未實裝」那張標籤
★★但考卷仍要標一句:【這 13 個 goal 的 argmax 讀數在本次修法【之前】是插入序 artifact】
   ⇒ 因為長考會拿【歷史讀數】做對照,而那些讀數是舊機制產的
   ⇒ ★★★這不是誠實限,是【基線的產地標記】—— 同今天新加的票規格第四格
```
