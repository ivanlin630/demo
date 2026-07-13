# dispatch 同需求 fallthrough（裁 A）— systems HOW

> 藍圖裁 A(`forage-dispatch-fix-A`)：rank[0] 不可 dispatch 時,fallthrough 優先同需求(食物類)替代 option,非 next-by-raw-util。結構性連帶緩解 C(target-fail)/B(食物 under-rank)。

## 動機（坐實）
Team7 餓隊：覓食(0.95 rank[0]) undispatchable(`_find_forage_tile` 只掃 7 相鄰,枯竭→-1)→dispatch loop `continue`→落 next-by-util **生產(0.58,非食物)**→產糧無用餓死。買糧(0.30 食物)排生產下→沒被試。fallthrough 落錯需求類別。

## 設計：同 main 需求層優先 fallthrough
複用 `NeedHierarchy.main_layer_of(opt)`（affinity argmax 層）。**核心食物類（覓食/買糧/乞食/返家補給/紮營）affinity argmax 皆 L_SURVIVAL** → main_layer 分組正好抓食物替代。
- rank[0] 不可 dispatch → 同 main_layer(=rank[0] 需求層) 的其他 option（util 序）**優先於跨層** option。
- **rank[0] dispatchable → NO-OP**（rank[0] 同層自身,穩定重排後仍首試→行為 byte-identical）。∴ 只改「rank[0] undispatchable」bug case,其餘保留。

### 實作：dispatch 前穩定重排 ranked
> ★修正(implementer 卡點 `samefall-join-seam`)：**分組準則=`SURVIVAL_OPTION_SET` 成員資格**（非純 affinity 層）。因併入(belonging-affinity)/掠奪(esteem-affinity)/佔村 **在 SURVIVAL_OPTION_SET 但 affinity main-layer≠survival**→純 affinity 分組會把絕境投靠/搶糧推到 rest 尾，破 desperate 忠義隊投靠(p2a)。dispatch fallthrough 語意=「同**求生 repertoire**」(絕境 option 一組),非「同 affinity 決策優先層」。∴ survival-set 成員一律歸「survival」category,涵蓋 覓食/買糧/紮營/併入/掠奪/佔村/乞食/返家；非 survival-set→affinity main_layer。

`DecisionEngine` 加（純函式,零 randf）：
# ★修正2(implementer 卡點 `samefall-loot-residual`)：fallthrough 食物組=**被動求生**,排攻擊型。
# 掠奪/佔村 ∈ SURVIVAL_OPTION_SET 但 to_task=TASK_LOOT/ATTACK=主動侵略(esteem-affinity,人格/野心驅)→
# 納 fallthrough 使 fed 溫和隊「同組其他不可派→落掠奪」繞過人格 weight gate(溫和不劫掠,p1 破)。
# ∴ fallthrough「食物需求」=被動求生子集(覓食/買糧/乞食/返家/紮營/併入=食物+認慫投靠),
# 排攻擊型(掠奪/佔村→按 affinity=esteem,weight 主導)。餓隊仍涵蓋覓食/買糧/紮營/併入 fallthrough。
const PASSIVE_SURVIVAL_SET: Array = ["覓食", "買糧", "乞食", "返家補給", "紮營", "併入"]

# fallthrough 分組準則:PASSIVE_SURVIVAL_SET 成員=「被動求生」同組(不看 affinity,保投靠 p2a);
# 非成員(含攻擊型掠奪/佔村)→affinity main_layer(掠奪/佔村=esteem,人格 weight gate 主導)。
static func _need_category(opt: String) -> String:
    if opt in PASSIVE_SURVIVAL_SET:
        return "survival"
    return "L%d" % NeedHierarchy.main_layer_of(opt)

# fallthrough 同需求優先(裁A):same category(=rank[0]category)在前、其餘在後,各組保原 util 序。
# rank[0] dispatchable 時 NO-OP(rank[0] category=自身 top_cat,穩定 partition 仍首試)。
static func reorder_same_need_first(ranked: Array) -> Array:
    if ranked.size() <= 1:
        return ranked
    var top_cat: String = _need_category(String(ranked[0].get("opt", "")))
    var same: Array = []
    var rest: Array = []
    for e in ranked:
        if _need_category(String(e.get("opt", ""))) == top_cat:
            same.append(e)
        else:
            rest.append(e)
    return same + rest   # 穩定:各組內保原降序 util
```
接入 **兩處 dispatch loop**（同改）：
- `faction_ai_system.gd _decide_unified`：`var ranked: Array = DecisionEngine.rank_scored(state, team)` 後加 `ranked = DecisionEngine.reorder_same_need_first(ranked)`。
- `faction_ai_system.gd _evaluate_solo`：`var ranked: Array = DecisionEngine.rank_scored(state, team)` 後加同行。
- **conquest/threat 分支不動**（loop body 不變,只改迭代序;攻擊征服 scout-verify/threat aux wiring 原樣）。

## 效果
餓隊覓食(survival-main)undispatchable→同層 買糧/乞食/返家/紮營(皆 survival-main)util 序優先試→買糧 dispatchable(有市集+錢)則買糧,非落生產。連帶緩解 C(覓食 target-fail 時有食物替代)/B(買糧即使 util 低,同層優先仍先試)。

## 注意/邊界
- **併入**：`PASSIVE_SURVIVAL_SET` 成員→歸 survival 組→餓隊覓食失敗涵蓋投靠(認慫求保護=被動求生),保 p2a 忠義隊投靠。
- **掠奪/佔村**（★修正2）：攻擊型(TASK_LOOT/ATTACK,esteem-affinity,人格/野心驅)→**不納 fallthrough 食物組**,按 affinity=esteem,**人格 weight gate 主導**(溫和不劫掠 p1 保)。餓隊要搶糧靠 掠奪 util 高(殘忍/好戰 weight)直接 rank 上,非 fallthrough 保底。
- **survival(FLEE)**：affinity=safety-main（非 survival）→ 威脅隊 FLEE 失敗優先試同 safety 層(備戰/迎戰/求和),合理。
- rank[0] dispatchable → 重排 NO-OP → 既有行為/測/determinism 不動（關鍵：非 bug case 零變）。

## TDD（headless_test.gd）
`_test_reorder_same_need`：
- ranked=[覓食(survival),生產(esteem),買糧(survival)] → reorder→[覓食,買糧,生產]（同 survival 層在前）。
- rank[0] 與後續全同層 → 順序不變（NO-OP）。
- 單 option / 空 → 原樣回。

## 驗收（measurer 終驗）
- **★餓隊覓食失敗→試買糧/乞食/返家/紮營**（非落生產）：Team7 式重跑,winner 在覓食 undispatchable 時是食物類替代非生產。
- **rank[0] dispatchable 不回歸**：既有 dispatch 行為 byte-identical（determinism 驗）。
- 融合閘/TC2/consolidation/combat 不回歸。

## 風險（R②）
- 重排是否影響 conquest/threat 分支既有 dispatch（loop body 不變,僅序;查兩分支不依賴絕對 util 序）。
- 掠奪/併入 排除是否夠（食物核心類 vs 廣義食物取得）——measurer 驗殘留。
- 純算術零 randf、determinism。
