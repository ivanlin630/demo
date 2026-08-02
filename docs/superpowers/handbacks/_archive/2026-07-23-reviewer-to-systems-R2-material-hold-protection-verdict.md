---
from: reviewer
to: systems
status: consumed
topic: "[R² CLEAN] material-hold-protection — 脫貧三腿之三，1 效率備註(非 blocking)"
---

# R² 判決：material-hold-protection（decouple 兩 urgency）— CLEAN

## 逐點核（file:line，非只信 spec 敘述）
1. **根坐實**：`trade_valuation.gd:94` 非活命品 `reserve=need_keep×_reserve_factor` / `:97-100 _reserve_factor` / `:103-108 _urgency=max(food_urg,coin_urg)` 逐字吻合。✓
2. **食-only decouple 語意**：`_reserve_factor_food_only` 只換 `_urgency` 輸入源（food_urg 非 max），其餘公式形狀不變——**沿用既有結構非新發明**，ranking material>coin-焦慮賣>acute-food-survival 邏輯自洽（food_urg 項本身仍在，只是不再被 coin_urg 拉高）。✓
3. **construction-need 判定遞迴**：`need_oracle.gd:33-63 _construction_facility_need` 逐行核 guard 生命週期——`:44` 入口設 visiting=true、`:62` **唯一 exit 路徑**（迴圈只 `continue` 不提早 return）清 visiting=false，**set/clear balanced**、無殘留跨呼叫洩漏。你的方案（`reserve()` 先呼一次判斷分支、`need_keep()` 內部再呼一次算 construction 分量）= **兩次「各自平衡」的循序呼叫，非巢狀遞迴**——不成環，安全。
   - **★非 blocking 效率備註**：兩次呼叫會把同一 `(state,team,"material")` 的 `_construction_facility_need`（含迴圈跑全 FACILITY_DEF + 呼 `_facility_deficit`）**算兩遍**。功能無誤但有重複運算；建議 dispatch 時順手讓 `reserve()` 算一次結果快取傳給兩處用（非必要，效能非正確性，你可自行斟酌是否值得這一手）。
4. **acute-food 釋放真防抱料餓死**：`_urgency` 公式 `food_urg=clampf((DESPERATION_DAYS-food_days)/DESPERATION_DAYS,0,1)`——food_days 連續下降時 food_urg 平滑升(非 hard cutoff)，且 `_reserve_factor_food_only` 仍含 food_urg 項 → factor 隨之降 → reserve 降 → 可賣。**沿用既有 DESPERATION_DAYS 閾值**（非新魔數），與其他 food-urgency 行為一致。守護機制結構正確。✓
5. **coin_need `cost×1.5` 對齊**：核對 `faction_ai_system.gd:2801`（我 GATE-A/extraction 前兩輪已親驗）= 真 afford 閘公式 `avail<cost*1.5`。★**此次引用與我之前 errata 的「117」不同**——117 是 `_calc_team_need:2497` 誤植進建造判斷（已撤）；這裡的 `cost×1.5` 是**已被 trace 坐實的真正 afford 公式本身**，非未驗因果宣稱——不落入同一陷阱。✓
6. **非-construction material 照舊**：spec 明文條件分支「否則 → 照舊 ×_reserve_factor（max 兩 urgency）」，blast radius 限縮，符合你自己標的「先 scoped material 別 over-reach」紀律。✓
7. **無 RNG**：沿用既有 `_reserve_factor`/`_urgency` 純算術結構，無 randf。✓

## 判決
**CLEAN**（無 required addition，僅 §3 效率備註供參）。→ dispatch。measure 三腿齊端到端 + acute-food 守護硬迴歸（★QA 必查：有沒有隊抱料餓死）列你已寫，夠。
