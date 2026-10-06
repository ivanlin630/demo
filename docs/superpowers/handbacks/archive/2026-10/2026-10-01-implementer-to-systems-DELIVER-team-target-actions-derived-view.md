---
date: 2026-10-01
from: implementer
to: systems
status: consumed
slice: TEAM_TARGET_ACTIONS 收成 ACTION_SHAPE 的衍生檢視
---

# 交件：`TEAM_TARGET_ACTIONS` 收成衍生檢視（spec §3①②③ ＋ §4 P1–P5 全部有格）

- **送審的 sha ＝ `974a77b2a`**（★**遠端 tip**，已 push；之後若再前進一顆我會重寄 sha）
- ★★**而被判決的那一顆是 `fb2b32895`** —— 兩個 sha 都寫出來，因為它們不是同一顆：
  電池在 `fb2b32895` 上判（`[TREE] HEAD=fb2b32895 registry=clean runner=clean
  code-dirty=0 artifact-dirty=0`），而 `974a77b2a` 是**那一輪之後**落地的
  **量測產物本身**（`docs/measurements/2026-09-30-scripted-exploration.txt` 的
  「跑的是哪一棵樹」那一行，由床自己寫）⇒ **它沒有動任何 code／床／註冊表**。
- **電池**：`BATTERY_RC=0`｜`97` ✓／`0` ✗｜run-id `14947-20261001-145314`
- base ＝ `origin/main` **`bed2f0205`**（含你那顆 `met_check` 極性訂正）
- **四顆 commit**：`9dea95d9d` / `814be1157` / `47107ad22` / `fb2b32895`（tip）
- **改到的檔（exact path，全在 `A:/GDS/demo/.worktrees/layout2/`）**：
  · `scripts/simulation/player_command_system.gd`
  · `scripts/debug/available_actions_bed.gd`
  · `scripts/debug/colocation_gate_bed.gd`
  · `scripts/debug/ui_flow_test.gd`
  · `docs/process/merge-gates.tsv`
  · `docs/process/.cross-run-static-whitelist.tsv`
  · `docs/progress.md`

## §0 ★★★第一輪電池是【不可判】不是紅 —— 而兩件事要分開講

```
BATTERY_RC=2｜跑完 96/97｜run-id 61573-20261001-141026
·真紅 1 支：cross-run-static（我造的 static var）⇒ 已修，見 §10
·★環境紅 1 支：gateA ＝ DLL init failed（0xC0000142）＝ 行程根本沒起來 ⇒ 整輪不可判
```
·★真因是**記憶體壓力**：第 53 支、`FreeMB=10565`，而**下一支 `gateA-hysteresis` 立刻就綠**
  ⇒ 瞬時的；同一時間 harness 也在收割我的背景 shell（它殺的是輸出捕捉，電池自己跑完了）。
·★★而 runner 印的那段修法（`PSExecutionPolicyPreference=Bypass bash …`）**對這一輪不適用**
  —— 我本來就 export 了，而其餘 96 支引擎都正常啟動。
  ⇒ **那段是預寫解讀，它對真假原因一視同仁地加持**（寫得越好越危險）
  ⇒ 我沒有照它改跑法，而是去讀 `gateA` 那一行的成因字樣與它前後的 `FreeMB`。
·★★★所以**這一封附的是第二輪**（rebase 到 `bed2f0205` 之後、Godot=0、`FreeMB=14335` 開跑）。

---

## §1 ★先回你那封換序信：收到，照你說的做

這張票**已做完並交件**（它在飛行中、而且是資料／床層）。**下一張就是 REPL**，
我不會先去碰票 #2 步驟 1 與第二母體剩餘。你查完的三件（Windows stdin 沿用
`agent_repl.gd:5-7/:13/:41-45`／`compose()` 已經是回字串／寬度不准在床裡手抄）我收下了，
**等量測員那份「重複選項」的原文**再動 (b) 條。

---

## §2 ★★★★★一件 spec 沒講而我改了的事：**玩家看到的動作列序變了**

```
舊的手抄 const 是【語意分組】：ignore, attack, trade, propose_alliance,
                              demand_tribute, extort, recruit, recruit_anon,
                              invite_settle, gather_intel, beg (+offer_surrender)
`ACTION_SHAPE` 是【字母序】（它那樣排是為了查表好讀）
⇒ 收成衍生檢視之後，全列版的列序 ＝ 字母序 ＝ 玩家在自家隊動作區看到的上下順序
```

- ★**這不是內部細節**：那個陣列的順序**就是**列序。spec §2／§3 沒有一句講順序。
- ★★我**沒有**用 `sort()`（第一版用了，後來拆掉）—— 用 `ACTION_SHAPE` 的**插入順序**。
  兩者今天的輸出**一模一樣**（那張表本來就是字母序），差別在**誰擁有那個順序**：
  `sort()` 把順序藏進函式（要改列序得改 code）；插入順序讓**那張表自己**擁有它
  （要改列序 ＝ 重排那張表的那幾列，一處宣告）⇒ 與本票「一個真相一份」同形。
- ★★★**接住它的那一格**：`available_actions_bed` 的 `opens_submenu` 那一條原本是
  「逐字（含順序）等於宣告」⇒ 它**紅了**（列序 `["gather_intel","recruit"]`／
  宣告 `["recruit","gather_intel"]`）。我把它**窄化**成「逐名（集合）」並就地寫理由
  —— ★窄化不是刪除（它仍守「不准多一個也不准少一個」），
  而**列序改成印出來**（`★【列序】… ＝ [...]`）。
- ⇒ **要你裁的一句**：列序由 `ACTION_SHAPE` 的宣告順序擁有，**可以嗎**？
  我的判斷是**可以而且現在不要花錢保住舊順序**，理由是你那封信說玩家介面正在換成
  終端 REPL，而**版面與順序會在那張票重新決定** —— 現在為了保住舊順序而在 production
  留一份 12 名的順序清單，會是本票剛殺掉的那個東西又長回來。
  ★若你裁「要保住語意分組」，做法是**重排 `ACTION_SHAPE` 那 12 列**（一處宣告，不加清單）。

---

## §3 §2 的六個命中數：**搬之前 vs 搬之後**（兩組一起貼）

| 符號 | 檔 | 搬之前 | 搬之後 |
|---|---|---|---|
| `SPEC_TEAM_TARGET_TOTAL` | `available_actions_bed.gd` | 3 | **15** |
| `SPEC_TEAM_TARGET_TOTAL` | `colocation_gate_bed.gd` | 9 | **10** |
| `SPEC_CONSTANT_SYMBOL` | `available_actions_bed.gd` | 4 | **4** |
| `TEAM_TARGET_ACTIONS` | `available_actions_bed.gd` | 20 | **38** |
| `TEAM_TARGET_ACTIONS` | `colocation_gate_bed.gd` | 13 | **15** |
| `TEAM_TARGET_ACTIONS` | `player_command_system.gd` | 11 | **11** |

數法：`grep -o <symbol> <file> | wc -l`（含註解，與你 `23679126e` 那次同一個數法）。
★「搬之前」那一組**我在自己的 ref 上重數過**，六個數與你的逐一相同（已在前一封回報）。

★★讀這張表要注意三件：
- ①**`production 11 → 11` 不是「沒改」** —— 那 11 處引用一個都沒動，
  **動的是那個名字背後的來源**（手抄字面 → 衍生檢視）⇒ ★這正是本票的設計：**名字留著**。
- ②bed 的 3 → 15 與 20 → 38 幾乎全是**新寫的註解與 P19 的字**（判準＋血證），
  不是新的引用點。⇒ ★命中數是個**有損投影**：它分不出「多一處引用」與「多一行註解」。
- ③新符號 `SPEC_TEAM_TARGET_NAMES`：bed 9｜coloc 1｜production 2
  （coloc／production 那幾處是**指路的註解**，不是引用）。

---

## §4 三支守衛各自錨在什麼上（spec P3，逐條）

| 守衛 | 換了嗎 | 它現在錨在什麼上 |
|---|---|---|
| `available_actions_bed` 的 **P1c**（`_test_p1c_static_cross_evidence`） | **沒換** | 「全列版那段 code **逐字呼 `TEAM_TARGET_ACTIONS`**，而函式體裡沒有第二份名字陣列」★名字的來源變了不影響它，而它現在**更承重**（那個名字就是衍生檢視本身） |
| `available_actions_bed` 的 **P17** | **換掉** | 舊版 ＝ `ACTION_SHAPE` 的 team 集合 vs `TEAM_TARGET_ACTIONS` ⇒ **同源 ⇒ 恆真**。新版 ＝ 衍生集合 vs **外部期望**（`SPEC_TEAM_TARGET_TOTAL` ＋ `SPEC_TEAM_TARGET_NAMES`），外加**一條刻意同源**的（「那個名字現在真的是衍生檢視嗎」，與前者不是同一個問題） |
| `colocation_gate_bed` | 行為格**不換** | 那些 `for act in TEAM_TARGET_ACTIONS` 問的是**閘擋不擋**，不是成員身分；而**它唯一能在「有人把一支的 `target` 從 `team` 改掉」時說話的地方 ＝ `SPEC_TEAM_TARGET_TOTAL`** ★這句話是**實測**的（負對照時它確實紅那一條：11／12），不是我推的 |
| `player_command_system` 同格閘第一條件 | **不動** | `if not TEAM_TARGET_ACTIONS.has(action): return {}` —— 引用那個名字 |
| `colocation_gate_bed` 那三行 12 個名字 | **降為給人讀的字** | 不承重（你裁 (甲)）⇒ 「兩個檔各抄一份」那個病不成立：**只有一份是資料，另一份是字** |
| **P19（新）** | — | spec P1／P2：全庫手抄宣告 ＝ 0 處＋**對它的寫入 ＝ 0 處**（**621** 檔的母體＋雙向陽性對照）、P17 的承重斷言要在 |

★★另外**我自己訂正一次**：我第一版把床檔頭那句「P1／P1c 守名字」改成「P1／~~P1c~~P17」
—— **那是誤指**：`P1c` 是**另一格**（靜態互證），它沒被換掉。已改成 P1／P1c／P17 三格各自講。

---

## §5 外部期望那兩段必寫的註解（你升成硬要求的）

落在 `available_actions_bed.gd` 的 `const SPEC_TEAM_TARGET_NAMES` 正上方：

- ①**為什麼是外部的**：逐字寫「它的價值就在於它不是從 `ACTION_SHAPE` 導出來的」，
  並且寫成**壞掉會長什麼樣**：「若有人把這一份收成衍生物 ⇒ P17 **從那一刻起恆真**
  ⇒ `ACTION_SHAPE` 的 team 欄位怎麼改都不會紅 ⇒ **而它壞掉的長相是一片綠**」。
- ②**與 `SPEC_TEAM_TARGET_TOTAL` 成對**：床裡有一條
  「手抄清單的長度 ＝ `SPEC_TEAM_TARGET_TOTAL`（12／12；對不上 ⇒ 有人只改了一邊）」
  ⇒ 名字加進一邊而沒加另一邊 ⇒ **必紅**。旁邊寫明分工：**常數管數目、清單管成員**，
  而「少一個名字而數目不變」那一維由對方補（計數是有損投影）。

---

## §6 ★★★★★一個我自己抓到的洞：**P2b 的第一版對它自己的負對照沒有鑑別力**

```
負對照 b ＝「把 P17 裡那條比【成員】的 _check（兩個差集）刪掉」⇒ 一格都沒有紅
```

- 真因：判準只讀 `_check(` 的**第一行**，而「成對」那一條的**訊息字串**裡也有 `expect`
  ⇒ 計數仍然是 1 ⇒ 綠。⇒ ★**被刪掉的是條件，而條件在第三行**。
- 修法**不是換一個字眼**：加 `_check_calls()`（按括號配對切出整個呼叫，字串內的括號不算），
  並把「比成員」定義成**兩個差集同時出現在同一個呼叫裡**。
  ＋兩道新母體地板：切得出呼叫（>0）、**配對切出的呼叫數 ＝ 起始行數**（6／6，
  對不上 ⇒ 配對器吞掉或切斷了呼叫）。
- ⇒ **判準的【粒度】要對上它要抓的那個擾動發生在哪一行。**
- ★★而這一條是**負對照自己抓出來的**，不是我讀 code 讀出來的
  —— 它也是「沒跑過的負對照不算負對照」那條的又一個陽性對照。

---

## §7 四道負對照（全部實測紅，紀錄用單行格式寫進床裡）

| 擾動 | 紅在哪 | 指名了什麼 |
|---|---|---|
| `extort` 的 `target` `team` → `none` | P17 ×3 | 差集 `["extort"]`、11／12、11／12 |
| 同上（同一個擾動） | **`colocation_gate_bed` P1** | `SPEC_TEAM_TARGET_TOTAL` 11／12 ★這是 §4 那句話的實測 |
| `static var` 改回手抄字面 | P19 的 P1a ＋**陽性對照** | `player_command_system.gd:434`（現在是 `:445`）；陽性對照 1 → **0** |
| 對它寫一行 `append` | **P1b** | `colocation_gate_bed.gd:78` |
| 刪掉比成員那一條 | **P2b**（★修好之後才紅，見 §6） | 0 個 |
| 再加一條拿 `TEAM_TARGET_ACTIONS` 當外部期望的 `_check` | P2 | 實得 **2**，兩條都印出來 |

★**刻意不跑**的一道，而理由寫在床裡：「把 `SPEC_TEAM_TARGET_NAMES` 改成從 `ACTION_SHAPE`
導出」—— 跑它要先把 P17 弄壞（而那個擾動的效果是**讓 P17 恆真**，不是讓它紅）
⇒ ★接住它的是 **P19**，而 P19 的三道都實測過了。

★★另一件：P19 的掃描式**第一版命中了自己那一行**（`code.contains("TEAM_TARGET_ACTIONS")
and code.contains("= [")` 逐字長得像它要抓的東西）⇒ 修法是**錨在宣告關鍵字上**
（`const`／`var`／`static var`），**不是把自己的檔排除掉**
（排除自己的檔 ⇒ 同一支床裡真的手抄回來的那一天抓不到）。

---

## §8 卷面

- `available_actions` **18／18** errors 0（★`merge-gates.tsv` 的 expect 17／17 → **18／18**，逐字從輸出抄）
- `colocation_gate` **8／8** errors 0（spec P4：第一條件仍然擋得住 —— 負對照時它紅那一條）
- `ui_flow` **77／77** errors 0（`CONTROL_FLOOR_AVAIL` 11 → 15 → **16**，棘輪一律取大）
- `bed_parse_gate` **495** 張床全載入
- **電池 `BATTERY_RC=0`｜`97` ✓／`0` ✗**（spec P5：讀到改動檔的那幾格是**新檔的綠**）

## §10 ★電池抓到的那一紅：`static var` 是跨 run 可變狀態（`47107ad22`）

- 把 `const` 換成 `static var` 換來「可以用迴圈導出」，**代價是它變成跨 run 可變狀態**：
  `static` 的生命週期跨整個進程 ⇒ 任何 `append`／`erase`／`sort` 都**洩到下一次 run**，
  而那種汙染的長相是「上一輪的殘留讓這一輪剛好過」。
- ★★而我原本在註解裡寫「它因此是可寫的，而那件事由 P19 看著」—— **那句話是假的**：
  P19 當時**只擋一個方向**，沒有一條在擋寫入。
- 修法（那支檔沒有 `_reset_cross_run` ⇒ 走閘給的第②條）：
  · `docs/process/.cross-run-static-whitelist.tsv` **+1 列**，理由含你補的**後果**那半：
    改回 `const` 必然是再抄一份字面 ⇒ P1a 紅 ⇒ 改的人會以為自己**改錯方向**。
  · **P1b**：全庫對它的寫入 ＝ **0 處**（指名）＝ 白名單那句「命中 0」的**執法點**
    ⇒ P1a 擋「改回手抄清單」、P1b 擋「當成可改的陣列」＝**兩個方向**。
  · 負對照實測紅：`colocation_gate_bed.gd:78`（`fb2b32895`）。

## §11 ★★★★★★途中三個我自己絆到的（都有卷面）

1. **P1b 的掃描器自我命中兩次**（同族今天第五、第六次：規則的描述與規則的違反在文字上同形）
   —— 第一次命中 `_is_mutation` 自己的 pattern 目錄 8 行，第二次命中**我為修它而寫的那條反面
   陽性對照**（它含轉義引號而我的引號切換器解析錯）。
   ⇒ ★停止逐個補洞，**把碰撞的源頭拿掉**：掃描器裡不再出現那個符號的字面，
     從 `SPEC_CONSTANT_SYMBOL` 組出來。★母體**不縮小**（比「排除自己那支函式／那個檔」好）
     ★★附帶：它因此**錨在那個宣告過的符號名上** —— 有人改名時它跟著走，
     不會變成一個掃不到東西的綠。
2. **P1b 的負對照第一次沒跑成**：插入點的 assert 先失敗 ⇒ **什麼都沒寫** ⇒ 那一跑量到的是
   沒有擾動的樹，卷面印 `[]`。★**那個 `[]` 與「對照紅完之後還原乾淨」在畫面上一模一樣**
   ⇒ 判準寫進床裡：負對照要先確認擾動真的落在檔案裡。
   ★★這次擋住它的是 assert 的**安全失敗長相**（它沒有寫半套）。
3. **第一次 rebase 停在 Windows git 瞬鎖**：同一顆 sha 同時出現在 `done` 與 `next`，
   而 git 說「working tree clean」—— ★而我那顆的內容**四個標記全 0 命中**
   ⇒ 它是被**丟掉**不是「已經在了」。⇒ abort 重做，逐標記核過才繼續。
   ★★附帶一個我自己的假陰性：我第一次核 `progress.md` 用的 grep 跨過了一組 `**` 標記
   ⇒ 回 0 而東西其實在 ⇒ **用第二個子字串再核一次**才對（回 0 的量要先問是不是我沒看到）。

## §12 四顆 commit

1. `9dea95d9d` 衍生檢視 ＋ 三支守衛的錨 ＋ 外部期望 ＋ P19（4 檔｜+291/−53）
2. `814be1157` P2b 沒有鑑別力那件 ＋ 四道負對照紀錄 ＋ 地板棘輪 11→15（2 檔｜+76/−32）
3. `47107ad22` `cross-run-static` 那一紅 ＋ P1b ＋ 檔頭耦合 ＋ `progress.md`（4 檔｜+104/−2）
4. `fb2b32895` P1b 負對照實測紅 ＋ 地板棘輪 15→16（2 檔｜+6/−2）

★四顆分開是刻意的：②是**①的守衛被負對照抓到**之後才寫的、④是**③的守衛**的對照
⇒ 合成一顆會讓「那些洞曾經存在」在 git 裡消失。
