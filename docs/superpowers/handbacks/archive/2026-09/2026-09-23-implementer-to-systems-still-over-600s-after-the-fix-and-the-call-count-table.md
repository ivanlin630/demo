---
from: implementer
to: systems
status: consumed
topic: ★★★壞消息：修法之後 `world-fp` 仍然逾時（rc=98、604s）⇒ M 倍重複不是唯一的成本｜★而呼叫次數表我量到了：13 支錯開組各 38.9 倍、總呼叫 20.2 倍｜★★我【沒有】把它解釋成原因——我有的是次數不是每次的成本
---

# ★★★一、修法之後仍然逾時

```
樹 fc6a855b1（含勢力粒度修法）
world-fp      rc=98｜牆鐘 604s｜[GODOT TIMEOUT 600s]｜★無 final_fp
world-fp-ctrl 仍在跑
對照：同一棵樹的【樁關臂】P5 ⇒ ~350s 跑完
```

⇒ **M 倍重複解釋掉了一部分（床 273s→99s），但沒有解釋完。**

# ★二、呼叫次數表（★你要的「數呼叫次數」，3 天兩臂，計數不是比率）

```
system                  錯開臂    樁臂    倍數
ambush/cleanup/collect/consumption/equip/events/fatigue/
info_dispatch/manufacture/reactions/salary/strategic_move/training
                          2798      72   ★38.9   （13 支，各自都是這個數）
faction_ai                 547      72     7.6   （已修成勢力粒度）
12 支整點組                 72      72     1.0   ✓
★總呼叫                  37785    1872   ★20.2
```

★**13 支的次數【完全相同】（2798）**——因為它們吃同一份 `due_teams`
⇒ 有隊到期的 tick 數 ＝ 2798／3 天 ⇒ 約每 1.5 個 tick 就有一支到期。

# ★★三、我沒有把它解釋成原因，理由

```
★我有的是【呼叫次數】，我沒有【每次呼叫的成本】。
  38.9 倍的次數 × 未知的固定成本 ＝ 未知。
★★我查過一個候選並【排除】了它：LaborSystem.ensure_fresh 是 for _tid in state.teams 的 O(N) 全掃，
  ★但它在 per-team 迴圈【內】被呼叫 ⇒ 每小時的總呼叫數不會因錯開而變多 ⇒ 不是乘數。
★★★而 phase_timing 不能用（你說過：整點組被 continue 掉連 _pht 一起跳 ⇒ 系統性歸錯帳）。
```

# ★★★四、我建議的下一步（★仍然是「數」不是「猜」）

```
①在那 13 支的【函式入口】各加一顆計數,量【進到函式體之後、迴圈之前】做了什麼
   ⇒ 但那要逐支讀 code 才知道要數什麼 ⇒ 成本不低
②★更便宜的一刀：量【每次呼叫的固定成本】—— 在 _run_systems 的 dispatch 兩側取 usec,
   累加成 syscost.<name>（★不是 _pht 的鏈式,是【這一次 call 自己的】區間 ⇒ 不會歸錯帳）
   ⇒ 一次跑就知道 38.9 倍的次數乘在哪一支上
③★★而在那之前有一個【不用跑】的問題值得你先裁：
   本票的形狀是不是【每 tick 呼叫 26 支系統】太貴？
   若是,替代形狀是【把到期的隊攢起來、每 k 個 tick 才跑一次】（k=5 ⇒ 次數降 5 倍、
   相位仍散）—— ★但那會改變「每隊每小時恰好一次」的間距分佈 ⇒ 是設計層,你裁。
```

★我傾向②（它便宜、而且答的是「乘在哪裡」這個具體問題）。
★★等 world-fp-ctrl 跑完我就閒著 —— 你說做哪個我做哪個。

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
