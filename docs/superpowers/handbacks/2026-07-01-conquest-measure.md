# Hand Back: 征服名vs實 measure（measure-first）

> branch `feat/conquest-measure`（未 merge）。spec `2026-07-01-conquest-name-vs-deed-measure-design.md` / plan 同名。
> 純觀測、零行為變。**修不在本 plan**——修向據下數據另定。

## 實作摘要
- `scripts/simulation/decision/decision_engine.gd`：抽 `rank_scored()`（帶 util 的 scored 陣列），`rank()` 委派之。零行為變（rank 回傳不變）。探針藉此讀 util 排序根。
- `scripts/simulation/faction_ai_system.gd`：
  - `_decide_unified`：改迭代 `rank_scored`；solo_intent=征服 隊記 `conq.intent` + winner 分類（`conq.winner_loot/prosperity/other/none`）+ `_probe_conq_winner` util note。
  - `_evaluate_independent_strategy`：宣告征服 intent 時記 `conq.declared` + `conq.declared_unified/nonunified`（分流診斷）。
  - `_evaluate_solo`（**舊非-unified solo path**）：solo_intent=征服 隊記 `conq.intent` + winner 分類（TASK_LOOT vs TASK_ATTACK）+ `conq.loot_lead` note。← 埋此處是量測中途發現的必要修正（見下）。
  - `_evaluate_prosperity_attack`：成功 dispatch TASK_ATTACK 時記 `conq.prosperity_reached`。
- `scripts/simulation/npc_combat_system.gd`：capture 兩點（`absorb_as_captive`/`capture_wounded_as_captive`）加 `_probe_capture_by_task`，按勝方 task 歸因（`loot.achieved_capture` vs `capture.by_attack` vs `capture.by_other`）。
- `scripts/debug/conquest_measure.gd`（新）：warring seed（好戰/野心 boost 獨立隊）跑 60 天，讀 conq.*/capture.* 分布。
- `scripts/debug/probe_stats.gd`：summary 加征服 intent winner 分布 + 掠奪達 capture 率衍生行。

**與 spec 差異**：spec/plan 只列 `_decide_unified` 為埋點落點。量測揭其對征服隊 = 空集（見下），故**加埋舊 `_evaluate_solo` path**——非發明新規則，是把探針放到真正的決策路徑（spec 意圖 = 量「征服 intent 隊實際做什麼」，落點跟著真相走）。

## 驗收
- headless_test：`=== DONE ===`、無 SCRIPT ERROR、全 conservation OK、coin_eq 綠。唯一 `[FAIL] 弱目標未加入攻擊 goal` = **pre-existing**（clean main 同樣 FAIL，非本軌）。
- 零行為變：所有埋點 `if Probe.enabled` gate，headless（Probe 關）行為與 main 逐字相同。

## 量測數據（warring seed，60 天，14400 tick；unseeded → 絕對數有 drift，比例/結構穩定）

```
conq.declared              = 1722    # 征服 intent 宣告次數（_evaluate_independent_strategy）
conq.declared_unified      = 0       # ★ 其中走 _decide_unified 的 = 0
conq.declared_nonunified   = 1722    # ★ 100% 非 unified
conq.intent                = 251     # 舊 solo path 見 solo_intent=征服 的決策事件
  conq.winner_loot         = 6       #   → 掠奪  2.4%
  conq.winner_prosperity   = 243     #   → 攻擊 96.8%   (TASK_ATTACK)
  conq.winner_other        = 2       #   → 其他  0.8%
conq.prosperity_reached    = 2       # scout-gated prosperity-attack 真正 dispatch
capture.total              = 1       # 全世界 capture 事件
  loot.achieved_capture    = 0       #   掠奪達 capture = 0
  capture.by_attack        = 1       #   攻擊達 capture = 1
conq.loot_lead      peak   = 0.173   # 掠奪領先攻擊的最大 util 幅（舊 solo 計分）
```

## 名實斷點分析（★ 首燒假設證偽）

**首燒 handback 假設**：「_decide_unified 掠奪 option 搶在 prosperity-attack 前 → winner=掠奪」。**數據不支持**：

1. **征服 intent 隊 100% 非 unified**（`uses_unified` = MERCHANT/PRODUCE tag）→ `_decide_unified` 對它們**根本不執行**（`conq.declared_unified=0`）。首燒假設的斷點位置對征服隊 = 空集。好戰征服隊走**舊 `_evaluate_solo` 計分 path**。

2. **舊 solo path 掠奪並未搶排序**：征服 intent 隊 winner 96.8% = **TASK_ATTACK**（征服手段），掠奪僅 2.4%。「想=征服 做=掠奪」在此 seed **不成立**——想征服的隊確實選了攻擊。

3. **真斷點 = 攻擊→征服(capture) 的轉化率**：243 次攻擊決策 → 僅 1 capture、2 次 prosperity-attack。TASK_ATTACK（舊 solo：打 `_nearest_independent`，**無 scout-gate、無 archetype/rung gate**）大量觸發，但幾乎不導向 capture/吸收/subjugate 的真征服鏈。且它 @PRIO_DISPATCH **搶在** scout-gated prosperity-attack 前（後者只跑到 2 次）——**兩條攻擊路徑並存，粗的那條淹沒了設計好的那條**。

**斷點級別**：名實斷點**不在 option 排序**（loot vs prosperity），在**攻擊實作分裂**——
- 「征服」intent 由**兩條不同 TASK_ATTACK** 承接：舊 solo 的粗攻擊（nearest-indep、無 gate）vs `_evaluate_prosperity_attack` 的細征服（weakest-prey、scout-gated、導向 subjugate）。
- 粗攻擊優先觸發且極少轉化 → 「想征服的隊在打，但打不成征服者」。

## 修向建議（數據支持哪個）

按「掠奪降權 / prosperity 優先 / 掠奪 escalate capture」三選項，**數據皆不直接命中**（因掠奪非元兇）。真修向：

1. **[數據首選] 統一征服攻擊路徑**：非 unified 好戰隊的 `_evaluate_solo` TASK_ATTACK 應**委派到 `_evaluate_prosperity_attack`**（或共用其 weakest-prey + scout-gate + subjugate 導向），而非自走 nearest-indep 粗攻擊。消除「兩條攻擊路徑」分裂，讓征服 intent 收斂到會 capture 的那條。← 直接對症 243→1 轉化崩。
2. **[次選] 攻擊→capture 轉化診斷**：capture.total 相對戰鬥量（g2.feud_formed 數百）極低，可能 absorb_as_captive 條件（敗方殘 anon>0）在多數戰鬥後不成立，或戰鬥多以 draw/retreat 收場。需再一輪 measure（戰鬥結局分布）確認轉化崩在「打不贏」還是「贏了不吸收」——**建議另 spec**。
3. **不建議**：掠奪降權/escalate——掠奪在征服隊僅 2.4% winner、0 capture，非名實斷點主因，動它是打錯靶。

**併發統一矩陣視角**：此為「攻擊」領域的實作分裂（同一 named 意圖多條未統一手段）→ 對齊 [[project_unification_matrix]] / 「凡 named 意圖必有可解釋驅動」但**手段須收斂到有效 affordance**。

## 連動風險
- `decision_engine.gd`：`rank()` 重構為委派 `rank_scored()`。行為逐字不變（headless 全綠），但 `rank_scored` 現為 public API——若他處誤用需注意。低風險。
- `_evaluate_solo` / `_decide_unified` 埋點：純 Probe-gated no-op，Probe 關時零影響。無連動。
- npc_combat capture 埋點：純觀測，不改守恆/戰鬥結算。無連動。
- **並行**：本軌只碰 faction_ai(_decide_unified/_evaluate_solo/_evaluate_independent_strategy/_evaluate_prosperity_attack 埋點)+npc_combat(capture 埋點)+decision_engine(rank 重構)+probe+新 harness。與單寫者(roster 寫)/B 食物(resource_system) 不同函數，merge 序解。**注意** decision_engine.rank 重構若與他軌同檔改動需 review。

## 待主 session 確認
- **修向決策**：採建議 1（統一攻擊路徑）還是先跑建議 2（戰鬥結局診斷）再定？修另開 spec。
- **首燒假設更新**：首燒 handback「_decide_unified 掠奪搶排序」結論應據本量測修正（斷點在攻擊路徑分裂，非 option 排序）。
- **conquest_measure.gd 去留**：診斷 harness，留作回歸/後續修驗證，或修完即刪？
- **好戰 boost 佈局**：harness 對獨立隊 leader 拉高好戰/野心（authored premise，不改世界模型）以確保征服 intent 有量。若要純 default 分布再量，可去 boost（但征服 intent 樣本會更稀）。
