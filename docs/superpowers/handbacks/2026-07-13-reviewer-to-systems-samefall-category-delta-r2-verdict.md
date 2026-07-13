---
from: reviewer
to: systems
status: consumed
topic: [R②delta verdict] reorder分組改SURVIVAL_OPTION_SET成員 = CLEAN
---

# R② delta 確認 verdict — reorder 分組準則改

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "NO-OP證明結構完全沿用上輪（純partition結構性論證，不依賴category函式內部邏輯）。SURVIVAL_OPTION_SET成員關係解p2a症狀正確。blast radius確認限定於rank[0]本身屬survival-set的場景，不擴散到威脅/常態隊。" }
```

## 逐項確認

1. **NO-OP保留**：證明結構完全沿用上輪——不管`_need_category`內部怎麼算，`top_cat=_need_category(ranked[0])`本就是從`ranked[0]`自身算出，`ranked[0]`必屬same組且排第一，`same+rest`第一個元素恆等於`ranked[0]`。換分類函式不影響這個純結構性證明（上輪的walk-until-success/NO-OP論證確認仍適用）。

2. **解p2a**：`SURVIVAL_OPTION_SET`（本session已多次驗證的既有常數，含返家補給/覓食/掠奪/佔村/併入/紮營/乞食/買糧共8項）確認涵蓋併入。絕境隊rank[0]若是覓食（在set內）→併入同歸"survival"類，不再被affinity（belonging層）拆到rest組，回復pre-reorder的util序（併入若util>紮營則仍先試）——解法邏輯正確對應p2a症狀。

3. **blast radius限定**：`top_cat`只在`ranked[0]`本身屬`SURVIVAL_OPTION_SET`時才會是"survival"字串；非-survival rank[0]（威脅隊/常態隊）的`top_cat`仍是`"L%d"%main_layer_of`，分組邏輯跟上輪驗過的affinity-層分組完全一致，不受此delta影響。範圍確實限定在絕境求生repertoire場景，不擴散到威脅/常態隊。

4. **determinism**：純字串比對+穩定partition，零randf。

CLEAN，implementer續commit+融合閘+measurer。
