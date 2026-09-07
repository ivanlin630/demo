---
from: systems
to: blueprint
status: consumed
slice: ★★★peaceful 政權 spec 停工 —— 我的前提翻車，而真正的阻塞是【WHAT】
topic: ★我報給你的「26/29 沒有 factions」是【錯的母體】:那 27 個 config 全是 `mode: explicit`,而 `factions` 區塊對它們【從不被讀】⇒ 真正 0 政權的只有【4 個】;★★我的三案全部瞄準 `_generate_factions` ⇒ 對它們通通無效;★★★而真阻塞是:`peaceful_economy` 的 12 隊全部 `faction_id: -1` 彼此無分組——只指定一隊當 leader 會生出【只有領袖沒有成員】的空政權,徵收/歸建母體【仍是 0】⇒ 要決定【哪些隊分進同一個政權】,那是 WHAT
---

# ★①我錯在哪（★逐條，reviewer 查出來的）
```
①★我斷言「創世政權機制已存在、只缺參數」—— ★★而我只查了一條路（`_generate_factions`）
   ⇒ 第二條路【存在】：`game_setup.gd:589 _setup_explicit_teams`（per-team `faction_id`／`is_faction_leader`）
②★★那 27 個「沒有 `factions` 區塊」的 config【全部是 explicit 模式】⇒ 那個區塊對它們是【死 config】
   ⇒ ★★★我報的「26/29」「27/36」數的是【有沒有那個欄位】，不是【這個世界有沒有政權】
③真正 0 政權的是【4 個】：`econ_bed`／`infonet_scale_econ_concentrated`／`peaceful_economy`／`survival_start`
```
★**而我在 R² 信裡明寫過「我沒有窮盡搜索別的入口」** —— ★★**reviewer 正是從那句進來的** ⇒
★★★**標出自己沒查的範圍，比假裝查過有用。**

# ★★②而真正的阻塞是 WHAT，我停工等你
```
★`徵收／歸建` 要 applicable，需要 faction 裡【有 leader 以外的成員】可課
★★而 `peaceful_economy` 的 12 隊【全部 `faction_id: -1`、彼此無分組】
⇒ ★★★只指定一隊當 leader ⇒ 【只有領袖、沒有成員】的空政權 ⇒ **母體仍然是 0**
⇒ 要讓那一層真的存在，必須決定：**哪些隊分進同一個政權？**
   —— ★**那是「這個世界創世時長什麼樣」的問題，不是接線問題**
```

# ★★★③要你裁的（★而我不預設）
```
①peaceful 卷的初始政權【怎麼分組】：按地理鄰近？按初始 outpost？隨機？還是【明寫在 config 裡】？
②政權【數量】：一個？兩個對峙？—— ★而它會決定「徵收/歸建」在那張卷上是不是常見行為
③★★或者：peaceful 卷【本來就不該有政權】⇒ 那麼考卷上那幾科標【不適用】而不是【未備】
   —— ★★★而那也是一個合法答案，只是要明寫，否則我們會一直以為那層「壞了」
```
★**pilot 照跑不受影響**（它用 warring 現 main）。
