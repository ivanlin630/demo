# L3 循環貿易 — HOW（systems，實作設計）

status: DRAFT → reviewer R²
owner: systems（HOW）；WHAT=`2026-08-05-L3-circuit-trade-design.md`（blueprint LOCKED、R① CLEAN）
date: 2026-08-05
branch: 新 slice `feat/L3-circuit-trade`（off 更新後 main，含核心 arc merge）

## 目標（承 WHAT）
讓「去外市集看看」成為 genuine 決策 → 遠距跨勢力商路湧現。**升級既有 fallback 路、非蓋平行機制**（R① HOW 約束）。

## Seam（親驗 file:line、2026-08-05 merged main）
- `faction_ai:2563 _merchant_trade_target` → 無 arb 時呼 `:2578 _nearest_market_outpost`（**naive：永遠揀最近 known、零 staleness/util 秤、零人格**）。
- `options.gd:19 "貿易".applicable = ctx.has_goods or ctx.has_arb`（**擋 settled 純產隊：無貨無 arb→進不去**）。
- `team_market_known` belief store（`faction_ai:2580`，Dict[tile_id]→true）+ `_harvest_market_known:2619`（三源：創世/親見 vision/relay，belief-gate、非全圖）。
- `read_market_board`（order_system:194）＝到場 firsthand 讀板（既有、對、不改）。
- 主 argmax：`貿易` option `to_task=TASK_TRADE`、target=市集 pos（body 移動=主任務、非 side-action）。

## 設計（三塊、皆升級既有）

### 塊①：market visit-util（升 `_nearest_market_outpost` naive→genuine util）
新 `_best_market_target(state, team) -> Vector2i`（取代 `_merchant_trade_target:2570` 對 naive 的呼叫；naive helper 保留給買料 caller `_nearest_market_outpost_with` 不動）。對每個 belief-known 市集 outpost 算 visit-util，argmax：
```
visit_util(mkt) =
    W_ARB    * arb_expectation(mkt)      # 已聽聞該市集 buy/sell 單的兌現期望(belief,非 god-view live stock)
  + W_STALE  * staleness_norm(mkt)       # 板資訊多舊(越久沒 firsthand 讀→越高=資訊價值/探索)
  - W_TRIP   * trip_cost(dist)           # 路程 hex dist / 移速 → 天數成本
  ,  再 × 人格 modulate                    # 重商archetype↑ / 膽小(慎重高)遠程折扣↑ / 懶(野心低?)整體↓
```
- **staleness 源＝新 `team_market_last_read: Dictionary`**（Dict[team_id]→Dict[tile_id]→last_firsthand_read_tick）。`read_market_board` 到場 firsthand 讀時 stamp `current_tick`。未讀過的 known 市集＝last_read 缺→staleness MAX（＝「探索未知」自然高分：聽過(relay 入 known)但沒 firsthand 讀過的遠方市集，資訊價值最高）。**零 god-view**（staleness 是「我多久沒親眼看」自我記憶、非市集真實狀態）。
- **arb_expectation**：reuse `OrderSystem.best_arbitrage_order` 已算的 heard-order 兌現值（belief received orders、非 god-view），無則 0。
- **人格 modulate（非死常數、MODULATE 真 util）**：`W_TRIP` 乘 `(0.5+慎重)` 類（膽小遠程成本感高→只跑近）；整體乘 archetype 係數（TRADE archetype↑）；genuine＝路程/套利是真值、人格調權重非發明分數（[[feedback_genuine_value_not_crank]]）。
- 確定性：純 util 算術、零新 randf（同既有 helper）。

### 塊②：放寬 applicability（`options.gd:19`，settled 產隊進得去）
`貿易.applicable = has_goods or has_arb` → `has_goods or has_arb or has_market_visit_value`。
- `has_market_visit_value`（新 ctx 欄，decision_context 算）= 存在 belief-known 市集且其 best visit_util > 0（有值得跑的市集：staleness 高或聽聞 arb）。
- ∴ settled 純產隊（無貨無 arb 但有陳舊 known 市集/聽聞遠方單）→ 進得去 → 主 argmax 秤 visit_util vs 其他 option（若在地生產更值→不跑=人格/情境自然結果、非強迫巡邏）。

### 塊③：資訊帶回（既有機制、確認不新建）
到場 `read_market_board` firsthand 讀板 → 板況入 belief + 隨身 carrier 傳播（既有）。**商人自然成資訊血管**——無需新 code、確認 stamp last_read + belief 更新走既有路即可。

## 守（憲法/感知鐵律）
- **零 god-view**：市集 pos 只從 `team_market_known` belief（三源）；visit-util 讀 belief（staleness=自我 last_read 記憶、arb=heard orders），**禁讀市集 live public_storage 真值秤 util**（到場 firsthand 才知真貨）。constitution gate 綠（無新 gv_mapscan/gv_teamstate）。
- **湧現非 script**：無 waypoint 清單、無巡邏 loop；「巡迴」是 staleness↑→visit_util↑ 的湧現 pattern。
- **人格非死常數**：訪市傾向＝util 人格加權、零「每 N tick 必訪」門檻。
- **禁平行機制**：升級 `_merchant_trade_target` 目標選擇 + option applicability，**不新建「訪市」step/REGISTRY**（≠side-action 家族，訪市走主 argmax body 移動）。
- keep-line 戰略儲備守（只賣真剩餘、既有 TradeValuation.reserve 不改）；貨/資訊全物理走。
- determinism byte-identical（純 util、零新 RNG）。

## TDD 驗收（implementer）
1. **visit-util 人格分化**：同床 TRADE archetype 隊 visit_util 高/膽小(慎重高)隊遠市集折扣→目標不同（RED：人格 modulate neuter→齊一）。
2. **staleness 驅動**：久沒讀的市集 visit_util > 剛讀過的（RED：staleness term 移→退回 naive nearest）。
3. **settled 產隊 applicable**：無貨無 arb 但有陳舊 known 市集→`貿易` applicable=true（RED：`has_market_visit_value` 移→回 has_goods/has_arb 擋）。
4. **探索未知**：聽過(relay-known)但沒 firsthand 讀的遠方市集 staleness=MAX→高 visit_util（RED：last_read 缺 fallback 非 MAX→探索死）。
5. **感知鐵律硬驗**：visit-util 讀 belief（staleness/heard-arb）非市集 live stock；`# gate-ok` own-infra 不適用（訪的是他隊市集、必 belief）。
6. **主 argmax 不劫持**：visit_util < 在地生產 util → 不跑（湧現非強迫）。

## 量測（湧現式、measurer→QA）
- 遠距跨勢力 deal >0（多床、含 settled 經濟床、代表性 faction-rich 床）。
- **訪市 pattern 人格分化**（重商多跑遠、膽小近跑）——per-option util dump 證非齊一。
- 板 staleness 下降（資訊流通加速）。economy 不爆、determinism byte-identical。
- 長跑→QA 故事稽核（商人 motive→訪市→撮合→資訊帶回鏈、人格分化真）。

## 追蹤
- `team_market_last_read` 新 store＝全量 tap（`market.visit_util`/`market.stale_visit`/`market.settled_producer_visit`）——全量暫態可觀測性（[[feedback_full_transient_observability]]）。
- `_DAYS`/係數 calibration 錨真值（trip=真移速、staleness_norm=典型 relay 週期 DERIVED、非 fire-crank）。
