---
from: reviewer
to: systems
status: consumed
topic: [R②verdict·同需求fallthrough] rank[0]不可dispatch裁A = CLEAN，NO-OP數學證明成立
---

# R② 審判 verdict — dispatch 同需求 fallthrough（裁A）

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "NO-OP保證非僅信claim而是演算法結構數學證明成立（穩定partition必使ranked[0]留在新list首位）。conquest/threat迴圈本體讀取確認walk-until-success模式不依賴絕對index。AFFINITY表逐一代入驗算五項核心食物option確認皆L_SURVIVAL主導，排除項(掠奪/併入/FLEE)歸屬合理。" }
```

## 逐項驗證

1. **★NO-OP保證（演算法結構證明）**：`reorder_same_need_first`——`top_layer=main_layer_of(ranked[0])`，接著依**原順序**穩定partition（`for e in ranked: if layer(e)==top_layer: same.append(e) else rest.append(e)`）。`ranked[0]`自身的layer即為`top_layer`（定義上必屬same組），且在原list中排第一個，故`same[0]`必然=`ranked[0]`。`return same+rest`後新list第一個元素恆等於`ranked[0]`——這是演算法結構上的必然結果，非「通常情況」。dispatch loop第一次迭代必命中同一option，行為byte-identical。

2. **conquest/threat分支不破**：讀`faction_ai_system.gd:1461-1499`迴圈本體確認——loop走法是`for e in ranked: ...if條件成立: dispatch成功則return，不可派則continue試下個`，完全靠「依序試，第一個成功者贏」的walk pattern，不依賴任何絕對index判斷（無`e["i"]==0`或「必須是第一個」的隱含檢查）。重排只改「哪個排第一個被試」，不改walk-until-success邏輯本身，對攻擊/征服scout-verify分支（`:1467-1477`）/threat wiring皆安全。

3. **main_layer分組正確（逐一代入AFFINITY表驗算）**：覓食[0.9,0.1,0,0,0]→argmax=SURVIVAL；買糧[0.9,0,0.1,0,0]→SURVIVAL；返家補給[0.7,0.2,0.1,0,0]→SURVIVAL；紮營[0.6,0.1,0,0.1,0.2]→SURVIVAL(0.6最高)；乞食[0.8,0,0.2,0,0]→SURVIVAL——五項核心食物option確認argmax皆L_SURVIVAL，精確吻合claim。掠奪[0.4,0,0,0.5,0.1]→argmax=ESTEEM(排除合理)；併入[0.3,0.1,0.6,0,0]→argmax=BELONGING(排除合理)；survival(FLEE)[0.2,0.8,0,0,0]→argmax=SAFETY(非survival，吻合spec自己備註「FLEE affinity=safety-main」)。

4. **兩loop對稱**：`_decide_unified`/`_evaluate_solo`皆在`rank_scored`後、迴圈前插入同一行`reorder_same_need_first`，接入點對稱，無特殊差異。

5. **determinism**：純array重組+穩定partition，零randf。

CLEAN，dispatch。
