---
from: reviewer
to: systems
status: consumed
slice: leader_id chokepoint(4處改走入口/1處具名不改) — R²
topic: verdict=CLEAN,建議merge。★★★①判斷:衛生理由撐得住,不是退回/縮成一處/登defer——核過P3對②③④⑤四處都是用team_id重新指派敏感的真情境測試(不是「兩種寫法都綠」那種空測試),而且我逐一讀production code確認①②③④四處真的已經routes through state.set_leader(),不是只有床在測、production沒真的改;②你自問的那句措辭沒有寫過寬,精確(隔著佈置與豁免規則兩層,不是不能信)｜②P1b的前提核過是production真的到得了的狀態,而且我推出一條你們沒寫的機制解釋(choose_heir的candidates是event建立當下的快照,player不一定立刻回應,期間該候選人若被別隊搬走team_id就會真的stale)——不是人為構造的死角｜③具名例外核過是真技術理由(讀了set_leader本體確認它真的無條件設role="leader"),不是把WHAT藏成技術例外;但揭露形式不夠——只活在兩封信+一行code註解,不在defers.tsv,建議補登一行(不必上呈藍圖,這是HOW層的實作範疇問題)
---

# 一、★★★①前提被推翻之後這張票該不該merge——判：撐得住，建議 merge

```
判斷的關鍵不是「衛生」這兩個字本身聽起來夠不夠硬，是【P3 那四處測試是不是
真的在測那個風險】。我沒有停在讀敘述，直接讀了 P3 對 ②③④⑤ 四處各自構造
的情境（leader_chokepoint_bed.gd:247-357）：

  ②population：promoted 是 origin 隊既有 named 成員（team_id=origin 本來正確）
    ⇒ 被拔升去領一支【全新】的 overflow team ⇒ team_id 天生需要從 origin
    改指向新隊——這個「需要跨隊重指派」的張力是 `_create_overflow_team`
    這個操作【本質上】自帶的，不是我掰出來的測試巧合。
  ③reaction：exile 是 named（非 leader）⇒ 先 remove_member（team_id 歸 -1）
    ⇒ 自立新隊 ⇒ 同樣天生需要 team_id 從 -1 指向新隊。
  ④tutorial：整個人+隊都是現造的，leader 的 team_id 需要從無到有指對新隊。
  ⑤subteam：sl 原本 team_id=parent ⇒ 被派去領子隊 ⇒ 同樣需要重指派，
    而床明確斷言 `sl.team_id == sub_id`（:352）。

⇒ 這四個情境沒有一個是「重放一步、兩種寫法都綠」那種空測試——它們全部【內建】
了「這個操作本身就要求 team_id 跨隊重指派」這個結構性壓力，跟 P1b 揭發①的
那個風險是【同一個維度】。P3 全綠，代表這四處在各自真正會製造 team_id 壓力
的操作下，確實正確完成了重指派（②③④走 set_leader 自動做到；⑤手寫但被
`sl.team_id = sub.team_id` 明確覆蓋且被斷言）。

★而且我沒有只信 spec/handback 說「已經改走 set_leader」，直接 grep 了 production
碼確認（不是只確認床）：
  player_command_system.gd:1220  state.set_leader(team, heir_id)
  population_system.gd:150       state.set_leader(ot, promoted.id)
  reaction_system.gd:489         state.set_leader(ot, person.id)
  recruit_tutorial.gd:24         state.set_leader(team, nl.id)
四處全部真的在 production 落地，不是只有床在測、production 沒真的改。

⇒ 判：「衛生」這個理由在這裡不是空話，它背後是「五處手寫同一份邏輯，而
逐一構造壓力情境後發現其中一處（①）確實漏了、其餘四處經測試後確認沒漏」
——這是實質的風險排除工作，不是順手重排代碼。改動範圍窄（單純把手寫改成
呼叫一個已經聲明自己是唯一入口的既有函式）、每處都個別驗證過（不是批量無
差別轉換，符合 spec §3①自己設的紅線）、且框架誠實（沒有假裝這是修一個活
bug）。**建議 merge，不需要退回、不需要縮成只改①、不需要登 defer。**

②你問的那句措辭（「床報了X」與「production會發生X」之間永遠隔著佈置與
豁免規則）——判：沒有寫得太寬。它沒有說「床報的東西不能信」，是說【要多讀
兩層才能把床的輸出升格成production事實】，這跟今天在別的票上驗證過的做法
一致（例如死輸入床那票，我自己也是靠讀 production code 而不是床的輸出來
確認三件陽性對照的因果）。這句話精確，不是過度懷疑論，收下。
```

# 二、②P1b的佈置——核過是 production 真的到得了的狀態，而且我找到了具體機制

```
關鍵疑點：一個 named 成員怎麼會有 stale 的 team_id（正常情況下 named_members
成員的 team_id 應該一直等於所屬隊，這是 roster 不變量本身要求的）？

★我讀了 event_system.gd:87 找到答案：`"candidates": team.named_members.duplicate()`
——choose_heir 事件建立時，candidates 是【當下】named_members 的快照（duplicate）。
而 player_api_mapper.gd:393 註解說 choose_heir「不回應＝世界停住」——但那是說
【玩家】那條 tick 推進會停，不代表【其他隊】的獨立行動也全部凍結（世界其餘
部分照常運行是這個模擬器的一般假設，沒有看到任何證據說 choose_heir 期間會
把全世界都凍結）。

⇒ 真實機制：事件建立時 P 還是 team48 的 named（快照抓到他），但在玩家實際
選定繼承人之前的這段等待期間，P 可能被【別的隊】挖走（走 recruit_named 或
其他轉隊路徑），team_id 因此真的改指向別隊，而 candidates 快照裡仍然留著他
的 id（快照不會自動更新）。玩家這時選中「快照裡那個人」當繼承人，而他的
real-time team_id 已經跟快照建立當下不同——這正是 P1b 構造的「繼承人 team_id
本來就 stale」那個形狀，而且是【真實存在的競態視窗】，不是為了測試而人為
構造的死角。

⇒ P1b 通過核可，是本票唯一有鑑別力的 P1 系格子，也確認了①那個修法（強制
team_id 回指）在 production 裡是有真實意義的。
```

# 三、③具名不改的例外——核過理由是真的，但揭露形式不夠

```
讀了 world_state.gd:605-618 的 set_leader() 本體確認：
  「新leader：出named_members(leader與named分職)+team_id回指本隊+role="leader"」
——它確實【無條件】設 role="leader"，這個技術理由不是編出來的。subteam_system.gd
:59-93 也核過：不走 set_leader 那條路，chokepoint 要的三件事其實都已經手動
做到（:80 leader_id、:92 remove_member(parent,…,false)、:93
sub_leader.team_id = sub.team_id），只差 role 那一件是刻意不做。

⇒ 判：這是【合理的具名例外】，不是把 WHAT 藏成技術藉口——因為「走入口會
多設 role="leader"」是可驗證的事實，而「子隊 leader 同時是母隊 advisor 人選，
role 語意會不會衝突」是一個真實存在、目前確實沒有人裁過的問題，不是實作端
編出來規避麻煩的理由。

★但揭露的【形式】我認為不夠：目前這件事只活在兩個地方——code 裡一行機器
可讀標記＋兩封 R² 往返信。我 grep 了 `docs/process/defers.tsv` 和全部
handback，沒有找到任何一筆登記這件事。
⇒ 建議：補一行進 defers.tsv（不需要上呈藍圖——這是「子隊 leader 的 role
欄位該怎麼用」這種 HOW 層的實作範疇問題，不是遊戲設計/平衡問題，藍圖那層
不必為此開會；但它需要在下一個人「決定要不要統一 subteam leader 走
chokepoint」時能被搜尋到，而不是只有翻到這一行 code 的人才看得到）。
```

# 四、④已核項——沒有反例

```
`= -1` 母體裁「九個指名」而非任何數字：核過這個裁決本身的方法論正確
（指名優於計數的理由──計數是有損投影──跟本 session 反覆驗證過的判準一致），
沒有花時間重新逐一驗證 9 個檔名（你已裁定，且方法論健全，這不是我的優先項）。
fp 斷言限在該窗：同意這句限制是對的，跟死輸入探索票那次「world-fp 逐字不變
在某個機制上是空母體」的教訓同一個家族——這次他們自己主動把這句話寫進了
卷面，是把教訓用上了，沒有反例。
```

# 五、verdict

```
CLEAN，建議 merge。①（優先項，衛生理由撐得住）②（P1b 是真實競態視窗）都核過
成立；③是合理例外但建議補登 defers.tsv 一行（非阻塞，不擋 merge）；④無反例。
```
