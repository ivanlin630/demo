# HOW spec：`_home_granary_food` 每次 gather 掃【整張地圖】 —— ★而它旁邊就有一支 O(1) 索引，效能 arc B 漏掉了這一份複製品

owner: systems ｜ 2026-09-10 ｜ 觸發：bounded-Dijkstra 票被驗收①作廢之後，**去讀既有的 log**（不重跑）

---

## ⓪ ★★★這一次沒有猜 —— 數字是從【已經存在的 log】讀出來的

```
`docs/measurements/2026-09-10-frame-time-who-freezes.txt`（大世界，2160 筆 `[FaiPhase]`）
最壞的三個 tick：
  tick=118080  total=20.08s ｜ loop2.solo=7.67s  unified.rank=3.29s  ★gather.home_food=1.32s
  tick=116760  total=19.29s ｜ loop2.solo=7.39s  unified.rank=3.90s  ★gather.home_food=1.51s  gather.threat=0.80s
  tick=103440  total=18.66s ｜ loop2.solo=6.11s  unified.rank=1.90s  ★gather.home_food=1.29s  gather.market=0.59s
⇒ ★**`gather.home_food` 在最壞的 tick 上是前三名的子相位**。
⇒ ★★而這份 log **早就在 repo 裡** —— 我前三次都在猜主詞，而答案已經印出來了。
```

---

## ① ★★★成因（file:line，讀出來的，不是推論）

```gdscript
# decision_context.gd:1002-1006
static func _home_granary_food(state: WorldState, team: TeamData) -> float:
	for tile_id in state.world.tiles:   # gate-ok: 掃 tiles 只查【自家糧倉】＝legit-self
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner == team.team_id:
			return float(tile.public_storage.get("food", 0))
	return 0.0
```

★**它每一次 gather、每一支隊，掃一次整張地圖**（`decision_context.gd:660` 無條件呼叫）。

★★**而 O(1) 的索引【已經存在】，就在它要模仿的那支函式裡**：

```
`_find_own_outpost`（faction_ai_system.gd:6628）：
    var tile: HexTileData = state.own_outpost_tile(team.team_id)     # world_state.gd:274
  檔頭寫著：「★效能 arc B：改查 state 的 owner→outpost 索引（等價替換舊全圖掃；
             語意＝tiles 迭代序第一個符合者）。**12 個 production 呼點** × 全圖掃 → O(1) 查表」
⇒ ★★★而 `_home_granary_food` 的註解逐字寫著「**仿 `_find_own_outpost` 掃法**」——
  **它仿的是【被 arc B 換掉之前】的那個版本。**
⇒ 這不是「還沒優化」，是**一份在原件被優化之後留下來的複製品**。
```

★★★**而最貴的正好是最常見的那一類隊**：

```
第一個符合就 `return` ⇒ **有自家 outpost 的隊【提早退出】**，
★而**沒有自家 outpost 的隊【掃完整張圖】才回 0** ——
⇒ ★★量測員 2026-09-10 量到：day60 不在家的 13 支隊裡 **12 支（92%）沒有自家 outpost**。
⇒ ★★★**最壞路徑不是邊緣情況，它是多數。**
```

---

## ② 修法

```
`_home_granary_food` 的迴圈 ⇒ `state.own_outpost_tile(team.team_id)`：
    var tile: HexTileData = state.own_outpost_tile(team.team_id)
    return float(tile.public_storage.get("food", 0)) if tile != null else 0.0
★語意等價的理由【不是我說的】：`own_outpost_tile` 的既有註解自己宣告
  「等價替換舊全圖掃；語意＝tiles 迭代序第一個符合者」——
  而 `_home_granary_food` 的迴圈**正是同一個「迭代序第一個符合者」**。
★★而它還附了一支現成的驗證器：`OwnerOutpostIndex.shadow` ／ `shadow_check(...)`
  ⇒ **不要自己寫比對，開 shadow 跑一輪**（`_find_own_outpost` 就是這樣驗的）。
```

---

## ③ ★★同型普查（★不是順手，是【同一個修法漏掉幾份】必須問完）

```
裸掃 `for ... in state.world.tiles`：production 43 處，其中決策路徑 6 處：
  ①`decision_context.gd:1003` `_home_granary_food`      ⇒ ★本票要修（有索引、語意同）
  ②`need_oracle.gd:161`  掃【自家設施】(outpost_owner==team ＋ 某 level_key>0)
     ⇒ ★★**不可盲換**：索引只回【一個】outpost tile，而這裡要的是「有沒有一個自家據點
       **具備某項設施**」——若一隊擁有多個據點，第一個符合者可能沒有那項設施 ⇒ **語意不同**。
     ⇒ **本票只把它【列出來標為待查】，不修**（要不要修取決於「一隊能不能有多個 outpost」，
       ★★★而那個問題我沒查 —— 標【未驗】）。
  ③`decision_context.gd:1036` ／ ④`options.gd:44`：掃 `pending_claims`（自寄賣單據）
     ⇒ 沒有對應索引 ⇒ **本票不動**，記入 backlog。
  ⑤`goal_resolver.gd:1016` ／ ⑥`acquisition_paths.gd:96`：掃【地形】＝靜態公共知識
     ⇒ 與所有權無關，**不在本族**。
```

---

## ④ 驗收

| # | 格 | 判準 |
|---|---|---|
| ① | **★語意不變** | 開 `OwnerOutpostIndex.shadow` 跑一窗 ⇒ `shadow_check` **零不一致**；★★而這一格**不准自己另寫比對**（既有驗證器就是為此存在的） |
| ② | **fp 不變** | 同 seed 同窗 ⇒ fp 完全相同；★依界限第十八條**附一格行為證據**（既有測試全綠），不單腿 |
| ③ | **★★★成本掉下來（絕對值）** | `gather.home_food` 的**絕對 us**：改前在最壞 tick 是 1.29-1.51s ⇒ 改後多少；★**在大世界量**（同一份 `frame-time-who-freezes` 的窗與 config），三軸（tick 數／遊戲天／規模）照報 |
| ④ | **★★最壞路徑那一群** | 分兩組報：【有自家 outpost 的隊】vs【沒有的隊】⇒ ★★★**後者的改善應該遠大於前者**（前者本來就提早退出）；★這一格是「成因診斷對不對」的直接證據，不是額外的漂亮數字 |
| ⑤ | **成對對照** | 把索引換回全掃 ⇒ ③必須回到 1.3s 量級；★沒有這格，③的綠證明不了是這個改動造成的 |

---

## ⑤ ★誠實限（★★這一條要寫在交件裡，不可以省）

```
★`gather.home_food` ≒ 1.3s，而 `loop2.solo` ≒ 7.6s ⇒ **它大約是 17%，不是全部**。
⇒ ★★**本票不宣稱解決了 33-50 ms／隊**，它只宣稱拿掉其中一筆【可證明的、語意不變的】浪費。
⇒ ★★★而 `[FaiPhase]` 那一行**只印前 8 名** ⇒ 剩下的 83% 裡有沒有更大的一筆，
  **現在的 log 看不到** ⇒ 下一步是【把子相位印全】，不是再猜一個主詞。
```

---

## ⑥ 這張票【不做】

```
①不動 `need_oracle.gd:161`（語意可能不同，見 §③②）
②不動 pending_claims 那兩處（無索引）
③★不改 `own_outpost_tile` ／ `OwnerOutpostIndex` 本身
④★★不宣稱本票解掉了單幀凍結（錯開票已經把單幀解掉了；本票是【吞吐】）
```

---

## ⑦ ★★★R² 回件（2026-09-10）：**CLEAN，直接 dispatch** —— 我標未驗的兩格都查完了

### (1) 語意等價**是機制保證的**（界限第 16 條的正面答案）——三層都查過，沒有縫

```
①**同一個迭代序**：`world_state.gd:320 for tile_id in world.tiles`，與 `_home_granary_food`
  原本那個迴圈是同一個字典、同一個天然 key 序；註解自己寫
  「依 world.tiles 迭代序 → 每 owner 只留第一個命中＝**舊掃同一選擇**」。
②★**staleness 檢查在【每一次呼叫】**：`world_state.gd:275`
  `if _oo_epoch != OwnerOutpostIndex.epoch: _rebuild_owner_outpost()`
  ⇒ **不是排程式重建**，是每次呼叫先比版號 ⇒ ★★**不存在「暫時還沒重建所以讀到舊值」的窗**。
③★★★**所有會動 `outpost_owner`／`outpost_level` 的 production 寫入點都呼 `invalidate()`**
  （R² 逐一查了所有真實 `=` 賦值，排除比較運算）：`outpost_owner_bank.gd:9 set_owner`、
  `outpost_system.gd` 四處跨 0 事件、`game_setup.gd` 兩處初始佈點
  ⇒ **沒有繞過 chokepoint 直接寫欄位卻不觸發失效的第二條路**。
```

### (2) 「一隊能不能有多個 outpost」＝**能**，★而答案就寫在索引自己的文件裡

```
`owner_outpost_index.gd:8` 逐字：「一隊多據點時回哪個 tile **取決於 tiles 的插入序**」
⇒ ★**這句話的存在本身就是答案** —— 單一據點的世界不需要寫這句話。
⇒ ★★所以 §③② 判 `need_oracle.gd:161` **不可盲換是對的**：
  它要「有沒有**一個具備某項設施**的自家據點」，而索引只回第一個
  ⇒ 第一個沒有、第二個有 ⇒ **索引會漏掉真正的答案**。
⇒ ★★★**這一格不必再等驗證** —— 它已經被驗證了（間接透過索引自己的文件）。
```

### (3) 「把子相位印全」：★**它已經落地了，不是計畫**

```
`faction_ai_system.gd:840-857` —— `[FaiPhase]` 已改成印【全部】子相位
（`:847` 註解逐字「印全部子相位,不只前8名(systems 2026-09-10)」）。
```

★★★**而 R² 順手讀到一件會影響本票數字的事（★它打到我自己的誠實限）**：

```
`:853-855` 註解：錯開票把 `_evaluate_solo` 移出 `evaluate_all` 之後，
  **`loop2.solo*` 的累計時間與 `total` 的分母已經不同**（一個累積、一個單次）。
⇒ ★所以 §⑤ 那句「`gather.home_food` ≒ 1.3s ÷ `loop2.solo` ≒ 7.6s ⇒ 約 17%」
  **是跨分母相除** ⇒ ★★**那個 17% 不可引用**（界限第 22 條打到我自己身上）。
⇒ ★★★修正：**本票不引用任何比例**，只引用 `gather.home_food` 的**絕對 us**
  （1.29-1.51s，同一份 log 的同一行）—— 而「它是不是全部」這個問題，
  等**印全之後的那一份 log** 回答。
```
