---
from: systems
to: implementer
status: consumed
slice: home-granary-full-scan ｜ worktree `.worktrees/granidx` ｜ branch `feat/home-granary-index`
topic: ★DISPATCH（R² CLEAN，三格全查完）：`_home_granary_food` 全圖掃 ⇒ 換 `state.own_outpost_tile()`｜★★★而我要先撤回自己 spec 裡的一句話：**「約 17%」是【跨分母相除】，不可引用** —— 錯開票把 `_evaluate_solo` 移出 `evaluate_all` 之後，`loop2.solo*` 是累計、`total` 是單次｜★你的「印全」已經落地了，R² 讀 code 看到的
---

# ⓪ 先撤回一句（★在你動手之前，因為它會影響你怎麼寫交件）

```
spec §⑤ 我寫「`gather.home_food` 1.3s ÷ `loop2.solo` 7.6s ≒ **17%**」——
★R² 讀到 `faction_ai_system.gd:853-855` 的註解：錯開票把 `_evaluate_solo` 移出
  `evaluate_all` 之後，**`loop2.solo*` 的累計時間與 `total` 的分母已經不同**
  （一個是累積、一個是單次）。
⇒ ★★**那個 17% 是跨分母相除 ⇒ 不可引用**（界限第 22 條，打到我自己身上）。
⇒ ★★★**交件裡不要出現任何比例**，只報 `gather.home_food` 的【絕對 us】。
  「它是不是全部」由**你已經做好的【印全】那份 log** 回答，不是由我的除法回答。
```

# ① 做什麼

```
`decision_context.gd:1002-1006` 的全圖迴圈 ⇒
    var tile: HexTileData = state.own_outpost_tile(team.team_id)
    return float(tile.public_storage.get("food", 0)) if tile != null else 0.0
★等價性**不必你自己論證**（R² 已查三層：同一迭代序／每次呼叫比版號、無 stale 窗／
  所有 `outpost_owner`・`outpost_level` 寫入點都呼 `invalidate()`）。
★★驗證用**既有的** `OwnerOutpostIndex.shadow` ／ `shadow_check(...)` ——
  ★★★**不要自己另寫比對**（`_find_own_outpost` 當初就是這樣驗的）。
```

# ② 成因（★寫進交件，因為它解釋了為什麼改善會不平均）

```
原迴圈**第一個符合就 return** ⇒ ★**有自家 outpost 的隊提早退出**，
★★**沒有自家 outpost 的隊掃完整張圖才回 0**。
⇒ ★★★而量測員 2026-09-10 量到：day60 不在家的 13 支隊裡 **12 支（92%）沒有自家 outpost**
  ⇒ **最壞路徑不是邊緣情況，它是多數。**
⇒ 所以驗收④（分【有／沒有自家 outpost】兩組報）**不是額外的漂亮數字**，
  它是「成因診斷對不對」的直接證據：**後者的改善應該遠大於前者**。
```

# ③ 驗收（spec §④ 是本體，這裡點三個最容易做錯的）

```
①`shadow_check` **零不一致**（用既有驗證器）
③★**絕對 us**：`gather.home_food` 改前 1.29-1.51s（大世界最壞 tick）⇒ 改後多少；
  ★★三軸照報（tick 數／遊戲天／規模）＋同窗同 config；★★★**不報比例**（見 §⓪）
⑤★成對對照：換回全掃 ⇒ ③必須回到 1.3s 量級
②fp 不變 ⇒ 依界限第十八條**附一格行為證據**，不單腿
```

# ④ 不做

```
①★不動 `need_oracle.gd:161`：R² 查實 `owner_outpost_index.gd:8` 自己寫著
  「一隊多據點時回哪個 tile 取決於 tiles 的插入序」⇒ **一隊確實可以有多個 outpost**
  ⇒ 它要的是「有**某項設施**的自家據點」，索引只回第一個 ⇒ **會漏掉真正的答案**。
②不動 pending_claims 那兩處（無索引）／不改 `own_outpost_tile` 本身
③★★不宣稱本票解掉單幀凍結（錯開票已解單幀；本票是【吞吐】）
```
