---
status: ★WHAT 已定（blueprint 2026-09-04 四原則），HOW 具體歸屬如 §⑥ —— 待 R²
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


---

# ★★★★★⑥HOW：`peaceful_economy` 的具體歸屬（★依 blueprint 四原則，★★而每一格都附【為什麼是它】）

## ①原始資料（★config 逐隊座標，不是我記的）
```
0 (7,6)   1 (2,7)   2 (15,6)  3 (10,14)  4 (0,14)  5 (9,3)
6 (1,12)  7 (8,2)   8 (8,8)【商隊】      9 (10,4)  10 (6,10) 11 (13,5)
```

## ★②分組（地理聚落圈；★不對稱是特性，禁刻意均分）
```
★政權 A【北緣一帶】6 隊：7(8,2) 5(9,3) 9(10,4) 11(13,5) 2(15,6) 0(7,6)
★政權 B【西南一帶】4 隊：1(2,7) 6(1,12) 4(0,14) 10(6,10)
★★獨立（`faction_id: -1`）2 隊：3(10,14)【東南孤點】、8(8,8)【商隊】
⇒ ★★★6／4／2 —— 不對稱（原則④留 1-2 隊獨立、原則②政權數 2-3、每政權 4-6 隊）
```
★**為什麼 3 獨立**：★★**它離兩圈都遠**（到 B 最近成員 10(6,10) 距離 ≈5.7；到 A 最近 ≈8）—— **它就是「流民」那一格**。
★**為什麼 8 獨立**：**商隊 tag** —— ★★**它不是「這一帶的人」，它是路過的人。**

## ★★★③leader：**config 裡沒有據點等級、也沒有技能** ⇒ 我不憑感覺挑
```
★blueprint 的準則是「圈內據點等級最高的居民團」（繼承簡易版同準：統領高者）
★★而 `peaceful_economy.json` 【兩者都沒有】—— 隊只有 `tile_pos`／`population`／`tags`
⇒ ★★★所以我用【可在 config 時決定、且與「這一帶的人」同源】的代理：**距該圈重心最近者**
   A 重心 (10.33, 4.33) ⇒ 最近 ＝ ★9(10,4)（距 ≈0.44）
   B 重心 (2.25, 10.75) ⇒ 最近 ＝ ★6(1,12)（距 ≈1.79）
★**而這是【代理】不是【準則本身】** ⇒ 我在 spec 裡明標，並交 R²：
   **若日後 config 有據點等級，應改回 blueprint 的原準則。**
```

## ④要 implementer 做的（★我不改 config，那是 production 資料）
```
在 `config/peaceful_economy.json` 逐隊補 `faction_id` 與 `is_faction_leader`：
   A：9 為 leader；7／5／11／2／0 為成員
   B：6 為 leader；1／4／10 為成員
   3 與 8：維持 `faction_id: -1`
```

## ★★★★⑤而這一刀會【改變那個世界】—— 必須連帶處理
```
★`peaceful_economy` 上所有既有量測【都是在「沒有政權」的世界做的】
⇒ ★★今天那筆「peaceful 承諾紮根＝0／0」在改動後【不可比】
⇒ ★★★`09_exam_gate §5.4` 的【報不修讀數②】要標「量於【無政權】版本」，
   而改動後要【重新取一次基準】—— **否則它會變成一個跨兩個世界的趨勢線**
```
