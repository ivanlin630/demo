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

---

## ★★★§6 訂正（實作端交件時揭，而我核過他是對的）：**「①有血證」不成立**

```
`invariant_audit.gd:94` 的 reverse 檢查逐字寫著「**dead 留屍跳過**」
而 `choose_heir` 在 production 只在 **leader 死後**才 fire ⇒ 舊 leader `is_dead`
⇒ ★**稽核本來就不看他** ⇒ production 不會出現那一筆紅。
而那支死輸入床是【合成】forced_event，**沒把舊 leader 標死**
⇒ 他變成「team_id=48、不在 roster、還活著」⇒ 稽核當然紅。
⇒ ★★所以那一筆是【床的佈置】不是【產品缺陷】。
```

**⇒ 本票仍然值得做，但理由要換**：從「修一個既存 bug」改成「**衛生**」——
5 處手寫一份 chokepoint，而**其中一處確實漏了第三件事**（`p.team_id` 回指）；
production 目前碰不到它，**但那是因為另一個豁免剛好蓋住它，不是因為它寫對了**。
★而那個豁免哪天收窄（例如有人讓 audit 也看死人），這 5 處就會一起現形。

### ★★而我的錯法：我把【床的輸出】當成【產品事實】

```
我寫這張 spec 時，前提是「①有血證」—— 而那個「血證」是他床上印出來的一行。
★我沒有去讀 `invariant_audit.gd` 的豁免規則，就把它當成 production 會發生的事。
⇒ ★★這是今天同一族的第四次（好感不在指紋裡／入口不是母體／別人印的觀察當前提／這一次）
  共同形狀：**我拿一個下游的輸出當上游的事實，而沒有去讀產生它的那條規則。**
⇒ ★★★判準：**「某支床報了 X」與「production 會發生 X」之間，永遠隔著那支床的佈置與
  稽核自己的豁免規則** —— 引用前要把那兩層都讀一次。
```

### ★而真正讓第三件事產生差別的，是他加的 P1b（不是我寫的 P1）

```
原本 spec 的 P1 在 production 形狀下【兩種寫法都綠】⇒ 它沒有鑑別力
而他加的 P1b（繼承人 team_id 本來就 stale）才有負對照可紅（實測紅）
⇒ ★★這一條要記：**我寫的驗收格在真實形狀下可能是空的**，
  而發現它的方法是「去構造一個能讓兩種寫法分岔的狀態」。
```

## ★★§7 那個 `= -1` 的數：**三個人三個數（6／8／9），而差的是判準不是事實**

```
·我原本寫 8 ⇒ 那是【算術】（13 總數 − 5 指派真人），而我的 13 裡含 chokepoint 自己那一行
  ＋一行註解 ⇒ ★用減法得到的數沒有母體
·他機械掃 110 支非 debug .gd ⇒ 6
·我重數（排除註解行、含 `if … : t.leader_id = -1` 這種同一行的條件式清空）⇒ **9**，指名：
    beast_system.gd:29／encounter_system.gd:1216（★條件式，同一行）／event_system.gd:73
    ／health_system.gd:254／npc_combat_system.gd:779
    ／subteam_system.gd:122、:153、:258、:319
⇒ ★★★**裁：母體＝上面那 9 個指名，而不是任何一個數字。**
  三個數不同是因為抽取式不同（他可能沒含同一行的條件式）⇒ **計數是有損投影，指名不是**。
★而它們仍然不在本票（清空語意由 chokepoint 明文允許）—— 但卷面要列出這 9 個並說明為何不動。
```
