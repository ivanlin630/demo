---
from: systems
to: implementer
status: open
slice: godview-belief-granularity（感知鐵律細則 1a 修法）
topic: ★派工:兩顆真 god-view(A 閘後 _is_border_adjacent 讀 live 餵 score／B 閘前 _find_occupy_target 用 live 決定算不算候選);★★B 照藍圖 WHAT【換列舉起點】不是換欄位:候選母體＝BeliefSystem.known_targets,地基 team_tile_known 已存在不必新建;★★★seam 已定案(R②):把 _harvest_tile_known 搬進 belief_system.gd、goal_resolver 改 delegate,不留第二份;★驗收明寫 fp【不是】條件(這是行為修正),要的是「差在哪印得出來」
---

# ★前置：spec 的 §③【已作廢】
`docs/superpowers/handbacks/2026-09-02-systems-to-reviewer-R2-godview-1a-slice.md` 裡的 **§③憲法帳對不上是我讀錯機制，已標作廢**
（inline `gate-ok` 不入 current／baseline 是凍結承認＝**不同機制**）。★**不要做那一節。** §①②④照做。

# ①Fix A —— `_is_border_adjacent`
```
:265  var border := 1.0 if _is_border_adjacent(team, prey) else 0.3     ←★乘進 target score
:316  func _is_border_adjacent(attacker, prey): prey.tile_pos …          ←★★live 真位
改法：
  ①呼叫端取 var prey_pos := BeliefSystem.belief_pos(state, team.team_id, tid)
  ②★_is_border_adjacent 改吃【兩個 Vector2i】——★★這樣函式本身【再也拿不到】live 值
    （不是「記得別讀」，是【拿不到】。防線要在型別上，不在紀律上。）
  ③prey_pos == (-1,-1) ⇒ ★這裡已過 has_belief 閘，理論上不會發生
    ⇒ ★★開一個 Probe 桶【必須恆 0】；非 0 ＝ has_belief 與 belief_pos 兩個 API 不一致（那是另一個 bug，報我）
★attacker（自己）那側讀 live `team.tile_pos` ＝ ★★R② 確認合法（自己的狀態自己知道），不用改。
```

# ★★②Fix B —— `_find_occupy_target`（本刀重點）
```
現況 :6074  for tid in state.team_discovered.get(team.team_id, [])   ←★「發現過」≠「現在有 belief」
     :6080  var tile := state.world.tiles.get(t.tile_pos…)           ←★★live，且在閘【前】
     :6084  if not BeliefSystem.has_belief(…): continue              ←★閘在這才出現
```
★★★**藍圖 WHAT（照做，不要自己改形狀）**：**候選母體 ＝ belief 集合本身**；
**列舉從「我知道的東西」出發，禁「世界全集過 belief 濾網」** ——★**不是把 `t.tile_pos` 換成 `belief_pos` 了事。**
```
①for tid in BeliefSystem.known_targets(state, team.team_id)     ←★母體換掉
②var tpos := BeliefSystem.belief_pos(…); 無效 ⇒ continue
③「站在自家 outpost」改查 state.team_tile_known[team.team_id]，★不是 state.world.tiles
```
★**③的地基已經存在，不要新建**：`world_state.gd:55-57` 檔頭就寫著
「**所有權/control 型 tile 查詢＝belief-gate（禁全圖 god-view）**」，`goal_resolver.gd:857` 已有查詢、`:875` 已有 harvest。

# ★★★③seam（R② 已定案，照做）
```
★belief_system.gd 對 faction_ai_system.gd / goal_resolver.gd 【零依賴】（我自己 grep 驗過 = 0）⇒ 放那裡不會循環
★★而 goal_resolver.gd:877 現在【已經】反向依賴 FactionAISystem（`var fai := FactionAISystem.new()`）
⇒ ★★★做法：把 `_harvest_tile_known` 搬進 `belief_system.gd`，goal_resolver 改 delegate
   ——【不留第二份拷貝】，也不是讓 faction_ai 去 include goal_resolver
★順手看一眼（★不強制、超出就別做）：搬完之後 goal_resolver 裡那個 `FactionAISystem.new()` 還需不需要存在？
  需要就留著並說一句為什麼；★★不要為了讓它消失而改別的東西。
```

# ★④驗收（★注意第①條跟你習慣的相反）
```
①★★★`fp` 逐位元不變【不是】驗收條件 —— 這兩顆是【行為修正】，fp 本來就會變
   ⇒ 改成：修法前後各跑一次，把【差在哪】印出來（哪些 target 被篩掉／分數變多少）
   ⇒ ★★fp 變了而【說不出差在哪】＝ 沒通過
②★候選集合差集必印：舊 `team_discovered` vs 新 `known_targets` 各自大小 ＋ 差幾個
   ⇒ ★★★這一格是本 slice【唯一】能證明「god-view 真的關掉了」的東西
   ⇒ ★若差集 ＝ 0，那是個真結果（代表這張床上兩者恰好相同），★★但要說出來，不要當成「沒事」
③恆 0 桶（見 A③）非 0 即報我，不要自己吸收
④detector 桶：見下
```

# ⑤detector warn 桶（藍圖裁「開」，warn 層）
```
★判準：決策檔裡，來自 `state.teams.get(<非自己>)` 的物件，其 .tile_pos/.population/.resources/.armed 被直讀
★★桶名要保住兩個子形的區分：`gv_belief_pre` / `gv_belief_post`（藍圖說 2 樣本【跨兩子形】才夠格開桶）
★★★陽性對照（硬要求）：對 A/B 兩顆【修好之前】各紅一次，修好之後轉綠 —— ★沒跑過對照的桶不算開
★warn 不擋 merge，但必須印出來，★★且要進 merge-gates.tsv（否則沒人跑它）
```

# ★不動的
`npc_combat_system.gd:403`（`death.combat_pop` 漏記）與那三個 tile-scan cluster **不在本刀**。
