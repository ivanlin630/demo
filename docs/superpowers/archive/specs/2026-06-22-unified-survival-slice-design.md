# 統一隊 survival 切片 — 引擎擁有 unified 隊求生（履約脫 0 正解）

> 承統一框架 arc：sub-proj1(商隊切片)+A(生產隊)+返家補給地基(merge `c97fc5b`)。
> 真根（measure-first 確認）：引擎 utility-survival **無牙**（survival_pressure cap 1.5 < 貪婪 trade ~1.8），逼停貿易的是引擎外 785 latch；返家補給 utility-class 繼承無牙 → dead-on-arrival（適用 55 勝 0）。
> 本塊 = 框架完成塊「survival 遷引擎」的**第一切片**（unified 隊）。完整遷移（loot/join/camp/beg + 全隊 + 退役舊 survival）= 後續塊。
> 藍圖裁定原則：角色=權重輸入非 gate；survival 優先序不洗平（危時該贏仍贏）。

## 病

統一隊（商隊+生產隊）的 survival 由**引擎外**舊 `_evaluate_survival` + 785 latch 擁有：
- 引擎 survival/覓食/返家補給 option 的 util 在糧危時**仍輸 trade**（`survival_pressure` eval cap 1.5、`restock_need` 0.2-0.4 vs trade 0.8-1.8+承諾0.3）→ 永遠選不上。
- 真正逼停貿易的是 785 latch（強制 survival task、繞過 utility），但 latch 把引擎鎖在門外 → 商隊一進 survival 永不智慧返家補給 → drift 餓死 / 卡 latch → 履約 0。

= 兩套求生決策者並存（引擎無牙 + latch 霸權）。修 = **讓引擎靠 util 量級擁有 unified 隊求生，退役 latch（僅 unified）**。

## 架構：survival-class term 量級支配（非 latch/非 tier）

讓 survival-class option 的 util 在糧危時**量級上碾壓** trade → 靠純 utility argmax 自然贏，無需 latch、無需優先序 tier。believability「餓→停貿易」由**量級**保證（非硬閘）。

**trade util 域（驗算基準）**：`weight("economic")=0.3+貪婪(0..1) → 0.3..1.3`，`economic_opp≈0.8` → trade util ≈ 0.24..1.04，+ COMMITMENT_BONUS 0.3（現行貿易）→ **約 0.5..1.35**，極端貪婪+滿貨 arb ~1.5。設計目標：survival-class 危時 util ≫ 1.5。

### 1. `survival_pressure` 重標度（覓食/survival option 用）— `terms.gd`
```
"survival_pressure":
    if ctx.food_days >= 3.0: return 0.0          # 吃飽(≥WARNING) → 不蓋過 trade
    return 4.0 * (3.0 - ctx.food_days)            # 糧危陡升支配
```
驗算（×weight 1.0）：food 2.9→0.4 / 2.5→2.0 / 2→4.0 / 1→8 / 0→12。→ food<2.5 即碾壓 trade，food 2.5-3 過渡帶 trade 仍可贏（3 天糧還行=合理）。

### 2. `restock_need` 重標度（返家補給,proactive 回家）— `terms.gd`
```
"restock_need":
    if opt != "返家補給": return 0.0
    return 1.5 * (RESTOCK_DAYS(5) - ctx.food_days)   # 不另設上限
```
驗算（×weight survival_pressure 1.0）：food 4→1.5 / 3.5→2.25 / 3→3.0 / 2→4.5 / 0→7.5。
- 普通商隊 ~food 4 回家、貪婪 ~food 3.5 回家（皆在硬危機前 proactive）。
- **有家偏好**：restock vs survival_pressure(覓食) 交叉 ≈ food 1.8（`1.5(5-f)=4(3-f)`）→ food>1.8 有家走返家補給、food<1.8（太餓走不動）就地覓食。合理（輕危回家/重危就地）。

### 3. survival option = 威脅用（與 hunger 分離）— `options.gd`/`terms.gd`
現 `survival` REGISTRY = `[["survival_pressure","survival_pressure"]]`（hunger 驅動 → 與覓食撞、且 FLEE 對 hunger 是錯反應）。改：
- `survival` option 改用 **`threat_pressure` term**（新，`ctx.threat` 驅動；threat 目前 0=dormant，他域遷入補）→ survival(FLEE) 暫休眠（無誤觸）。
- **hunger 反應 = 覓食(forage)/返家補給(home)**，非 FLEE。
- 新 term `threat_pressure` eval = `ctx.threat`（0..），weight 複用 survival_pressure(1.0)。

> argmax tie 註：覓食 與其他同 util 時，REGISTRY 順序覓食在前 + strict `>` → 覓食贏 tie（hunger 無家 → 覓食，正確）。

### 4. 覓食 to_task 接真覓食格 — `options.gd`
現 `覓食 → TASK_FORAGE, target=team.move_target`（無效）。改 `target = FactionAISystem.new()._find_forage_tile(state, team)`（現成 helper，回最多 wild_game 鄰格）。無覓食格→(-1,-1)→ to_task 回不強設（沿用現有 (-1,-1) 保護）。

## 切片邊界（僅 unified 隊；非 unified 原樣）

`faction_ai_system.gd` 三處：

### B1. `_evaluate_survival` 開頭跳過 unified
```
func _evaluate_survival(state, team):
    if uses_unified(team): return    # ← unified 隊求生改由引擎(下方)決，不走舊系統
    ...(舊邏輯原樣,非 unified 隊用)
```

### B2. `_assign_member_tasks` — uses_unified hoist 到 gate 前
現 781（`combat_target!=-1 or known_task!=IDLE → continue`）+ 785（survival latch）在 793 uses_unified **之前** → unified 隊非 IDLE/survival 永到不了引擎。改：保留 combat 檢查，**uses_unified 提到 known_task/survival gate 前**：
```
if mt.combat_target != -1: continue          # 戰鬥覆蓋(全隊)
if not mt.player_commanded_task.is_empty(): continue   # 玩家(全隊)
if uses_unified(mt):                          # ← hoist:引擎每 cadence 重評(無 survival latch)
    _decide_unified(state, mt); continue
# 以下非 unified 隊原樣：known_task IDLE gate / survival latch / 舊派工
if mt.combat_target != -1 or known_task != TeamData.TASK_IDLE: continue
... (785 latch 等原樣,僅非 unified 隊到達)
```
（785 latch 的 `g1.merchant_survival` 探針：unified 隊已不到此 → 改在引擎側補常態探針，見驗收。）

### B3. `_evaluate_solo` — uses_unified hoist 到 IDLE gate 前
現 1001（`current_task!=IDLE and not _is_stuck → return`）在 1006 uses_unified 前。改：
```
if team.leader_id == state.player_id: return
if team.combat_target != -1: return
var leader_p = state.persons.get(team.leader_id); if leader_p == null: return
if uses_unified(team):                         # ← hoist 到 IDLE gate 前
    _decide_unified(state, team); return
if team.current_task != TeamData.TASK_IDLE and not _is_stuck(team): return   # 非 unified 原樣
...
```

→ unified 隊：無舊 survival、無 latch、引擎每 cadence 單一決策（survival term 量級支配時自然贏，COMMITMENT_BONUS 防抖）。非 unified 隊：舊 survival+latch+派工**完全原樣**（切片邊界、零影響）。

## believability（守藍圖護欄）

- **危時 survival 量級支配**（餓→停貿易）：food<2.5 survival_pressure≥2.0 碾壓 trade；不靠 latch。
- **不過早**：food≥3 survival_pressure=0、restock ~food 4 才起 → 商隊多數時候貿易（沒崩 mush）。
- **有家回家/無家覓食**：restock vs forage 交叉設計。
- survival(FLEE) 改威脅驅動 → hunger 不再誤 FLEE。
- 富野心商隊仍能蓋城（建設 option 在桌，sub-proj A/裁定）= 湧現角色轉換不受影響。

## 切片缺口（接受,後續塊補進引擎）

unified 隊暫失舊 survival 的 **loot/join/camp/beg/hunt**（難民/掠奪行為）→ 危機走 覓食/返家補給/建設(bootstrap,生產隊)。完整遷移（這些變 engine option + 全隊 + 退役舊 `_evaluate_survival`）= 後續框架塊。非 unified 隊仍有全套舊 survival。

## 驗收

- **履約脫 0（主目標）**：world_sim `g1.order_fulfilled > 0`、`[Market]成交` 常態、`merchant_survival`(或新探針)大降、商隊「貿易↔返家補給」迴路（trace carried 週期回補、不再 drift 餓死）、`restock_chosen > 0`。
- **believability**：商隊 task 分布貿易占多數（無 mush）；危時（food<2.5）商隊不貿易走覓食/返家補給（反例單測 + trace）；有無商隊湧現蓋城。
- **非 unified 隊 survival 不變**：既有 survival/飢荒/絕境測全綠（真絕境隊仍正確進/留 survival、camp/beg/loot 路徑非 unified 隊照走）。
- **回歸**：TC1/4/6/7 原樣全綠（survival_pressure 重標度只在 food<3 起，TC 用糧足隊 → 0 影響）、sub-proj A 測綠、headless 全綠、coin_eq=0、InvariantAudit 0。

## 檔案

- `scripts/simulation/decision/terms.gd`：`survival_pressure` 重標度、`restock_need` 重標度、新 `threat_pressure` term。
- `scripts/simulation/decision/options.gd`：`survival` REGISTRY 改 `threat_pressure`、`覓食` to_task 接 `_find_forage_tile`。
- `scripts/simulation/decision/decision_context.gd`：（`threat` 欄位已存在=0；確認 `_find_forage_tile` 可從 options 呼叫）。
- `scripts/simulation/faction_ai_system.gd`：B1（_evaluate_survival 跳 unified）、B2（member uses_unified hoist）、B3（solo uses_unified hoist）。
- `scripts/debug/headless_test.gd`：新測（糧危商隊 survival_pressure 碾壓 trade→選覓食/返家補給；food≥3→選貿易；有家→返家補給 vs 無家→覓食；非 unified 隊舊 survival 不變）。
- `scripts/debug/probe_stats.gd` / 引擎側：加 `g1.restock_chosen` 常態探針（Probe taxonomy = systems owner）。
- world_sim 驗收。

## 風險 + 緩解

- **rescale 曲線值**：全 TEST VALUE，已驗算（trade 域 0.5-1.5 vs survival 危時 ≥2-12）。world_sim 量測 restock_chosen>0 + 貿易占多數 + 危時不貿易，異常再調係數（4.0/1.5）。
- **退 latch 致 unified 隊 thrash**：COMMITMENT_BONUS + survival_pressure 在 food≥3=0（過渡帶不抖）；world_sim 驗無高頻 survival↔trade 跳。
- **覓食無格**：`_find_forage_tile` 回 (-1,-1) → to_task 不強設 → 退而求其次（argmax 次選/IDLE）；真絕境靠後續塊 camp/beg（缺口已標）。
- **survival(FLEE) 休眠**：threat=0 → 威脅應對暫缺 for unified 隊（他域遷入補 threat term）；糧危走覓食/返家補給已覆蓋主因。
- **不碰守恆**：只改決策面（term/option/派工路由）+ return_home/forage 走既有守恆移動。coin_eq/InvariantAudit 無關。
- **非 unified 隊**：三邊界改皆 `if uses_unified` 短路，非 unified 路徑零改 → 零影響（回歸驗）。

## 開放細節（plan 階段定）

- rescale 係數初值（survival_pressure 4.0 / restock_need 1.5 / WARNING 3 硬編 or 引用 const）→ 建議 terms.gd 內 const + 註明對齊 faction_ai WARNING/URGENCY。
- `g1.restock_chosen`/`g1.engine_survival` 探針打點位置（`_decide_unified` 或 to_task）。
- `_find_forage_tile` 從 options.to_task 呼叫（`FactionAISystem.new()._find_forage_tile`）的簽名確認。
- B2 重構：保留原 781 對非 unified 的 `known_task!=IDLE` 語意（snapshot-based），僅 unified 短路提前。
