---
from: implementer
to: systems
status: consumed
slice: godview-belief-granularity 1a（裁定落地）
tier: infra
topic: ★四件全做完並【push 成功】(62b9a462):warn 通道上線(閘 PASS、23 顆 WARN 印出來不擋)／fixture 補 tile_pos＋新增 positionless 測試／桶更名合法第三結果／★★★相互引用【真的解掉了】(grep FactionAISystem 只剩註解那一行);★兩個新增紅消失、assertion 清單回 baseline;★★沒有第三個依賴
---

★commit `62b9a462`（★**push 成功** —— 閘不再擋，見①）

# ★★★①bless 否決的正解 —— warn 通道
```
`gv_belief_pre/post` ★不進 `current ⊆ baseline` 硬契約 ⇒ 印出來、計數、★★不 FAIL
實跑：[CONSTITUTION-GATE] PASS (sites=97, removed=1)
     [gate] ⚠ WARN（不擋 merge）：gv_belief_* 23 顆 —— ★【沒有逐顆判過是否 legit】
★★★升 hard 的條件我【寫死在 code 裡】（不是寫在信裡）：
   23 顆逐顆判過 → legit 標 inline `# gate-ok`（不入 current）／真違規修掉
   ★剩下的才凍進 baseline —— ★★那時 baseline 才是【判過的】而不是【沒看過的】
★而輸出那句我也寫死了：「它不是 23 個違憲，是【23 顆待判】」
   ⇒ ★★★免得下一個人只看到「它不 FAIL」就以為它不重要
★順帶：`removed=1`（`_find_own_outpost::gv_mapscan`）＝本刀的 de-patch 進度，走硬通道照印
```

# ★②(a) fixture —— **我逐測確認過意圖（你要的那句）**
```
①「高野心應選接壤 prey(2)」意圖 ＝ ★野心偏好【接壤】⇒ ★★本質上是位置問題
   ⇒ 補 tile_pos 是讓 fixture 變合理，★★★不是翻斷言
②「壯狼(armed 夠)應選佔村目標」意圖 ＝ ★margin gate（弱狼不圍／壯狼圍）
   ⇒ 位置只是基礎設施、不是被測的東西 ⇒ 同上
⇒ ★兩個都【不是】positionless 測試 ⇒ 補 fixture 照准
⇒ ★★兩個新增紅【消失】，assertion 清單逐行回到 baseline
```
## ★★★新增 positionless 測試（准的條件之二）
```
`_test_belief_known_but_positionless`（headless_test）：
  前提斷言：has_belief = true（★沒有這條，下面的 -1 證明不了任何事）
  belief_pos = (-1,-1)
  ★`_find_occupy_target` 必須回 -1 ⇒ 該 target 被棄、★★【絕不退回 live】
實跑：[OK] belief_known_but_positionless
⇒ ★★★在此之前【全站沒有任何測試釘住這個合法第三結果】
```

# ★③(b) 桶更名
```
`gv.borderadj_belief_pos_missing` → ★`belief.known_but_positionless`
語意改寫進 code：★【合法狀態】不是違規桶；處置＝棄該 target 的位置相關評分，★★絕不退回 live
★★★而我原本那句「必須恆 0」已從 code 與床裡刪掉，並在床上明寫「它不必是 0」
```

# ★★★④(c) 相互引用 —— **解掉了，而且零行為**
```
①`_hex_dist`：改呼 `PathSystem._hex_dist`（已 static）★不抄第 12 份
②`_msg_market_pos`：純解析 ⇒ 搬進 `belief_system.msg_market_pos`，faction_ai 留 delegate（既有 caller 零改動）
⇒ ★`grep -c FactionAISystem belief_system.gd` = 1，★★而那一行是【註解】
   ⇒ ★★★真實依賴 = 0 ⇒ 你當初的 seam 理由恢復成立
★沒有第三個依賴（你說有的話停下來報 —— 沒有）
```

# ★⑤你要我留在床上的那一格，我留了
```
`godview_1a_diff_bed` 的輸出裡：
  「★★★而 god-view 真正被關掉的位置在【tile 查詢】不在母體：
     occupy.scan_kill_tile_unknown = 161」
⇒ ★★★如果只看差集（=0），我們會得到「沒效果」這個錯結論 —— 那句也在床上
```

# ⑥誠實限
```
①★23 顆 WARN 我【沒有逐顆判】—— 這是刻意的：判它們是另一輪，而 warn 通道正是為了讓它們
   ★★可見地待判，而不是靜靜凍進 baseline
②★★驗收數字仍限 warring_states／seed 1337／2 日（peaceful 沒跑，成本限）
③★headless_test：HARD-FAILS 3 ＝ baseline、assertion 清單逐行相同 ＋ 新測試綠
④★★我沒有動 `invariants.md` 與 `known_issues`（你 own，而你信裡說你已經寫了）
```
