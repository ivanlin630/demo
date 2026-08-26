# 據點發展：獨立隊與 faction 共用同一把秤（HOW）

`from: systems`｜`tier: behavior`｜`WHAT`：blueprint 裁定 2026-08-26 ——
**獨立隊該有升級路徑 ＝ YES，★非新立法**，是用戶 2026-07-16「獨立隊也發展生產＝YES、綜合發展涵蓋所有據點主非 faction 特權」的**延伸適用**。
★**接法（WHAT 指定）**：**進統一秤，不是平行特例。**

## 病（★量出來的閉環，四層）
```
蓋不了設施 ← slot 滿（L1 civilian 只有 2 格）← 據點永遠不升級 ← ★升級只掛在 faction 路徑
```
★**`_evaluate_infrastructure`（faction 版，`:4559`）有兩段**：**(1) 升級既有 outpost　(2) 擴建設施**
★★**`_evaluate_independent_infrastructure`（獨立版，`:4508`）★只有 (2)** ——
⇒ ★★★**獨立隊 `infra.entry = 258`、`pick_empty = 180`（slot 滿），而【拿到第 3 格的唯一出口】它根本沒有。**

★**實測**：`upg.eval_entry = 0`（faction 迴圈跑零次，本床 12 隊全 `faction_id = -1`）
＋ 窮盡搜索：`start_upgrade_level` ＝ 玩家路徑、`_subteam_upgrade_level` 只由 `_dispatch_upgrader` 派
⇒ **NPC 在本床上沒有任何一條路 L1→L2。**

## 修法（★一把秤，兩個入口）
★**抽出共用的「據點發展評估」**：**給定一支 leader_team ⇒ ①先評升級 ②再評設施**（★**順序照 faction 版現況，不改**）。
**兩條路徑各自只保留【怎麼找到那支隊】的差異**：
| 入口 | 差異 |
|---|---|
| faction | `faction.leader_team_id` |
| ★獨立 | `team` 自己 |

★★**禁止**：**在共用體內寫 `if faction_id == -1` 的分支** —— ★★★**那就是 WHAT 明令排除的「平行特例」。**
### ★★★分解（R² 給的具體形狀，我採用 —— **共用體吃「一格＋一隊」，迭代權留給各自入口**）
```
共用：evaluate_upgrade(state, leader_team, tile) -> bool          # 段(1) 的單格版
共用：evaluate_facility(state, owner_team, tile, leader) -> bool  # 段(2) 的單格版（`_pick_facility` 已經是這層）
faction 入口：for tile_id in state.world.tiles → 過濾自家 → 逐格餵共用函式
獨立入口  ：own_pos = _find_own_outpost(...) → 一格餵共用函式
```
★**共用體本身【不知道】呼叫者是 faction 還是獨立** ⇒ ★★**不是吃五個旗標的函式，是把【迭代】與【單格判斷】拆成兩層。**
★**而「掃所有自有 tile」vs「單格」不是實作隨意選的，是結構性事實**：
**faction 是多隊結構（leader＋居民／子隊／其他 owner tile），獨立隊天生只有自己那一格。**

### ★★★迭代順序【不得改】（R² 揭，2026-08-26 —— 與 RNG 那條同一母題）
`_evaluate_infrastructure` 段(1)(2) 都是 `for tile_id in state.world.tiles:`（**全地圖字典，靠 `outpost_owner` 過濾**），
★**而它在第一次成功後就 `return`** ⇒ ★★**「哪一格先被掃到」決定了「哪一格先升級」。**
⇒ ★★★**抽共用體時，faction 入口對 `state.world.tiles` 的迭代順序、餵進共用函式的 tile 次序，必須跟現況【逐格一致】**
—— **不得為了「乾淨」改成先收集清單再排序、或換一種資料結構迭代。**
★**否則即使邏輯完全正確，`fp` 也會因為「同樣都升級了，但先升的那格不同」而假紅。**
★★**這跟上一票的 RNG 教訓是同一母題**：**判準沒錯，而【執行重構的方式】可能悄悄改變被量的東西。**
★**好消息（R² 查過）**：**這整條決策鏈沒有 `randf()`／`randi_range()`** ⇒ **這次的風險【不是】RNG，是純迭代順序。**

## ★★★驗收（★兩個母體，缺一不可）
1. ★**獨立隊路徑【會 fire】**：`upg.eval_entry > 0`、`upg.own_tile_seen > 0`（★**現況 0**）
2. ★★**閉環鬆動的因果下游**：`infra.pick_empty`／`empty_slot_full_margin` **下降**（★**現況 180 / 258**）
   ⇒ ★**判準是【方向】不是數值**：**若不降，照原樣回報，不要調參數去追它。**
3. ★★★**faction 路徑【不得被改壞】** ——
   ★**而它在 `peaceful_economy` 上驗不了（那張床零 faction）** ⇒ ★★**必須跑 `warring_states`：`fp` 逐位元不變。**
   **★這條是這張票唯一的回歸防線，不能省。**
4. **三段對帳仍逐日平**（`skip+skip+call == own_tile_seen`／八類 == `upg.call`／六類 == `pick.infra.entry`）
5. **headless 閘 PASS（baseline 7）／憲法閘 PASS**

## ★誠實限
- ★**`fp` 在 `peaceful_economy` 上【會變】** —— **獨立隊開始升級 ＝ 世界不同，這是預期。**
- ★★**驗收 2 若沒動**：**可能是升級本身也被別的閘擋**（`_dispatch_upgrader` 八個歸宿現在都有名字）
  ⇒ ★**那不是失敗，是【下一格】** —— **照原樣回報。**
- ★★★**本票不動 `FACILITY_SLOTS`／`DEMOLISH_MARGIN`** —— **它們是 tuning，而這張票修的是【接線】。**
  **先讓路存在，再談路上的門檻。**
