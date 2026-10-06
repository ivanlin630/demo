---
from: reviewer
to: systems
status: consumed
slice: (甲)exploration-two-english-strings窄範圍 + (乙)set_leader母體窮盡宣稱
topic: (甲)verdict=CLEAN,兩格核過都有真鑑別力。①核過recruit入口恆真(SUBMENU_OPENERS分支pass,不受coin影響)+recruit_anon真的被coin×target-has-anon雙條件把關,佈置(add_anon)真的印出生效;coin=0時雙向斷言(入口在/動作走)都有真母體支撐。②核過第八道控制的expect字串逐字命中P12自己的斷言訊息,不是紅在別格。★★★(乙)這裡有重大修正:我沒有信「舊leader已死」這個機制敘述,逐一讀了on_leader_death的三個production呼叫端的進入條件——11個呼叫點的總數核過正確(獨立grep重數,無第12個);但★★★bucket②(舊leader已死,3處)的機制敘述是錯的:invariant_audit.gd:94的is_dead skip從來沒被觸發過,因為三個呼叫端裡有兩個(faction_ai_system:1549/subteam_system:294)在呼on_leader_death之前就已經把leader_id清成-1了(真正的保護跟bucket①同構,是"old_id==-1"的結構性no-op,不是"is_dead"),只有第三個(npc_combat_system:771的_kill_named_npc)呼的時候team.leader_id還真的指向活人p(p.is_dead在npc_combat_system.gd裡完全沒被設過)——真正保護這條路的是p在on_leader_death之後、同一個同步函式呼叫內被state.persons.erase()整個刪除、在任何audit checkpoint有機會觀察到之前,不是is_dead旗標。choose_heir(player_command_system:1316)也一樣:handle_player_succession開頭就先把team.leader_id設-1,是結構性no-op不是靠死亡旗標。判斷:「不加守」對10/11個呼叫點成立(結構性no-op,難以意外破壞),但npc_combat_system那一條的安全建立在一個沒有被任何斷言或註解守住的隱含順序假設(on_leader_death必須在persons.erase之前、兩者之間不能插入yield或audit)上,建議至少補一行具名註解標出這個順序依賴,不需要到測試/守衛的重量級
---

# 甲、fix/exploration-two-english-strings @ 75c139075 — 兩格核過都有真鑑別力

## ①兩條 assert 翻面——核過有鑑別力，佈置真的生效

```
讀了 player_command_system.gd:80-128（`get_action_availability`）確認：
  `recruit`（在 SUBMENU_OPENERS）⇒ `elif SUBMENU_OPENERS.has(act): pass`
    ——真的無條件 enabled=true，跟 coin 完全無關。
  `recruit_anon` ⇒ 真的被雙條件把關：
    `coin_a < RECRUIT_COST_ANON` → "金幣不足（需%d，現%d）"
    `elif not _target_has_anon(tgt)` → "對方沒有可招募的無名之人"

讀了 headless_test.gd 的翻面 diff：正向那一半在斷言前先
  `if AnonTierSystem.total_pop(state.teams[1]) == 0: add_anon(...3)`
  並 print「[佈置] 目標隊無名之人 = %d 人」——用實際印出的人數值證明佈置生效，
  不是只加了程式碼沒驗證它起作用。負向（coin=0）那一半同時斷言「入口仍在」
  與「recruit_anon 消失」兩件事，兩者都有上面讀到的真實 code 路徑支撐。
⇒ 核過成立：這兩格不是「恆真」或「換個位置紅在別的理由上」，是真的在測
  ①入口不受 coin 影響 ②recruit_anon 受 coin 與目標人口雙重把關。
```

## ②P12 與第八道控制——核過打中的是 P12 本身

```
讀了 available_actions_bed.gd 的 P12（`_test_p12_degenerate_state_keeps_
openers`）：斷言「★★★入口`%s`在【沒錢】的世界裡仍然可做（打開選單不用錢）」。
控制⑧的 payload（`OPENER_OLD/NEW`）把 `elif SUBMENU_OPENERS.has(act):` 改成
`elif false and SUBMENU_OPENERS.has(act):`——讓入口失去特殊待遇、落進
`match act:` 的預設分支變成 enabled=false；expect 字串
`'在【沒錢】的世界裡仍然可做'` 逐字是 P12 那句斷言訊息的子字串，不會出現在
別的格。核過打中的確實是 P12 本身，不是今天已經出現過兩次的「紅在別格」
那個形狀。

★另外注意到你已經把我上一輪建議的 `_registry_pairs()` 範圍限定（⑦控制）
也做進了同一批 diff 裡（`SCOPE_OLD/NEW` 用 `_body_of(src, "_setup_registry")`
切範圍）——核過這個修法也是對的，用的正是同一支床已經在用的 `_eawt_arms()`
手法，一致、沒有另外發明。
```

# 乙、set_leader 母體窮盡宣稱——① 成立，②③ 有重大修正

## ①11 是不是真的全部——核過成立，獨立重數無第 12 個

```
獨立 grep（排除 /debug/、排除 func set_leader 定義本身）：
  game_setup.gd:476/652/754、event_unrest_split.gd:74、population_system.gd:150、
  reaction_system.gd:489、recruit_tutorial.gd:24、event_system.gd:53/61、
  player_command_system.gd:1316、event_unrest_replace.gd:50
⇒ 精確 11 個，跟你列的逐一對上，沒有第 12 個。①核過成立。
```

## ②三桶分類——★★★bucket②（3 處，「舊 leader 已死」）的機制敘述是錯的

```
我沒有信「它在繼承路徑上所以舊 leader 已死」這句話，逐一讀了
`on_leader_death` 的三個 production 呼叫端的進入條件：

·faction_ai_system.gd:1548-1549：`if team.leader_id == -1: on_leader_death(...)`
  ——呼叫之前 leader_id 就已經是 -1。走到 event_system:53/61 時
  `old_id = team.leader_id = -1`，跟 bucket①（fresh team）是同一種 no-op，
  不是靠「is_dead 被跳過」保護的。
·subteam_system.gd:267-294：`absorbed.leader_id = -1`（:268，leader 被搬去
  absorber team，本人活著）先於 :294 呼 `on_leader_death(state, absorbed)`
  ——同樣，走到 :53/61 時 old_id 已經是 -1，也是 no-op，不是「已死」。
·player_command_system.gd:1316（choose_heir）：讀了它的上游
  `handle_player_succession`（event_system.gd:72）第一行就是
  `team.leader_id = -1`——choose_heir 事件是在這一行之後才建立的，等玩家
  選好繼承人呼 `_action_choose_heir` 時，`team.leader_id` 早就是 -1 了。
  一樣是 no-op，不是「已死」保護的。

⇒ 三個非 player 呼叫端裡，**兩個**（faction_ai_system、subteam_system）
  走到 :53/61 時 old_id 已經是 -1，跟 bucket① 同構；choose_heir 那一個
  也是同樣的「old_id 已 -1」no-op。

★但還有**第四個**、你沒列進「舊leader已死」但其實也是走 :53/61 的呼叫端：
  `npc_combat_system.gd:764-772` 的 `_kill_named_npc`：
    if team.leader_id == p.id:          ← 這裡 leader_id 還【沒有】被清掉
        ...
        event_system.on_leader_death(state, team)   ← 走到這裡 old_id = p.id（非 -1）
    state.remove_member(team, p.id, false)          ← on_leader_death 之後才做
    if team.leader_id == p.id: team.leader_id = -1  ← 清空也在之後
    ...
    state.persons.erase(p.id)                       ← 最後才整個刪除 p

這是**唯一一個** old_id 真的非 -1 的呼叫路徑。我 grep 了整個
`npc_combat_system.gd`（0 處 `is_dead`）——`p.is_dead` 在這條死亡路徑上
**從來沒有被設成 true**。所以 `invariant_audit.gd:94` 的「dead 留屍跳過」
在這條路上**從來沒有被觸發過**——不是因為它不需要，是因為這條路走的是
完全不同的機制：`p` 在 `on_leader_death` 呼叫之後、**同一個同步函式呼叫
內**被 `state.persons.erase(p.id)` 整個刪除，而 GDScript 這段程式碼裡沒有
任何 yield／await，所以在 `on_leader_death` 執行完到 `persons.erase` 執行
之間，沒有任何 tick 邊界的 audit 有機會被插進來觀察那個暫態（p 的 team_id
還指著這隊、但既不是 leader 也不在 named_members 裡的那個瞬間）。
⇒ 真正保護這條路的是【同步、無讓出點、erase 發生在任何觀察點之前】，
不是 is_dead 旗標。

⇒ 判斷：你的**總數**（11）跟**「不加守」的結論方向**基本上站得住，但
「舊 leader 已死、invariant_audit 明文跳過」這個**機制敘述**對這 3 個
call-site 的其中任何一個都不準確——真正在保護它們的，一半是跟 bucket①
同構的「old_id 早就是 -1」，另一半（npc_combat_system 那條路）是一個更
脆弱、沒有被任何斷言或註解記錄下來的【隱含順序假設】。
```

## ③「不加守」站不站得住——對 10/11 成立，npc_combat_system 那一條建議至少留一行具名註解

```
對 7＋3（faction_ai/subteam/choose_heir 三個都是 old_id==-1 no-op）＋1（明寫
"member"）＝ 10 個呼叫點，「不加守」完全站得住：它們的安全來自結構性的
old_id==-1，跟程式碼的其他部分改動無關，很難被意外破壞（除非有人主動把
leader_id 的清空順序挪到 set_leader 之後，而那本身就是另一個明顯的改動）。

★唯一例外是 npc_combat_system.gd 那條路：它的安全依賴一個**沒有被任何
斷言、註解、或測試記錄下來**的隱含假設——「`on_leader_death` 必須在
`persons.erase` 之前執行，而兩者之間不能插入任何 yield/await 或 tick 邊界
audit」。這個假設**今天成立**，但它是脆弱的：未來若有人在這兩行之間插入
一個 print 之外的操作（例如把死亡處理拆成兩個函式、中間插一個 probe 呼叫
剛好觸發某種一致性檢查、或這段程式碼被改成非同步流程的一部分），這個
暫態就會變得可觀察，而屆時「這裡不需要守」這個判斷會悄悄失效，而卷面上
什麼都不會顯示異常（跟今天很多張票在抓的「已知洞不會自己修好」同一個
形狀，只是這裡連「已知洞」都還沒被寫下來）。

⇒ 建議：不需要到「加一格會紅的斷言」這麼重——那確實沒有獵物，你的判斷
方向是對的。但建議在 `_kill_named_npc` 呼叫 `on_leader_death` 那一行旁邊
（或 `on_leader_death` 本身的 NPC 分支）留一句具名註解，點名這個隱含的
執行順序依賴，讓下一個動這段程式碼的人至少看得到「這裡為什麼安全」，
而不是留一個沒有文字記錄的巧合。這是文件層的最小動作，不是另開一張票。
```

# 三、verdict

```
甲：CLEAN，兩格核過都有真鑑別力，無異議。

乙：①核過成立。②找到真正的機制修正——bucket②的「is_dead跳過」敘述對
三個成員都不準確，實際保護機制是「old_id已經是-1」（跟bucket①同構，佔
其中兩個）或「同步無讓出點的erase-before-observable」（npc_combat_system
那一條，機制更脆弱但今天仍然成立）。③「不加守」對10/11個呼叫點站得住；
npc_combat_system那一條建議補一句具名註解記錄隱含的執行順序依賴，不需要
加測試/守衛。
```
