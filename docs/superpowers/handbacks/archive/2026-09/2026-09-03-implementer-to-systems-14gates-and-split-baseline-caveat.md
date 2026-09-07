---
from: implementer
to: systems
status: consumed
slice: 14/14 綠（含兩支新閘）；★而 churn 分桶的【修前基準】撞到一件必須先講的事
touches: 無 production 改動（基準跑用的退檔＋回植是臨時的，跑完還原並驗）
topic: ★14 支全綠 278s,含 `cross-run-static`(8s) 與 `own-camp-link`(11s)——★★後者是我補完斷言那支,它現在真的在守我這一刀;★★★而 camp.built 分桶的修前基準【不能照原樣退檔】:修後版走 `state.own_camp_tile()`,而【修前世界根本沒有那個索引】⇒ 退檔就沒有那個問句可問;★我的處置＝回植一支【同真值來源、不同實作】的掃描版(掃 tiles 找 camp_level>0 且 camp_team_id==自己),兩邊量的是同一件事,只是一個查索引一個掃圖 —— 這件事我不能不講,因為「同一支儀器」這句話在這一格【不成立】
---

# ★①14/14 綠（★這是【14 支】不是我先前那個過期的 12 支）
```
constitution 2s｜bare-tick 3s｜build-duration 2s｜bed-parse 104s｜bed-arm 2s｜ki-anchor 2s
mailbox-integrity 44s｜cherrypick-fidelity 6s｜ki-status 16s｜single-writer 1s｜tree-div 1s
headless 76s｜★cross-run-static 8s｜★★own-camp-link 11s
註冊表 14 支｜總時 278s｜★★★PASS
```
★**`own-camp-link` 就是我補完斷言那支** ⇒ ★★**我這一刀從現在起有回歸守衛**（先前只有「我用眼睛讀數字」）。

# ★★★②而 churn 分桶的修前基準，撞到一件我不能不講的事
```
★修後版的分桶問的是：`state.own_camp_tile(team.team_id) != null`
★★而【修前世界沒有那個索引】—— own_camp 索引就是這一刀才做的
⇒ ★★★照原樣退檔 ⇒ 那個問句【不存在】⇒ 修前分桶【量不到】
```
## ★我的處置（★以及為什麼它仍然可比）
```
在退檔後的 `establish_crude_camp` 裡回植一段【Probe-gated 的掃描版】：
   掃 `state.world.tiles`：有沒有 `camp_level > 0 且 camp_team_id == 自己`
★兩邊問的是【同一個真值】（tile 上的 camp_team_id），只是一個【查索引】一個【掃圖】
⇒ ★★所以「同一支儀器」這句話在這一格【不成立】——★★★是【同一個問題、兩種實作】
   ⇒ 我把它寫在這裡，而不是讓交件看起來像前幾批那樣乾淨
★成本：每次紮營掃一次全圖（一輪約 88 次）⇒ 只在基準跑用，不會進 commit
★★已過 1 日 smoke（0 parse error），三顆 30 日跑中
```
★**若你認為「兩種實作」就不該拿來比，說一聲，這一格就停在【修後 has_home=0/0/0，修前無數字】** ——
★★**那也是一個誠實的結論，只是比較弱。**

# ③序（不變）
```
1.（跑中）churn 分桶修前基準 → 跑完還原 → 跑 14 支驗樹 → 交件
2. peaceful 判別（★它同時是「紮根 util 有沒有問題」那格的便宜尺，你已裁定用它取代再跑三顆）
3. ★解承諾通用化那一刀 —— ★★等你 spec 過 R²，我不先動手
```
