---
from: systems
to: implementer
status: open
topic: 派工：那筆稽核紅的真因不是「那一步寫錯」，是它繞過一個已存在的唯一入口 —— 而全庫還有 4 處同類【沒人測過】｜★★本票真正的價值在 P3：去construct那四處的同樣情境｜★不准整批改成 set_leader 了事
---

# 派工：`leader_id` 的 chokepoint 被繞過 5 次

**spec** `docs/superpowers/specs/2026-09-30-leader-id-direct-writes-bypass-chokepoint-HOW.md`
**來源** 你那支死輸入床報的那一筆 `InvariantAudit` 紅（`L3:choose_heir` ⇒ `roster 反向破 P127`）
**序** 排在 NPC 索貢零轉移之後或之前隨你（兩張都小，這張的爆炸半徑大一點）

## ★★★一、真因：它手寫了一份 chokepoint，而漏掉最關鍵的那一件

```
`world_state.gd:605` `set_leader()` 的檔頭**逐字**寫著：
  「統一 leader 指派 chokepoint…★所有 team.leader_id= 直寫改走此」
它做三件：①設 leader_id ②leader 出 named ③★`p.team_id = team.team_id`（強制回指本隊，修 stale desync）

而 `player_command_system.gd:1211-1214`：
  team.leader_id = heir_id                  ← 直寫，繞過
  state.remove_member(team, heir_id, false) ← 手做 ② 的一半（false ⇒ 不動 team_id）
  heir.role = "leader"                      ← 手做 role
⇒ ★**漏掉 ③** ⇒ 繼承人 team_id 指向 48 而 48 的 roster 裡沒有他 ＝ 稽核那一行
★★而 `old_leader_action`（舊 leader 降 named）那一半也完全沒有對應
```

## ★★二、母體我數過並指名：產品碼 13 處直寫，而【指派真人】的有 5 處全部繞過

```
①player_command_system.gd:1213  ← ★今天有血證
②population_system.gd:148   ③reaction_system.gd:487
④recruit_tutorial.gd:21     ⑤subteam_system.gd:67
（另 8 處是 `= -1` 清空 ⇒ chokepoint 明文允許 ⇒ 不在本票，但**要在卷面列出來說明為何不動**）
★★★②③④⑤ **沒有人測過** —— 你那支床只走玩家那條路。
```

## ★★★三、本票真正的價值在 P3，而不是修①

```
P3：對②③④⑤**各構造一次「那個人原本不在該隊」的情境**並跑稽核
⇒ ★若其中任一處也紅 ⇒ **那不是本票失敗，是本票找到第二個** ⇒ 照樣修，寫進卷面
⇒ ★★而若全部綠，也要印出【你構造的情境長什麼樣】——
  否則「綠」可能只是那個情境沒建起來（今天你自己踩三次的那一族）
```

## 四、兩件我先擋掉的做法

```
★①**不准整批改成 set_leader 了事**：那 5 處的語意不一定相同
  （subteam 的 `sub` 不是真隊、population getter 有特殊語意）
  ⇒ 能走就走，**不能走的要就地具名寫理由**
  ⇒ ★★「看起來一致」正是今天這個 bug 的來源（有人以為自己複製對了）
★②P1 要母體地板：印出【繼承人原本的 team_id】與【fe 的 team_id】——
  若兩者相同，那一格會在一個「不需要 ③」的世界裡**恆綠**
```

## 五、順帶

```
·spec §3③ 要你在 chokepoint 的註解補一行【現存例外（具名）】——
  ★一句「所有直寫改走此」在 5 個繞過者面前不是規則，是願望
·死輸入床本身：R² CLEAN（★他用 `git log -S` 自己查出三件症狀各自對應一顆獨立的真 fix commit，
  不是只信敘述）⇒ 電池跑完我就 merge
·其餘三類症狀（70 筆參數原樣印／41 筆靜默／1 筆 join_request 接受說被拒）我另外開
  —— ★★而 41 筆那一組我先呈報藍圖，因為它共用的前提是【遭遇戰進行中】，那是用戶那句「按了沒反應」
```
