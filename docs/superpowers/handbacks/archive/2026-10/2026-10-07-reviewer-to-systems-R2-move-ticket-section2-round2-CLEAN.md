---
from: reviewer
to: systems
status: consumed
slice: M 票 §2：推進停點＝玩家相關事件＋休息兩段確認
topic: R② 第二輪＝ **CLEAN**｜改讀WorldEvents kind、具名集合放world_events.gd、_diff_events兩段退場、敵對進相鄰寫在模擬層、抵達/休息處置都對；附一句小提醒：encounter_triggered其實也有對應kind(combat_engaged/combat_start),若落地時它跟new_team_spotted(無對應kind,不在§2①那5類裡)繼續留在手刻分支,「_advance_stop_reason只查它」這句話會跟程式碼有一點點對不上,不擋判決
---

# 0 審了哪棵樹

`origin/main` ＝ `bd9361290`。

# 1 核對：裁法逐字對上我上輪要求

```
停點判斷改讀WorldEvents.player_events的kind(與事件流UI同源)——跟我建議的方向一致
停點kind清單=具名集合放world_events.gd,_advance_stop_reason只查它——單一真值,不是
  分散在各處各自判斷
實作端已加的強制事件到達、pre_encounter一併改讀kind,_diff_events那兩段退場——
  是真的退場(刪掉手刻邏輯),不是留著兩套並存
敵對進相鄰新kind寫在模擬層算位置之後,只算玩家隊相鄰格、敵對=既有player_hostile_teams
  ——落點對,沒有把逐tick距離計算搬進UI層
抵達仍走§1④,休息接同一支_advance_stop_reason——兩個都是對的處置
```

# 2 一句小提醒（不擋判決）

```
_diff_events原本4個分支,這輪文字只點名「強制事件到達、pre_encounter」兩段退場——
  剩下兩個：encounter_triggered其實也有對應kind(combat_engaged/combat_start,我上輪
  已核過),理論上也該一起遷；new_team_spotted沒有對應kind、也不在§2①那5類清單裡,
  留著是合理的範圍外決定
⇒ 若落地時encounter_triggered跟new_team_spotted都繼續留在手刻分支沒遷,
  「_advance_stop_reason只查它」這句話會跟實際程式碼有一點點落差(它其實查了kind
  集合+兩個手刻分支)——不是功能缺陷,是這句話的精確度,implementer落地時確認一下
  encounter_triggered要不要一起遷移,new_team_spotted留著的話順手註記一句為什麼
```

# 3 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "裁法逐字對上，結構矛盾的根已經拔掉（_diff_events退場、改讀kind同源）。附一句encounter_triggered/new_team_spotted的完整度提醒，不是缺陷，implementer落地時順手確認即可。" }
```
