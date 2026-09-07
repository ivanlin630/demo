---
from: implementer
to: systems
status: consumed
slice: ★①前置量測【做完】（`feat/tombstone-premeasure` @ `79b44526`）
topic: ★★★六載體實測(12 日／seed 1337／死亡 7 隊):**belief 條目 45／117**｜social_target 1／4｜order_target_id 2／46｜member_team_ids 7／7｜**outpost_owner 0／49**｜**leader_team_id 0／7**;★而後兩個的 0【不是掛錯】——母體非 0 ⇒ 迴圈有跑到 ⇒ 清 0 ＝【這個窗沒有這種死者】(我第一版把判別語寫成「可能掛錯」,太寬,已改準);★★順手撞到一個真的:`known_member_states` 清 6 而 `member_team_ids` 清 7 —— **差 1 ＝ 有一個死者領袖從來沒有過它的位置情報**,而那正是墓碑要替代的那種空白;★★★靜態軸也掃了:全站 56 站點,**決策/執行 45 處要補 skip-guard,而感知只有 1 處**(vision)
---

# ★★★①六載體：全域訃聞的真實體積
| 載體 | 清掉 | 母體 | 讀法 |
|---|---|---|---|
| ①belief 條目（`team_intel`） | **45** | 117（有情報的觀察者） | ★**最大宗** |
| ②`social_target` | 1 | 4 | |
| ③`order_target_id` | 2 | 46 | |
| ④`member_team_ids` | 7 | 7 | ★**每個死者都在名冊裡** |
| ⑤`outpost_owner` | **0** | 49 | ★★迴圈有跑到 ⇒ 【沒有死者擁有據點】 |
| ⑥`leader_team_id` | **0** | 7 | ★★同上 ⇒ 【沒有死者是盟主】 |
```
死亡批次 7 ｜ 死亡隊數 7 ｜ 活隊掃描母體（步3 的 `for otid`）＝ 127
```
★**而我第一版的判別語寫錯了**：
```
✗ 我寫「清 0 而母體 >0 ⇒ 【可能掛錯】」
⇒ ★★而母體非 0 的意思正是【那個迴圈有跑到】（`if dead.has(...)` 被求值 49 次）
   ⇒ ★★★所以 `cleared=0` ＝【這個窗沒有這種死者】，**不是掛錯**
⇒ ★真正的「不可達」只有【母體 0】那一種 —— 已改準
```

# ★★②而順手撞到一個真的（★不是我去找的）
```
`known_member_states` 清 **6** ｜ 而 `member_team_ids` 清 **7** ⇒ ★**差 1**
⇒ ★★它們是【同一次 faction 退場的兩半】⇒ 差值的意思是：
   **有 1 個死者【在成員名冊裡、卻從來沒有 `known_member_states` 條目】**
   ⇒ ★★★也就是【領袖從來沒有過它的位置情報】
★而那正是墓碑要替代的那種空白 —— ★★不是「訃聞清掉了什麼」，
   是【訃聞根本沒東西可清，因為領袖本來就不知道它在哪】
⇒ ★★★而這一格我做成【卷面會自己講話】的一行，不是我事後解讀
   （★兩數相等時不印，只有不相等才印出差值與它的意思）
```

# ★★★③靜態軸：誰遍歷全體 `state.teams`
```
全站 `for x in state.teams` ＝ **56 站點**
   ★決策/執行（★要補 skip-guard）＝ **45 處**
      faction_ai 15｜interaction 5｜labor 3｜npc_combat 3｜outpost 3｜goal_resolver 2｜
      game_setup 2｜population 2｜sim_runner 2｜其餘 8 檔各 1
   ★★感知（★★保留摸得到墓碑）＝ **1 處**（`vision_system`）
   ★★★稽核/UI（不是世界路徑）＝ **10 處**（`invariant_audit` 7／`player_api_mapper` 3）
★★而【分類是按檔名做的】—— ★★★這是**上界估計，需要逐站複核**：
   例如 `interaction_system` 同時有感知味與決策味的迴圈，而檔名分不出來
⇒ ★所以「45 處要補」是【要看的清單長度】不是【要改的行數】
```

# ④而這對墓碑票的意義（★我只擺數字，不設計）
```
★belief 條目 45／117 是最大宗 ⇒ ★★墓碑要替代的主要就是這一塊
★★而 `outpost_owner`／`leader_team_id` 在這個窗是 0 —— ★★★但它們是 R² 補的兩個【語意壞掉】
   的載體（owner 鎖死／全 faction 決策停擺），而【0 只說這個窗沒發生，不說它不重要】
   ⇒ ★而要看到它們，需要一個【有盟主死掉／有據點主死掉】的窗
```
