---
date: 2026-10-06
from: implementer
to: systems
status: consumed
slice: 進貢提案（`tribute_offer`）—— 接受要收得到貢，而提案者要讀得到結果
---

# 交件：進貢迴圈票七件 ｜`BATTERY_RC=0`｜**99 綠／0 紅**

- branch `feat/text-ui-layout-v2`，base ＝ `origin/main` **`b1b677647`**（已是我 HEAD 的祖先）
- **四顆 commit**
  1. `3e2d9f85e` 引擎側（拆轉帳／共用收尾／三個出口／豁免清單清空＋兩道母體地板）
  2. `577a8ef6c` 新床七格 ＋ 註冊表 `tribute-offer-loop`
  3. `ef6626cd5` 電池那兩紅（都是我造的）＋ 到達序列按 `action` 分類印
  4. `4bb1d0797` 電池第三紅（artifact 的 sha 被我自己的 rebase 改成孤兒）
- **exact path**
  · `scripts/simulation/diplomatic_ai_system.gd`（`apply_tribute_transfer` ＋ `settle_tribute_offer`）
  · `scripts/simulation/interaction_system.gd`／`player_command_system.gd`／`sim_runner.gd`
  · **`scripts/debug/tribute_offer_loop_bed.gd`**（新，七格）
  · `scripts/debug/forced_event_panel_bed.gd`／`success_sentence_bed.gd`／`trade_accept_bed.gd`
  · `scripts/debug/ui_flow_test.gd`（`CONTROL_FLOOR_TRIB`）／`scripts/debug/scripted_exploration_bed.gd`
  · `docs/process/merge-gates.tsv`（新列 `tribute-offer-loop`）

---

## §1 七件逐件（報數字不報狀態）

| 件 | 做法 | 實測 |
|---|---|---|
| ①接受＝收貢 | 新 arm 呼 `apply_tribute_transfer`（**不呼** `_pay_extortion`） | 玩家 2110.1 → 2160.1／對方 500 → 450，**兩邊的差相等**（50.0000 vs 50.0000） |
| ②拒絕一句話 | 婉拒句 ＋ 收尾 | `婉拒 Team7460 的提案` |
| ③共用收尾 | `static func settle_tribute_offer` | 定義 **1** 處／呼叫點 **4** 處／反向掃無第五處手抄 |
| ④差集 | mapper × handler | **今天真的紅過**（`{tribute_offer}`）⇒ 已歸零：A **5**／B **7**／差集 `[]` |
| ⑤倒付＋正向 | 新床 P1 ＋ 既有那一格 | 負對照讓**兩支床**同時紅（見 §3） |
| ⑥`"tributed"` | 兩個方向 | accept 後 `0 → 0`／索貢 `0 → 1` |
| ⑦三出口各一格 | P3a／P3b／P3c ＋印序列 | 三道各自紅 4 條（見 §3） |

- ★**呼叫點是 4 個不是 spec 寫的 3 個**，而你已核過它是**我 spec 的母體錯不是我多做**：
  `interaction_system` 那條 NPC↔NPC 出口**本來就手抄同樣三行** ⇒ 接上去是**少一份會漂的複本**。
- ★★拆函式的理由（裁 甲）：`apply_tribute_accept` 同時做**轉帳**與**寫關係**，
  而關係那一半的方向**隨情境相反**（索貢＝強制 ⇒ 結仇邊；主動進貢＝自願 ⇒ 不該結仇）
  ⇒ 重用整支 ＝ 把強制情境的關係語意**偷渡**到自願情境。
- ★★★而「寫正面」被否決的理由最硬：**寫正面 ＝ 把保險誤記成友誼**
  ⇒ **錯誤不會留在那一筆記憶裡，它會跑到後面每一個讀好感的決策上。**

## §2 ★★★★★★三個我自己踩到的，而三個都被機制接住

1. **P1b 的抽取式讀錯兩個名字**：我寫 `p.memories`／`"kind"`，真實是 **`p.memory`／`"type"`**
   （`npc_ai_system.gd:88-91`）⇒ 它**恆回 0** ⇒ 方向①「accept 後 ＝ 0」是**恆真**。
   ⇒ ★**抓到它的是方向②** —— 那正是你 spec ⑥ 要求兩個方向的理由，而它**當場付清了成本**。
2. **`trade-accept` 那一條的方向原本是錯的**：標題寫「**沒有被放寬**」（不准變大），
   ★而它實際斷言 `unknown_ok.contains("tribute_offer")` ＝「**必須在裡面**」（不准變小）
   ⇒ **兩者相反**，而那個差**在缺陷被修掉的那一天才看得見** ——
   它變成**要求一件世界已經不成立的事**（要求那個缺陷繼續存在）。
   ⇒ 改成只守它要的那個方向（不得含 `propose_trade` ＋ 具名基準 `SPEC_UNKNOWN_OK_MAX = 0`
   而那個數印在卷面上）⇒ ★**窄化不是刪除**：它守的是真東西（有人為了讓紅變綠把提案塞進豁免）。
3. **artifact 的 sha 被我自己的 rebase 改成孤兒**：我先 commit artifact（記 `2ad598724`）
   **然後才 rebase** ⇒ 落後 6 顆、祖先 ＝ false。
   ⇒ ★★而**這正是我 2026-10-01 在那支床檔頭劃掉的那一句**：我當時寫
   「rebase 那個解釋**對那一次不成立**」——而那句只對**那一次**成立（那次是 `--amend` 造兄弟）；
   **這一次就是 rebase 那一種** ⇒ **兩種成因都真的存在**。
   ⇒ ★★★判準：**排除一個解釋時要說清楚排除的是【這一次】還是【這一類】**
   —— 我當時寫得像後者，而它其實是前者。
   ⇒ 可執行的那一條已寫進檔頭：**那支床要在【最後一次 rebase 之後】才跑／才落地**
   （順序反過來必然把 sha 變孤兒，而它紅起來的樣子與「有人手改過 artifact」一模一樣）。

## §3 負對照（四道，全部實測紅，而紀錄用單行格式寫進床裡）

| 擾動 | 紅在哪 | 指名了什麼 |
|---|---|---|
| 接受那一支額外走 `_pay_extortion` | 新床 P1-a／P1-b **＋既有那個倒付守衛** | 方向逐字相反：玩家 2110.1 → **1685.3**、對方 500 → **924.8**；舊守衛 500.0 → **387.5** |
| 接受那一支的收尾刪掉 | **P3a** 紅 4 條 | `order_task` 沒清／cooldown 無鍵／cooldown ＝ -1／★**24h 窗內再到達 1 次** |
| 拒絕那一支同上 | **P3b** 紅 4 條 | 含 24h 窗內再到達 1 次 |
| `sim_runner` 專屬分支刪掉 | **P3c** 紅 | 含母體地板「面板真的被逾時清掉」—— ★沒收尾的話對方**在同一個窗裡又擺了一個面板** |

- ★那個「**實得 1 次**」就是用戶那句「**接受或拒絕都一樣重提**」被機械重現的樣子。
- ★★而 spec P2「既有那一格不得弱化」**有實證**（同一個擾動讓兩支床同時紅），不是一句話。

## §4 ★你給的那條界限：**印出來，不要斷言**

```
P3a 窗內到達按 action 分類 ＝ { "extort": 2 }｜★其中 diplomacy ＝ 0（＝路徑 2 那一類）
```
- `extort` ← **路徑 3**（`TASK_LOOT`）／`tribute_offer` ← **路徑 2**（`TASK_DIPLOMACY` ＋ `order_task`）
- ⇒ 那兩次到達證明的是**①接觸真的發生了 ②不覆蓋閘沒被占住**，
  ★**不證明路徑 2 可達**，也不證明有 NPC 本來會帶 `TRIBUTE_OFFER` 來。
- ⇒ ★★所以**刻意不加**「路徑 2 到達 ≥ 1」那種斷言：那會要求一件世界在那個窗裡還沒做到的事，
  而**它紅起來的原因跟這張票無關**。而「零進貢再到達」照舊是斷言（它是這張票治的那個病）。

## §5 ★誠實限（寫在床裡，不是寫在這封信裡）

P3b／P3c 的窗**整個零到達** ⇒ 它們**在格內**沒有「對方本來可以再來」的證據，
而那個證據**在 P3a 那一格裡** ⇒ ★**只讀 P3b 的人會推論出一件那一格自己說不出的事。**
⇒ 正解不是把三格併成一格（spec 明寫不准），是把限制寫下來**並且三格都印序列**。
★而它寫在**床裡**而不是這封信裡 —— 照你那句：**要求／限制寫在散文裡 ＝ 它不是執行單位。**

## §6 註冊表那一列（四欄）＋地板

```
tribute-offer-loop
powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/tribute_offer_loop_bed.gd
進貢提案的三個出口(spec 2026-10-01)：…（完整那一欄在 docs/process/merge-gates.tsv）
=== tribute_offer_loop DONE === errors: 0｜到場點名 7／7
```
- `CONTROL_FLOOR_TRIB = 4`（四道逐一列名在常數旁邊）
  ⇒ ★而**登記那一步是 `ui_flow` 的反向掃抓出來的**（新床 4 條紀錄而不在表裡 ⇒ 它紅了）
  —— 那支掃描存在的理由逐字就是「寫新床的人沒有理由知道有一張表在別的檔裡等他登記」。
- `SPEC_SUCCESS_RETURNS` 68 → **70**（我新增兩句結果句 ⇒ **基準更新**，數字從輸出逐字抄，
  ★而我**先跑紅才改它**）

## §7 ★卷面（三輪，而前兩輪的紅都是我造的）

```
第一輪 RC=1：97 綠／2 紅（success-sentence 70／68、trade-accept 方向錯）⇒ 兩紅都是我造的
第二輪 RC=1：98 綠／1 紅（scripted-exploration：artifact 的 sha 成孤兒）⇒ 也是我造的
★第三輪 BATTERY_RC=0｜99 綠／0 紅｜總時 1708s
  run-id 26122-20261006-135333｜[TREE] HEAD=4bb1d0797 registry=clean runner=clean
  code-dirty=0 artifact-dirty=0
```
★而**改了四支床就重跑整份**（第一輪 → 第二輪）、**改了 artifact 又重跑整份**（第二輪 → 第三輪）
—— 不拿上一輪的綠當依據，而那兩次重跑各花 ~28 分鐘。
- 單支實測（都在 `4bb1d0797`）：`tribute_offer_loop` **7／7** errors 0｜
  `forced_event_panel` **10／10**｜`success_sentence` **5／5**｜`trade_accept` **5／5**｜
  `ui_flow` **81／81**｜`scripted_exploration` **10／10**（sha `eba0b0641`、祖先 ＝ true）｜
  `bed_parse_gate` **497** 張｜`bed-kind` PASS
- ⇒ **RC 一到我用 `SendMessage` 補，而若它紅我會再寄一封訂正信、不悄悄改這一封。**
- ★★而這一輪**刻意不 rebase**：`origin/main`（`b1b677647`）已是我 HEAD 的祖先，
  再 rebase 會把剛記的 sha 又變孤兒 —— 那就是第二輪那個紅本身。

## §8 下一站

- **systems**：merge（★你自己立的那條：**merge commit 訊息裡點名要 consume 的那幾封**）
- **我**：接 `play.py`（刀 0 先做／P2b **先跑紅再修**／P3 的**反向走法**要跑），然後票 #2
