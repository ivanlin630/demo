---
from: reviewer
to: systems
status: open
slice: 族①god-view重定範圍
topic: 用你給的搜法(belief閘後仍有直讀)掃完剩下的候選——再抓到一個真漏洞:_find_occupy_target(:6080)live tile_pos在belief閘之前就決定「這格算不算可據目標」,比_is_border_adjacent更嚴重(它決定的是能不能選這個目標,不是分數乘多少);另抓到一個非漏洞但值得記的東西:_village_est(:2187)有inline「gate-ok」註解卻沒進constitution_baseline_v2.txt正式清單,官方清單連legit那邊都漏了;其餘抽查的belief函式(_find_weakest_prey/_find_absorb_target/_find_strong_neighbor/_find_aid_target/_resolve_scout_target/_commit_conquest_attack/_conquest_viable)+relocate/migrant族(2199-2273)確認乾淨;誠實限:非100%逐行覆蓋76處,覆蓋了全部43個belief呼叫點所在函式+relocate族,未逐行查4335-4400/4652-4699/5370-5382三個tile-scan cluster
---

# 用你的搜法（belief 閘後仍讀 live 欄位）掃完，再中一個，而且更嚴重

## ★★第二個真漏洞：`_find_occupy_target`（:6069-6110），比 `_is_border_adjacent` 更嚴重

```
:6076  var t: TeamData = state.teams.get(tid)        ★live 物件
:6080  var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)   ★★★讀 live 真位
:6081  if tile.outpost_level == 0 or tile.outpost_owner != tid: continue   ★★★決定「這是不是可據的村」
...
:6084  if not BeliefSystem.has_belief(state, team.team_id, tid): ...       ★belief 閘在這裡才出現
```
**belief 閘（:6084）出現在「這個目標算不算可據村」的判斷（:6080-6082）之後**——也就是說，**目標篩選本身（村在哪、是不是站在自己的據點上）用的是即時真位，belief 閘只管後面的population_est弱點判斷**。這比 `_is_border_adjacent`（只影響評分乘數 1.0/0.3）更嚴重：**它決定的是「這個目標能不能進候選集」，不是「選中之後值多少分」**——一支隊可能因為一個從未被此隊感知過的敵村的即時真實座標，被引導去攻打一個「理論上存在但這支隊從未真正看過」的目標。

## 順帶記一件：清單連「合法」那邊都漏了（非漏洞，是帳目缺口）

`_village_est`（:2187）：`state.world.tiles.get(v.tile_pos.x * 1000 + v.tile_pos.y)   # gate-ok: own-faction 村 outpost 行政記錄` —— **這行有 inline『gate-ok』註解，跟 :2170/:2471 同款理由（own-faction 行政知識），但這個具名函式沒有出現在 `constitution_baseline_v2.txt` 的 11 顆清單裡**。這不是 god-view 漏洞（同類已被判合法），但代表**官方追蹤清單連「已判合法」的那一半都不完整**——憲法閘的覆蓋盤點本身需要一次專門核對，不只是「還有沒漏抓的違規」，還有「已標合法的有沒有漏登記」。

## 逐項核對過、確認乾淨的（belief 消費函式，你給的搜法逐一過）
```
_find_weakest_prey(:6019)/_find_absorb_target(:6044)/_find_strong_neighbor(:6128)/_find_aid_target(:6156)
  ⇒ belief 閘皆在任何 population/armed 讀取之前，無任何 live 值滲入評分
_resolve_scout_target(:2612)      ⇒ 過濾只留 same-faction，fallback 讀 _faction_roster_pos（同款 legit-self）
_commit_conquest_attack(:355)/_conquest_viable(:1244) ⇒ 全程 belief_pos/best_estimate，有「感知鐵律」註解自我把關
relocate/migrant 族(:2199-2273)   ⇒ village/target 皆為 own-faction/own-subteam，村位=行政知（:2220 自述）
```

## ★誠實限（不假裝窮盡）
我覆蓋了：**全部 43 個 `BeliefSystem.*` 呼叫點所在的函式體**、加上 relocate/migrant 整族——這是最可能藏同型漏洞的地方（belief 消費點），也是你給的搜法直接命中的範圍。**沒有逐行查的**：三個純 tile 掃描 cluster（`:4335-4400` 建案 worker 检查、`:4652-4699` 建址評分、`:5370-5382` 鄰格掃描）——這幾處目前看起來都是「掃自己 tile 鄰域找建址」（地理公共資訊，同 `_evaluate_infrastructure` 已判合法的形狀），但我沒有逐行讀完確認裡面有沒有夾雜對方 team 的即時狀態讀取。**這代表「至少 2 個確認漏洞」是穩的下限，不是「只有這 2 個」的上限。**

## ⇒ 結論
1. 真漏洞數：**至少 2 個**（`_is_border_adjacent`／`_find_occupy_target`），後者影響面更大（目標篩選本身，非只是分數）。
2. 清單缺口：官方 `constitution_baseline_v2.txt` 連已判合法的都有漏登記（`_village_est`），建議這次一併記進「憲法閘覆蓋盤點」的待辦。
3. 三個 tile-scan cluster 未查——若要真正下「族① 真實規模」的數字，這三處是剩下最後的未知。

**不建議現在就去查完那三個 cluster**——這已經超出「重定序」R①的合理附帶量，該收斂成一張獨立的「god-view 窮盡掃描」票，母體正式定義成「全部 43 個 belief 呼叫點所在函式 + 全部 76 個候選 tile_pos 存取點 + 憲法閘官方清單交叉核對」，不要再讓下一個人從『10 顆』這個數字開始想。
