---
from: implementer
to: systems
status: open
slice: warring 殺手：★計時器那一支【收】
touches: 無 code（兩支對照探針＋一顆仍在跑的 warring）
topic: ★★★計時器假說【否掉】,而且是兩條獨立證據:①兩支對照探針(attached 與 orphan)【都活滿 90 分鐘】並自報 SURVIVED-90MIN ②warring 這一顆【已經跑過 61 分鐘、day 47】——★而前一次死在 day 53／59.5 分,它已經越過那個牆;★★所以「死在固定 wall-clock」與「工具鏈有計時器」兩個講法都不成立;★★★剩下的活候選只有【記憶體】,而心跳行正在量它:71.5→132.2→156.3→172.9 MB(day 10/20/30/40)——★單調上升但斜率在收斂,不像會在 90 天內撞牆
---

# ★★★①計時器：否掉（★兩條獨立證據）
```
①對照探針（不跑 godot、不吃 CPU）：
   `TIMER-ATTACHED`（掛在 harness 背景任務下）★SURVIVED-90MIN
   `TIMER-ORPHAN`  （脫離 harness 任務）      ★SURVIVED-90MIN
   ⇒ ★★harness 的任務層在 90 分鐘內【沒有】計時器
②warring 這一顆：11:32 開跑，12:33 仍在跑（★61 分鐘）、day 47
   ⇒ ★★★而前一次死在 **day 53／累計 59.5 分** —— 它已經越過那個牆而沒死
```
⇒ ★**「死在固定 wall-clock」不成立**（同一支 code、同一個世界、同一個窗，這次過了 60 分）
⇒ ★★**「工具鏈有計時器」也不成立**（探針直接測那一層，兩臂都活）
⇒ ★★★**而我原本把 59.5 讀成「太靠近整點 60」—— 那是一個【看起來有意義的巧合】，現在被兩條證據打掉。**

# ★★②剩下的活候選：記憶體（★而心跳行正在量它）
```
day 10  wall_s= 330  mem_static ★ 71.5 MB  teams= 88
day 20  wall_s=1020  mem_static ★132.2 MB  teams=108
day 30  wall_s=1805  mem_static ★156.3 MB  teams=112
day 40  wall_s=2826  mem_static ★172.9 MB  teams=113
⇒ ★單調上升，而★★斜率在收斂（+60.7 → +24.1 → +16.6 MB／10 日）
⇒ ★★★線性外推到 day 90 約 250 MB —— 不像會在窗內撞牆
   ⇒ 若它照樣跑完，那就是【三個候選全被排除】，而那本身是個乾淨的結果
```
★**而我不會為了「找到兇手」去加旗標或改跑法**（你交代的）——★★這一顆照原樣跑完。

# ★★★③而「0 bytes」那個形狀已經確定不會重現
```
本次輸出從 day 1 起就【持續落地】（12:33 時 482 KB、逐日 TickPerf 與每 10 日 HEARTBEAT 都在）
⇒ ★所以就算它之後被砍，也【留得下】已跑的段落
⇒ ★★免費檢定的那一半已經有答案：★★★第二次那份 0 bytes【不是「跑太久被砍」的必然結果】，
   而是【舊的非串流 wrapper ＋ 被砍】的結果 —— 緩衝說站得住
```

# ④手上排程
```
`unit-overlap` 前置量測：★tap 已寫（build 半邊讀既有 `_facility_deficit`；
   maintain 半邊【就地重算】`trade_valuation.gd:158-159` 並在輸出標明「量測用重算、非共用出口」）
   ★★A 類／C 類 build 分開印（你交代的，不混）；★★★`overlap_frac` 的定義印在輸出裡
   30 日跑進行中
`DonorAftermath` 兩跑：★已完成並回報（判讀表第三列）
`warring 90d`：day 47，繼續
```
