# #1 經濟閉環 — Plan 2：腐壞 / 儲限 HOW design（DRAFT — 未 dispatch）

> 來源：ruling `2026-06-20-blueprint-to-systems-feud-scenarios-ruling`（§3 #1：履約 + **腐壞/儲限**，食物囤 4-5萬無壓力）。
> **狀態：DRAFT，未派子 session。** dispatch 前置：① plan-1 履約 merge（序）② **rate/allowance feel 建議請藍圖 confirm**（腐壞影響飢荒 feel，類比 #0 dramatic-distribution 走 feel ruling；rate 太兇會餓死世界）。
> WHAT（囤糧要有壓力、經濟別空轉）藍圖給；腐壞形狀/rate/allowance = 系統 HOW + TEST VALUE。

## 病
食物無腐壞、無儲限 → 定居/outpost 隊囤 4-5 萬食物無代價 → 經濟空轉（無消耗壓力 → 無貿易動機 → G1 半 inert）。

## HOW 決定：軟腐壞（pop-scaled 新鮮配額之上才壞），不設硬 cap

**只腐壞 food（易腐）**；material/ore/goods/weapon 不壞（耐放）。

**配額制**：每隊有「新鮮配額」= `population × FOOD_PER_PERSON_PER_DAY × FRESH_DAYS_BUFFER`（= 約 N 天存糧免腐）。配額**之下不腐**（保護維生/小隊），之上按 `SPOIL_RATE` 腐：

```gdscript
const FRESH_DAYS_BUFFER: float = 30.0   # TEST VALUE：N 天存糧免腐（pop scaled）
const FOOD_SPOIL_RATE: float = 0.05     # TEST VALUE：超額部分 5%/day 腐壞
```

在 `resolve_consumption`（resource_system，消耗後）尾加：
```gdscript
# 腐壞：新鮮配額之上的 food 按 rate 腐（配額 pop-scaled，保護維生；只 food）
var allowance: float = float(team.population + team.minor_population) \
	* FOOD_PER_PERSON_PER_DAY * FRESH_DAYS_BUFFER
var food_now: float = float(team.resources.get("food", 0))
var excess: float = maxf(food_now - allowance, 0.0)
if excess > 0.0:
	var spoiled: float = excess * FOOD_SPOIL_RATE * day_fraction
	team.resources["food"] = food_now - spoiled
	Probe.bump("g1.food_spoiled", int(spoiled))   # 累計腐壞量（量測壓力）
```

### 為何配額制非硬 cap / 非全量 flat %
- **硬 cap**（food 不能超 X）：粗暴、要 spill 邏輯、易卡 AI。
- **全量 flat %/day**：連維生小隊的救命糧都腐 → 加劇飢荒、不公平。
- **配額軟腐**：<配額（~1 月糧）零腐 → 維生/小隊不受影響；只囤積（4-5萬 >> 1 月）流血。直接打 ruling 標的（idle 囤糧），不誤傷生存層。pop scaled → 大隊配額大（合理：大隊本該存更多）。

## 邊界 / 守恆
- **food 是 sink，無守恆不變量**（只 coin_eq 守恆；`resolve_consumption` 早已燒 food）→ 腐壞 = 另一 food sink，**invariant 安全**（coin_eq/InvariantAudit 不受影響，回歸驗 0 為形式確認）。
- 只動 `resources["food"]` + 1 probe。不碰 coin/其他 res/交易。
- `g1.food_spoiled` 新 probe（量測囤糧壓力是否生效）。

## 平衡風險（要 watch / 可能要藍圖 feel）
- rate × allowance 決定壓力強度：太兇 → 世界普遍餓（飢荒 attrition 連鎖）；太鬆 → 4-5萬照囤無感。
- 與既有飢荒系統（`famine_days`/grace/attrition）疊加：腐壞使存糧縮 → 更易跌破 famine 門檻。需重量看世界是否過餓。
- **建議**：FRESH_DAYS_BUFFER(30)/FOOD_SPOIL_RATE(0.05) 占位，dispatch 前或 merge 前請藍圖 confirm「囤糧壓力 feel」（多久該開始流血、世界該不該因此更缺糧→更多貿易/搶奪）。

## 驗收
- 單測：food < 配額 → 零腐；food >> 配額 → 超額部分按 rate 腐、配額內不動；pop 大 → 配額大。
- headless 全綠、coin_eq=0、InvariantAudit 0（food sink 不破守恆）。
- （重量，煙霧）world_sim：`g1.food_spoiled` > 0（囤糧開始有代價）；觀察囤糧峰值是否從 4-5萬 下降 + 是否連帶刺激貿易/缺糧行為（受非確定限，僅趨勢）。

## 後續 / OUT
- goods 是否也微腐（貿易品損耗）= 後續 refinement，本 plan 只 food。
- 硬儲限 / 倉庫建築 cap = 若軟腐不夠、或要據點建設深度時再做。
- mint：待 #1 整體重量。
