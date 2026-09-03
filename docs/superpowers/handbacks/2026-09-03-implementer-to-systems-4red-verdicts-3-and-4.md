---
from: implementer
to: systems
status: open
slice: 4 紅守衛 ③④ 判定（★而 ④ 有 file:line 級答案）
touches: scripts/simulation/interaction_system.gd, scripts/debug/specimen_tracer.gd
topic: ★★★④`unified_commerce` ＝【床過期】,而且我把它逼到具名桶:`trade.market_bail.buy_no_want = 1` ⇒ 訪客【沒有需求】——現行規則買方要有 reserve 缺口(interaction_system.gd:841-843),而 fixture 只給了 coin 與現貨、從沒建立需求;★★③`tracer_completeness` ＝【不確定】,而我寫清楚卡在哪一格、下一格怎麼量;★兩張都【在 main 上一樣紅】⇒ 都不是我 branch 造成的
---

# ★★★④`unified_commerce_test` ＝ **床過期**（★有具名證據）

## ★我沒有用讀 code 猜，而是把它逼到一個具名桶
床本身不 arm Probe ⇒ 五條 FAIL 只說「沒發生」。我另寫臨時床（用完已刪）**重跑同一個 fixture 並 arm Probe**：
```
dealt = false
visitor material 0.0｜owner coin 500.0｜tile material 100.0
   mkfill.attempt.buy               = 1     ← ★撮合【有】被走到（不是沒進來）
   ★trade.market_bail.buy_no_want   = 1     ← ★★就是這一條
   trade.meet = 1｜trade.meet_nodeal = 1
```

## ★★成因（file:line）
```
interaction_system.gd:841-843
   var want: float = maxf(TradeValuation.reserve(visitor, res, ...) 
                          - ResourceSystem.effective_holding(state, visitor, res), 0.0)
   var qty: int = int(minf(minf(order_rem, stock), minf(vcoin / ask, ★want)))
interaction_system.gd:848
   elif want <= 0.0: Probe.bump("trade.market_bail.buy_no_want")
⇒ ★現行規則：買方要有【reserve 缺口】才買 —— 有錢有貨【不足以】成交
⇒ ★★而 fixture 只給了 `coin: 500` 與 tile 現貨，★★★從來沒有建立「訪客需要 material」這個前提
```
★**所以床的期望描述的是【需求閘存在之前】的世界。**
★★**而這與今天那三支 `_pick_facility` fixture 是【同一個形狀】**：
★★★**前提原本由下游檢查、後來被提到前置條件，而 fixture 從來不必寫那個前提。**

## ★我沒有做的
```
★沒有改床（你的規矩）；★★也沒有判「需求閘該不該存在」——那是 WHAT
★★★而若有人要說「有錢有貨就該成交」，那是【要改規則】不是【床過期】⇒ 要 blueprint 裁
```

# ★★③`tracer_completeness_test` ＝ **不確定**（★而我寫清楚卡在哪）

```
症狀：`commit-fail/heartbeat entry ≥1` 期望 1、實際 0（400 tick、Team7 specimen）
★已排除：`_last_entry_tick` 有被 `SpecimenTracer.reset():77` 清 ⇒ ★★不是今早那個 static 跨 run 洩漏
★★★在 main 上一樣紅 ⇒ 不是我 branch
```
## ★而兩種可能我分不開，缺的是同一格
```
(a)★【床過期／床脆弱】：那 400 tick 裡 Team7 【真的】沒有任何 non-committed 決策，
   而且每 6h（HEARTBEAT_CADENCE = TICKS_PER_DAY/4）內都有決策 ⇒ 心跳不該補 ⇒ 0 是正確的
(b)★★【code 真壞】：Team7 【有】non-committed 決策，而 tracer 沒記到 ⇒ 那是觀測盲點（嚴重）
⇒ ★★★分開它們只要一格：**那 400 tick 裡 Team7 的決策中，result != "committed" 有幾次**
   （★用 Probe 在 `capture_decision` 呼叫端數，或直接 dump Team7 的 archive 逐筆 result）
```
★**我沒有做那一格** —— ★★**因為它要動 tracer 或加 tap，而你這張票寫的是「不修、判完就停」**，
★★★**而我不想在「判定」這一步就改被判的東西。** ⇒ **要我量，回一句我就做。**

# ★③兩張的共同事實
```
★都在 `origin/main`（da1f1bd4）上【逐字一樣紅】⇒ ★★都不是我 branch 帶進來的
★★★而我這次是用【臨時 worktree + --import】跑 main 的 —— ★而那個 class-cache 守衛
   （78155950）當場自己 fire 了一次，印出三行診斷後自動 import ⇒ 它在真實情境下有效
```

# ④四張總結（★①②見上一封）
```
①observability_path      ＝ ★床有缺陷（tracer 無罪；順序對調差異換邊；`goal_resolver.gd:492` static 不清）
②seam1_registry          ＝ ★★床過期（比今天早六週；`28470932` 的 null-belief-flee 閘；fixture 沒設 threat_pos）
③tracer_completeness     ＝ ★★★不確定（缺的那一格寫在上面）
④unified_commerce        ＝ ★床過期（`trade.market_bail.buy_no_want`；fixture 沒建立需求）
```
