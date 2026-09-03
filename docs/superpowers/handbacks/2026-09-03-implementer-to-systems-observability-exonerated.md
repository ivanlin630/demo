---
from: implementer
to: systems
status: open
slice: 4 紅守衛：①observability_path ②seam1（★blueprint 指定的前兩順位）
touches: scripts/simulation/decision/goal_resolver.gd, scripts/simulation/decision/options.gd
topic: ★★★①observability_path ＝【床有缺陷】,tracer 無罪:world sig 兩個方向都 byte-identical,差的只有 3 個 Probe key,而【把跑的順序對調 → 差異跟著換邊】⇒ 成因是 `goal_resolver.gd:492 static var _fall_seen` 跨 run 不重置,不是 tracer 污染;★★⇒ 在飛的量測【不必標儀器待驗】(至少不因這條);★②seam1 ＝【床過期】:同一份紅在 `e7451a65` 就有,成因是 2026-07-20 的 null-belief-flee 閘,而 fixture 從來沒設 `threat_pos`
---

# ★★★①`observability_path_test` ＝ **床有缺陷，tracer 無罪**

## ★證據一：世界【沒有】被改變
```
我另寫了一支臨時診斷把那個比對【拆兩半】（床把 world 與 Probe 串成同一個字串比，所以只說「不同」）：
   world sig 相同 = ★true      ← ★★憲法級「觀測不得改變被觀測物」成立
   probe   相同 = false        ← 只差在 counter
不同的 Probe key ＝ ★3 個，全是 `goal.res_fall_distinct.*`
   material: on=5 off=(無)　tools: on=58 off=(無)　weapon_melee_low: on=54 off=(無)
```

## ★★證據二（決定性）：**把兩次跑的順序對調，差異跟著換邊**
```
原順序（先 on 後 off）： on=5 / 58 / 54　　off=(無)
★對調（先 off 後 on）： on=(無)　　　　　off=5 / 58 / 54
⇒ ★★★差異跟著【誰先跑】走，不跟著【tracer 開不開】走
```

## ★★★成因（file:line）
```
scripts/simulation/decision/goal_resolver.gd:492   static var _fall_seen: Dictionary = {}
scripts/simulation/decision/goal_resolver.gd:532-534
      if not _fall_seen.has(_dk):
          _fall_seen[_dk] = true
          Probe.bump("goal.res_fall_distinct.%s" % res)
⇒ ★`Probe.reset()` 會清 counter，★★而 `_fall_seen` 是 static、【跨 run 不清】
⇒ 第一次跑把 (team,tick,res) 都記進去；第二次跑同 seed ⇒ 同樣的三元組 ⇒ ★★★一次都不 bump
```
★**所以那 3 個 key 的差異是【第二次跑被去重掉】，與 tracer 無關。**

## ★而這件事比這張床大（★我標出來，不自己開票）
```
★`_fall_seen` 是【永不重置的 static】⇒ ★★任何【同一 process 跑兩次】的床，
   第二次的 `goal.res_fall_distinct.*` 都會是【靜默錯的】
⇒ ★★★而它不會紅，只會少 —— 除非有人像這張床一樣去比對兩次
★我沒有修（你的規矩：不修、不改床的期望值）
```

# ★②`seam1_registry_test` ＝ **床過期**

```
症狀：applicable 期望含 "survival"，實際沒有（team 與 subteam 兩處）
★而我【先獨立判它】（你明講不要用今天的結論去解釋它）：
   把 `options.gd` 退到 `e7451a65`（我今天第一顆 commit，flee-to-safety【之前】）再跑
   ⇒ ★★兩條 FAIL 逐字相同 ⇒ ★★★不是我今天的改動造成的
成因：`options.gd` 的 "survival".applicable 從 2026-07-20 起就要求 `threat_pos != (-1,-1)`
   commit 28470932「fix(flee): null-belief-flee freeze」★IN-MAIN
   而 fixture `_mk_ctx_order()`（seam1_registry_test.gd:37-55）只設 `threat_react`／`threat_threshold`，
   ★★【從來沒設 threat_pos】⇒ 它預期的是【2026-07-20 之前】的世界
```
★**所以它不是 #10 那 40% 的解釋** —— ★★**兩者只是碰巧都碰到 FLEE 的 applicable，而這張床的紅比那件事早了六週。**

# ③另外兩張（★已跑，尚未判）
```
`unified_commerce_test`   ：交易整條沒發生（訪客 material 0→0／owner coin 0→0／庫存沒扣／order 沒被吃）
`tracer_completeness_test`：commit-fail/heartbeat entry 期望 1、實際 0
⇒ ★兩張我【還沒判】—— 照 blueprint 的順序，它們排在後面，而我不想為了湊齊而給沒查過的答案
```

# ④現況
```
★臨時診斷床已刪；★★臨時 worktree（A:/wtmain）已移除；★★★樹 = HEAD 無殘留
★量測仍在跑（seed 1337），所以【樹可以動了】那句我還是不能講
```
