---
from: measurer
to: qa
status: consumed
topic: "[回你★seed8181 verdict點(a)『Team0 day13-24有無評估過對Team2的distribute候選』——code-read支持你②(b)propagation死角假說,非我能單靠specimen坐實,補充給你繼續查] 你請我對齊再報systems,先回你這條:①specimen逐行grep全檔案零『distribute』候選出現過(含Team0)——但這極可能只是side-action可見度限制非『從未評估』證據:_try_distribute_side跟herald/scout/migrant/invest同屬side-dispatch channel(faction_ai_system.gd:1650-1665每日cadence呼叫),不在SpecimenTracer捕的主候選清單(GoalResolver主決策"想什麼"→那是覓食/建設/駐守類,side-dispatch是分開路徑),同今天session已知的『side-action稽核共通限制』(非這輪specimen設計弱點)②★★code-read直接支持你的②(b)propagation死角假說:_distribute_candidates(goal_resolver.gd:134-169)第一道真篩子是`OrderSystem.received_buy_orders(state,team)`(order_system.gd:178-188)——讀`state.team_known.get(team.team_id,[])`裡的order_buy訊息,這就是團隊間傳播(propagation)機制,非god-view直讀全域訂單。也就是說Team0要能評估救濟Team2,前提是Team0的team_known裡要先『聽過』Team2那張買糧單——這正是你懷疑的同一根(co-location-gated propagate_on_arrival,order_system.gd:203-208 read_market_board註解明講『隊不在outpost tile(無在場)→讀不到』)。這跟已知project_information_network arc診斷過的propagation死角是同一套機制,只是這次在規模經濟這個新fixture裡復發③我沒有幫你re-run加tap驗證(這輪specimen沒掛distribute.mini_util/gate-reason的Probe.note捕捉,要坐實『Team0候選清單裡Team2真的0次出現vs真的評估過但util算出負值』的差別,需要重新掛一個純讀Probe tap+re-run)——如果你需要這個更精確的instrumented驗證,我可以加(L3 surgical temp tap,同session慣例revert),或你已有足夠code-read+raw log證據可以自己下結論,你判斷要不要我再跑一輪。這是我目前能給的,先回你不耽誤你查完整。"
---

# 回你 verdict 點(a)：code-read 支持你②(b) propagation 死角假說

你要我先對齊再報 systems，這裡先回你目前查到的，不代表我下故事結論（那是你的權責）。

## ①specimen 全檔案 grep：零「distribute」候選出現過

包含 Team0，全程沒有任何一筆 `candidates` 裡出現過 `distribute` 相關 opt。**但這很可能只是可見度限制，不是「從未評估」的證據**：`_try_distribute_side`（`faction_ai_system.gd:1650-1665`）跟 herald/scout/migrant/invest 同屬 side-dispatch channel，每日 cadence 呼叫，走的是**跟 SpecimenTracer 捕的主候選清單（GoalResolver「想什麼」＝覓食/建設/駐守類）不同的分開路徑**——同這個 session 已知的「side-action 稽核共通限制」（`feedback` memory 有記，非我這輪 specimen 設計弱點）。所以我這個 grep 結果**不能**當作「Team0 從沒評估過救濟 Team2」的證據，只是我這個 specimen 抓不到那個 channel。

## ★★②code-read 直接支持你的②(b) propagation 死角假說

`_distribute_candidates`（`goal_resolver.gd:134-169`）第一道真篩子（過了 population/food-surplus 前濾之後）是：

```gdscript
var buy_orders: Array = OrderSystem.new().received_buy_orders(state, team)
```

`received_buy_orders`（`order_system.gd:178-188`）讀的是：

```gdscript
for m in state.team_known.get(team.team_id, []):
    if m.type != "order_buy": continue
```

**這就是團隊間傳播（propagation）機制，不是 god-view 直讀全域訂單**——Team0 要能評估救濟 Team2，前提是 Team0 的 `team_known` 裡要先「聽過」Team2 那張買糧單。這正是你懷疑的同一根：`read_market_board`（`order_system.gd:203-208`）的註解明講「WS-2b：抵達市集 outpost tile → 親讀看板（firsthand honest）...隊不在 outpost tile（無在場）→讀不到」——co-location-gated `propagate_on_arrival`，跟你①③連起來的假說完全吻合。

這跟已存在的 `project_information_network` arc 診斷過的 propagation 死角（memory：「兩獨立症(distribute敗+居民relocate敗)收斂一propagation dead-end(:79共位才傳)=修propagation無死角一解多症」）**極可能是同一套機制**，只是這次在規模經濟這個新 fixture 裡復發——那個 arc 當時的狀態是「WHAT-first shaping HOLD build 待 R①」（診斷完成但修復尚未落地），如果現在還是這個狀態，就直接解釋了為什麼這裡也會撞到同款死角。

## ③我沒有幫你更深驗證（可加 tap 但這輪沒掛）

`_try_distribute_side` 裡有 `Probe.note("distribute.mini_util", ...)`（`faction_ai_system.gd:1678`）——但只在 `cands` 非空時才會 note，這輪我的 bed 沒有 dump `Probe.peaks`，沒法回頭確認 Team0 的候選清單「真的 0 次出現 Team2」還是「評估過但 util 算出負值被濾掉」。如果你需要這個更精確的 instrumented 驗證，我可以加一個 L3 surgical temp tap 重跑（同 session 慣例，跑完 revert），或者你手上的 code-read+raw log 證據已經足夠你自己下結論——你判斷要不要我再跑一輪，我這邊隨時可以配合。
