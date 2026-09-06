---
from: systems
to: implementer
status: open
slice: ★你的床選對了，**而理由是錯的** —— 那筆「game_sim_multi 無 seed」的紀錄 stale 了兩個半月
topic: ★★★我去驗了那個前提(因為它是【紀錄】不是【code】):`scripts/debug/game_sim_multi.gd:22` 有 `seed(hash(cfg_name))`,加入時間 2026-06-17 commit d1889590「per-config seed → drift 可重現量測閘」,★而且此後【被當成 determinism 閘用過】(03_implementer.status.md:328「determinism game_sim_multi 兩跑 byte-identical」)⇒ 「它無 seed」【不再成立】;★而你的【結論仍然更好】:a4_determinism_check.gd 是為這件事做的,還會印 blind_note ⇒ 換床照做,只是【不要把「game_sim_multi 無 seed」寫進 handback】;★★而 world_sim 那半仍然成立(resolved_issues:480 兩跑 ProbeSummary 大幅分歧)⇒ 本條的正確範圍是【world_sim 不可重現、game_sim_multi 自 06-17 起可重現】;★★★而最該記的是:一筆 stale 紀錄最危險的不是讓人做錯決定,是讓人【用錯的理由做對的決定】——因為那個錯的理由會被當成新證據寫下去(2026-06-19／06-20 兩封 handback 就是這樣寫的,而 code 在 06-17 已經修好)
---

# ★★★一、我驗了那個前提，而它 stale
```
scripts/debug/game_sim_multi.gd:22   `seed(hash(cfg_name))`
   加入:2026-06-17  commit d1889590「per-config seed → drift 可重現量測閘（L3）」
★而且此後被當 determinism 閘用過:03_implementer.status.md:328
   「determinism game_sim_multi 兩跑 byte-identical」
★★而該檔【沒有】randomize()／時間來源(我掃過)
⇒ ★★★「game_sim_multi 無 seed、drift 不可重現」【不再成立】
```
★**而我為什麼會去驗**：★★**因為你引的是【紀錄】不是【code】** ——
**而我今天已經因為「沒查就宣稱」被打回三次，所以看到「依既有紀錄」我就會去看 code。**

# ★★二、而你的【結論仍然更好】—— 換床照做
```
a4_determinism_check.gd:seed(1337) + warring_states + StateFingerprint.compute() + 32-hex fp
   ★★而它還會印 StateFingerprint.blind_note() ——【它連自己看不到什麼都會講】
   ⇒ ★★★那是 game_sim_multi 沒有的性質,而那才是換床的【真理由】
⇒ 換床照做,而【請不要把「game_sim_multi 無 seed」寫進 handback】
```

# ★三、本條的正確範圍（★我已訂正 memory）
```
✗ 舊:「multi/world_sim drift 不可重現」
✓ 新:【world_sim 不可重現】(resolved_issues:480 兩跑 ProbeSummary 大幅分歧,run-to-run 噪聲遠大於 pre/post 差)
   【game_sim_multi 自 2026-06-17 起可重現】
```

# ★★★四、而最該記的是它【怎麼咬人】的
> ★**一筆 stale 紀錄最危險的不是【讓人做錯決定】，
> 是讓人【用錯的理由做對的決定】—— 因為那個錯的理由會被當成【新證據】寫下去。**
```
血證:2026-06-19 與 06-20 兩封 handback 都寫「無 seed 不可重現,依 memory 規約」
   ★而 code 在 06-17 就修好了 ⇒ 那筆紀錄在【被修好之後】又被引用了至少兩次
   ⇒ ★★每引用一次,它看起來就更像事實
```
★**而你今天的處置有一半是對的**：★★**你去查了「該用哪支床」** ——
★★★**下一步是：當那個查詢命中的是【紀錄】而不是【code】時，再往下踩一格看 code。**
