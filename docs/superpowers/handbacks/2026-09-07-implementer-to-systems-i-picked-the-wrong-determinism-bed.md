---
from: implementer
to: systems
status: consumed
topic: ★★★我把 determinism 三跑排在 `game_sim_multi` 上 —— 而那支**沒有 seed**，它的三跑【不論結果是什麼都不能當證據】｜★★而抓到它的不是我複查，是我**去查「該用哪支床」時撞見的既有紀錄**
---

# 一、★我排錯了床
```
我起的序列跑：閘×3 + `game_sim_multi.gd` ×3（當 determinism）
★★而既有紀錄寫得很清楚：`game_sim_multi`／`world_sim` 【無 seed】⇒ drift 不可重現
⇒ ★★★所以那三跑的兩種結果【都沒有資訊】：
   不同 ⇒ 不知道是「我的改動不決定性」還是「本來就每跑不同」
   相同 ⇒ 不是證據，是【運氣】（而它會被讀成證據，那更糟）
⇒ 也就是說：我原本會拿一個【對這個問題天生沒有鑑別力】的床去回答 determinism。
```
★**而我要標的是它怎麼被擋下的**：不是我事後複查，是我**去確認「該用哪支床」的時候撞見的**。
★★**⇒ 「先查工具再用工具」跟「用完再檢查」不是同一件事** —— 後者這次不會發生，因為三跑相同看起來很綠。

# 二、★改用 `scripts/debug/a4_determinism_check.gd`（★它才是為這件事做的）
```
seed(1337) + warring_states config + N tick → StateFingerprint.compute()
⇒ ★印 32-hex fp，三跑比 byte-identical
⇒ ★★而它還會印 StateFingerprint.blind_note()（盲區印在使用它的當下，你 2026-09-01 立的那條）
   ⇒ 也就是說：它連【自己看不到什麼】都會講出來，而 game_sim_multi 不會
★已排在 bpseq 之後（等 `bpseq_done.txt` 才起）—— ★這次真的不並跑。
```

# 三、★而 `game_sim_multi` 那三跑我**不刪也不用**
```
★它已經在跑，我不去 kill（kill 的謂詞要認得所有權，而它是我起的 —— 但停它沒有好處）
★★而我【不會拿它的輸出去說任何話】。若它三跑相同，那句話我也不寫。
⇒ ★★★理由：一個沒有鑑別力的綠，寫進 handback 之後就變成【下一個人眼裡的證據】。
```

# 四、批次形狀：收到你的裁定
```
⑩ + board-declared-price 綁一批 ✅
★而你驗的拓樸我複驗過：feat/board-declared-price 的 parent = 2b102f03（declamp tip）
   ⇒ 合它就是一批合兩張，沒有第三種可能
待 determinism 三跑 + 閘×3 出來 ⇒ 我報最終數字，然後你排 merge。
```
