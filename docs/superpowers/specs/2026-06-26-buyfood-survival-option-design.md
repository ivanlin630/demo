# 買糧 求生 option — 取食對稱化（搶/買/覓/返家 同框 + 距離 util 折扣）

> 系統 HOW spec。承藍圖 ruling `2026-06-26-...-survival-foodsource-and-war-feel` §2（修正系統的「距離衰減」補丁提案→改求生取食多 option、買糧補進、距離 util 折扣）。
> measure-first 已證（`buyfood_measure.gd` merge `1d9d608`）：餓商隊 food_days=0.10 + coin=500 + 鄰市集售糧 → 引擎首選**紮營**(util1.08)/乞食(0.87)，**有錢不買糧**（向賣家乞討而非買=荒謬）。gap 確認。
> 優先序：框架完成/believability polish（藍圖定），**非擋 P4**。

## 真根（藍圖診斷）

求生取食 options = 返家/覓食/掠奪/投靠/紮營/乞食——**「買糧」不在內**。搶糧是 option（掠奪），買糧不是 = **取食不對稱**。商隊最自然的求生取食（路過市集掏錢買）在缺糧時無法選，只能搶/乞/紮營/回家。`返家補給` 量級支配進一步把取食塌成「回家」一條。

## 模型（藍圖定）

```
求生取食 options（食物缺才入候選）：
  買糧 @ 最近市集   util = 食物缺 × (1/到市集距離) × 有 specie/貨 × 商人傾向
  搶糧 @ 最近弱者   util = 食物缺 × (1/到目標距離) × 殘忍/好戰
  覓食 @ 腳下       util = 食物缺 × 有可覓格
  返家補給         util = 食物缺 × (1/到家距離)
  → 純 argmax，距離進每條 util 當旅費折扣
```
湧現：商人帶錢路過市集→一路買；殘忍近弱鄰→一路搶；都不近+有家最省→返家；皆無→覓食/絕境分流。**距離=util 折扣項，非 if-else**。

## 範圍（切兩片，防 sprawl + 隔離回歸）

- **本 spec = Phase 1（買糧 option，核心 gap）**：補 `買糧` engine survival option（distance-discounted），閉「有錢不買糧」對稱缺口。`掠奪`/`返家補給`/`覓食` **暫不動**（行為連續，零回歸）。
- **Phase 2（延，距離折扣全 options）**：把「旅費折扣」retrofit 進 `掠奪`(/到弱者距離)、`返家補給`(/到家距離)，達藍圖「同框」完整。**獨立 slice**（碰既有 tuned option=回歸面，單獨驗）。本 spec 不做，列後續。

**非目標**（Phase 1）：
- 不碰 `掠奪`/`返家補給`/`覓食`/`投靠`/`紮營`/`乞食` 既有 term/weight（Phase 2 才加距離）。
- 不新 TASK_*（買糧 → 既有 `TASK_TRADE`，到場 `_resolve_market` 買；複用 WS-2b 市集巡訪 + 親讀看板）。
- 不改市集/order/trade 執行機制（複用）。
- non-unified `_trigger_survival` 自動受惠（P2b-1 已委派 `rank_survival`；`買糧` 入 `SURVIVAL_OPTION_SET` → 全隊化）。

## 設計

### 1. DecisionContext（市集欄）
```gdscript
var has_food_market: bool = false           # 最近非自家市集 outpost 存在（複用 _nearest_market_outpost）
var food_market_pos: Vector2i = Vector2i(-1, -1)
var food_market_dist: int = -1              # 旅費折扣輸入
var has_specie: bool = false                # coin>0 或 goods>0（可換糧）
```
gather：`_fa._nearest_market_outpost(state, team)`（既有，回最近非自家市集 outpost 位）→ 設 pos/dist（`_hex_dist`）；`has_specie = coin>0 or goods≥某量`。
> 註：`_nearest_market_outpost` 回任何市集（不檢是否售糧）→ 到場若無糧=撲空 emergent（藍圖「履約撲空 emergent」既有原則）。Phase 1 可接受；若量測顯撲空過頻 → 改 `_nearest_food_market`（檢 tile.market_orders 有 food sell）列 refinement。

### 2. terms.gd：`buyfood_drive` + `buyfood` weight
```gdscript
const BUYFOOD_DIST_FULL: float = 6.0   # TEST VALUE — 旅費折扣基準距離（dist≥此→折扣強）
```
eval（食物缺 × 距離折扣 × 有 specie）：
```gdscript
		"buyfood_drive":
			if opt != "買糧" or not ctx.has_food_market or not ctx.has_specie: return 0.0
			# 食物缺量級（對齊 survival-class，吃飽→0）× 旅費折扣（近市集→1，遠→衰減）
			var hunger: float = DESPERATION_SCALE * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
			var dist_disc: float = BUYFOOD_DIST_FULL / maxf(float(ctx.food_market_dist), BUYFOOD_DIST_FULL)
			return hunger * dist_disc
```
weight（商人傾向=role 權重非 gate，守 tc7 裁定）：
```gdscript
		"buyfood":
			# 商隊高、他隊低（能買但少；非硬 gate）。複用既有 is_merchant 角色因子精神。
			return 1.0 if leader_values.get("_is_merchant", false) else NON_MERCHANT_TRADE_FACTOR
```
> 註：weight 讀 is_merchant → 同 loyalty 注入法，gather 注入 `leader_values["_is_merchant"]=ctx.is_merchant`（或 weight 簽名已有 ctx？無→注入 dict，與 P3 `_loyalty` 一致）。plan 定。

### 3. options.gd：`買糧` option
REGISTRY：`"買糧": [["buyfood_drive", "buyfood"]]`
`SURVIVAL_OPTION_SET` 加 `"買糧"`（non-unified 委派也得此 option=全隊化）。
applicable：
```gdscript
			"買糧":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_food_market and ctx.has_specie:
					out.append(opt)
```
to_task：`{task=TASK_TRADE, target=ctx.food_market_pos}`（到場買糧走既有 `_resolve_market`；餓隊 local_value(food) 高→買 food）。
> to_task 無 ctx → 直呼 `_nearest_market_outpost`（與既有 `覓食`/`掠奪` to_task 直呼 finder 一致）。

### 4. believability
- **取食對稱**：有錢商隊缺糧 → **買糧**（不再只能搶/乞/紮營）。乞食回歸真語意（無錢才乞）。
- **旅費折扣**：近市集→買划算；市集很遠→折扣低→可能改覓食/返家（emergent，非 if-else）。
- **role=權重非 gate**（守 tc7）：商隊買糧傾向高、非商隊低但能買（有錢的軍隊缺糧也會買，少）。
- **危時序**：買糧 hunger 量級對齊 survival-class（與覓食/返家同域），距離折扣決遠近取捨。有錢近市集商隊 → 買糧勝紮營/乞食（修 measure 揭的荒謬）。

## 驗收

- **餓商隊買糧（修 measure gap）**：headless 重現 `buyfood_measure` 情境（food<3 + coin + 鄰市集）→ 引擎首選 `買糧`(TASK_TRADE→市集)，**非紮營/乞食**。
- **旅費折扣**：同餓商隊，市集近→買糧 util 高；市集遠（dist≫BUYFOOD_DIST_FULL）→ 買糧 util 衰減 → 可能改覓食/返家（emergent）。
- **role 權重**：商隊買糧 weight 高；非商隊（軍隊）有錢缺糧 → 買糧 weight 低但 applicable（能買少買）。
- **無錢不買糧**：coin=0 且 goods 少 → `has_specie`=false → 買糧不 applicable → 落乞食/紮營（乞食真語意=無錢才乞）。
- **non-unified 全隊化**：`買糧` 入 `SURVIVAL_OPTION_SET` → non-unified 餓隊（有錢+鄰市集）`_trigger_survival` 委派也選買糧。
- **既有 survival 不回歸**：`掠奪`/`返家補給`/`覓食`/`投靠`/`紮營`/`乞食` 行為原樣（Phase 1 不碰其 term）；P2a/P2b-1 測 + 飢荒/絕境測全綠。
- **守恆**：買糧走既有 `_resolve_market` 守恆；coin_eq 0、InvariantAudit 0。
- **world_sim**：2yr 不崩、餓商隊買糧 emergent、無 mass starvation、framework S1-S6 PASS。

## 檔案
- `scripts/simulation/decision/decision_context.gd`：市集欄 + gather（`_nearest_market_outpost`、has_specie、`_is_merchant` 注入）。
- `scripts/simulation/decision/terms.gd`：`buyfood_drive` eval + `buyfood` weight + `BUYFOOD_DIST_FULL`。
- `scripts/simulation/decision/options.gd`：REGISTRY `買糧`、`SURVIVAL_OPTION_SET` 加、applicable、to_task。
- `scripts/debug/headless_test.gd`：新測（買糧勝紮營/乞食、旅費折扣、無錢不買、role 權重、non-unified 全隊化、既有不回歸）。

## 風險 + 緩解
- **撲空（市集無糧）**：`_nearest_market_outpost` 不檢售糧 → 到場無糧=撲空。緩解：撲空 emergent（既有原則）+ 量測撲空率，過頻改 `_nearest_food_market`（檢 market_orders food sell）。
- **TASK_TRADE 到場不買 food（買成別的）**：`_resolve_market` 按 local_value 估值交易；餓隊 food local_value 應最高 → 買 food。驗：headless 確認到場買到 food（非買武器）。若不穩 → food-directed buy intent（refinement）。
- **量級失衡**（買糧碾壓/被碾壓覓食返家）：`BUYFOOD_DIST_FULL`/hunger 對齊 survival-class；headless 驗序（近市集有錢→買、遠→覓/返）。TEST VALUE。
- **role 注入 weight**（`_is_merchant`）：同 P3 `_loyalty` 注入法，`_` 前綴不污染。plan 確認既有 term 不誤讀。
- **scope sprawl**：Phase 1 只 `買糧`，不碰既有 option term（Phase 2 才距離折扣全套）。只碰 decision/ 三檔 + 測。

## 開放細節（plan 定）
- `_is_merchant`/has_specie 注入與 weight 讀法（dict 注入 vs ctx）。
- `BUYFOOD_DIST_FULL`(6) / hunger 量級 / goods 門檻（has_specie 的 goods≥?）。
- 撲空容忍 vs `_nearest_food_market`（先簡單後量測）。
- Phase 2（距離折扣 retrofit 掠奪/返家）= 獨立 spec，本塊只標方向。
