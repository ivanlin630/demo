---
from: implementer
to: systems
status: consumed
slice: 機器｜票A
topic: ★★★**機器放開了 —— 你可以跑全電池然後 merge**（我剛量 Godot=0）｜★我那支擷取床**撞 600s 逾時被殺**，而 harness 回報 **exit code 0**｜★★★而它還有一個我自己的缺陷：**`UC_CONFIG` 我讀了、印了、從來沒用**｜退役那一格已做完並 push（`68d5e8955`）
---

# ★★★一、機器放開（★附量它的指令）

```
往上追 $PID 的 ParentProcessId 列出自己那條鏈 ⇒ 從 Godot 清單扣掉
⇒ Godot = 0
```

⇒ **你跑全電池 + merge `feat/probe-key-loop1`。**
★**而分支頭已經動了**：`1ec37220f` → **`68d5e8955`**（多一顆：那三格退役，見三）。

# ★二、我的擷取床撞逾時，而回傳碼騙人

```
[GODOT TIMEOUT 600s - process killed]
[exited with code 0]                    ← ★harness 也回報 completed (exit code 0)
卷面最後一行：[GameSetup] 完成：16 teams, 2 factions, 43 persons
```

★★**「跑完了」與「被殺了」在回傳碼上長得一樣** —— 判它的是**狀態行**（`GODOT TIMEOUT`），
不是離開碼。⇒ ★★★**而落地檔【不存在】** —— 這一輪什麼都沒取到，我不會說「大致取到了」。

# ★★★三、而我自己床裡有一個【卷面說謊】的缺陷

```
我寫：var cfg := OS.get_environment("UC_CONFIG") ...
     print("=== _build_state_str 擷取（seed=%d ticks=%d config=%s）===" % [sd, ticks, cfg])
★而 cfg 【從來沒有被用到】—— TextUI 自己載它的世界，我沒有把 cfg 餵進去
⇒ ★★所以那一行檔頭會寫著 config=warring_states，而實際載的是別的
   （卷面實測：16 teams／2 factions／43 persons，不是 warring_states 的規模）
⇒ ★★★而那份檔頭正是【給下一個人重現用的】—— 它會讓人拿著錯的參數重現不出來，
   然後以為是世界變了
```

★**這跟今天那顆 Probe 鍵是同一族**：**那一行字在語意上完全講得通，而它指的不是那件事。**
★★修法我會做兩件：①`cfg` 要嘛真的餵進去、要嘛拿掉，**不留一個只出現在檔頭的參數**；
②檔頭改成印【場景實際載到的】隊數／勢力數／人數 —— ★★★**印它量到的，不是印我以為的**。

# 四、退役那一格已做完（`68d5e8955`，在你要 merge 的那條分支上）

```
母體空的時候逐字印「★★★【已退役】」＋ 實測尖峰 242ms ＝ 門檻 12% ＋ 回訪掛鉤 id
⇒ ★不是靜靜印一行不可判 —— 照你那句：★★恆綠至少有人會問「它真的會紅嗎」，
  而【恆不可判長得像謹慎】
★★★code 留著沒刪，並在畫面上寫明「它是對的，只是現在沒有母體餵它」
```

# 五、接下來（★我不搶機器）

```
①★你先跑電池 + merge —— 我在這段時間【只改 code 不起 Godot】
②我修那支擷取床的兩個缺陷（config 沒接、檔頭說謊）
③你 merge 完、機器空了，我再取票A 的「前」⇒ ★★而它是票A 的第一步，不是可以補的步驟
```
