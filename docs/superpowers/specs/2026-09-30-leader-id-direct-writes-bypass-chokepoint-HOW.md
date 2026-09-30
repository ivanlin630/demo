# HOW：`leader_id` 的統一 chokepoint 有 5 處直寫沒改過去（其中一處今天被稽核抓到）

**來源**：死輸入探索床報一筆 **`InvariantAudit` 紅**（`roster 反向破 P127：team_id=48 但不在該隊 roster`），
落在 `L3:choose_heir` 那一步。我開檔追到底，而**真因不是那一步寫錯，是它繞過了一個已經存在的唯一入口**。

## ★★★§1 前提：那個 chokepoint 的註解**自己寫著**「所有直寫改走此」

```
`scripts/data/world_state.gd:605-618` `set_leader()` 的檔頭逐字：
  「統一 leader 指派 chokepoint，mirror add_member/set_team_faction：
    ★**所有 team.leader_id= 直寫改走此**。」
它做三件事（而三件都是 P127 需要的）：
  ①`team.leader_id = pid` ②`team.named_members.erase(pid)`（leader 出 named，分職）
  ③★`p.team_id = team.team_id`（**強制回指本隊，修 stale desync** —— 註解明寫這一點）
  ＋可選 `old_leader_action="member"`（舊 leader 降 named）
```

**而 `player_command_system.gd:1211-1214` 是手寫一份**：

```gdscript
team.leader_id = heir_id                    # ← ★直寫，繞過 chokepoint
state.remove_member(team, heir_id, false)   # ← 手做 ② 的一半（false ⇒ 不動 team_id）
heir.role = "leader"                        # ← 手做 role
```
⇒ ★**它漏掉 ③**（`p.team_id` 強制回指本隊）⇒ 當繼承人原本的 `team_id` 與 `fe["team_id"]` 不同時，
那個人就「team_id 指向 48，而 48 的 roster 裡沒有他」⇒ **正是稽核那一行**。
★★而舊 leader 怎麼辦也沒處理（`old_leader_action` 那一半完全沒有對應）。

## ★★§2 母體：產品碼裡還有幾處（我數過，指名）

```
非 debug 的直寫共 13 處，其中 8 處是 `= -1`（清空；chokepoint 明寫 pid=-1 允許）
★而【指派一個真人】的有 5 處，全部繞過 chokepoint：
  ①player_command_system.gd:1213  team.leader_id = heir_id      ← ★今天被稽核抓到的那一處
  ②population_system.gd:148       ot.leader_id  = promoted.id
  ③reaction_system.gd:487         ot.leader_id  = person.id
  ④recruit_tutorial.gd:21         team.leader_id = nl.id
  ⑤subteam_system.gd:67           sub.leader_id  = sub_leader_id
⇒ ★★★①有血證，②③④⑤**沒有人測過**（那支床只走玩家那條路）
  —— 而它們是【同一類】：手寫一份 chokepoint 而可能各漏不同的一件。
```

## §3 做什麼

```
①那 5 處**逐處判**：能走 `set_leader()` 就走（含 `old_leader_action` 該給什麼）
   ★不能走的，要**就地具名寫理由**（例如 subteam 的 `sub` 不是真隊、population getter 有特殊語意）
   ⇒ ★★**不准整批改成 set_leader 了事**：那 5 處的語意不一定相同，
     而「看起來一致」正是今天這個 bug 的來源（有人以為自己複製對了）
②`= -1` 那 8 處**不在本票**（清空語意由 chokepoint 明文允許）⇒ 但要在卷面上**列出來說明為何不動**
③★而 chokepoint 的註解要補一行：**它已經被繞過 5 次** ——
   一句「所有直寫改走此」在 5 個繞過者面前不是規則，是願望。
   ⇒ 補上「★現存例外（具名）：…」讓下一個人看得到真實狀態
```

## ★★§4 驗收

```
P1 [今天那一筆紅消失] 重放床裡那一步（`L3:choose_heir`）⇒ `InvariantAudit` 零違反
   ｜負對照：把 `set_leader` 換回直寫兩行 ⇒ 稽核紅 ⇒ 必紅
   ★母體地板：印出【繼承人原本的 team_id】與【fe 的 team_id】——
     若兩者相同，這一格會在一個「不需要 ③」的世界裡恆綠
P2 [另外四處逐處有交代] 逐處印：改走 chokepoint／或具名不改＋理由
   ★斷言：5 ＝ 已改 ＋ 具名不改（三數相加，同今天按鍵那票的形狀）
P3 [★其餘四處有沒有同樣的洞] 對每一處**構造一次「人原本不在該隊」的情境**並跑稽核
   ⇒ ★★這一格是本票真正的價值：①有血證，②③④⑤沒人測過
   ⇒ 若其中任一處也紅 ⇒ **那不是本票失敗，是本票找到第二個**（照樣修，寫進卷面）
P4 全電池 BATTERY_RC=0；★fp 可能變（leader/team_id 的修正會動狀態）
   ⇒ **先量再換基準、同 commit**；沒變就不要動並寫明為何沒變
```

## §5 不在本票
```
·那 8 處 `= -1`（見 §3②）
·`choose_heir` 的其餘語意（候選集怎麼算、誰有資格）—— 本票只修 roster 一致性
```
