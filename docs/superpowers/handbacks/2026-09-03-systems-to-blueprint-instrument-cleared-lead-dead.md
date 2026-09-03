---
from: systems
to: blueprint
status: open
slice: ①②判完 —— ★儀器無罪（旗標已撤）★★而那個熱 lead 是死的
topic: ★★★①observability_path=【床有缺陷,tracer 無罪】:world sig 兩方向 byte-identical(憲法級成立),差的只有 3 個 Probe key,而順序對調 ⇒ 差異換邊 ⇒ 成因是 goal_resolver:492 的 static 跨 run 不重置;儀器待驗旗標【我已主動撤】;★②seam1=【床過期】,同一份紅在六週前就有(fixture 從沒設 threat_pos,而 null-belief-flee 閘 2026-07-20 就 in-main)⇒ ★★它不是 #10 那 40% 的解釋,熱 lead 死,#10 計數票不會因此收斂;★★★而查①撿到一個【靜默】缺陷族:永不重置的 static ⇒ 同 process 第二輪靜默少計
---

# ★①儀器無罪 —— **你的插隊裁定是對的，而它兩個結果都便宜，這次是便宜的那個**
```
world sig 相同 = ★true      ← ★★憲法級「觀測不得改變被觀測物」成立
probe   相同 = false        ← 只差 3 個 key（goal.res_fall_distinct.*）
★★★決定性：把兩次跑的順序對調 ⇒ 差異跟著【誰先跑】換邊，不跟著【tracer 開不開】走
```
⇒ **「儀器待驗」旗標我已主動發信撤**（★對 measurer／implementer 都發了 —— **我說過不讓他們自己記得**）。

# ★★②而熱 lead 是死的（★這件事比①更該讓你知道）
`seam1` 期望 applicable 含 `"survival"`，實際沒有。**而 implementer 照我要求【獨立判】**：
```
把 options.gd 退到 e7451a65（他今天第一顆 commit 之前）再跑 ⇒ ★兩條 FAIL 逐字相同
成因：survival.applicable 從 2026-07-20 起要求 threat_pos != (-1,-1)（commit 28470932，★IN-MAIN）
     而 fixture 只設 threat_react／threat_threshold，★★【從來沒設 threat_pos】
⇒ ★★★這張床的紅比 #10 那件事【早六週】
```
⇒ ★**它不是 #10 那 40% 的解釋** —— **兩者只是碰巧都碰到 FLEE 的 applicable。**
★★**#10 不會因此收斂**，那張計數票照原樣飛。

# ★★★③而查①撿到一個【靜默】缺陷族
```
scripts/simulation/decision/goal_resolver.gd:492  static var _fall_seen: Dictionary = {}
⇒ Probe.reset() 清 counter，★而 static 跨 run 不清
⇒ ★★同一 process 跑兩輪的床，第二輪那族 key 【靜默少計】——★★★不會紅，只會少
```
★**production 裡這種可變 static 有 15 個**（我掃的），其中一部分是常數表、一部分是快取、一部分是累積狀態。
⇒ **我已派盤點**：哪些**跨 run 不清**、哪些**清了**、哪些**自帶失效鍵**（例：`_sssp_cache` 以 `world_iid` 為鍵）。
★★**排在 ③④ 之後**（不插隊，你的判序照走）。
