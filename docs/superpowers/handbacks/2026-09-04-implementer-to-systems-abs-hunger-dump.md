---
from: implementer
to: systems
status: open
slice: #2 絕對餓 organic 逐隊 dump —— ★數字很大，★★而我要先講【這份 dump 答不了「是哪些隊」】
touches: 無 code 改動（量測交件）
topic: ★★★fire 次數:seed1337 = 2010／seed42 = 1199,而取樣 500 筆【全部】`would_fire_by_old = false` ⇒ 這一條真的是新抓到的,不是本來就會 fire 的;★而逐隊那半【我不能用】:`bump_sample` 是 first-N 不是 reservoir ⇒ 500 筆是【最早的 500 筆】,而印出來的 10 筆【全是同一隊(team 52)】——★★所以它說的是「最早那批是 team 52」,不是「2010 次都是 team 52」;★★★要答「是哪些隊」需要 per-team 桶(無 cap),而那是一行 bump,我不自己加
---

# ★①數字
```
seed1337：`crisis.abs_hunger` fire = ★2010｜取樣 500（cap 滿）｜★★其中 `would_fire_by_old=false` = 500
seed42  ：fire = ★1199｜取樣 500（cap 滿）｜★★`would_fire_by_old=false` = 500
seed7   ：★跑中（`b8fp96pre`，另一個批次）
```
⇒ ★**「這一條是不是只是重抓舊的」——【否】**：取樣的 500 筆裡，**舊三判準當下【一條都不成立】**。
⇒ ★★**所以它抓到的是【存量歸零而流量為 0】那一類** —— **正是它被加進來要抓的那一類。**

# ★★②而【逐隊】那半我不能用 —— ★儀器限制，先講
```
★`Probe.bump_sample` 是 ★★first-N（不是 reservoir）⇒ 500 筆是【最早的 500 筆】
★印出來的 10 筆：★★★全部是 team 52（pop=1、raw_food=0、eff_food=0、flow=0，每 60 tick 一次）
⇒ ★所以這份 dump 說的是【最早那批是 team 52】，★★【不是】「2010 次都是 team 52」
⇒ ★★★而 blueprint 要的是【逐隊】—— 這一格我【交不出來】，不是數字不好看，是儀器不對
```
★**要答「是哪些隊」需要 per-team 桶**：`Probe.bump("crisis.abs_hunger.team." + str(team.team_id))`
   ⇒ ★★無 cap、不取樣 ⇒ 相異隊數與各自次數都出得來
   ⇒ ★★★而那是【一行】，但它是 production tap ⇒ **我不自己加，等你判**
   （★而它正好可以併進四格那一批，同一輪跑完 —— 照你批准的「備援資料順手收」）

# ★★★③而 raw 與 effective 並排那一格【有結論】
```
印出來的每一筆：`raw_food=0` 且 `eff_food=0`
⇒ ★兩者一致 ⇒ ★★不是「accessor 讀錯了」——★★★是真的一粒都沒有
⇒ 而這正是「兩者都印」的用途：若只印 eff，這一格就分不出來
★誠實限：這個結論只涵蓋【印出來的那 10 筆】——同上，first-N
```

# ④一個我只描述不解釋的形狀
```
team 52：pop=1、糧 0、flow 0，★每 60 tick fire 一次，從 tick 660 起持續
⇒ ★★而 crisis 會讓 cadence 變成 1/4 ⇒ 一支【什麼都沒有的 1 人隊】會【更頻繁地重新決策】
⇒ ★★★這是 fire 次數 2010 的機制面，而【它算不算問題】不是我判的
   （blueprint 的原話我照抄：「更常 fire 不是平衡問題，是真相問題；怕多 fire ＝ 怕真相」）
```
路徑：`scratchpad/abs_{1337,42}.txt`（seed7 跑中）
