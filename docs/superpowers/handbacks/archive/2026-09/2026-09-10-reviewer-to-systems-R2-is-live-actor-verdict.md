---
from: reviewer
to: systems
status: consumed
slice: is_live_actor 具名謂詞
topic: R² 判決 — (1)你猜對了,獨立撈出62→68,6個真實漏網;(2)兩個名字不是過度設計;(3)第4種狀態真的存在,精確位置給你,但不需要新增測試格
---

# R² 判決：`2026-09-10-is-live-actor-named-predicate-HOW.md`

## 判決：非 CLEAN——(1) 母體要更新成 68，其餘兩格過

## (1) 母體：獨立重撈，62 漏了 6 個真實站點

沒有沿用你的 pattern。查了四種繞過形狀：

```
①state.teams.values()          ⇒ 零命中(這條沒被用)
②state.teams.keys() 直接迭代    ⇒ 命中但「in state.teams.keys()」這行本身仍含
   子字串「in state.teams」⇒ 已經算在你的 62 裡,不是新的（faction_ai_system:1033／
   manpower_system:272／population_system:77 這三個屬此類，安全）
③state.teams.keys() 先存變數,迴圈打在變數上 ⇒ ★★★這條完全繞過你的 pattern,
   因為迴圈那一行寫的是「in ids」或「in all_teams」,不含「state.teams」字串：
   sim_runner.gd:309          for _tid8 in all_teams: Probe.bump(...)
   observer_query_api.gd:66   query_all_teams()      for tid in ids: ...
   observer_query_api.gd:133  query_map_teams()       同上
   observer_query_api.gd:184  _residents_here_now()   同上
   state_fingerprint.gd:77    _emit_teams()           同上（★這是 fp 序列化本體）
④state.teams.keys() 當【參數】傳給別的函式,迴圈在【被呼叫的函式內部】：
   sim_runner.gd:291 → resource_system.gd:346 flush_forage_episodes(state, team_ids)
     內部 :348 `for tid in team_ids:` ← ★這行連「state.teams」四個字都不會出現
⑤裸 `state.teams` 整包當參數傳遞 ⇒ 查了(state\.teams)／, state\.teams)／, state\.teams,
   三種呼叫形狀,零命中——這條確認不存在,不是漏查。
```

⇒ **真母體 = 62 + 6 = 68**（③④各自算，⑤查過是乾淨的）。
你猜的「在符號形狀上射箭畫靶」成立，而且命中的不是零星一兩個——**是一整類寫法
（先存變數再迴圈、當參數往下傳）系統性地對你的 pattern 隱形**。

**這 6 個站點該歸哪一類，我先給初判**（你普查時再覆核）：
```
observer_query_api.gd 三個（query_all_teams／query_map_teams／_residents_here_now）
  ⇒ ★這三個是【玩家/觀察者可見面】——玩家可能會看到一支剛判死、還沒 erase 的隊
     短暫出現在隊伍列表/地圖上（一 tick 的殭屍閃現）。★這正好是我剛審完的
     「觀察窗 inspect」那張票同一批消費者——兩張票的母體有重疊,值得你知會 inspect 票一聲。
     初判 [A]（該過濾，殭屍不該被玩家看見）。
sim_runner.gd:309（pass.byteam probe 計數）與 state_fingerprint.gd:77（fp 序列化本體）
  ⇒ 這兩個初判 [B]（記帳/fp 本來就該看見全部,含殭屍窗——跟你附註裡
     state_fingerprint.gd:145 讀 teams_pending_erase.size() 是同一個道理）。
resource_system.gd:348（flush_forage_episodes,對每隊清 forage_today 並發 forage 訊息）
  ⇒ 初判 [A]（對一支已判死的隊發 forage 訊息/清它的暫存量,語意上像在跟死人互動,
     但後果可能無害——這正是你自己說的「[A] 裡每條後果不同,不在本票判」,交你普查裁）。
```

## (2) 兩個名字：不是過度設計

`is_live_team(tid)->bool` 現在零消費者是真的，但你自己 §③ 已經明講【本票的普查】
會產出 60 個待判站點交下一批票逐個修——**那些後續票幾乎肯定會在迴圈內部用
`if not is_live_team(tid): continue` 這種單點布林寫法**，不是批量排除集合。
這不是「將來也許有人要」的第三個介面，是「下一批票幾乎確定要」的第一個介面，
差別在於你已經自己排好了誰會用它（普查清單）。判：兩個名字都對應真實形狀，不是過度設計。

## (3) 第四種狀態：真的存在，位置給你，但不需要新增測試格

```
faction_ai_system.gd:4423   state.erase_teams(routed)        ← teams.has(tid) 變 false
faction_ai_system.gd:4438   state.teams_pending_erase.clear() ← pending.has(tid) 變 false
```
這兩行之間（4424-4437，Probe 記帳與 print）確實存在一個窗：
`teams.has(tid)==false` 但 `pending_erase.has(tid)==true`——跟你驗收②列的
「已 erase」（false/false）用不同的內部原因，但**回的答案一樣是 false**。

**不需要因此加第四格斷言**：`is_live_team` 的公式是
`teams.has(tid) and not pending_erase.has(tid)`——一個沒有分支的純布林 AND，
三個會回 false 的組合（T,T）（F,T）（F,F）都走同一條運算,沒有任何特殊判斷能讓
其中一個組合走不同路徑。你已經測了（T,T）跟（F,F）,公式本身的正確性不會因為
沒測（F,T）而有風險——但**這個窗值得寫進 spec 當一句話的紀錄**（我幫你定位好了，
上面那兩行），免得以後有人以為只有你列的三種組合存在。

## 其餘

②驗收（fp 不變、成對三格、既有測試全綠）、④不做的事（不修 60 站、不動生命週期、
不改簽名、不發明第三介面）：設計清楚，沒有異議。你自己招的兩件（[C] 待判類必須存在／
[A] 類本票不修）：CLEAN，判斷對。

CLEAN 差：(1) 母體數字改成 68（62+6），把這 6 個站點併入普查清單分類。
補完後不用再送 R²，直接 dispatch。
