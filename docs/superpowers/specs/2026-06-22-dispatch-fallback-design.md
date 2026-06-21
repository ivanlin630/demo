# 引擎 dispatch-fallback — argmax 退次佳可派 option（修凍死缺口）

> 承統一隊 survival 切片（merge `b57c79c`，履約脫 0）。修其 believability 缺口（標記 2 stuck）。
> 藍圖 believability 守則：危時 survival 該贏（量級已保證）；無家危機隊須 believably 退化（持續嘗試/餓死 OK，**別卡 stuck/鬼打牆**）。

## 病（measure-first 子 session 確認）

`_decide_unified`：`DecisionEngine.decide` argmax 出單一 option → `to_task` → 若 target 無效（`(-1,-1)` 且非 FLEE）→ **`return` 不設 task、不退選**。

深危 unified 經濟隊：`survival_pressure(覓食)` 量級壓過其他 → argmax 選 **覓食** → 但 `_find_forage_tile` 腳下/鄰格無 wild_game → target `(-1,-1)` → `_decide_unified` 放棄 → **current_task 凍在前一個**（trace：生產村 T3 凍 `建設` ~25 famine 日不動）→ 餓死。返家補給/建設雖**可派**卻因 util 較低被 argmax 蓋掉、又無 fallback。

= 引擎健壯性 bug：**argmax 選了「不可派」option 就整個放棄**，而非退而求其次可派者。違藍圖標記 2（凍死=鬼打牆）。

## 修：argmax 退次佳「可派」option（general，非特例）

引擎決策應選**最高 util 的「可派」option**，非「最高 util option，不可派就放棄」。

### 1. `DecisionEngine.rank(state, team) -> Array`（新）
回 applicable options **依 util 降序排列**（含 current_option 承諾 bonus）。純函式（不寫 current_option）。
```
rank(state, team):
    ctx = gather
    scored = []
    for opt in applicable(ctx):
        u = Σ weight(tw[1], ctx.leader_values) × eval(tw[0], ctx, opt)
        if opt == team.current_option: u += COMMITMENT_BONUS
        scored.append([u, opt])
    scored.sort (u 降序)
    return [opt for _,opt in scored]
```

### 2. `DecisionEngine.decide` 改用 rank（向後相容）
`decide` 維持簽名（回 best、設 current_option），實作 = `rank()[0]`：
```
decide(state, team):
    var r = rank(state, team)
    if r.is_empty(): return team.current_option
    team.current_option = r[0]
    return r[0]
```
（既有測試呼叫 decide → 行為不變：仍回最高 util。）

### 3. `_decide_unified` 退次佳可派
```
_decide_unified(state, team):
    for opt in DecisionEngine.rank(state, team):
        var td = DecisionOptions.to_task(state, team, opt)
        var tgt = td["target"]
        if tgt == Vector2i(-1,-1) and td["task"] != TeamData.TASK_FLEE:
            continue                      # 不可派 → 試次佳
        team.current_option = opt          # 承諾追蹤實際派出的 option
        [探針 restock_chosen/engine_survival]
        TaskArbiter.try_set(state, team, td["task"], tgt, PRIO_DISPATCH, "unified")
        return
    # 全不可派 → 保持現行(no-op)
```

## 效果（believable 退化，滿足標記 2）

- **有家深危隊**：覓食(無格)跳過 → 返家補給（util 次高、target=家有效）→ 回家補糧。✓
- **無家深危隊**：覓食(無格)跳過 → 次高可派（建設 target=tile_pos 恆可派=就地紮營-ish／或貿易=移動找機會）→ **不凍死、持續嘗試**（最終餓死=believable，符標記 2「持續嘗試/餓死 OK」）。✓
- **承諾追蹤實際派出**：current_option = 真派出的 option → 下 tick 承諾 bonus 給它（穩定、防抖）。

> 註：無家危機隊「理想」走 camp/beg（建食物源）= 藍圖標記 1 的經濟隊債（loot/join/camp/beg 還經濟隊），框架完成塊補。本塊只保證**不凍死**（標記 2），不補完整難民行為。

## believability（守藍圖）

- survival 量級支配不變（危時 survival-class option 仍 util 最高、優先嘗試）。
- 退次佳只在最高 util option 不可派時發生 → 不影響正常決策。
- 危時不會退到「明顯不該」：survival-class（覓食/返家補給）util 在危時最高 → 優先；退到貿易/建設僅當前述皆不可派（無格+無家）= 移動找機會，非凍死，符標記 2。

## 範圍邊界 / 非本塊

- loot/join/camp/beg 還經濟隊 = 藍圖標記 1 債，框架完成塊。
- is_merchant 硬 gate → 權重、舊 survival 全隊退役 = 框架完成塊。
- 不碰 survival term 量級（已調好）、不碰守恆。

## 驗收

- **無凍死**：world_sim trace 先前凍死的 unified 經濟隊（如無家生產村）→ 不再同格同 task 凍 ~25 日；task 隨情境切換（移動/回家/建設）。標記 2 達標。
- **履約不退**：`order_fulfilled` ≥ 切片後值（5）、`restock_chosen` 維持、成交常態。
- **回歸**：TC1/4/6/7 原樣（decide 行為不變=rank[0]）、survival magnitude/boundary 測綠、既有 survival/飢荒測綠、headless 全綠、coin_eq=0、InvariantAudit 0。
- **單測**：argmax 最高 util option 不可派（如覓食無格）→ `_decide_unified` 退次佳可派（返家補給/建設）、不留前 task；`rank` 回降序、`decide`=rank[0] 不變。

## 檔案

- `scripts/simulation/decision/decision_engine.gd`：加 `rank`、`decide` 改用 rank。
- `scripts/simulation/faction_ai_system.gd`：`_decide_unified` 改退次佳可派迴圈（探針保留）。
- `scripts/debug/headless_test.gd`：新測（rank 降序 / decide=rank[0] / _decide_unified 覓食無格退返家補給或建設、不凍）。
- world_sim 驗無凍死。

## 風險 + 緩解

- **退次佳致貿易在危時被選（無家無格）**：survival-class util 危時最高、優先嘗試；僅皆不可派才退貿易/建設=移動非凍死，符標記 2（理想 camp/beg 屬債）。world_sim 量無家隊不凍即可。
- **承諾追蹤改動致抖**：current_option=實際派出 → 承諾穩定；world_sim 驗無高頻跳。
- **decide 改用 rank 致回歸**：decide 仍回最高 util（rank[0]）、設 current_option → TC/既有測行為不變（驗）。
- **不碰守恆**：純決策面。coin_eq/InvariantAudit 無關。

## 開放細節（plan 定）

- `rank` 排序穩定性（util 相等時 REGISTRY 順序 → 沿用 applicable 順序，與現 argmax strict `>` 首勝一致）。
- 探針位置（rank 迴圈內實際派出時 bump）。
