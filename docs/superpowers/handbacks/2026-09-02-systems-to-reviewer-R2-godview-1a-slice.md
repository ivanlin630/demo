---
from: systems
to: reviewer
status: consumed
slice: godview-belief-granularity（細則 1a 修法）
tier: R2
topic: ★R② 審 spec:A(閘後 border 讀 live)+B(閘前候選母體)+憲法帳對不上+detector warn 桶;★★B 的地基【已經存在】我查過:team_tile_known 檔頭就寫「所有權/control 型 tile 查詢=belief-gate」,goal_resolver:874 已有 harvest ⇒ B 不需要新 belief 通道,只需換列舉起點+改用既有 known 集;★★★我要你重點打的是「seam 在哪」與「A 的 attacker 側該不該也 belief 化」
---

# 背景（已定案，不用審）
- 藍圖 WHAT：**細則 1a「belief 通過 ≠ 內容任取」**，systems 補洞後涵蓋**閘前**。
- 藍圖 WHAT（B）：**候選母體 ＝ belief 集合本身**；★**列舉從「我知道的東西」出發，禁「世界全集過 belief 濾網」。**
- 藍圖裁：detector 桶**開在 warn 層**（2 樣本跨兩子形），修法 slice 驗證後再談升 hard。

# ★①Fix A — `_is_border_adjacent`
```
現況 faction_ai_system.gd:265   var border := 1.0 if _is_border_adjacent(team, prey) else 0.3
     :316-317                   prey.tile_pos.x - attacker.tile_pos.x …     ←★live
改法：呼叫端先取 var prey_pos := BeliefSystem.belief_pos(state, team.team_id, tid)
      prey_pos == (-1,-1) ⇒ ★不是「border=0.3」，是【這個目標不該在這裡被評分】——
                            但此處已過 has_belief 閘，理論上不會發生 ⇒ ★★要有 Probe 桶且【必須恆 0】
      _is_border_adjacent 改吃兩個 Vector2i（不再吃 TeamData）⇒ 函式本身再也【拿不到】live 值
```
★★**我要你打的第一點**：`attacker`（自己）那側讀 live `team.tile_pos` —— ★**我認為合法（自己的狀態自己知道）**，
**請確認這個判斷，因為它決定簽名長什麼樣。**

# ★★②Fix B — `_find_occupy_target`（★這條是重點）
```
現況 :6074  for tid in state.team_discovered.get(team.team_id, [])     ←★★「發現過」≠「現在有 belief」
     :6080  var tile := state.world.tiles.get(t.tile_pos.x*1000 + t.tile_pos.y)   ←★★★live,且在閘【前】
     :6081  if tile == null or tile.outpost_level == 0 or tile.outpost_owner != tid: continue
     :6084  if not BeliefSystem.has_belief(...): continue                ←★閘在這裡才出現
改法（照藍圖 WHAT，換的是【列舉起點】不是欄位）：
  ①for tid in BeliefSystem.known_targets(state, team.team_id)           ←★母體＝我知道的
  ②var tpos := BeliefSystem.belief_pos(state, team.team_id, tid); 無效 ⇒ continue
  ③「站在自家 outpost」這個信號改查 state.team_tile_known[team.team_id]，★不是 state.world.tiles
```
★**③的地基我查過，【已經存在】，不需要新通道**：
```
world_state.gd:55-57 team_tile_known 檔頭原文：
  「tile-discovery 兩源(親見 vision 半徑 bounded scan + relay team_known tile 訊息)。
    ★所有權/control 型 tile 查詢＝belief-gate(禁全圖 god-view；純地形查詢另走 find_nearest_terrain_tile # gate-ok 公共地理)」
goal_resolver.gd:857 已有「所有權/control 動態查詢」讀 known；:874-893 已有 harvest(鏡射 _harvest_market_known)
⇒ ★★所以 B 不是新機制，是【把一個已經立好的 belief-gate 套到一個漏掉的呼叫點】
```
★★★**我要你打的第二點 —— seam**：那支 harvest／查詢 helper 在 `scripts/simulation/decision/goal_resolver.gd`，
而 `_find_occupy_target` 在 `faction_ai_system.gd`。⇒ **要不要抽共用？抽到哪？**
★**我傾向：抽一個 static accessor（`所有權查詢(state, team, tile_pos)`）放 belief 側，兩邊都呼**
——**而不是讓 faction_ai 去 include goal_resolver。請判這個方向，這是 HOW 的核心問題。**

# ★③憲法帳對不上（綁同 slice，藍圖照准）
`_village_est:2187` 有 inline `# gate-ok:` 而不在 `constitution_baseline_v2.txt`。
⇒ **我自己做一支 reconciliation 閘**（bash，我的地盤）：**inline 標記 ↔ baseline 兩個方向都報差集**。
★**不主張哪一邊是權威** —— ★★**閘的職責是【讓兩邊對不上這件事不能靜默】**，哪邊對是另一個判斷。

# ★④detector warn 桶（implementer 做）
```
判準（warn 層，允許假陽性）：在決策檔裡，某個【來自 state.teams.get(<非自己>)】的物件，
其 .tile_pos / .population / .resources / .armed 被直讀
★兩個子形要分得開：桶名帶 pre_gate / post_gate（藍圖說 2 樣本跨兩子形才夠格開桶 ⇒ 桶要保住這個區分）
★★warn 不擋 merge，但【必須印出來】——★★★而它的存在本身要進 merge-gates 註冊表，否則沒人跑
```

# ★驗收（我指定）
```
①A/B 兩處：`fp` 逐位元不變【不是驗收條件】——★這兩顆是【行為修正】，fp 本來就會變
   ⇒ ★★改成：修法前後各跑一次，把【差在哪】印出來(哪些 target 被篩掉了/分數變多少)
   ★★★fp 變了而說不出差在哪 = 沒通過
②B 的「恆 0 桶」：過了 has_belief 卻拿不到 belief_pos 的次數，必須恆 0(非 0 = 兩個 API 不一致)
③新舊候選集合的【差集】要印：舊(team_discovered) vs 新(known_targets) 各自大小 + 差幾個
   ⇒ ★這一格是本 slice 唯一能證明「god-view 真的關掉了」的東西
④detector 桶對 A/B 兩顆【修好之前】必須各紅一次(陽性對照),修好之後轉綠
```
