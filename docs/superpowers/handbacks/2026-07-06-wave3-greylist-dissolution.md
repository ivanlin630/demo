# Hand Back: 序8 灰項 dispatch 溶入（strategic trade_net）— ★憲法溶入 arc 末張

## 實作摘要
- `scripts/simulation/strategic_ai_system.gd` — 刪 `tick` 內 `match "trade_net": _dispatch_trade_net(...)` 分支 + `_dispatch_trade_net` 整函數（`try_set TASK_TRADE` 繞引擎＝唯一違憲）+ `_update_faction_goals` 致富→`trade_net` strategic_goal append（唯一消費者=已刪函數，一併清）。**保留** `_find_trade_partner` / `_tile_has_resident`（純查詢，無 `TaskArbiter` 呼叫＝非違憲；仍供 headless_test 覆蓋）。
- `scripts/debug/greylist_dissolution_check.gd`（新建）— 融合驗 harness：① repertoire（致富商隊 ctx→貿易/買糧/囤貨 引擎 applicable）② ★冗餘證（餓商隊+coin+市集→`_decide_unified` 派 `TASK_TRADE`）③ gap 檢（純買家承接分析）。
- `scripts/debug/headless_test.gd` — 刪 `_test_trade_net_dispatches`（測已刪函數）+ 其 `_run` 呼叫；`Faction0 strategic_goals≥1` 硬 assert 移除（致富 intent 不再產 trade_net goal→合法 0 goal，曾靠 append 保底）。
- `scripts/debug/constitution_baseline.txt` — `strategic_ai_system::_dispatch_trade_net` 指紋 removed，sites 31→30，序8 標 + **★8 known 違憲全溶完宣告**。

## ★憲法 8 違憲全溶完宣告
序1 threat / 序2 solo / 序4 vendetta / 序5 prosperity / 序6 dispatch / 序7 reaction / **序8 灰項 trade_net** 全溶入引擎（序3 rung 亦 merged）。`constitution_gate` 現鎖 30 sites，全為保留 scaffolding（world-mechanic dispatch 落點，非個體 utility 判斷器）。**arc 尾轉全掃常駐 + 撤 pre-commit（另 slice，見待辦）。**

## 融合驗 + 致富交易保證
- **冗餘證**：`_dispatch_trade_net` 6月 seed 1337 零派發（baseline `trade.dispatch.trade_net=0`）＝已死路；引擎 `ambient=32 solo=36` 承接全 trade dispatch。刪＝零漂移。
- **before/after 逐點同**（seed 1337 6月 config default）：站4 dispatch=68（ambient=32 solo=36）、`trade.deal=23`(coin=11 barter=12)、矛盾率 183/278=0.658 PASS——**貿易不歸零**，致富交易全由引擎（貿易/買糧/囤貨 option）承接。
- **greylist 融合驗 ALL PASS**：致富商隊 貿易/買糧/囤貨 引擎可達；`_decide_unified` 實派 `TASK_TRADE`。

## gap 檢結果
純買家（coin 無 goods 無 arb 致富商隊）引擎承接：
- 有市集 + 餘糧（非餓）→ **囤貨** 承接（致富+surplus+food_market applicable）。
- 有市集 + 餓 → **買糧** 承接。
- 僅「全無市場可達」（無 arb 無 food_market 無 goods）→ 無 trade option；**但此＝與 `_dispatch_trade_net` 需 outpost partner 同限**（無可達對象＝無交易），非本次刪除引入的新 gap。→ **無淨 gap，引擎 option 不需微調。**

## 回歸（全綠）
- `constitution_gate` PASS sites=30
- `framework_validation` PASS=7 DORMANT=0（★S6 `order_fulfilled=1` 不 DORMANT）
- `greylist/threat/solo/rung/vendetta/prosperity/faction_dispatch/reaction` 8 融合驗全 ALL PASS
- `headless_test` `=== DONE ===` 無 SCRIPT ERROR；seeded warring 逐點重現 49/8/1/381 零漂移
- seeded 漂移：seed 1337 trade_funnel before==after 逐點同（零漂移）

## 連動風險
- `player_command_system.gd:742` — 玩家 `set_faction_goal` 仍驗 `"trade_net"` 字串（→ `player_goal_override` → `faction_ai:932 f.goals.append`，**與 strategic_goal trade_net 正交**，未觸 strategic_ai）。本刪不影響；惟玩家設 trade_net override 現僅落 `f.goals` 字串（該路消費另議），非本 scope。**建議系統評估** player_goal_override "trade_net" 語意是否隨之調整。
- `_find_trade_partner` / `_tile_has_resident` 現為 dead-except-tests（`_dispatch_trade_net` 曾唯一 runtime caller）。保留供 3 個 headless 測 + FI handback 已標 C 類 finder god-view dedup。**建議後續** C 類 finder dedup slice 一併清。

## 待主 session 確認
- **文件更新（系統單寫者）**：`docs/progress.md:270` strategic_ai 描述仍列「trade_net handler」（已刪，factually stale）；`docs/known_issues.md` / `docs/invariants.md` 若有 trade_net dispatch 條目需反映溶解。實作未動（progress/invariants 系統 owner）。
- **★arc 尾 slice**：8 違憲全溶完 → 撤 pre-commit site-freeze 閘、轉全掃常駐（plan Global Constraints 所述「另 slice」）。
- **建議後續 task**：C 類貿易 finder dedup（`_find_trade_partner` god-view fallback vs `faction_ai._find_trade_target`）。
