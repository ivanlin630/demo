# 封建財政 / 公庫經濟（Fief Economy）— Design

> 日期：2026-06-13
> 議題：W4 leader 行為性貧窮的完整解。根因鏈（程式查證）：
> - 建造扣 `team.resources`（`outpost_system._can_afford`/`_deduct_cost` :594-608），不碰公庫
> - 但 food/material 採集進採集團 `team.resources`（私產）；只有 ore/製造成品進 public_storage
> - leader 漫遊在外、口袋空 → 公庫財富（若有）也用不到 → 永遠摸不到建造門檻
> - 徵收稅需 leader 親自走到居民同格（W1 式追逐），且食物驅動非建材累積
> - 乞食慷慨度範圍窄（人人中等大方），居民村被吸乾無法累積
> 設計目標：財產分層（居民私產 vs 統治者公庫）+ 一般稅自動化解 leader 窮 + 慷慨光譜製造貧富分化 → 強村浮現 → 掠奪/貿易動機。

## 設計核心

- **財產兩層分明**：居民私產 = `team.resources`（稅後）；統治者稅金 = outpost `public_storage`（公庫）
- **一般稅自動化**：居民在 outpost 採集 → `tax_rate × 產出` 每 cadence 自動撥腳下 tile 公庫（owner 的），無需 task
- **建造扣公庫（本地）**：建造/升級付款先扣腳下 tile public_storage，不足才補施工團 team.resources。嚴格本地（人站在 tile）— 非隔空取物
- **特別稅 = 徵收 task 改造**：leader 主動額外加徵（戰時/缺糧/野心），重 rate + 強 unrest
- **慷慨光譜**：乞食給予由個性兩極決定（守財奴囤積致富 / 聖人散盡）+ 人性底線
- **兩稅獨立不滿**：一般稅慢性低度、特別稅尖峰怨恨

## 不變量

- 居民私產與統治者公庫**永不混淆**：採集稅後進私產、稅金進公庫；乞食動私產、建造動公庫
- 守恆：一般稅 = 居民私產 → 公庫**轉移**（總量不變）；建造扣公庫不憑空生滅
- 建造嚴格本地：只能扣施工團腳下 tile 的 public_storage（不可遠端他格公庫）
- coin/有限資源守恆原則不破（沿用 facility-overhaul 守恆審計）

---

## 1. 一般稅：自動撥公庫（A + C）

居民團在 outpost tile 採集後（`resource_system._collect_from_tile` 尾端或 `collect_resources` 結算點）：

```gdscript
# 一般稅：採集所得按 tax_rate 自動撥給「腳下 tile owner」的公庫
# 對象 = food / material（goods 若採集亦同）；ore/製造成品已直接進公庫不重複課
const NORMAL_TAX_RES: Array = ["food", "material", "goods"]

func _apply_normal_tax(state, team, tile, gained: Dictionary) -> void:
    if tile.outpost_level == 0: return
    var rate: float = tile.... # owner 的 tax_rate（見下「稅率歸屬」）
    for res in NORMAL_TAX_RES:
        var g: float = float(gained.get(res, 0))
        if g <= 0.0: continue
        var tax: float = g * rate
        team.resources[res] = float(team.resources.get(res,0)) - tax   # 居民私產扣稅
        var cap: float = OutpostSystem.new()._get_storage_cap(tile, res)
        var cur: float = float(tile.public_storage.get(res,0))
        tile.public_storage[res] = minf(cur + tax, cap)                 # 進公庫（守恆轉移）
```

**稅率歸屬**：tax_rate 是「該 tile owner 對在此採集者收的稅」。實作取 `tile.outpost_owner` team 的 `tax_rate`（既有 `TeamData.tax_rate` 預設 0.3）。若採集者就是 owner（自立村）→ 自己存自己公庫（村庫），語意成立。

**C 儲蓄概念由此自然成立**：公庫 = 統治者常態稅累積的金庫，會跨 cadence 累積（受 storage cap 限）→ 不再「有就花光」。

**公庫 cap**：food/material/goods 需有 cap（`_get_storage_cap` 目前只定 mounts/ore 類；本 spec 補 food/material/goods cap，依 outpost_level 給足夠大值如 [500,1500,4000]，TEST VALUE）。

## 2. 建造扣公庫（A，本地）

`outpost_system._can_afford` / `_deduct_cost` 改吃「腳下 tile 公庫 + 施工團 resources」合併池，**優先扣公庫**：

```gdscript
func _can_afford(team, tile, cost) -> bool:
    for res in cost:
        if res == "ticks": continue
        var avail: float = float(tile.public_storage.get(res,0)) \
            + float(team.resources.get(res,0))
        if avail < float(cost.get(res,0)): return false
    return true

func _deduct_cost(team, tile, cost) -> void:
    for res in cost:
        if res == "ticks": continue
        var need: float = float(cost.get(res,0))
        if need <= 0.0: continue
        var from_vault: float = minf(need, float(tile.public_storage.get(res,0)))
        tile.public_storage[res] = float(tile.public_storage.get(res,0)) - from_vault
        var rem: float = need - from_vault
        if rem > 0.0:
            team.resources[res] = maxf(float(team.resources.get(res,0)) - rem, 0.0)
```

所有 caller（`start_build` / `start_upgrade_level` / `start_upgrade_facility` / `_begin_facility_construction` / faction_ai 派工 `_fund_subteam_cost`）傳入 tile。**malthus 的 `_fund_subteam_cost`（owner 補差額給子隊）改為：owner 公庫足 → 子隊直接扣公庫；不足才 owner 私產補**。

## 3. 特別稅：徵收 task 改造（B）

`_resolve_tribute`（特別稅，已有 unrest）強化：

- **rate 提高**：特別稅 = `tax_rate × SPECIAL_TAX_MULT`（如 ×1.5），抽 owner 公庫**或**居民私產（leader 親訪封臣 → 抽該封臣公庫一成歸 leader 口袋；封臣自己的稅金被上級再抽 = 封建層次）
- **觸發**：`_update_faction_goals`（:574-579）的 `徵收` goal 除缺糧，加「野心/好戰高 → 戰爭基金」週期
- **強 unrest**：搜刮量越大尖刺越高（見 §5）
- **E 子團門檻**：`DISPATCH_DIST_THRESHOLD`（=2）放寬，或 pop 門檻降（leader 更常派子隊代徵，不必親跑）

特別稅進 **leader 口袋（team.resources）** — 應急/戰爭用途（非建造常規來源；建造走公庫一般稅）。

## 4. 乞食慷慨光譜（D）

`_resolve_aid_request`（:809）改：reserve 與 give 由個性兩極決定。

```gdscript
# 留存：守財奴囤光、聖人少留（取代 flat AID_RESERVE_DAYS=14）
var hoard: float = greed - honor                         # [-1,1]
var reserve_days: float = lerp(2.0, 60.0, (hoard+1.0)/2.0)
var reserve: float = float(target.population) * reserve_days * 2.4   # 食物天數→量

# 給予比例：個性 + 交情 − 厭煩，光譜兩極
var give_fraction: float = clampf(honor - greed*0.5 + rep*0.3 - annoyance, 0.0, 1.2)

var surplus: float = maxf(target_food - reserve, 0.0)
var give: float = minf(need, surplus * give_fraction)

# 人性底線：對方「快餓死」（satisfaction 極低 / famine_days 高）→ 再吝嗇也給最低限
if give <= 0.0 and beggar_is_starving and honor > 0.1:
    give = minf(need, MIN_MERCY_FOOD)   # 如 1 天份，TEST VALUE
```

效果：守財奴村（高貪低義）reserve≈全部、give≈0 → 囤積 → **公庫/私產雙累積 → 蓋強村**；聖人村散盡。**湧現貧富分化** = 掠奪有對象、貿易有差價、強村能擴張。底線保「再吝嗇遇將死者仍給一口」的人性微光（除非 honor 趨 0 的真禽獸）。

## 5. 兩稅獨立不滿（新）

| 稅 | 不滿機制 |
|---|---|
| **一般稅** | 慢性：`tax_rate` 超容忍閾值才累積微 unrest。`tolerance = 0.3 + 順從×0.2 + 義氣×0.1 − 野心×0.2`；`rate > tolerance` → 每課稅 cadence `stress += (rate−tolerance)×0.02`、超久 unrest_turns 緩增 |
| **特別稅** | 尖峰：保留既有（rate>0.5 unrest+1 + stress/loyalty/fear），再按搜刮比例強化：`stress += taken_ratio × 0.3`、`annoyance`（近期特別稅次數）疊加 → 連續特別稅 → 怨恨爆 → 起義（既有 unrest→起義鏈） |

明君（適度一般稅、罕特別稅）→ 村繁榮；暴君（兩稅全開）→ 富而叛亂頻。

---

## 連鎖效果（自動湧現，不另實作）

- leader 自有 outpost 居民/子團生產 → 一般稅自動積公庫 → leader 回家即有建材蓋（W4 解）
- 守財奴村囤積 → 強村浮現 → 有實力蓋據點/打仗/被掠奪 → W1/W2 的「無貧富不均」上游解
- 公庫財富 = 掠奪/攻城的實質戰利品誘因（攻下強村公庫滿）
- 特別稅過度 → 起義（接既有 unrest 機制）

## 測試

1. 一般稅：居民 outpost 採集 → tax_rate 比例進腳下公庫、私產扣對應量（守恆：私產減=公庫增）
2. 公庫 food/material/goods cap 生效（不溢出）
3. 建造扣公庫優先、不足補私產；公庫足時施工團私產不動
4. 本地約束：施工團腳下 tile 公庫才可扣，他格公庫不受影響
5. `_fund_subteam_cost` 改公庫優先
6. 特別稅：rate × MULT 抽公庫/私產進 leader 口袋；觸發含野心戰爭基金；子團門檻放寬後派子隊代徵
7. 慷慨光譜：守財奴（貪0.9義0.1）give≈0、聖人（義0.9貪0.1）give 高且可動 reserve；中性居中
8. 人性底線：守財奴遇將餓死者（honor>0.1）給 MIN_MERCY_FOOD；honor≈0 真禽獸不給
9. 一般稅慢性不滿：rate>tolerance → stress/unrest 緩增；rate<tolerance → 無
10. 特別稅尖峰：搜刮比例 → stress 尖刺；連續特別稅 annoyance 疊加
11. 守恆：全鏈 coin 等值 + food/material 總量（私產+公庫+地面）不憑空生滅
12. multi 2 年：公庫累積出現、設施建造 > 2 年 baseline、貧富分化（村公庫存量 variance 上升）、強村出現、ALL INVARIANTS PASSED、coin delta 0

## 風險

- 全參數 TEST VALUE（tax_rate 0.3、SPECIAL_TAX_MULT 1.5、reserve_days 2-60、MIN_MERCY_FOOD、tolerance 係數、cap）
- **過度課稅自我毀滅 = 刻意湧現，不加保護**：tax_rate 過高 → 居民私產被抽乾 → 居民餓（famine 鏈接手乞食/逃難/餓死）→ 稅基崩潰 → 公庫收入歸零。拉弗曲線自然懲罰，暴君自食惡果。**不加「私產低於 N 天免稅」之類硬性兜底**（會抹掉因果、替暴君護航）。tax_rate 是有真實下行風險的統治者決策。NPC leader 依個性收斂稅率（慎重高→低稅）屬 faction_ai 後續觀察層，本 spec 只讓後果存在
- 建造扣公庫改 caller 簽章（多處傳 tile）— 確保所有路徑同步，玩家建造 UI 路徑一併
- 特別稅抽公庫 = 上級抽下級稅金，與一般稅可能雙重課稅同批產出 → 觀察居民負擔
- 慷慨光譜 reserve 60 天上限：守財奴近乎不給 → 流浪團更難乞到 → famine 死亡可能上升（設計意圖：慷慨村才養得起流民，但觀察滅團率）
- 公庫成攻城戰利品後，掠奪誘因上升 → 可能與 W1 會合問題交互（W1 未解前掠奪仍可能追不到）
