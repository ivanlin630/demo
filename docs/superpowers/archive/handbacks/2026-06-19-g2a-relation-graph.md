# Hand Back: G2a 關係圖 schema

## 實作摘要

依 `docs/superpowers/plans/2026-06-19-g2a-relation-graph.md` 全 3 Task 完成（TDD：紅→綠）。

- `scripts/simulation/relation_graph.gd`（新）：`class_name RelationGraph` 純 static helper——`add_edge`（同 type+target 取 max intensity + 更新 tick；`target==-1` guard）、`edges_of_type`、`edges_to`、`strongest`（無回 `{}`）。核心型別無關，只按 type/target filter。
- `scripts/data/person_data.gd`：`relations` 下加 `var relation_edges: Array = []`（typed 邊容器）。
- `scripts/simulation/npc_ai_system.gd`：`write_memory` 末加 additive `_write_relation_edge`——映射對齊既有 `_trigger_goals`：`betrayal/looted/extorted → feud`、`kindness/aided_in_battle → gratitude`、`master → protect`。**無 reader**，行為不變。
- `scripts/debug/headless_test.gd`：3 測試 + `_initialize()` 註冊——`_test_relation_graph_core` / `_test_person_relation_edges_default` / `_test_g2a_memory_writes_edges`。
- `docs/invariants.md`：加「關係圖（typed-edge）」段（核心型別無關硬約束 + 與扁平 `relations` 語義分職）。

與 spec 無差異。OUT of G2a（未做，照 plan）：邊 reader（G2b/G2d）、`killed` 型別填充（G2d）、血仇傳播、死者邊 cleanup、decay（YAGNI）。

## 回歸閘

- `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd` → `=== DONE ===`（1 次）。
- 3 個 G2a 測試 print：`RelationGraph core OK` / `relation_edges default OK` / `G2a memory edges OK`。
- 0 SCRIPT ERROR / 0 Assertion failed / 0 Parse Error / 0 InvariantAudit 違反。coin_eq 守恆測試照常通過。
- 既有測試 0 變動（additive、無 reader）。
- 注意：新 `class_name` → 跑測試前須 `.\tools\godot.ps1 --headless --import`（fresh worktree 亦需先 import 建 cache）。

## 連動風險

- `NpcAiSystem.write_memory`：唯一改動點為末尾 additive 呼叫，現無 reader 消費 `relation_edges` → 無行為改。所有 `write_memory` caller 不受影響。
- `PersonData` 序列化／存檔：若有 save/load 路徑序列化 PersonData，新增 `relation_edges` 欄位預設空 Array，舊存檔載入時該欄缺失須以預設補（未檢查專案是否有持久化路徑——目前 headless 無存檔，無已知風險）。
- 記憶體：`relation_edges` 隨 memory 寫入單調增長，目前無 cleanup/decay（plan 明列 OUT，待有 reader 再加，現無害）。

## 待主 session 確認

- 死者邊 cleanup / decay：plan 標 OUT（無 reader 時無害）。G2d 死亡鏈引入 `killed` 邊 reader 後須一併處理死者 target 懸空邊，建議屆時排入。
- `relation_edges` 無上限增長：長跑下單人邊數理論可累積（受同 type+target 去重壓制，實際上限 ≈ 不同 (type,target) 對數）。若 G2b 消費前要設防，可加上限/LRU——目前無需。
