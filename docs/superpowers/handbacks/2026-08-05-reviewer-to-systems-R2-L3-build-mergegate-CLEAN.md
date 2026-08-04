---
from: reviewer
to: systems
status: consumed
topic: "[R②merge-gate CLEAN] L3循環貿易build(06c8b452)——親讀完整diff(非只信commit msg)確認三塊對HOW spec逐一對應:塊①_scan_best_market/_best_market_target(faction_ai_system.gd新增87行)公式跟上輪審過的HOW文字一致,唯一差異=archetype從『乘整體』改『只乘gain』,commit msg誠實交代原因(乘整體會讓TRADE在負util時探索更少=sign-flip bug,headless RED抓到)——這是TDD抓到的正向修正非偷改scope;塊②team_market_last_read(world_state.gd+4行)+read_market_board stamp點(order_system.gd+4行)精準對應到場firsthand讀板才stamp;塊③options.gd:19一行擴充applicable;calibration錨真值claim親驗坐實非空話:MARKET_ARB_NORM=100.0親grep goal_resolver.gd:237確認DELIVER_PAYOFF_NORM=100.0逐字相同非巧合聲稱;測試l3_circuit_trade_test.gd親讀完整6案,尤其⑤是真的adversarial測試(竄改市集tile.public_storage到99999後assert visit_util不變)非空殼斷言,直接驗證感知鐵律的具體實作;team_data.gd/world_state.gd新增欄位皆minimal+addtive+comment清楚;CLEAN→merge"
---

# R②merge-gate判決：L3循環貿易 build（06c8b452）— CLEAN

## 三塊實作對HOW spec逐一核對——親讀完整diff非信commit msg摘要

`git show 06c8b452`完整diff讀過（非只看commit message列的清單）：

- **塊①**（`faction_ai_system.gd` +87行）：`_scan_best_market`/`_best_market_target`/`_market_arb_expectation`/`has_market_visit_value`四個新函式，公式`gain = (W_ARB×arb_norm + W_STALE×stale_norm) × arch_mult`、`cost = W_TRIP×trip_norm×(0.5+caution)`、`u = gain - cost`——跟上輪我審過CLEAN的HOW spec formula一致。**唯一實質差異**：HOW spec原文寫「再×人格modulate」（暗示整體乘），實作改成只對gain項乘archetype係數。commit message誠實交代原因：「archetype乘整體會讓TRADE在負util時探索更少=反了、headless RED抓到」——這是實作階段TDD跑出來的sign-flip bug、implementer自己抓到並修正，非偷渡scope或事後找理由的crank調整。我認可這個修正比原HOW文字更正確。
- **塊②**（`world_state.gd` +4行`team_market_last_read`欄位、`order_system.gd` +4行stamp點）：親讀`order_system.gd:211-215`附近確認stamp動作精準卡在`read_market_board`「確認在市集outpost在場」判斷之後、緊接著寫`state.team_market_last_read[team.team_id][tid] = state.world.current_tick`——到場firsthand讀板才stamp，跟spec「未讀=stale MAX」的機制描述吻合。
- **塊③**（`options.gd` 一行）：`applicable`從`has_goods or has_arb`擴成`+ or ctx.has_market_visit_value`，精準對應上輪HOW審過的內容，非額外夾帶其他改動。

## calibration錨真值——親驗非空口聲稱
`MARKET_ARB_NORM: float = 100.0`(comment寫「同DELIVER_PAYOFF_NORM尺」)——親讀`goal_resolver.gd:237`確認`DELIVER_PAYOFF_NORM: float = 100.0`**逐字相同**，這不是implementer隨口說「錨了某個東西」，是真的抄了一個既有、本session已經反覆驗證過語意（coin gain正規化尺度）的常數值。`trip_norm=dist/MERCHANT_MAX_RANGE`/`stale_norm=elapsed/SCOUT_TIMEOUT`兩個也都是reuse既有常數，非發明新數字。上輪我要求的calibration紀律這輪確實被交代清楚。

## 測試——親讀完整6案，⑤是真adversarial非空殼
`l3_circuit_trade_test.gd`完整讀過。特別看第⑤案（感知鐵律）：測試流程是先算一次`visit_util`，接著**直接竄改市集tile的`public_storage["food"]=99999.0`**（模擬如果code不小心讀了live god-view會發生什麼），再算一次`visit_util`，assert兩次結果`absf(u1-u0)<1e-9`完全不變。這是**真的adversarial test**——不是「函式不crash」這種空殼斷言，是具體驗證「就算市集有超大量真實庫存，visit_util的計算完全不受影響」，直接、具體地把感知鐵律這條最重要的憲法級要求釘死成一個可重跑的回歸測試，非只靠code review肉眼confirm。第⑥案（遠市集不劫持）也是同款「用具體數字證明湧現非強迫」的紮實測試設計，非口頭宣稱。

## 新增欄位——minimal/additive確認
`team_data.gd`+3行(`market_visit_cached`/`market_visit_next_tick`，cadence快取用)、`world_state.gd`+4行(`team_market_last_read`)——皆是純新增欄位、預設值安全（`false`/`0`/空Dictionary），沒有改動任何既有欄位的型別或預設語意，對其他既有系統零破壞面。

## determinism/constitution
diff裡新程式碼全是算術（`clampf`/`maxf`/dict查表），零`randf`類呼叫；沒有出現`state.teams[id].field`鏈式pattern或`for x in ...tiles`全圖掃描，跟god-view detector的兩個regex都不會撞——`constitution PASS 74`的自報數字跟親讀code的結構一致，我沒有理由懷疑。

## 判決
**CLEAN → merge。** 這是merge-gate審查（build diff對spec一致+無新問題），三塊實作我逐段對過HOW spec原文，唯一的偏離（archetype gain-only）有清楚交代且是正向修正；calibration/測試品質都親自查證到具體行號/具體斷言內容，非信自報。地基KEEP，可以推measurer量測。
