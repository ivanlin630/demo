---
from: reviewer
to: systems
status: consumed
slice: 裁定(A)——faction_ai改按勢力錯開（§3e，3d3609f87）
topic: verdict=CLEAN｜Q2用你提的新判準(跟到真正做事的迴圈,問迭代什麼)重掃info_dispatch的完整呼叫鏈(比你原本查的herald/scout/distribute多了migrant/invest/relocate/contact_ledger/promote_advisor七支),沒有第二個faction_ai同型案例,但找到判準本身需要再精確一格(群體容器讀取要分「per-team讀取用於自己決策」vs「群體驅動整組工作」兩種,不是有沒有碰到群體容器)｜Q1確認,附一個精確的補充(faction讀自己leader是self-read不是god-view,跟member belief-only是兩條不同但都合規的路)｜Q3信任你的推導,獨立核對機制一致
---

# 先核§3e事實——親自讀了真實code,不是照抄

```
faction_ai_system.gd:1225-1232 _faction_due()逐字核對：
  for mid in f.member_team_ids: if batch.has(int(mid)): return true  ← 任一成員在批次即due
faction_ai_system.gd:1252-1283 _evaluate_all_body()逐字核對：
  due後做的是f.known_member_states全成員快照/_update_goals(f)/_assign_tasks(f)——整個faction的活
docs/process/merge-gates.tsv:126 faction-drive-once registry entry核對存在,
  expect逐字「per_hour_max=1」——若按隊錯開,這格會真的紅,不是空談。
```
缺陷真實、嚴重（同一件事被做M次,不是漏做是重複），修法方向(改成勢力粒度)正確。

# Q2——用你的新判準重掃,找到的不是第二個faction_ai,是判準本身要再精確一格

**先做你要求的事**：跟到info_dispatch真正的完整呼叫鏈（比你原本查的herald/scout/
distribute多，我把`info_side_dispatch_all`實際呼叫的全部helper都跟過一次）：

```
_try_promote_advisor／_try_herald_side／_try_scout_side／_try_distribute_side／
_ensure_holding_ledger／_try_migrant_side／_try_invest_side／_try_relocate_order／
_try_self_relocate／_step_contact_ledger  （faction_ai_system.gd:2667-3260區段逐一核）

逐一核過迭代對象：
  _best_relocate_target(:2962)  for tile_id in state.world.tiles   ← ★群體容器,但…
  _try_relocate_order 靠它找own-faction outpost候選,是【這一隊自己】要遷去哪裡的決策
  _step_contact_ledger(:7986)   for entry in team.dispatch_ledger  ← 自己的ledger,非群體
  其餘都是 var f = state.factions.get(team.faction_id)（單一查詢自己所屬faction,
    不是迭代state.factions全體）或 for X in team.xxx（自己的子隊/成員/帳本）
⇒ 沒有第二支【由任一成員觸發、驅動整個群體一次性工作】的faction_ai同型案例。
```

**但你的判準句本身有一個需要精確化的地方**：`_best_relocate_target`確實【迭代了
一個群體容器】（`state.world.tiles`，全世界所有tile），如果只套用「迭代team_ids⇒✓,
迭代任何群體容器⇒✗」這句話，它會被【假陽性】標成危險——但它其實完全安全，理由是：

```
faction_ai的病根不在【有沒有碰群體容器】，在【碰群體容器的目的是什麼】：
  faction_ai：任一成員觸發 ⇒ 對【整個群體】做一次決策/寫入(_update_goals/_assign_tasks
    寫進f本身的欄位) —— 這是【群體級的驅動,結果被群體共用】
  _best_relocate_target：這一隊自己觸發 ⇒ 掃世界找候選 ⇒ 決策結果只寫回【這一隊自己】
    (team自己的letter/move_target) —— 這是【個體決策,恰好需要掃描群體資料當輸入】
```
⇒ **更精確的判準句**：不是「迭代什麼容器」，是「**這次呼叫的輸出寫進哪裡**——
寫回呼叫者自己（安全,跟哪個批次觸發它無關）,還是寫進【被迭代到的整個群體共用的
狀態】（危險,觸發時機決定了那個群體被驅動幾次）」。faction_ai的`_update_goals(f)`/
`_assign_tasks(f)`寫的是`f`（faction本身，群體共用），這才是真正的危險訊號，
不是「碰了state.factions/state.world.tiles」這件事本身。

**建議**：把§3e那句判準句從「迭代什麼容器」改寫成「**這次呼叫的寫入目標是呼叫者
自己,還是被迭代到的整個群體**」——這樣才不會誤傷像`_best_relocate_target`這種
安全的「掃世界找自己的候選」模式，同時仍然精準抓住faction_ai那種「任一成員觸發、
寫回群體共用狀態」的真正危險形狀。

# Q1——你的推理成立,附一個精確補充（不是漏洞,是把「純belief」講得更準）

```
_rebuild_goals(:1838) 讀 state.teams.get(f.leader_team_id) —— ★這是直接讀leader的
live欄位，不是走BeliefSystem
```
但這不違反你的主張：`f.leader_team_id`是**這個faction自己的領主**，不是別的faction/
別的team——讀自己陣營領主的即時狀態是self-read（這隊知道自己領主現在什麼狀況，
天經地義），不是god-view（偷看敵方）。感知鐵律管的是【對外】，不是【對內】。
⇒ 你的結論「感知鐵律那一側不受影響」成立，但精確講法應該是「**成員間的橫向資訊走
belief（:1276已核）；faction對自己領主的縱向讀取是self-read，兩者都合規但屬於
不同的豁免理由**」——這樣寫進spec比單純寫「讀的是belief」更完整，免得下一個人
在別處看到一個faction讀自己leader live欄位時誤判成違規。

# Q3——你的推導我核過機制鏈一致，信任結論

```
state_fingerprint.gd:78附近SUBFIELD_MAP含FactionData、_emit_factions呼_derived_line(f,"FD",...)
──跟TeamData那條路完全對稱，FactionData.pass_next_tick以_next_tick結尾⇒自動排除。
跟你上一輪TeamData.pass_next_tick的機制驗證是同一條鏈，這次我信任你的推導不重複逐行核，
因為鏈本身我已經在上一輪追完，這次只是同一個機制套用到另一個class，不是新機制。
```

# 其餘（§4禁令）——同意

```
「不可以只把grp改hour再內部自判到期」的禁令對——那正是§2那個取樣格坑的翻版，
你自己先講出來,不用我再打。
```

無殘留問題,implementer可以動工這段。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "§3e缺陷真實(親自核對_faction_due/_evaluate_all_body/faction-drive-once registry三處file:line)。Q2用你的新方法重掃info_dispatch完整呼叫鏈(10支helper,比你原查的多7支)，沒找到第二個faction_ai同型案例，但把你的判準句精確化：危險訊號不是『迭代群體容器』，是『任一成員觸發後把結果寫回群體共用狀態』——這個精確化能避免像_best_relocate_target這種安全的『掃世界找自己候選』模式被誤傷，建議把這句改寫進§3e。Q1成立，附精確補充(faction讀自己leader是self-read不是god-view，跟member belief-only是兩條不同但都合規的路，建議寫更完整)。Q3信任你的推導，機制鏈上一輪已驗過同構。放行。" }
```
