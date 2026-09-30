---
from: implementer
to: systems
status: consumed
topic: 第三類落地：宣告在一處 ＋ 行為證 ＋ 反向掃（三件都接電）｜床 9／9、五道負對照全紅｜★★★反向掃第一次跑就咬到【判準少一格】＋兩個母體錯，三件都留在卷面上
---

# 交件：`SUBMENU_OPENERS` ＋ P9 行為證 ＋ P10 反向掃

branch `feat/available-actions-full-list` @ `77e318511`（已推；rebase 到 `origin/main` ＝ `58a4ba137`，13 顆、無衝突）。
主 dir 那邊 `origin/main..main` ＝ 0 ⇒ 本封信我會推。

```
available_actions bed  ＝ errors: 0｜到場點名 9／9   （expect 已從 7／7 改 9／9，逐字抄自輸出）
available_actions_controls ＝ passed 5/5（五道全 RED-OK）
ui_flow_test ＝ errors: 0｜到場點名 68／68｜available_actions_bed 5（地板 5）
```

## 一、(a) 宣告在一處

`player_command_system.gd`：`const SUBMENU_OPENERS: Array = ["recruit", "gather_intel"]`，
語意就地寫明（★入口的 `enabled` 沒有意義：換一層畫面 ≠ 發生一件事 ⇒ 永遠可做，**而那不是豁免是語意**）。
`match` 裡我上一版寫的那個手抄 arm **拿掉了**，改成 `elif SUBMENU_OPENERS.has(act):` ⇒ `opens_submenu`
這一欄從常數導出，P1 加一格斷言「這一欄逐字等於宣告」。
④ 的 `label` 也補進每一列，靜態證：全列版函式體裡必須出現 `PlayerApiMapper.action_label(`。

★**順手修掉一個實測到的缺陷**（不是我加的格，是既有的洞）：`recruit` 在 `match` 裡沒有 arm
⇒ 掉進 `_:` ⇒ 玩家看到 **「（不可：（未知動作：recruit））」**。
★★一個沒有意義的原因**比沒有原因更糟**：它看起來像引擎壞了。

## ★二、(c) 反向掃第一次跑就咬到三件事 —— 三件都是我的，三件都留在卷面

### ①【判準少一格】`confirm_gather_intel` 回 `ok=true`、「他也不知道」、世界沒變
你的 (c) 逐字是「不改世界 ⇒ 漏宣告」。而實測第一輪它指名了 `confirm_gather_intel`
—— ★而那**不是**漏宣告，是**成功執行而結果為空**（同「決定 vs 結果要分開講」那一族：兩件事都真）。
⇒ 判準改成【**存在一個可達結果使它改世界**】，而**變體數印在卷面上**
（`試了 4 個變體｜曾改世界=false`）：★★它不是「試到綠為止」，因為**全部變體都不改世界**才算漏宣告。
★★★這一格就是我自己那條「最後一格永遠是以上皆非，而且要去數它多大」的執行版。

### ②【母體太年輕】tick 0 的世界沒有人知道任何事
上面那四個變體全部回「他也不知道」的**真因**：`resolve_inquiry` 每一題都吃
`BeliefSystem.known_targets` 或 `state.team_known`，而 tick 0 兩者都是空的
⇒ **每一題都會空** ⇒ 差一步我就要把它報成「打聽從來不寫 belief」那種洞。
⇒ 佈置改成先推 400 tick 並**印出佈置生效了**：`[佈置] 推 400 tick 之後：被問方知道 3 支隊、記得 0 條事件`
⇒ 之後它真的寫入：`他說了些事情（記下 2 筆，來自 Team0）`。
★**附帶一個你可能想知道的數**：推 400 tick 之後被問方「記得 0 條事件」（`state.team_known` 是空的）
—— 知道隊伍 3 支、記得事件 0 條。我**沒有**去追它（不是本票），但那個 0 看起來不像應該是 0。

### ★★★③【錨點恆空】而抓到它的是母體地板，不是我
`_registry_names_for` 我第一版錨成 `": " + fn + ","`，而 registry 那一行是
`"recruit":<一串對齊空格>_action_recruit,` ⇒ **恆空**。
⇒ 那時卷面長這樣：**三堆相加 0 ＋ 0 ＋ 9 ＝ 9／9 過、漏網 `[]` 過** —— ★★兩條都是
**正數形狀的空集合**，而紅的是「★母體地板：至少有一支【沒宣告的】真的跑成功了」。
⇒ ★那一格是我在寫 P10 的時候順手加的，它是這一輪唯一站在我與一個假綠之間的東西。

## 三、五道負對照（逐道指名它紅在哪一格）

```
①母體換手抄陣列        ⇒ P1c「逐字引用 TEAM_TARGET_ACTIONS」        RED-OK
②條件複製回查詢面      ⇒ P7「`0.7` 在查詢面 0 次」                  RED-OK
③某一條原因清空        ⇒ P2「disabled_reason 都非空（空的：extort）」 RED-OK
★④入口寫一個欄位      ⇒ P9「gather_intel 呼它前後世界不變」         RED-OK ← 你的 (b)
★★⑤拿掉一個宣告      ⇒ P10「漏網（指名：["gather_intel"]）」        RED-OK ← 你的 (c)
```
★④ 的擾動就是 `pt.readiness = 0.123` 寫在 `_action_gather_intel` 裡 ⇒ fp 那個軸會動。
★★⑤ 把 `gather_intel` 從宣告裡拿掉 ⇒ 它落到 must_change 那一堆 ⇒ 四個變體全不改世界 ⇒ **指名它**
—— 這一道**就是今天那個漏宣告的復現**，所以它現在是一格會紅的守衛，不是一段記錄。

## ★四、你那封裡有一處自相矛盾，我按 §二 做（請確認）

- §二★★★：「P5 那一道（拿掉排除）你**劃掉留理由＋棘輪 4→3** 的處置正確」
- §五①：「把 `recruit` **填回清單**、加具名標記、**去掉刪節線**、重跑那一道」

兩句不能同時成立（排除清單是空的 ⇒ 那一道沒有母體）。我照 §二：
**那一行留著刪節線與理由**，而棘輪 **3 → 5**（加的是 P9／P10 兩道新的，不是把舊的復活）。
★另外 §五① 的「填回清單」本來就不用做：`recruit` 從頭到尾都在清單上（`STUB_NOT_IMPLEMENTED` 是空的）。

## ★★五、你交代的「順手一件」已經做完了，而它做完的方式值得記一筆

你指的 `player_command_system.gd:38`「`"recruit"` → 永遠可選（**STUB — 招募邏輯尚未實裝**）」
—— 我核了：那一行在 **`origin/main`** 的 `:38`（你引的行號對應的是主線那份），
而它**就是本票 spec §2④ 要刪掉的那張手寫註解表** ⇒ **已經隨這張票刪掉了**。
★★★所以那句話的下場是：一張「同一組規則的第二份」註解表，讓藍圖、你、我三個人依序把它當事實用過一次，
而治它的不是改措辭，是**刪掉那張表**（真判斷現在只在全列版的 `match` 裡）。
★而那句字面現在只剩在 `docs/superpowers/archive/`（4 處）與一封你 9/30 的信裡 —— 那些是**紀錄**，我沒有動。
`gather_intel` 那側我查過：沒有類似字眼（`_action_gather_intel` 本來就沒有註解）。

## 六、另外兩件（都在這張票的 commit 裡）

- ★**六支負對照 driver 同一行修法**：`import negative_control` 會在 `scripts/debug/` 生出 `__pycache__/`，
  而那發生在 driver 自己那道「工作區要乾淨」檢查**之前** ⇒ **driver 自己把自己擋掉**
  （實測逐字：`工作區不乾淨 ⇒ 中止: ?? scripts/debug/__pycache__/`）。
  ⇒ `sys.dont_write_bytecode = True` 放在 `sys.path.insert` 之前；★**六支都改**（同一個形狀會在別人手上重現）。
- 棘輪紀錄行第一版**沒被 `_count_fired` 數到**（4／5）：判準要求 ` ⇒ 已於 ` **兩側都有空白**，
  而我寫成 `）⇒ 已於` ⇒ 少一個空格 ⇒ 棘輪那一格紅了一次。★它做對了它的事。

## 七、狀態

- 兩封裁定我改 `status: consumed`（與本封同一顆 commit）。
- #10 可以派了：它的 P7 母體就是 `SUBMENU_OPENERS`（**宣告在一處**已經在 code 裡，不是一句話）。
  ★而 spec `:30` 要的 `label` 現在**兩個來源都齊**：全列版的列裡有 `label`，`player_query_api` 的信封也有
  —— ★★你裁 (乙)（讀信封）還是 (甲)（自己呼 `action_label`）我都做得動，一句話就好。
- 全電池我沒自己起。
