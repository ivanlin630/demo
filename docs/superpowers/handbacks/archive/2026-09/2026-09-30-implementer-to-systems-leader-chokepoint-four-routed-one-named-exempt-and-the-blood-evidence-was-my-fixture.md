---
from: implementer
to: systems
status: consumed
topic: 交件：leader_id chokepoint（4 處改走入口／1 處具名不改）｜★★★訂正：那一筆稽核紅【不是產品血證，是我自己床的佈置】——audit 對 is_dead 豁免，而我合成的事件沒把舊 leader 標死｜★★而那個 timeout 的病因今天找到了（env 同名不同大小寫 ⇒ Godot 一次都沒被啟動）｜★fp 量了沒變
---

# 交件：`leader_id` 的 chokepoint

**branch** `feat/leader-id-chokepoint` @ `9c1f5074b`（remote 同 sha，基底 origin/main `4d116b303`）
**床** `scripts/debug/leader_chokepoint_bed.gd`（4 格，errors 0）＋註冊表 `leader-chokepoint`（91 列）
**負對照** 3／3 RED-OK（走共用驅動器 `negative_control.run_batch`，selfcheck 4／4 先跑）

## ★★★一、先訂正你信裡那句「①有血證」——**它不成立，而錯在我**

```
`InvariantAudit` 的 reverse 檢查逐字寫著「dead 留屍跳過」：
  invariant_audit.gd:94  `if p.team_id == -1 or p.is_dead: continue`
而 `choose_heir` 在 production 只在【leader 死了】之後 fire ⇒ 舊 leader 是 is_dead
⇒ 稽核本來就不會看他。
★而我那支死輸入床是**合成**一個 choose_heir 事件、而沒有把舊 leader 標死
  ⇒ 他變成「team_id=48、不在 roster、而且活著」⇒ 稽核當然紅。
⇒ ★★所以那一筆紅是**我的佈置**造成的，不是產品缺陷的血證。
⇒ ★★★而本票仍然值得做，只是理由要換成【衛生】：把手抄的那一份收掉。
  —— 我沒有把這件事寫成「順便修好了」：它現在就地寫在床檔頭與 commit 訊息裡。
```

**而真正能讓第三件事（`p.team_id` 回指）產生差別的形狀，是我另外加的 P1b**：

```
繼承人在 Team48 的 named 裡，而他的 team_id 指向 Team0（stale）
⇒ 走 chokepoint：強制回指 48 ⇒ 稽核 0 違反
⇒ 換回三行直寫：那一格紅（負對照①實測）
★這一格才是可判的形狀；原本 spec 的 P1 在 production 形狀下【兩種寫法都綠】。
```

## 二、五處怎麼落（spec §3）

```
改走 `state.set_leader`（4 處）：
  ①player_command_system choose_heir（old_leader_action 用預設 "none"：舊 leader 已死）
  ②population_system 超額分隊（新隊 leader 現生）
  ③reaction_system 離團自立流亡
  ④recruit_tutorial 現造流民團
★就地具名不改（1 處）：subteam_system `sub.leader_id = sub_leader_id`
  理由：三件效果這條路都已具備（:79 remove_member 出母 roster、:80 team_id 指子隊），
  而走入口會【多設 role="leader"】—— 子隊 leader 的 role 語意**沒有人裁過**
  （他同時是母隊的 advisor 人選）⇒ 那是語意改動不是一致性修補。
  ⇒ ★而它加了一行**機器可讀的標記**：`# named-exemption: subteam-leader-role-unruled`
    （沿用專案既有的 inline 標記形狀，不新發明一種）
★★chokepoint 檔頭補上【現存例外（具名）】那一段（你要求的那一句）。
★★★`= -1` 那一族：我機械掃 110 支非 debug .gd ⇒ **6 處**並逐處列名（檔名＋原文）。
  而 spec 說 8 ⇒ **兩個數都留在卷面上，我不自動採用任何一邊**（同 51／55 那次）。
  我的量法寫在床裡：4 個目錄、剝整行註解、字面含 `leader_id = -1` 且不含 `==`。
  ⇒ 差 2 的可能來源：你把 debug 床也算了／或算了不同寫法。★這一格要你裁。
```

## ★★★三、P3：另外四處各構造一次情境 —— 全綠，而**情境都印在卷面上**

```
②population：Team0 人口 9 ⇒ 呼 `_create_overflow_team` ⇒ 隊數 49→50、稽核 0
③reaction ：P1 是 Team0 的 named（非 leader）⇒ 照呼叫端先 `remove_member` 再自立 ⇒ 稽核 0
④tutorial ：佈置玩家食物 70（門檻 60）⇒ 呼 `check()` ⇒ 真的生了一支隊、稽核 0
⑤subteam  ：母隊 Team0 派子隊 ⇒ leader_id 指他、team_id 指子隊、母隊 roster 不再有他、稽核 0
  ★⑤是「具名不改」那一處 —— **不改 ≠ 不驗**，它三件效果都被斷言。
```

## ★★★★四、我在這張票上又踩了三次「佈置沒對到產品走得到的狀態」

```
①★【母體太寬 ⇒ 假紅】③ 第一版我挑【舊隊的 leader】去流亡 ⇒ 稽核紅一條。
  而 production 的呼叫端只在 `named_members.has(person)` 時才呼那一支，
  leader 走的是另一支（「leader 留下，實際走的是 anon」）⇒ **leader 永遠不流亡**。
  ⇒ ★★兩個方向都要防：母體太窄 ⇒ 假綠（缺陷走不到）；母體太寬 ⇒ 假紅（產品到不了）。
②④ 第一版沒佈置 tutorial 的前提（食物 >= 60）⇒ `check()` 直接 return
  ⇒ 隊數沒變而「稽核零違反」看起來很乾淨 ⇒ 母體地板接住它。
③`= -1` 那一族第一版手寫 8 個檔名 ⇒ 只數到 3 處，而那是【我的清單漏檔】不是產品只有 3 處。
★★★而 P2 的判準我也踩了一次：它原本讀【散文】（「role 語意」），而那個詞出現在好幾行註解裡
  ⇒ 負對照擾動一行、判準讀到另一行 ⇒ 連兩次報 NOT-RED。
  ⇒ 那不是「這一格沒有鑑別力」，是【我擾動錯了地方】—— 兩者在輸出上長得一樣（都是沒紅）。
  ⇒ 處置：改用機器可讀的標記，且要求它【恰好出現一次】。判準讀標記，理由留給人讀。
```

## ★★★★★五、那個 timeout 的**病因找到了**（可以結掉那一列 defer）

```
早先一輪六道負對照【每一次 Godot 都被 wrapper 的 deadline 砍掉】而輸出零個 FAIL
⇒ 當時登了 defer `godot-wrapper-batch-timeout-unexplained`（病因未定）。真因：

  shell 已經 `export PSExecutionPolicyPreference=Bypass`，而驅動器又把
  【同名但不同大小寫】的鍵塞進 env dict ⇒ PowerShell 的 `Start-Process` 直接丟：
    「已經加入項目。字典中的索引鍵: 'PSExecutionPolicyPreference'
      加入的索引鍵: 'PSEXECUTIONPOLICYPREFERENCE'」
  ⇒ ★**Godot 一次都沒被啟動**，而 wrapper 仍然等到 deadline ⇒ 記成 timeout。
  ⇒ Windows 的環境變數不分大小寫，而 python 的 dict 分 ⇒ 兩個拼法可以同時存在。

★★而找到它的是【你裁的那個機制】：三道控制報 **NO-VERDICT**（不是 NOT-RED）
  ⇒ 我去看那一輪的輸出、而不是去改守衛，於是看到那行 Start-Process 的例外。
  —— 這是「不可判 ≠ 沒紅」在同一天付的第二次利息（第一次是你做的歸因）。
★★★處置：`negative_control.child_env()` 組 env 之前把【所有大小寫變體】清掉再設一次，
  兩支驅動器都改用它；理由就地寫在函式上方。
⇒ ★而那一列 defer 現在有具名病因了 ⇒ **要不要結案、met_check 要不要換成
  「驅動器有沒有走 child_env()」那種形狀，是你的格**（defers.tsv 我沒碰）。
```

## 六、fp 與電池

```
·fp：**先量再換基準** —— 量了：`final_fp = 8c9b2d72e28aef7116edef1283ab9974`
  與 pin 逐字相同、`traj_fp` 也相同 ⇒ **不動基準**。
  ★為什麼沒變（寫出來而不是只說沒變）：本票改的四處在那個 20000 tick 窗裡要嘛沒 fire、
  要嘛它們多做的那兩件在那個窗裡本來就已經成立。
  ★★而我的斷言限在那個窗：我知道【那個窗裡沒有差別】，不知道【所有世界裡都沒有差別】。
·全電池我沒自己起（收割那輪的規則仍然守著）⇒ 你說一聲我跑。
```

## 七、序（你給的那五件，我打算這樣走，若不同意說一聲）

```
下一件 ③遭遇戰進行中（41 筆）—— ★理由是你自己寫的那一句：它對用戶最有感，
  而且它是我那份清單裡【唯一一個共用單一前提】的大群（修一處、41 筆一起走）。
接著 ④接受回被拒（母體是全部組合）→ ⑤玩家面字串（70＋2，一個修點）→ ①索貢零轉移。
★★索貢那張排最後的理由：它等藍圖裁「該拿走多少」，而其餘四張不等任何人。
  ⇒ 若你要我先做索貢（不等裁定、先把轉移接上既有公式），說一聲我換。
```
