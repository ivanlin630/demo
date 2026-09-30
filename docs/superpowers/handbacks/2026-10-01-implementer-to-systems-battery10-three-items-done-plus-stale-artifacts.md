---
from: implementer
to: systems
status: open
topic: ★merge 錨：遠端 tip ＝ `75c139075`（`fix/exploration-two-english-strings`）｜你交代的三件全做完並各自實測綠｜★★而過程抓到兩件你沒點的：**main 上的 exploration artifacts 過期了 114 列**、以及那筆既存不變量違反的**確切成因行**
---

# ★merge 錨

```
branch fix/exploration-two-english-strings
遠端 tip ＝ git rev-parse origin/fix/exploration-two-english-strings
         ⇒ 75c139075601361b4a47d1b4c2372512408efb4b
base 已 rebase 到 origin/main ＝ 0090cdfe5（含你那兩個修）
```

## 四個閘實測（rebase **之後**重跑）

```
bash .claude/hooks/headless-regression.sh
  ⇒ [HEADLESS] HARD-FAILS ＝ 3 ｜ baseline ＝ 3
     [HEADLESS] ✓ 失敗清單與 baseline 逐條相同（★不只數量）
     [HEADLESS] PASS
scripted_exploration  ⇒ 本輪 (d) ＝ 0 筆（走過 131 步）
                       === scripted_exploration DONE === errors: 0｜到場點名 10／10｜症狀 1 筆｜步數 131
available_actions     ⇒ === available_actions DONE === errors: 0｜到場點名 11／11
available_actions_controls ⇒ passed 8/8
ui_flow_test          ⇒ errors: 0｜68／68｜available_actions_bed 8（地板 8）
```

# 一、你交代的三件

## ①兩句英文識別字
`:458` 不再把引擎的 `resp`（accept／refuse／reject）直接印給玩家
⇒ `"外交結果：%s" % PlayerApiMapper.diplomacy_reply_label(resp)`；
`:1336`「目標非自家 outpost」⇒「那一格不是你自己的據點」。
★新增的 `diplomacy_reply_label()` 放在玩家面字串的唯一生產者裡，而它**刻意不重用 `forced_label()`**：
後者是【玩家自己要按的選單標籤】（帶 ✓／✗、吃 `evt` 與 `state`），這裡要的是【對方回了什麼】
⇒ 兩者主詞不同，共用會讓畫面把「✓ 接受」當成對方的回答。★★未知值不吞（印「（未知回覆：xxx）」）。

## ★②expect 9／9 → 10／10，而我**沒有**把「症狀 N 筆｜步數 N」放進 expect
逐字抄自輸出的是 `=== scripted_exploration DONE === errors: 0｜到場點名 10／10`。
★理由：那兩個數會隨世界走法變動 ⇒ 放進 expect 會讓這一格變成「**世界不許改**」的閘。
★★而「到場點名」不會隨世界變（它是格數）⇒ 它才是該釘的那一段。

## ③那兩條 assert
兩行原文**留著劃掉**、理由寫在原處。新語意：
```
·入口那一條方向反過來：`recruit` 在 coin=0 時**仍然列得出來**
·「coin 足夠時可選」在新語意下【恆真】⇒ 換成驗 `recruit_anon`（★錢真正在守的地方）雙向
```
★而第一版我沒佈置對方的無名之人 ⇒ 正向那一半紅，**而紅的原因是沒有人可招不是沒錢**
⇒ 補 `AnonTierSystem.add_anon` 並**印出佈置生效了**
（`[佈置] 目標隊無名之人 = 3 人｜玩家 coin = 100（RECRUIT_COST_ANON = 50）`）。
★★一個紅在錯理由上的斷言會被讀成「錢那條守衛在工作」。

## ★★★而我多做一件：把那個血證釘成票內的一格（P12）
你那條判準（「兩個版本行為相同」的斷言，母體必須含會讓兩者分岔的**退化狀態**）
⇒ 我把 `coin = 0` 釘進**本票自己的床**，兩半：
①每一個宣告過的入口仍然可做、原因仍然空　②`recruit_anon` 消失**並說出原因**
（實測 `金幣不足（需 50，現 0）`）＋衍生檢視那一半。
★只驗 ① 會讓「全部都永遠可做」也綠；只驗 ② 抓不到入口被錢擋掉。
★★第八道負對照：把入口那一格關掉（`elif false and SUBMENU_OPENERS.has(act)`）⇒ P12 紅。
棘輪 `CONTROL_FLOOR_AVAIL` 7 → 8。
⇒ ★★★接住裁定與 code 分岔的是【跨切面的網】，而票內的守衛沒接住 ⇒ 現在票內有了。

# ★★二、你沒點的第一件：**main 上的 exploration artifacts 過期了 114 列**

```
committed 版本來自 `2656643ec`（「131 步、115 筆症狀落在 5 個成因」那一顆）
  ⇒ rule 分佈：a 1｜b 1｜c 41｜d 72 ＝ 115
而今天實跑 ⇒ 1 筆（只剩那筆 a）
⇒ 差 114 列，而它從 ⑤ merge 之後就一直躺在 repo 裡
```
★★而**沒有任何東西紅**：那一格的 expect 只比**橫幅那一行**，artifacts 是它的產出而**沒有人在讀**。
⇒ ★★★所以 repo 裡躺著一份**說謊的卷面**：任何人打開它會看到 72 筆 (d)，而世界早就 0 筆了。
⇒ 我這一輪把它刷新了（含 `跑的是哪一棵樹：sha 43e43e9b6`）。
⇒ ★而結構問題我不自己開票：**「床的 artifacts 要不要進閘」是你的格**。
  我只放一個判準在檯面上：**一份產出如果沒有任何斷言在讀它，它的過期是靜默的**
  —— 而它比沒有那份產出更糟（沒有的話人會去跑，有的話人會去讀）。

# ★★★三、你沒點的第二件：那筆既存不變量違反，我找到**確切的成因行**

```
`a｜L3:choose_heir(alliance)/heir_128｜InvariantAudit 回報 1 條違反：
  roster 反向破 P127 team_id=48 但不在該隊 roster(leader/named)`
★它在【新舊兩版 artifacts 裡逐字相同】⇒ **既存，不是我帶進來的**（我核過才敢這樣寫）
```
成因行：`scripts/data/world_state.gd:624`
```gdscript
if old_id != -1 and old_id != pid and old_leader_action == "member":
	...
	add_member(team, old_id)   # 舊 leader 降 named
```
⇒ **`old_leader_action` 的預設是 `"none"`** ⇒ 舊 leader **保留 `team_id` 而不進 roster**
⇒ 就是那條違反的字面。而 `choose_heir` 走的是 `state.set_leader(team, heir_id)`（用預設值）。
⇒ ★兩個讀法，而我**不自己選**：
```
(甲) 它是 fixture 的不真實：production 的 `choose_heir` 只在領袖【死了】才 fire
     ⇒ 舊 leader is_dead ⇒ `InvariantAudit.check` 會跳過（`invariant_audit.gd:94`）
     ⇒ 那麼要修的是**床的佈置**（把舊 leader 標死），不是 `set_leader`
(乙) 它是真洞：有某條路帶著【活的】舊 leader 呼 `set_leader(..., "none")`
     ⇒ 那麼 `set_leader` 要對「活的舊 leader」有守
```
★★而我今天在領袖咽喉那張票**已經遇過同一件事**（我合成的 `choose_heir` 沒把舊 leader 標死
⇒ 那時我把「①有血證」那個前提撤回）⇒ **同一個根，第二次從不同的門進來**。
⇒ ★★★所以我建議 (甲)＋一句：`set_leader` 的檔頭把「`old_leader_action` 預設 `none` ＝
舊 leader 變成有 `team_id` 而不在 roster 的孤兒」**寫出來**，因為它今天已經騙過兩個人
（兩次都是我）。而要不要加守是你的裁定。

# 四、清單狀態

```
①兩句字串        ✔ 實測綠
②expect 9→10     ✔ 實測綠（★沒把會漂的數字放進 expect）
③兩條 assert     ✔ headless 閘 PASS、HARD-FAILS 3／3 逐條相同
＋P12 與第八道負對照 ✔ 8/8 全紅、棘輪 8
```
★#10 那批（4 顆未驗證，branch `feat/text-ui-layout-v2` 本機 `1f32c8289`）**還沒驗** ——
機器剛還我，我先做你交代的這三件。下一步照我自己那條順序：先跑那四顆、綠了**先推**，再套草稿。
