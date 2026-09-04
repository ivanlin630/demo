---
status: ★R² issues(重) —— 前提翻車，全文重寫（2026-09-04）
owner: systems
slice: initial-regime-in-worldgen
what: 用戶 2026-08-21【建國雙層①】—— 創世帶初始政權；政權數＝worldgen 參數（blueprint 轉述 2026-09-04）
premise: ★機制【已存在】，缺的是參數與預設 —— 逐行查過，非推論
---

# ★①先把前提釘死：**這不是「缺機制」，是「缺參數」**
```
`game_setup.gd:284 _generate_factions(state, plan, config, rng)`
   :285 `var fcfg: Dictionary = config.get("factions", {})`   ←★沒有該欄 ⇒ 空字典
   :313 `var faction_id: int = state.create_faction(first_team_id)`  ←★★創世建政權【本來就會做】
   :316 `state.set_team_faction(...)`                                 ←★★★入 faction 也已接
⇒ ★**所以缺的是：27/36 個 config 沒有 `factions` 區塊** ⇒ 那些世界【政權數 ＝ 0】
```
★★**而我原本要寫的是「新增創世政權機制」—— 查完發現那會是重複造一個已經存在的東西。**

# ★★②病（★量到的，不是推的）
```
含 `factions` 的 config：★9／36（`default`／`warring_states`／`perf_scale*` 系列）
不含的：★★27／36 —— 含【全部 peaceful／infonet／econ 系】
⇒ ★★★那些床上 faction 層【全程 dormant】⇒ 在它們上面考「派系／義務／徵收／歸建」＝考一個【不存在的層】
```
★**而今天的量測已經踩到它**：`覓食／紮根` 輸給的贏家是 **徵收／歸建**（faction 義務）——
★★**那個結論只在 warring 卷成立，而我們差點把它當成世界性質。**

# ★★★③修法（★三選一，我傾向 A，交 R² 裁）
```
★案A（傾向）：`_generate_factions` 的 `fcfg` 給【預設值】—— 沒寫 `factions` 的 config 也產生初始政權
   ＋：一處改動、27 個世界同時有政權；★★－：**會改變 27 個既有床的世界** ⇒ 所有既有 baseline 失效
★案B：只給【新卷】用的 config 補 `factions` 區塊（peaceful 卷專用）
   ＋：不動既有床；★－：**「創世帶初始政權」變成【某些卷才有】** ⇒ 與用戶 WHAT（創世帶）不符
★案C：預設值 ＋ 既有床顯式寫 `factions: {count: 0}` 保持原樣
   ＋：★★★WHAT 落實（預設是「有政權」）而既有 baseline 可【顯式】保住
   －：要動 27 個 config 各一行
```
★**我傾向 C**：★★**它讓「沒有政權」變成【明寫的選擇】而不是【沒人填的欄位】** ——
★★★**而今天已經有一顆同型血證：`TeamData.new()` 出來的隊食物 0，因為沒有人覺得那需要交代。**

# ④驗收（★判讀先寫死）
```
①★27 個 config 各自的 `state.factions.size()` ＞ 0（案 C：除了顯式寫 0 的）
②★★既有 baseline：顯式寫 0 的床 `fp` 逐位元不變（★★★那是案 C 的整個賣點，不變就是驗收）
③★在一張 peaceful 床上，`徵收／歸建` 的 applicable 母體 ＞ 0（★★否則政權建了而義務仍不存在）
④★★而【不驗】世界變好或變壞 —— 這一刀只讓那一層【存在】，不判它的效果
```


---

# ★★★★⑤R² 判決：**我的前提翻車，三案全部無效**（reviewer 2026-09-04）

## ①負斷言翻車（★而我自己標過「沒有窮盡搜索」，reviewer 就從那裡進來）
```
★第二條創世建政權路【存在】：`game_setup.gd:589 _setup_explicit_teams`
   —— per-team `faction_id` ／ `is_faction_leader`
★★而那 27 個「沒有 `factions` 區塊」的 config【全部是 `mode: explicit`】
   ⇒ ★★★`factions` 區塊對它們是【死 config，從不被讀】
⇒ 我的 A／B／C 三案【全部瞄準 `_generate_factions`】⇒ **對那 27 個世界通通無效**
```

## ★★②真正的母體是【4 個】不是 27 個
```
0 政權的 config（`is_faction_leader` 計數皆 0）：
   `econ_bed`／`infonet_scale_econ_concentrated`／`peaceful_economy`／`survival_start`
⇒ ★而我報給 blueprint 的「26/29」「27/36」都是【錯的母體】 —— 它們數的是「有沒有那個區塊」，
   ★★而不是「這個世界有沒有政權」
```

## ★★★③而真正的阻塞是【WHAT】不是【HOW】
```
★`徵收／歸建` 需要 faction 裡【有 leader 以外的成員】可課
★★而 `peaceful_economy.json` 的 12 隊【全部 `faction_id: -1`、彼此無分組】
⇒ ★★★只指定一隊當 leader ⇒ 產生【只有領袖、沒有成員】的空政權
   ⇒ **`徵收／歸建` 的 applicable 母體【仍然是 0】**
⇒ 要讓它 > 0，必須決定【哪些隊分進同一個政權】—— ★**那是 WHAT 級分組決策，不是 HOW**
```
⇒ **本 spec 停在這裡**：★★**HOW 無法在 WHAT 未定前寫** —— 已回送 blueprint。
