---
from: systems
to: implementer
status: open
slice: 終端 E2E 床（狀態驅動）＋輕路資格
topic: ★**派工，R² CLEAN（`7b1298a45`，三輪）**｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-terminal-e2e-state-driven-HOW.md`｜★序 ＝ 繼承回歸 → 威脅欄 → **本票**（與觀察輪並行）｜★輕路那一段（§5）的 `docs/process/` 改動**由我在 merge 那一顆寫**，你不用碰
---

# 一、四件最容易走錯的（spec 裡都有，這裡講白）

```
①兩個鍵位空間：數字鍵（action_block，`text_ui_view.gd:328`）＋ **字母鍵**（強制事件，`text_ui_main.gd:2086-2090`，手刻）
  ⇒ ★字母鍵那一套就是「按 A 做 B」血證發生的地方 ⇒ P1 分空間印、**字母鍵 ≥ 1**，等不到就佈置
②世界自己在動 ⇒ **雙世界對照**：分叉 ＝ **重跑到同一步**（全站零 clone，不准順手生一個）
  ⇒ ★先量一次 Godot 啟動秒數再定 N；不准默默換成比前後快照
  ⇒ 每次分叉兩份 fp 必須相同（不同 ⇒ ABORT，不是綠）
③`effect` 欄放 `ACTION_SHAPE`（`player_command_system.gd:366`），**只填 10 個 listed:true**
  ⇒ 每個值附「那個 handler 寫了什麼」的 file:line（逐個開 handler，不從名字推）
  ⇒ ★「打聽」是 `"belief"` 不是 `none_expected` ⇒ 狀態差異要**加讀 `query_memory_panel()`**（`player_query_api.gd:53`）
    ⇒ ★不准在 `map_player_snapshot` 開第二個 belief 入口
④三種紅各要一個陽性對照：鍵表錯位一格（紅一）／handler 只回 ok 不改狀態（紅二）／handler 改狀態不寫結果句（紅三）
```

# 二、它第一次跑抓到的東西

```
★**列清單、回報，不在本票修**（同探索床的紀律）
⇒ 交件時每一個紅附：哪一步／按了哪個鍵／結果句／差異摘要 ⇒ 我分流（UI → 你／規則 → 我＋藍圖）
```
