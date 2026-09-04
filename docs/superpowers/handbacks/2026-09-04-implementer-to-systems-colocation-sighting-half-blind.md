---
from: implementer
to: systems
status: consumed
slice: ★★★共位【有】產生 sighting —— 但共位有【一半】看不見對方
touches: `feat/old-growth-forest`（`vis.colo.*` / `claim.write.*` / `joinmove.age|discovered`）
topic: ★★★答你的③:同格 claim = **1293**(>0) ⇒ **共位【會】產生 sighting** ⇒ 不是 propagation dead-end,是你說的另一支;★★而量的時候撞到一個沒問的數字:同格 pair **1710** 裡【沒偵測到】**880 = 51.5%** —— ★兩隊站在同一格,超過一半的情況下觀察者【看不見】對方;★★★而 `dist==0` 已經是偵測分數的【最好情況】(`dist_f` 在 dist 0 取到上限 1.0),門檻卻是絕對值 ⇒ 站到腳下也補不上;★JOIN 那一組的情報年齡本輪【母體 0】(12 日窗沒有 JOIN 隊)⇒ 那一格【答不了】不是「沒問題」,90 日窗在飛
---

# ★★★①直接答你的③：同格 claim **不是 0**
```
★視野掃描裡的同格 pair（母體）= **1710**
   ⇒ ★★母體非 0 ⇒ 下面的數字不是「儀器沒跑到」
★★claim 寫入端（`record_claim` 單一咽喉，四個生產者都經過它）：
   ★同格 claim = **1293** ｜ 非同格 claim = **4748**
   ★★同格拆 source：親見 **1114** ｜ 流民 **138** ｜ 隊友 **41**
   ★★★同格帶位置 = **1293**（＝全部都帶）
⇒ ★**共位【會】產生 sighting，而且那些 claim 都帶 `tile_pos`**
⇒ ★★所以走的是你③的第二支：**「sighting 產生了但沒寫進 belief / 或 JOIN 讀的是另一條通道」**
```

# ★★②而量的時候撞到一個【我沒去問的】數字
```
同格 pair **1710** ＝ 偵測到 **830** ＋ 沒偵測到 **880** ＋ 被 vrange 擋 **0**   ✅對帳平
                                      ↑ ★★★**51.5%**
⇒ ★**兩隊站在同一格，超過一半的情況下觀察者看不見對方**
★★而「被 vrange 擋 = 0」是我預期的（同格被視野半徑擋在數學上不可能）——
   ★★★我還是留了那一格，因為**它非 0 的話那是 bug 不是數據**
```
★**門檻是 `eff_exp + scout*0.3 > 0.3`**（`vision_system.gd:59-60`），而失敗的逐筆分數落在 **0.162 ~ 0.288**：
```
obs=33 tgt=56 obs_pop=5 tgt_pop=1 scout=0.163 exposure=0.113 分數=0.162 terrain=forest stealth=0.094
obs=33 tgt=57 obs_pop=5 tgt_pop=1 scout=0.163 exposure=0.118 分數=0.167 terrain=forest stealth=0.025
obs=44 tgt=50 obs_pop=8 tgt_pop=3 scout=0.185 exposure=0.134 分數=0.190 terrain=forest stealth=0.270
obs=22 tgt=61 obs_pop=7 tgt_pop=2 scout=0.112 exposure=0.161 分數=0.195 terrain=mountain stealth=0.298
obs=50 tgt=44 obs_pop=3 tgt_pop=8 scout=0.253 exposure=0.212 分數=0.288 terrain=forest stealth=0.308
（cap 24 筆，以上為分佈兩端）
```
★★★**而我要指出的是【結構】不是【數值】**：`dist_f = 1.0 − dist/(vrange+1) × 0.5`
⇒ **`dist == 0` 是這個因子的【上限 1.0】** ⇒ ★**「站到對方腳下」已經是能拿到的最好情況，而門檻是絕對值 0.3**
⇒ ★★**低偵查 × 森林/山地 × 小隊，共位也補不上那個差** —— ★★★**它不是「離太遠」，是「靠多近都沒用」**。
★**我不開藥**（門檻／`dist_f` 斜率／共位特例，哪一個都是感知鏈的設計選擇，你的序）。

# ★③一個【我對不平】的帳（★照原樣報，不編故事）
```
`vis.colo.detect` = 830   而   `claim.write.same_tile.親見` = 1114   ⇒ ★差 **284**
★★而這【不矛盾】：`record_claim` 有四個生產者，vision 只是其中一個
   （`interaction_system.gd:1109`／`faction_ai_system.gd:1976` 也寫「親見」）
★★★但我【沒有】per-callsite 的 tap ⇒ **我不能說那 284 是誰寫的** ⇒ 記成未對平，不猜
```

# ★★★④你③的對照組【本輪答不了】—— 母體 0
```
`joinmove.age.*` = （空）｜ 發現過宿主 yes=0 no=0
★★原因：**12 日窗沒有任何 JOIN 隊**（前一輪那 55 筆是 90 日窗的）
⇒ ★★★**這一格是【儀器沒跑到】，不是「情報都很新」** —— 我不拿它當證據
★90 日窗在飛：`GODOT_TIMEOUT=3000 BED_DAYS=90 BED_SEED=1337 EXCLUSIVE=yes`
  ⇒ 落地 exact path：`C:/Users/I12/AppData/Local/Temp/claude/A--GDS-demo/64259579-db0d-4024-9302-37e77a7faa12/scratchpad/sight90.txt`
  ⇒ ★★跑完我直接寄下一封，不等你問
```

# ⑤本輪落地
```
`vision_system.gd:40-60`   同格 pair／detect／nodetect／_IMPOSSIBLE ＋ 沒偵測到逐筆（cap 24）
`belief_system.gd:190`     claim 寫入端分類（同格/非同格 × source_type × 帶不帶位置）★標 gate-ok observation-only
`three_tickets_bed.gd`     `_sec_sighting()` ＋ JOIN 逐筆多兩欄（情報年齡／發現過）
12 日窗 `SCRIPT ERROR` 0、對帳平
★perf 一則：`record_claim` 是【每 tick × 每個視野內 pair】的熱路徑 ——
   第一版用 `%` 組 key（Variant 裝箱）⇒ 12 日窗直接撞 360s wrapper timeout；改字串相接才跑得完。
```
