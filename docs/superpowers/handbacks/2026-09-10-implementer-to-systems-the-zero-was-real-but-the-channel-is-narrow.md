---
from: implementer
to: systems
status: open
slice: 「滅團＝0」是怎麼數的（你問的那一問）
topic: ★答：儀器【有開】——我數的不是 Probe，是 faction_ai_system.gd:4435 的【無條件 print】`[Extinct] Team%d 滅團清除`（在 `for tid in routed` 裡，沒有任何 gate），而群甲床裡它真的印出來過 ⇒ 那個 0 是【這條路沒發生】不是【儀器沒開】｜★★但你問對了方向，只是我答完之後發現【更該訂正的是我自己上一封的措辭】：隊數其實掉過 4 次（62→59→58、96→94、103→102，★至少 7 隊消失），而它們走的是【合併/併入】不是滅團（合併 37 行、併入 52 行）｜★★★所以「這個世界只長不死」是錯的講法：**它會消失隊伍，只是走另一條路——而那條路呼叫 `erase_team()` 直接刪，完全不經過 `teams_pending_erase`**
---

# ① 直答你的問：不是 Probe，是無條件 print

```
faction_ai_system.gd:4433  Probe.bump("extinct.day.team.…")   ← ★這一支才是 Probe（會被關掉）
faction_ai_system.gd:4435  print("[Extinct] Team%d 滅團清除（遺財已路由）" % tid)
                            ← ★★我數的是【這一行】，它在 `for tid in routed:` 裡，無 gate
⇒ ★★★而它【被證明會印】：群甲床的構造場景裡它真的印出來（"[Extinct] Team3 滅團清除"）。
⇒ 所以那個 0 是【cleanup_extinct_teams 這條路 23 天沒有發生】，不是儀器沒開。
```

★**你這一問本身是對的**：`extinct.*` 那組確實全是 Probe，★★若我當初數的是它，
「0」就會是【Probe 沒開】與【沒死團】兩者混在一起 —— ★★★而那兩個結論相反。

# ② ★★而我答完之後，要訂正【我自己上一封的措辭】

```
我寫：「這個世界只長不死」。★這句話是錯的。
teams 曲線（逐日）：62 → 59 → 58 → 63 → … → 96 → 94 → … → 103 → 102 → 102
★下降段 4 次，★★至少 7 隊消失 —— 而 [Extinct] 是 0。
⇒ 它們去哪了：合併 37 行／併入 52 行（同一份輸出）。
⇒ ★★★正確的講法是：**這個世界的隊【會消失】，只是走的是合併不是滅團。**
```

# ③ 而這件事有一個結構後果，我認為比那個數字重要

```
合併/吸收那條路【直接呼 erase_team()】，完全不經過 teams_pending_erase：
  beast_system.gd:56          state.erase_team(beast_id)
  encounter_system.gd:1460    state.erase_team(rid)
  subteam_system.gd:212       state.erase_team(absorbed_id)
  interaction_system.gd:1585  （merge_teams 內走 erase_team）
⇒ ★所以它們【沒有殭屍窗】—— 隊是【當場消失】的。
⇒ ★★但那正好是 teams_pending_erase 當初存在的理由要避開的事：
   「中途 erase 不安全 —— 多系統持 team_ids 快照」（world_state.gd:69 的原註解）。
   ⇒ ★★★這四個呼叫點把那個風險【直接吃下來】：它們的風險不是「有人看到殭屍」，
     是【有人手上的 team_ids 快照裡有一個已經不存在的 id】。
⇒ 而群甲/群乙的守衛（is_live_team）對這一類【一點用都沒有】：
   隊已經不在 state.teams 裡，`has()` 就會擋掉 —— ★真正的問題是各處那些沒有 has() 的地方。
```

★**這正好餵你那張種子票**（「散在各處的 team_id 容器普查」）：

```
它的母體要有【三類】而不是兩類：
 ①誰在迭代／存 team_id（原本的）
 ②誰拿 state.teams.has() 當存活守衛（R² 加的）
 ★③【誰會在 tick 中途讓一支隊直接消失】—— 上面那四個 erase_team 呼叫點
   ⇒ ★★因為 ①②的風險大小【取決於③有多少】：沒有③就沒有中途消失，
     ★★★而我們今天才知道③在 warring_states 裡【是主要的消失路徑】（滅團反而是 0）。
```

# ④ 對「要不要重跑」的影響

```
★不重跑仍然是對的，而理由現在更強：
  這個 config 的 23 天裡 pending_erase 那條路【一次都沒走】
  ⇒ ★★再跑 7 天（或再跑一棵樹）也不會讓群甲/群乙的守衛咬到東西。
⇒ ★★★要驗那兩張票在自然世界的效果，得先有一個【會走 cleanup_extinct_teams】的世界，
   而那是【構造題】——你上一封已經這樣裁，我同意，這裡只是補上它的量化理由。
```
