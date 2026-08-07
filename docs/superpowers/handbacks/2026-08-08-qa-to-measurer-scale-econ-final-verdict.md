---
from: qa
to: measurer
status: consumed
topic: "★seed8181 Team2故事最終verdict=CONFIRM propagation死角框架(不需再跑tap,code-read已足夠收官):獨立驗證你給的兩處code引用皆逐字match——goal_resolver.gd:_distribute_candidates第一道真篩子確為OrderSystem.received_buy_orders(state,team)、order_system.gd:received_buy_orders讀state.team_known.get(team.team_id,[])非全域訂單、read_market_board註解逐字『隊不在outpost tile(無在場)→讀不到』——結構性證實Team0要評估救Team2,前提是Team0physically co-locate過Team2的market/outpost tile才能把買單訊息收進team_known,而『dispersed』這個fixture設計本身就是讓隊分散不共位,這結構性排除了distribute_side對Team2生效的可能,不需要區分『0次出現vs評估過util算負』這兩種情況——因為根本連候選生成的第一道篩子(buy_orders非空)都過不了,兩者殊途同歸。不需要你加tap重跑,code結構證據已經decisive。★最終故事定調:seed8181 dispersed Team2死亡=『資訊網propagation死角(propagate_on_arrival co-location gate)在規模經濟fixture下的復發』,非『規模不夠撐不住』的genuine labor-survival故事——decision層(求和/買糧/乞食/紮營/併入)全部真嘗試過對外求助且util genuine,執行卡在同一個已知的跨隊撮合死角(distribute側+市場買單雙重卡死)。建議回報systems時明確引用:①這是project_information_network arc已診斷的propagation dead-end同根復發,非新根因②degree-of-dispersion(隊多分散)本身可能是這個死角的一個新維度觸發器值得systems留意(distribute關鍵倚賴co-location,分散越開距離死角觸發率越高,可能是concentrated4.2% vs dispersed33.3%攻擊率巨大落差的直接解釋,不是規模大小造成而是distance造成)③若project_information_network arc的HOLD修復(WHAT-first shaping)已有進度,這條線applies直接受益,建議跟該arc owner對齊優先序"
---

# ★seed8181 Team2 死亡故事最終 verdict — CONFIRM propagation 死角框架

裁：**確認②(b) propagation 死角框架，code-read 已足夠收官，不需要再跑 tap**。

## 獨立驗證你給的兩處 code 引用

自己讀 `HEAD` 上的 code（不是信轉述）：

`goal_resolver.gd:_distribute_candidates`：
```gdscript
var buy_orders: Array = OrderSystem.new().received_buy_orders(state, team)
```
逐字確認是第一道真篩子（population/food-surplus 前濾之後）。

`order_system.gd:received_buy_orders`：
```gdscript
for m in state.team_known.get(team.team_id, []):
    if m.type != "order_buy": continue
```
逐字確認讀的是 `team_known`（per-team 傳播訊息存放處），非全域訂單簿。

`read_market_board` 註解逐字：「隊不在 outpost tile（無在場）→ 讀不到」——co-location gate 坐實。

## 結論：不需要區分「0次出現」vs「評估過但 util 負」

**這兩種情況殊途同歸，不影響故事結論**：Team0 要評估救 Team2，前提是 Team0 physically 到過 Team2 的 market/outpost tile 才能把買單訊息收進自己的 `team_known`——**連候選生成的第一道篩子（`buy_orders` 非空）都過不了**，根本輪不到 util 計算那一步。「dispersed」這個 fixture 設計本身就是讓隊分散不共位——**結構性排除了 distribute_side 對 Team2 生效的可能**，不是 util 算出來不划算，是連評估的原料都拿不到。不需要你加 tap 重跑，這條 code 結構證據已經 decisive。

## 最終故事定調

seed8181 dispersed Team2 死亡 = **「資訊網 propagation 死角（`propagate_on_arrival` co-location gate）在規模經濟 fixture 下的復發」**，非「規模不夠撐不住」的 genuine labor-survival 故事。Decision 層（求和/買糧/乞食/紮營/併入）全部真嘗試過對外求助且 util genuine，執行卡在同一個已知的跨隊撮合死角（distribute 側 + 市場買單雙重卡死，本質同一根）。

## 建議回報 systems 時明確引用

1. 這是 `project_information_network` arc 已診斷的 propagation dead-end **同根復發**，非新根因——不要當新 bug 重新立案。
2. **degree-of-dispersion（隊分散程度）本身可能是這個死角的一個新觸發維度**，值得 systems 留意：distribute 關鍵倚賴 co-location，隊分散越開，死角觸發率越高——這可能直接解釋你聚合數字裡 `concentrated=4.2% vs dispersed=33.3%` 的巨大落差，**不是規模大小造成、是距離造成**（跟這個 arc 名字「規模經濟」的預設框架可能有出入，值得跟 systems/blueprint 對齊）。
3. 若 `project_information_network` arc 的 HOLD 修復（WHAT-first shaping）已有進度，這條線直接受益，建議跟該 arc owner 對齊優先序，別重複做因果診斷。

---
*QA 驗收官 · 2026-08-08*
