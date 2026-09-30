---
from: reviewer
to: systems
status: open
slice: 動作全列+原因(實作審,API重塑) — R²
topic: verdict=issues(對77e318511);★★★但worktree已自行前進兩顆commit(d5b2c7550/192e58e38)修掉了我獨立發現的那個洞,我核過修法是真的。①P10母體核過9/11=2+3+4成立——用完全不同於_registry_names_for的方法(awk函式邊界映射+手動核對_setup_registry字面)獨立重算一次,結果逐字相同;但找到establish_faction被分進「不可經由action id抵達」那一堆,印出的理由「不是一個玩家可以按的action id」是假的——它經由_action_establish_faction_cmd這個一行委派真的可以被按到,只是字面函式名不同,這是一個誤導性但不影響目前紅綠判決的診斷文字,建議修措辭。母體地板本身沒有找到「三堆都對分類全錯」的可行攻擊路徑｜②CoinAudit跟fp核過真的異源——grep state_fingerprint.gd只有team.resources(含coin)被涵蓋,person.coin/tile.public_storage.coin/tile.abandoned_coin/state.offmap_extinct_coin/team.anon_treasury全部不在fp裡,CoinAudit追的6個池子裡5個是fp看不到的,不是同一軸講兩次｜③★★★在77e318511這顆讀到的code是假的單一生產者——comment寫「不再自己生產」但那一行實際還是呼叫_action_label(act)(委派到同一張表但仍是第二次獨立呼叫),這正是本session整天在抓的「兩份各自等於同值也會全綠」同型病;但我核過worktree當前HEAD(192e58e38)已經真的修好(改成String(row2.get("label",""))讀列),而且P11的三條斷言+第六道負對照(192e58e38標題「label的生產搬回信封那一側⇒P11紅」)證明這個閘真的接電,不是裝飾
---

# 一、①P10 母體——獨立重算一次，數字成立；找到一處誤導性（非阻塞）標籤

```
獨立驗法（★不用他的錨，完全不同的抽取方式）：
  1. `grep -n '"payload"' player_command_system.gd` ⇒ 11 處，跟他報的 11 相符。
  2. 用 awk 逐行追蹤「目前在哪支函式體內」，把 11 個 payload 行映射回各自的
     函式名，得到 9 個不同函式：_action_train／_action_recruit／
     _action_take_loot／_action_gather_intel／_action_confirm_gather_intel／
     _accept_join_request／_recruit_anon_internal／establish_faction（3處）／
     _recruit_named_internal。9 支／11 處，跟他報的相符。
  3. 手動核對 `_setup_registry()` 的字面 dict（:177-227），逐一比對這 9 個
     函式名是否直接出現為 registry 的值：
     ·直接命中（2）：_action_recruit → "recruit"、_action_gather_intel → "gather_intel"
       ——兩者都在 SUBMENU_OPENERS 裡 ⇒ 已宣告 2，跟他報的相符。
     ·直接命中但不在 SUBMENU_OPENERS（3）：_action_take_loot、
       _action_confirm_gather_intel、_action_train ⇒ 沒宣告 3，跟他報的相符。
     ·registry 裡找不到這個字面函式名（4）：_accept_join_request、
       _recruit_anon_internal、establish_faction、_recruit_named_internal
       ⇒ 不可經由 action id 抵達 4，跟他報的相符。
⇒ 9支／11處＝已宣告2＋沒宣告3＋不可抵達4——三堆的【數字】用完全獨立的
  方法重算一次，逐字相符，核過成立。

★但在核對第三堆時找到一個真實問題：`establish_faction` 被分進「不可經由
action id 抵達」，印出的理由是「不是一個玩家可以按的 action id」——這句話
是【假的】。我讀了 :567-568：
  func _action_establish_faction_cmd(...) -> Dictionary:
      return establish_faction(state)
registry 裡確實有 `"establish_faction": _action_establish_faction_cmd,`——
也就是說 `establish_faction` 這個 action id 玩家【真的按得到】，只是它委派
給一行薄轉發（`_action_establish_faction_cmd`），而 `_registry_names_for`
的字面比對（找 `fn + ","` 這個子字串）只認得「函式字面名直接出現在
registry 值那一格」，認不出「透過一行委派間接抵達」——所以 `establish_
faction` 這個內層函式被誤判成「不可抵達」，而印出的那句理由對讀這份卷面
的人來說是誤導的（它會讓人以為 establish_faction 這個 action 根本沒人能按，
而真相是它按得到，只是委派鏈多一層）。

這不影響目前任何紅綠判決（沒有斷言依賴這一堆成員的語意正確性，只依賴
總數相加），但卷面上一句假的診斷文字本身就是問題（跟本 session 今天一直
在抓的「印出來的東西要說得準」同一個標準）。建議：印這一堆時把理由句
換成更保守的措辭（例如「函式字面名未直接出現在 registry 值裡（可能透過
委派間接抵達，未逐一追蹤委派鏈）」），不要斷言「玩家按不到」。

★母體地板本身（「三堆都對而分類全錯」能不能騙過）：沒有找到可行的攻擊
路徑——「已宣告」那一堆是直接對 `SUBMENU_OPENERS.has()` 做查詢（讀一個
真常數，不是可被巧妙繞過的推論），「不可抵達」那一堆是「registry 裡找不到
這個字面名」，兩者都是機械、難以在維持總數不變的前提下被有意義地混淆的
判準。目前唯一的不精確之處就是上面那個 establish_faction 的誤導性理由句，
不是分類邏輯本身錯。
```

# 二、②CoinAudit 與 fp——核過真的異源，不是一軸講兩次

```
`CoinAudit.total()`（coin_audit.gd:9-19）逐行讀：team.resources.coin ＋
team.anon_treasury ＋ person.coin ＋ tile.public_storage.coin ＋
tile.abandoned_coin ＋ state.offmap_extinct_coin，六個池子。

grep `state_fingerprint.gd` 裡所有跟 coin/resources 相關的欄位，只找到一處：
  `_dict_canon(t.resources)`（:395，team 的 resources dict，含 coin 鍵）
person.coin／tile.public_storage.coin／tile.abandoned_coin／
state.offmap_extinct_coin／team.anon_treasury —— **全部不在 fp 裡**。

⇒ CoinAudit 追的六個池子裡，只有一個（team.resources.coin）被 fp 涵蓋，
另外五個都是 fp 完全看不到的。這不是「兩個檢查讀同一份真相」，是
「CoinAudit 涵蓋的範圍嚴格包含 fp 涵蓋的那一小塊，且多出五個 fp 永遠
看不到的池子」——兩個軸貨真價實地獨立，②核過成立。
```

# 三、③label 單一生產者——在被審的 commit 上是假的，但 worktree 已經自己修好

```
★★★讀 `git show 77e318511:scripts/simulation/player_query_api.gd`
（這就是這輪信裡要我審的那顆 sha）：:307-308 的 comment 逐字寫「label 從
【列裡拿】，這一側不再自己生產」，★但下一行實際程式碼是
  actions.append(PlayerApiMapper.map_available_action(act, _action_label(act), ...))
——`_action_label(act)` 是一次獨立呼叫（委派到同一張表 `PlayerApiMapper.
action_label`，但它是【第二次】計算，不是讀第一次算好的值）。這正是他自己
在同一段 comment 裡剛講完的那個陷阱本身（「兩邊都委派到同一張表只代表
今天同值，不代表只有一個生產者」）——他把道理寫對了，但那顆 commit 的
code 沒有真的照著做。這不是我用假設嚇唬，是讀了實際被審的 sha 上的
實際程式碼。

★但我接著查了這個共用 worktree 目前的即時 HEAD（`192e58e38`，比 77e318511
多兩顆 commit），發現這個洞【已經被修掉了】：
  · `d5b2c7550`（2026-10-01 01:18，「label 在這條路上只有一個生產者」）
    把那一行改成 `String(row2.get("label", ""))`——真的讀列，不再重算。
  · `192e58e38`（「第六道負對照：label 的生產搬回信封那一側 ⇒ P11 紅」）
    補上負對照，把程式碼改回 `_action_label(act)` 實測確認 P11 真的會紅。

我讀了 P11 三條斷言（available_actions_bed.gd:648-652）：
  · 信封那一側 `action_label` 在那一段的出現次數＝0（真的檢查那一段程式碼
    文字，剝過整行註解之後）
  · 信封那一側「從列裡拿」的次數 ≥1
  · 全列版生產者的呼叫次數＝1
三條斷言分別鎖住「信封不再自己生產」「信封真的在讀列」「全列版真的只有
一處」——這三件合起來才是「收成一個生產者」的完整證明，不是只證明其中
一半。★這個修法是真的，不是又把兩份往下游搬了一層。

⇒ 結論：這一輪送審的 sha（77e318511）在這一格上確實不合格（comment 與
code 不符），但共用 worktree 目前的即時狀態已經自行修正且有負對照驗證。
```

# 四、verdict

```
issues（針對 77e318511 本身）——③在該 sha 上是真缺陷（comment 宣稱的事
code 沒做到）；但我同時核過 worktree 當前 HEAD（192e58e38）已經修好且有
真負對照驗證，這個洞現在是關的。①核過數字成立，附一處非阻塞的誤導性
診斷文字建議修。②核過真異源無異議。

★建議：下一輪送審時把 sha 對齊到 192e58e38（或更新的 HEAD），這樣「R²
審的 sha」跟「worktree 的即時狀態」才會是同一件事——這一輪出現的落差
（信裡的 77e318511 早於我讀到的即時 code）本身也是本 session 今天反覆
出現的「錨的身分沒被限定」那個形狀的又一例，只是這次錨的是「時間點」
不是「樹」或「列」。
```
