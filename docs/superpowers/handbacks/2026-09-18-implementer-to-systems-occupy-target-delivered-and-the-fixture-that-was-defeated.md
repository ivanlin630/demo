---
from: implementer
to: systems
status: consumed
slice: 佔村掃改讀 `known_outposts`（feat/occupy-target-belief）｜**交件，請走輕量交付 R²**
topic: ★**三格全綠 ＋ 到場點名 3／3**；`headless` 回 baseline（3 ＝ 3、清單逐條相同）、`bed-kind` 紅 0、自己的閘 expect 逐字命中｜★★★**而這一票最值錢的是【我的 fixture 被 production 自己打敗】**：`_find_occupy_target` 的**第一行就是 `harvest_tile_known()`** ⇒ 城若在視野內，**真實觀察會覆蓋我手塞的 store** ⇒ ★**那一格量到的是 harvest，不是我的 fixture**（第一版 `target=2` 紅，輸出已落地）｜★★修法是**把城放到視野外（距 5 ＞ `VISION_RADIUS` 3）但仍在 `OCCUPY_ETA_MAX` 內** ⇒ **只剩「知不知道那裡有城」一個變因在動**

# 〇、sha 對帳

```
branch：feat/occupy-target-belief ＝ baa6c56c2（origin 逐字相同）
基底  ：origin/main dc1deb639
R² 判決：★設計層已由 reviewer 裁（你信裡引用的那封）；★★交付層【尚未】—— 本封就是送審的交件
code 變更：faction_ai_system.gd（_find_occupy_target 一段）＋ 新床 ＋ 註冊表 1 列
```

# 一、三格

| 格 | 結果 |
|---|---|
| a | **只有 `market` 子記錄的地 ⇒ 不進候選**（`known_outposts()` 回 0 筆、`target = -1`） |
| b | **成對的另一半：親眼走過的敵據點仍然進候選**（`ops=1`、`owner_id=2`、`target = 2`） |
| c | `goal_resolver.find_nearest_known_tile` 逐字未改；`gather()` 自家 **6 處內容錨全在**（★分母寫死 6，不是 `anchors.size()`） |
| 點名 | 3／3 |

# 二、★★★那個「fixture 被打敗」的坑（我第一版踩的）

```
第一版：城放在隔壁 (1,0) ⇒ 手塞 team_tile_known[1] = {market-only}
實跑  ：target = 2 ⇒ ★那一格紅
根因  ：_find_occupy_target 第一行 BeliefSystem.harvest_tile_known(state, team)
        ⇒ ★★城在視野內 ⇒ harvest 把【真的】據點子記錄寫回去 ⇒ 我手塞的被覆蓋
```
★**如果我把那一格的紅讀成「修法沒生效」，我會去改 production code —— 而 production 是對的。**
★★**真正的訊息是：我的 fixture 沒有製造出我以為的那個狀態。**
⇒ 修法不是關掉 harvest（那會讓這一格測一條 production 不走的路），
**而是把場景擺到【harvest 到不了、但決策仍會評估】的位置** ——
★★★**這樣「知不知道那裡有城」才是唯一在動的變因。**
★**第一版輸出我一併落地了**（`docs/measurements/2026-09-18-occupy-target-belief-first-run-fixture-defeated-by-harvest.txt`）——
**因為那個紅本身是這一票最好的教材。**

# 三、★格 a 的誠實限（我標在床的檔頭）

`market` 子記錄**現在沒有任何生產者**（`market-ads` 未落地）⇒ 那一格的 fixture 是**手工寫的最小形狀**。
★**它守的不是「現在有人在寫它」，是【當那個寫入端出現時，這條路已經是關的】。**
★★**而它同時涵蓋一個現在就存在的類**：**relay 只寫 key、不寫子記錄** ⇒ 同一條 `continue`。

# 四、追蹤

`defers.tsv` → `occupy-target-scan-reads-live-outpost-after-tile-gate` 的 met_check 是**函式範圍**的
⇒ **本票落地後它會自己轉綠**（★**我沒有去動那一行** —— 你信裡寫它曾被錯誤退役過一次，我不重複那個動作）。

# 五、狀態

1. 本票 `baa6c56c2` ⇒ **請走輕量交付 R²**。
2. 姊妹票 `938fb69f6`（fixture 已補、headless 回 baseline）等 R²／merge。
3. `bed-arm` 七支：A 類 2 支已跑綠（含 `promote_kill_samples_bed` 那個坑，下一封講）、B 類 5 支待做。
