---
from: systems
to: implementer
status: open
slice: 兩張票，都只要【逐條計數】
topic: ★#10 重開:第一格【只問哪個 applicable 條件擋的】,逐次記【條件名】,★★禁猜(blueprint 明令);★★★而施主那條我讀出五道濾網,並找到一格資訊門檻特別高:`bel.has("food_est")` 而親見 snap【沒有 food_est】——它只在互動時寫入 ⇒ 要乞食得曾經互動過;★但那是【假說】,要你逐道濾網記拒絕次數
---

# ★①#10 重開 —— **第一格只問一件事**
```
`not_in_ranked` ＝ 10/25（40%）⇒ 承諾的 option 四成時候【連候選都不是】
★要的：★★【是哪一個 `applicable` 條件擋的】—— 逐次記下【那個條件的名字】
★★★禁猜（blueprint 明令）：不要在拿到條件名之前提出任何「大概是因為…」
⇒ 母體：`current_task == IDLE` 且 `survival_committed_option != ""` 的隊 × tick（同上輪）
```

# ★★②施主可及性 —— **逐道濾網記拒絕次數**
```
`faction_ai_system.gd::_find_aid_target` 五道（我讀出來的順序）：
   ①母體 `team_discovered`
   ②`has_belief` 否則 continue
   ③★`bel.has("food_est")` 否則 continue      ←★★我最懷疑這道
   ④`food_est <= reserve` ⇒ continue
   ⑤`catch_result.reachable` 否則 continue
★要的：每一道【擋掉幾次】＋母體（★★而「①母體本身是 0」與「①非 0 但全被②擋」意思完全不同）
★★★而我懷疑 ③ 的理由（★這是假說不是結論，請你用數字打它）：
   `vision_system` 的親見 snap 【沒有 food_est】（它有 activity／pop／tags／tile_pos…）
   而 `food_est` 全站只在 `interaction_system.gd:1067` 寫入 ⇒ ★【互動過才知道對方存糧】
```
★**分帶照舊**：★★**最深帶（`food_days`→0）單獨看** —— **那才是「該乞食的時候」。**

# ★③兩張共同
```
`fp` 逐位元不變（純觀測）／母體與命中同印／命中 0 照三讀法（含「儀器沒跑到」）
★而兩張【可以同一輪跑完】——★★它們的母體不同但世界同一個，分開跑只會多花時間
```
