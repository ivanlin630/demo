---
slice: 求居／佔村的流量估算改讀 belief 的據點等級（`feat/join-occupy-belief-level`）
owner: systems
status: draft — 待 R②
基於: `defers.tsv` → `join-occupy-flow-reads-live-outpost-level`（reviewer 揭 2026-09-18；條件已達成：姊妹票已 merge）
---

# §0 病灶（★我剛逐行重核過，非註解命中 3 處）

```gdscript
decision_context.gd:806-824（gather 內，★production 決策路徑上）
  閘：has_belief ＋ belief_pos ＋ best_estimate(population_est)      ← ★位置與人口【走 belief，合法】
  落地：state.world.tiles.get(<belief 位置>) ⇒ ★★.outpost_level     ← live
     :811／:813  join_host_flow（讀 strong_neighbor 的 tile）
     :824        occupy_target_flow（讀 occupy_target 的 tile）
```
★**判準命中**：`outpost_level` **會變**（升級／拆除／被攻陷）⇒ 讀它等於知道**現在**，而我只該知道**當時**。
★★**而同一行讀的 `terrain` 不會變** ⇒ **那半是合法的，不要一起修掉。**

# §1 修法（★前例現成，不是新設計）

```
改讀 BeliefSystem.known_outposts(state, team.team_id) 的子記錄：
  level    ← ★觀察當時寫下的值
  owner_id ← 用來確認那座城【就是】那支隊的（★閘已經確認「我對那支隊有 belief」，
             而【那座城是不是它的】是另一件事 —— 今天姊妹票已經走過這個分界）
terrain ← ★維持 live（地形不會變）
```
★**找不到子記錄時**（我沒看過那座城）⇒ **那一項流量估算 ＝ 0／不成立**，
★★**而【不是】退回 live**（§1a：`unknown` 一律不通過、禁 default-pass）。

# §2 驗收（★每格能紅）

| 格 | 內容 | 反向 |
|---|---|---|
| 1-a | ★**見過那支隊、沒看過它的城** ⇒ `join_host_flow` ＝ 0（不是用 live level 估出來的數） | 仍有數 ⇒ 紅 |
| 1-b | ★**看過那座城** ⇒ 用**子記錄的 level** 估（而非現在的 level） | 用了 live ⇒ 紅 |
| 1-c | ★★**城被升級之後、我沒再看過** ⇒ 估值**仍是舊 level**（★這格才是「當時 vs 現在」的真對照） | 跟著升 ⇒ 紅 |
| 1-d | ★`occupy_target_flow` 同上三格 | 同上 |
| 1-e | ★★**`terrain` 仍走 live、逐字未改**（★不要修過頭） | 被一起改 ⇒ 紅 |
| 1-f | ★★★**自家 6 處讀取逐字未改**：`:484`／`:655`／`:672`／`:748`／`:749`／`:783`（★**用內容錨不要用行號** —— 我上一票寫行號寫錯過） | 動到 ⇒ 紅 |
| 1-g | 到場點名 ＋ expect 釘 `N／N` | 少一格 ⇒ 紅 |

# §3 ★世界級要印的數（★★而我先寫死我的預期，免得事後合理化）

```
join_host_flow／occupy_target_flow 有值的次數：前 vs 後
★我的預先聲明：**會變少**（因為「見過隊但沒看過城」的那批現在算 0）
★★而若【幾乎沒變】⇒ 代表「見過隊 ⇒ 幾乎總是也看過它的城」⇒ 那是一個關於世界的發現，要記一筆
★★★若【變成 0】⇒ 代表我把它修過頭了（或那個子記錄在世界裡幾乎不存在）⇒ 停下來回報
```

# §4 不在本票
- `BELIEF_STALE_TICKS` 物理化（另一張 defer）。
- 那兩條 flow 的**數值模型**（本票只換資料來源，不動公式）。
