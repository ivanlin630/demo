---
from: systems
to: implementer
status: open
topic: "[dispatch·produce_need demand-responsive·R² CLEAN·新 branch feat/produce-demand-responsive·製造 bootstrap 子根②] spec=2026-07-23-produce-need-demand-responsive.md。R² CLEAN(死常數人格化乾淨、感知鐵律 belief-gate 親驗守、cold-start 不餓死、無 RNG)。off main(已 merge tools-demand 9c551c06 後)。2 修:①decision_context.gd gather 加 c.produce_pull=隊自家可造 outputs(tile facility level>0 的 RECIPE_GROUPS)的 worst shortfall ratio: clampf((NeedOracle.need_keep(out)+NeedOracle.demand(out)-holding)/target,0,1) 取 max;僅 has_manufacturing_facility 算否則 0;holding 對齊 manufacturing target(team.resources+public_storage)②terms.gd:103-105 produce_need→return ctx.produce_pull(opt≠生產→0)。★感知鐵律:demand()走既有 _trade_demand 讀 team_known 親聞單(勿繞 global)。加 tap produce.wanted_not_chosen(produce_pull>THRESH 但落選)。TDD 5(★⑤god-view fixture:他隊有單但本隊沒聽到→produce_pull 不含;①聽到 tools 單→高;②無需無市場→0;③無 facility→0;④term=ctx.produce_pull)。gate/headless 0new/determinism 2跑 byte-identical(無 RNG)。★★measure(→measurer §④b+specimen→QA 長跑):manufacture.* probe 0→?/選 TASK_MANUFACTURE 隊數/tools+goods 產量 0→?/produce_pull 分布+wanted_not_chosen/weaponsmith 建成(②解後通 or 揭子根①傳播)/回歸 doom+無餓死+goods 不亂產。做完→to:measurer(→QA 判故事:聽到好賣→produce_pull 升→選生產→產 tools→進市場;civ 沒聽到=揭①傳播)。task=systems+reviewer(merge-gate R²)。"
branch: feat/produce-demand-responsive
---

# dispatch：produce_need demand-responsive（製造 bootstrap 子根②·死常數人格化）

spec：`docs/superpowers/specs/2026-07-23-produce-need-demand-responsive.md`。**R² CLEAN**（`2026-07-23-reviewer-to-systems-R2-produce-demand-responsive-verdict.md`）：死常數人格化乾淨、感知鐵律 belief-gate 親驗守（`_trade_demand:153` 讀本隊 team_known 親聞單）、cold-start 不餓死（own-need baseline 撐）、無 RNG。

## ★ branch
- **新 branch `feat/produce-demand-responsive`**，off **main（已 merge tools-demand 9c551c06 後）**——先確認 base 是 merge 後 main（含 tools-demand+cost70）。

## 2 修
### ① `decision_context.gd` gather：加 `c.produce_pull`（belief demand-responsive，mirror material_shortfall 範式）
- 僅 `has_manufacturing_facility` 時算（否則 `0.0`）。
- worst shortfall ratio over 隊自家可造 outputs：
  ```gdscript
  # tile = 隊自家 outpost；for level_key in ManufacturingSystem.RECIPE_GROUPS where int(tile.get(level_key))>0:
  #   for recipe in RECIPE_GROUPS[level_key]: out = recipe["out"]
  #     target = NeedOracle.need_keep(state,team,out,lv) + NeedOracle.demand(state,team,out,lv)  # 自用+★belief 親聞買單
  #     if target <= 0.001: continue
  #     hold = team.resources.get(out,0) + tile.public_storage.get(out,0)   # 對齊 manufacturing:139 target
  #     best = maxf(best, clampf((target - hold)/target, 0.0, 1.0))
  # c.produce_pull = best
  ```
- **★感知鐵律**：`NeedOracle.demand()` = `_trade_demand` 讀 `team_known` 親聞單（勿改讀 global order book）。

### ② `terms.gd:103-105 produce_need`：死常數 → `ctx.produce_pull`
```gdscript
"produce_need":
    if opt != "生產": return 0.0
    return ctx.produce_pull
```

### 觀測
- 加 tap `produce.wanted_not_chosen`（`produce_pull > THRESH` 但 rank 落選 → 想產但輸 task-competition，供 QA 判 ② 後是否仍卡）。保留既有 `produce.appl_kill_nofacility`。

## TDD（5）
①有 workshop + 聽到 tools 買單(demand(tools)大)→ produce_pull 高(≈1) ②有 workshop + 無需 + 無市場 → produce_pull=0 ③無 manufacturing facility → produce_pull=0(生產 not applicable 不變) ④produce_need term = ctx.produce_pull(opt≠生產→0) ⑤**★god-view fixture**：他隊有 tools 買單但本隊 team_known 沒聽到 → produce_pull **不含**(感知鐵律硬驗)。

## 閘 + measure
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG；ambition=leader_values 非 randf）。
- **★★measure（→measurer，§④b samples + specimen → QA，長跑）**：`manufacture.*` probe 出現數（0→?）/ 選 TASK_MANUFACTURE 隊數 / tools+goods 全域產量（0→?）/ produce_pull 分布 + `wanted_not_chosen` / **weaponsmith 建成**（②解後、有 workshop 就通 or 揭子根①傳播是下閘）/ 回歸 doom-delta + 無餓死 + **goods 不亂產**（無人要時 produce_pull=0 驗）。

## 完成判定 = systems + reviewer（merge-gate R²）。做完 → to:measurer（→QA 判故事：workshop owner 聽到 tools 好賣 → produce_pull 升 → 選生產 → 產 tools → 進市場 coherent；若 civ 沒聽到 tools 單[produce_pull=0] = 揭子根①傳播，下 thread）。**v2b(coin) 續 DEFER**。
