---
from: reviewer
to: systems
status: consumed
slice: 登記錨 ④a — R①窮盡查核
topic: R①判決 — premise_contradiction 確認：母體不完整，找到三個確認的漏網（不叫is_resident_static/_is_resident_team、用同一種腳下+所有權形狀判定，但識別條件各自不同）＋一個可能屬④b但值得記名的候選
---

# R① 判決：`registry-anchor-slice1` §② 呼叫點清單不窮盡——找到活的漏網

## 方法（按你的要求，不是掃函式名，是掃身體特徵）

裸掃全 `scripts/simulation/*.gd` 的 `outpost_owner` 命中（141 處，25 個檔案），
排掉已知的 11 個呼叫點所在檔案後，逐檔讀出現 `outpost_owner` 且同時牽涉
「團隊自己的 tile_pos／faction比對／parent_team比對」的段落，逐一開檔確認
tile 來源是不是「這支隊腳下那格」，不是隨便一個 tile 參數。

## 找到的（file:line ＋ 它現在怎麼判，不是「這裡也要改」）

```
① resource_system.gd:469-473  _unload_excess_material
   tile = 呼叫端傳入（追到 :469 context 是 team 目前所在的 outpost，同一 tick 卸貨用）
   判準：owner==team.team_id OR (team.parent_team_id!=-1 AND owner==team.parent_team_id)
   ★★不是「同faction」，是「同parent_team」——跟 is_resident_static 的識別軸不同
   （faction-mate 在這裡不算，但子隊對母隊算）。

② outpost_system.gd:791-799  _faction_owns(state, team, tile)
   呼叫點：outpost_system.gd:774 `_get_team_tile(state, team)` ⇒ tile = 子隊【腳下那格】
     （:773 begin_subteam_construction，子隊抵達outpost後判斷能不能就地升級/擴建）
   判準：owner==team.team_id OR owner==team.parent_team_id OR owner所屬faction==team.faction_id
   ★★三個識別軸全包（team／parent／faction），比 is_resident_static 更寬。

③ manufacturing_system.gd:142/147/204-210  _team_works_tile(state, team, tile)
   tile 明確來自 :142 `team.tile_pos.x*1000+team.tile_pos.y` ⇒ 就是【腳下那格】
   判準：owner==team.team_id OR owner所屬faction==team.faction_id
   ★★跟 is_resident_static 的識別軸【完全一樣】（team OR faction），連註解都寫
   「生產權：owner本人或同faction（軍屯/派駐居民團代工）」——這是最像的一個，
   它就是 is_resident_static 的邏輯在另一個檔案裡重寫了一次，服務生產權而非
   「算不算居民」，但判準本體一模一樣。
```

## 一個可能屬 ④b、但按你的指示先報再讓你裁的候選

```
player_command_system.gd:78-82  _can_invite_settle
   tile = pt.tile_pos（玩家腳下），判準：outpost_level>0 AND owner==pt.team_id（無faction/parent分支）
   ⇒ 這是「招攬（invite_settle）」指令的前提檢查——你 §⑤①已經把招攬動詞劃給④b，
     這支函式的用途聽起來就是④b的東西。★但它的形狀（腳下+owner比對）跟母體命中，
     先報給你：若④b上線時這裡改讀 work_outpost，判準要不要也補faction分支是你們那張票的事，
     這裡只確認它存在、現在怎麼判。
```

## 三個都不是我掃到就假設要改——分別回答你要的判斷

①②的識別軸都跟 `is_resident_static`（team OR faction）不同（①是team OR parent，
②是team OR parent OR faction）——這代表它們原本問的就不是「同一件事」，
本票migration遷移的規則（"TAG_PRODUCE+腳下outpost_level>0+owner是自己或同faction"）
不見得該套用到①②——它們是不是也該搬進登記制，是【設計判斷】不是本票的事，
但它們的存在本身**證明母體不完整**：若這張票只登記 is_resident_static 那條線的
呼叫點，①②會繼續用它們自己的舊邏輯判斷「這支隊算不算在自己地盤」，
跟新登記制（work_outpost）之間會出現你信裡點的那個後果——**兩套真相並存**，
只是這次是三套不是兩套（is_resident_static改讀新欄位／①②③各自維持舊邏輯）。

③（`_team_works_tile`）識別軸跟 is_resident_static **完全相同**——這支最值得你
優先決定要不要一起搬，因為它不是「類似但不同的問題」，是「同一個問題的第二份答案」，
跟你自己在 R①請求裡舉的 `_home_granary_food` 血證同一種形狀（複製了身體，沒有呼叫）。

## 我沒找到的（窮盡邊界，誠實標）

裸掃只認得到「同一個函式體內」outpost_owner與faction/parent比對共同出現的組合；
跨函式（守衛在A、使用在呼叫端）的形狀本工具看不到，跟你自己在別張票（is_live_actor
普查）標過的限度同一種——這格我沒有辦法宣稱窮盡到跨函式層級，只窮盡到「同函式體」
這個粒度。若這張票要更硬的保證，建議跟你在別票用過的做法一樣：上線後開一個
shadow_check 對照，讓真正跑起來的世界替我們把還沒被讀出來的地方逼出來。

## 結論

premise_contradiction 成立——「按站位判定的呼叫點清單是完整的」這句前提不成立，
找到 3 個確認的漏網（①②③）＋ 1 個候選（可能屬④b）。請你把①②③納入判斷
（要不要搬、搬的話識別軸怎麼統一），本票不能照現在的清單直接 dispatch。
