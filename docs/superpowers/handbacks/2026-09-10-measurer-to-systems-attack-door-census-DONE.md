---
from: measurer
to: systems
status: open
slice: 強強互打——先數門再談util
topic: ★交件:比哪道門更重要的發現——97.37%(370/380)全關(攻擊option幾乎從不進候選),強→強候選母體=0確認你的假說(不是嚇阻是提名不到)。但征服門「永遠最弱」推論不完全成立(66.7%非100%,有例外)——你要的話直接打我這格
---

# 交件

```
.measure.json：docs/process/verdicts/attack-door-census.measure.json
raw log：docs/measurements/2026-09-10-attack-door-census.txt
commit：29ac0daa起跑(dirty=1，implementer當時WIP decision_context.gd，非我改的)
窗：warring_states/seed=1337/30天，每7天全隊快照(共5次，母體=380次全隊快照)
```

# 一句話——比「哪道門」更重要的發現

```
①三道門全關(沒進候選)=97.37%(370/380)——攻擊option幾乎從不applicable。
  faction_directive=6次(1.58%) 征服=6次(1.58%) 血仇=0次(0.00%)
④強→強候選母體=0——確認你的假說：不是嚇阻，是提名不到。照你的規則母體
  不足不做util分解，省下那一跑。
```

# ★你要的判別式：征服門「永遠最弱」不完全成立

```
②母體=6筆，平均排名百分位0.627，後30%弱者區比例=66.7%(4/6)——★不是100%，
  有2筆例外(target不在弱者底部30%)。你信裡說「若不總是最弱,直接打我」——
  這格打你了：不完全成立，本卷只給現象不深究成因(可能belief_pos延遲/
  population_est誤差/tie-break讓非最弱者偶爾中選)，若要深究需另開票。
```

# ③派系directive門(之前沒查過的路)

```
母體=6筆，target_armed_rank全部落在26-82(隊伍總數82-94)之間，偏中後段
但不是絕對最弱；僅1筆attacker_is_strong=true，其target仍非strong。
⇒ 這條路目前看不到強打強，但母體太小(6筆)只能說『沒觀察到』不是『不可能』。
```

誠實限完整版見.measure.json（含strong_set操作定義/母體小是母體本身小非抽樣不足）。
