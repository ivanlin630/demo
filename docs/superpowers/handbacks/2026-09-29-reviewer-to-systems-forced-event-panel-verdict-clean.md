---
from: reviewer
to: systems
status: open
slice: 強制事件面板+生命週期 — R②裁定
topic: verdict=CLEAN｜(甲)真因推論不只讀對,我把整條資料流從寫到讀追完了(diplomatic_ai_system.gd:146/149寫"propose_alliance"/"propose_trade"→_send_diplomacy_message:174原樣存進state.player_forced_event["proposal"]→respond_to_forced:942原樣讀出fe.get("proposal")→_accept_diplomacy:1159 match),中間沒有任何正規化/映射層,你擔心的反例(在別處被正規化過)不成立,機制上是釘死的,但仍同意由P4床確認才是對的流程(靜態能證明機制存在,不能證明它是這次玩測踩到的那一個)｜(乙)order_task值域核過:全庫grep它的賦值點,實際只有一個具體非空值TASK_TRIBUTE_OFFER="tribute_offer"(其餘全部賦值成清空""),不是真正任意字串,你的「任意」措辭稍寬;★但你的結論不但沒被推翻反而被加強了——tribute_offer本身也不在_accept_diplomacy的match裡,是第三個具體會撞同一個病灶的字串,兩個寫入者兩套詞彙這件事本身成立,主張留那一格對｜(丙)P4寫成指認不寫成結論不是逃避判斷,是blueprint先量後修裁定下唯一正確的紀律——即使我剛把(c)的機制追到底,也不代表(a)/(d)不會同時/單獨在真實runtime發生,靜態證明機制存在≠證明它是這次的真因,床仍是唯一有資格下結論的東西｜附四候選外一個小提醒:P4母體地板(先斷言forced_event非空)也該同時斷言proposal真的是propose_alliance/propose_trade這種會撞match的值,否則床可能在一個proposal剛好合法的世界裡對(c)恆綠
---

# 一、(甲) 真因推論——不只讀對，我把整條資料流追到底了

你只讀了 match 字面與兩個寫入者的字面，說「若在別處被正規化過整段作廢」——
我把中間那一段【寫到讀的完整路徑】也走過了：

```
①寫入：diplomatic_ai_system.gd:146  _send_diplomacy_message(state, self_team, other, "propose_alliance")
                              :149  _send_diplomacy_message(..., "propose_trade")
②存值：diplomatic_ai_system.gd:174  state.player_forced_event = {..., "proposal": action}
        ⇒ action 參數原樣存入，這裡沒有任何字典查表、沒有字串轉換
③讀出：player_command_system.gd:942  fe.get("proposal", "alliance")
        ⇒ 原樣讀出，同樣沒有正規化
④判斷：player_command_system.gd:1159 match proposal:（只認 alliance/surrender/tribute/demand_tribute）
        ⇒ "propose_alliance"／"propose_trade" 落到 return {"ok": false, "未知提案類型：..."}
```

⇒ **從寫到讀，中間沒有第三層**——你擔心的反例（在別處被正規化過）不成立，
機制在【靜態層面】是釘死的：只要這個 proposal 類型真的被寫進 forced_event，
`_accept_diplomacy` 一定會落到未知分支。

★★但這不代表 P4 可以省略——靜態追完只證明【機制存在】，不證明【它是這次玩測撞到的
那一個】。runtime 裡可能是 (a) 逾時競態先發生（forced_event 在到達 accept 之前就被
清掉）、也可能 propose_alliance 這個具體提案類型在真實世界的 AI 行為權重下極少被選中
（機制在，但沒被踩到）。你堅持交給 P4 床確認，我同意這是對的紀律，不因為我把機制
追到底就該改寫成結論。

# ★★二、(乙) `order_task` 值域——核過，你的措辭稍寬，但結論被加強了

```
全庫 grep `\.order_task\s*=`（賦值點）與 `"order_task"\s*:`（dict 字面值來源）：
  賦值成清空 ""：interaction_system.gd:543,819（明講「防殘留→下次外交/結盟誤路由」）
  賦值成具體值：options.gd:563 唯一一處 ⇒ "order_task": TeamData.TASK_TRIBUTE_OFFER
  TeamData.TASK_TRIBUTE_OFFER := "tribute_offer"（team_data.gd:41）
⇒ 實際只找到【一個】具體非空值，其餘全是清空——不是真正的「任意字串」，
  你的措辭比實情寬了一點。
```

```
★★但你的結論沒有被推翻，反而多了一個獨立證據：
  "tribute_offer" 這個具體字串，同樣【不在】_accept_diplomacy 的 match 裡
  ⇒ 若一個 TASK_DIPLOMACY 的 NPC 帶著殘留的 order_task="tribute_offer"（清空邏輯
    沒覆蓋到的路徑）走到 interaction_system.gd:294，寫進 forced_event 的 proposal
    會是 "tribute_offer"，一樣落到「未知提案類型」——這是第三個具體會撞同一個病灶
    的字串，不是你原本舉的兩個（propose_alliance/propose_trade）而已。
⇒ 「兩個寫入者兩套詞彙，這件事本身已經成立」——不但成立，我多找到一個實例。
  主張留著 P2 那格（未知 id 不吞）對，維持不動。
```

# 三、(丙) P4 寫成「指認」——不是逃避判斷

```
blueprint 裁的是先量後修，而你在 §2 的靜態推論已經很強（甲）——但【很強的靜態推論】
跟【床實際指認出來的真因】是兩件事：即使我剛才把 (c) 的機制路徑追到滴水不漏，
也不代表 (a) 逾時競態或 (d) 措辭撞車不會在真實 tick 序裡同時發生、甚至比 (c) 更早觸發
（例如：如果逾時發生在 accept 入列之前，玩家根本走不到 (c) 那個分支，看到的會是
(a) 的症狀，不是 (c) 的症狀）。
⇒ 把 spec 寫成「(c) 已確認，直接修」才是真正的逃避——逃避「也許不只一個真因，
  或真因跟我猜的不一樣」這個可能性。你寫成【四個候選各自的證據欄】，讓卷面自己說話，
  是把判斷權交給唯一有資格下結論的東西（床），不是不判斷，是不【搶】床的判斷。
```

同意，這不是逃避判斷。

# ★四、附一個小提醒（不擋這次，供你參考）

```
§4 P4 的母體地板寫「先斷言 forced_event 非空」——★建議再往前一步：同時斷言
  fe.get("proposal") 真的是 propose_alliance／propose_trade 這種會撞 match 的值。
  ⇒ 沒有這一句，若那次造的到達事件剛好 proposal="alliance"（合法值，不會撞 (c)），
    床對 (c) 那一格會【恆綠】——不是因為 (c) 不成立，是因為母體根本沒把 (c) 的
    觸發條件造出來。跟你自己在 P4 開頭那句「先斷言到達真的發生」是同一個家族的風險，
    只是母體要地更精確一點。implementer 寫床的時候順手加這一句即可，不需要改 spec。
```

# 五、verdict

```
CLEAN。可 dispatch 給 implementer。
```
