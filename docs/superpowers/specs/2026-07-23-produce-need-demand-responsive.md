# spec：produce_need demand-responsive（製造 bootstrap 子根②·死常數人格化）

> 層級：L3（1 term + 1 ctx 欄，決策模型 measure-sensitive）。off main（tools-demand merge 後；檔案 terms.gd+decision_context.gd 與 tools-demand[need_oracle/order_system/outpost] 無交集，亦可並行）。
> 來源：arc 收斂 workshop 供給側（`2026-07-23-blueprint-...-production-rate-WHAT` + `...-producedemand-fix-confirmed-proceed`）。blueprint 認可 locus + belief-aggregate 實作 + 攻序②先。
> ★本刀 = **子根②（已建 workshop 不產）**。子根①（workshop 建少）/apothecary crowding/傳播時序 = 後續 thread（measure ② 後定）。

## 根（file:line 坐實）
- 生產只在 `manufacturing:67` `current_task==TASK_MANUFACTURE` 跑；`options:28-38`「生產」applicable 需 facility，util = terms `produce_need`（weight settle）+ `ambition_drive`。
- **`terms.gd:103-105 produce_need` = 死常數**：
  ```gdscript
  "produce_need":
      if opt != "生產": return 0.0
      return 0.3 if ctx.has_goods else 0.6   # 只看自家 goods 存量,不讀 market demand
  ```
- → civ workshop owner 聽到 795 tools 買單，produce_need 恆 0.3-0.6，競不過貿易 → **從沒選 TASK_MANUFACTURE**（measurer「0 manufacture probe」鐵證）→ production 零觸發 → tools=0。

## 修（死常數 → belief demand-responsive）
### ① `decision_context.gd` gather：加 `c.produce_pull`（mirror material_shortfall 範式，belief-gated）
- 僅 `has_manufacturing_facility` 時算（否則 0；生產本就 not applicable）。
- `produce_pull` = 隊「自家可造 outputs」的 **worst shortfall ratio**（0-1）：
  ```
  for level_key in RECIPE_GROUPS where tile.get(level_key) > 0:
      for recipe in RECIPE_GROUPS[level_key]:
          out = recipe["out"]
          target = NeedOracle.need_keep(state,team,out,lv) + NeedOracle.demand(state,team,out,lv)  # 自用+★belief 聽到的他隊買單
          if target <= 0.001: continue
          gap_ratio = clampf((target - holding(out)) / target, 0, 1)   # 想要多少 vs 已有
          best = maxf(best, gap_ratio)   # 最缺/最好賣的 output 驅動
  produce_pull = best
  ```
- **★感知鐵律**：`demand()` = `_trade_demand` 讀 `team_known`（親聞買單），非 god-view 全域 order book。「市場好賣」= 這隊**知道**的好賣（merchant 中繼/看板傳來）。守鐵律（systems owner 明載）。
- holding = `ResourceSystem.effective_holding` 或 `team.resources`（與 manufacturing:139 target 對齊：team.resources+public_storage）。

### ② `terms.gd:103-105 produce_need`：死常數 → `ctx.produce_pull`
```gdscript
"produce_need":
    if opt != "生產": return 0.0
    return ctx.produce_pull   # belief demand+自用 gap（市場好賣 or 自缺→高；無人要+自足→0）
```
- **語意升級**：市場（聽到）+ 自用想要且自己短缺 → 高 util → 選生產；無人要 + 自足 → 0（不產無用 goods 浪費 material，比舊 0.6 baseline 亂產更對）。weight「settle」穿人格保留（生產=定居活）。
- **merchant-profit archetype（blueprint）**：produce_pull 讀 demand → 任何生產隊都對市場反應；`demand()` 內含 ambition 秤（need_oracle:157 `×(0.5+野心)`）→ 野心高更追市場產。

## ★觀測（§④b，decision-bearing）
- `produce_pull` = 決策秤 → decision trace 記 + §④b bounded sample（哪隊 produce_pull 多少、驅動 output、選中/落選）。
- 保留既有 `produce.appl_kill_nofacility` tap；**加 tap**：`produce.wanted_not_chosen`（produce_pull>THRESH 但 rank 落選 → 想產但輸競爭，供 QA 判是否 ② 後仍卡 task-competition）。

## 驗收
- **TDD**：①有 workshop + 聽到 tools 買單（demand(tools)大）→ produce_pull 高（≈1）②有 workshop + 無人要 + 自足 → produce_pull=0 ③無 manufacturing facility → produce_pull=0（生產 not applicable 不變）④produce_need term = ctx.produce_pull（opt≠生產→0）⑤感知鐵律：produce_pull 只算 team_known 親聞買單（god-view fixture：他隊有單但本隊沒聽到 → produce_pull 不含）。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG；demand ambition 秤是 leader_values 非 randf）。
- **★★measure（→measurer，§④b+specimen→QA，長跑新規則）**：manufacture.* probe 出現數（0→?）/ workshop 選 TASK_MANUFACTURE 隊數 / tools+goods 全域產量（0→?）/ produce_pull 分布 + wanted_not_chosen / **weaponsmith 建成**（②解後是否+建了 workshop 就通，or 揭子根①傳播是下個閘）/ 回歸 doom+無餓死+goods 不亂產（無人要時 produce_pull=0 驗）。
- **送 QA 判故事**：workshop owner 聽到 tools 好賣 → produce_pull 升 → 選生產 → 產 tools → 進市場 coherent；若 civ 沒聽到 tools 單（produce_pull=0）= 揭子根①傳播（下 thread）。

## 排序（blueprint 攻序②→③→①）
本刀 ②（produce_need）。measure 後：若 workshop 產了但 weaponsmith 仍卡 → ③apothecary crowding（workshop 建少）或 ①傳播（civ 沒聽到 tools 單）。R²（produce_pull 語意/normalization/感知鐵律 belief-gate/無 RNG/cold-start 無 demand 時 produce_pull=0 是否餓死製造業[需 own-need baseline 撐]）→ dispatch。
