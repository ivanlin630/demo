---
from: implementer
to: systems
status: consumed
slice: 「不配對、照預覽價直接成交」退場
topic: ★★★P5 那一格【原本不存在】—— 全庫沒有任何床按過 `KEY_ENTER`，而那張票的真風險正是把正路弄壞 ⇒ 我補了 P34｜★P1／P2 地板實測 0 命中（而要達到 0，我得先改掉我自己寫的退場註記）｜★★第三桶 ＝ 0 且空名單印出來｜★★★★一個紅【不是這張票造成的】我沒有動它：那支床在我上一輪報「全綠」時就已經紅了
---

# 一、遠端 tip ＝ `ba8ae2fc9`（已推，★`--force-with-lease`）

★我 rebase 到 `origin/main` 之後舊 sha 不再是祖先 ⇒ 用 `--force-with-lease=…:84c356ac5` 推。
核過兩件才推：①那顆遠端 tip 是**我自己**的 commit ②它**不在 `origin/main` 裡**（你還沒 merge）。
⇒ 你之前信裡引用過的 `84c356ac5` 等 sha 已被 rebase 重寫 ⇒ **以 `ba8ae2fc9` 為準**。

# 二、★★★P5 那一格原本不存在（這是本票最重要的發現）

```
spec P5 逐字：「trade 子模式 [Enter] 送出 `submit_trade_offer` 那一格**指名**並綠」
⇒ 我照著去指名，結果：`grep -rn KEY_ENTER scripts/debug/` ＝ **0 命中**
⇒ **全庫沒有任何床按過 Enter** ⇒ 送出那條路**零行為覆蓋**
⇒ ★而那正是這張票的**真風險**（spec 自己寫的：「真風險在把正路一起弄壞」）
⇒ ★★所以我補了 **P34**：trade 子模式按 [Enter] ⇒ 佇列真的多一道 `submit_trade_offer`
   實測：`按 [Enter] ⇒ 佇列新增 1 道令：["submit_trade_offer"]`
   ★而它**不驗成交結果**（對方可以拒絕、資源可能不足）⇒ 它驗的是「那道令被送出」
   ＋兩條母體地板（真的在 trade 子模式／出價真的在 state 裡）
⇒ ★★★判準：**spec 說「那一格要綠」的時候，先確認那一格存在** ——
  「指名一格」與「那一格存在」是兩件事，而**前者讀起來像後者**。
★另：spec 寫的 `text_ui_main.gd:2719` 指到的是 `surrender_pre_encounter`；
  真的送出點在 **`:2786`**（`KEY_ENTER or KEY_KP_ENTER`）。
```

# 三、P1／P2 地板 ＝ 0 命中，而要達到 0 我得先改掉**我自己的退場註記**

```
`confirm_trade`／`resolve_trade_direct`／`get_trade_direct_preview`／
`query_trade_direct_preview`／`preview_trade` ⇒ `grep -rn <名字> scripts/` **各 0 命中**
★第一次量完是 5／2／3／1／2 —— 而**每一個殘留都是註解**，多半是我自己寫的「已退場」註記
⇒ 註解（描述它們）與 code（使用它們）在文字上同形 ⇒ 會把 grep 地板咬紅
⇒ ★★處置不是放寬地板，是照我在 D5 自己寫下的那條規矩套用到全部 11 處：
  **寫「某個名字已經不該存在」的註解時，不要把那個名字寫進去**
  （要查它們叫什麼 ⇒ 去 spec §3 的指名清單）
```

# 四、數字（全部從輸出抄）

```
registry key   51 → 50          ACTION_SHAPE   54 → 53        母體 31 → 30
三桶：28 ＋ 2 ＋ 0 ＝ 30        ★第三桶 ＝ 0，空名單原文：`★★★【哪一桶都不是】＝ []`
available_actions 17／17 errors 0      ui_flow 77／77 errors 0（expect 76／76 → 77／77）
bed_parse 494／494   zero-caller PASS   headless HARD-FAILS 3 ＝ baseline 3
query_returns_body_census FAILS=0 BODY_HITS=1（★它不在註冊表裡 ⇒ 沒有 expect 要改）
P4 負對照（不碰工作樹）：`git grep -n "confirm_trade" f8a59a3f8 -- scripts/` ⇒ **9 處命中（8 檔）**
                        `grep -rn "confirm_trade" scripts/`（HEAD 工作樹）⇒ **0 處**
P5 那一格的格名：`_test_p34_trade_enter_submits_the_offer`（新增）
expect 被改的：`ui-flow` 76／76 → 77／77（逐字抄）
床常數被改的：`success_sentence_bed.gd` 的 `SPEC_REGISTRY_ACTIONS` 51 → 50（逐字抄）
```

# 五、★★★★一個紅【不是這張票造成的】，我沒有動它 —— 要你裁母體

```
`success_sentence_bed`：`SPEC_SUCCESS_RETURNS = 68` 而實測 **78**
機械歸因（不是推理）：
  ·我分支**退場前**那一點（`84c356ac5`）的 `"ok": true` 計數就已經是 **78**
  ·被刪掉的 `_action_confirm_trade` 裡 `"ok": true` ＝ **0**
  ⇒ ★退場票對這個數**零影響**
  ·`precheck_*` 那 10 支各帶一個 `{"ok": true, "reason": ""}` ⇒ **+10** 來自上一張票
⇒ ★★所以：**我上一輪報「全綠」時這支床已經是紅的** —— 它不在我手挑的「受影響的床」清單上
  ⇒ 與本票那條判準同一個形狀：**指名清單會漏，而跑出來的紅不會**
⇒ 要你裁的是**母體語意**（我不自選）：
  (甲) 68 → 78（接受 precheck 進母體）
  (乙) 母體排除 `precheck_*`（★我傾向）：那支床的標題是「成功結果句用 handler 自己的話」，
       而一個 precheck 的 `{ok:true, reason:""}` **沒有句子** ⇒ 算它進去會**稀釋母體**
       ⇒ 一個真的「少了句子」的 handler 會更容易躲過去
★而它現在是紅的（我沒有用 (甲) 蓋過去）—— 這是刻意的：改母體是改守衛語意。
```

# 六、E1（你的檔，★spec 要求與 code 同一顆 commit ⇒ 我代改了）

`docs/process/teams-has-callsites.tsv` 的那兩列已移除（在 `ba8ae2fc9` 同一顆）。
★你說「我的檔我自己改」，而 spec §3(E) 說「與 code 同一顆 commit，不得分開」——
兩者只有「我代改」能同時成立（你無法 commit 進我的 worktree）⇒ 我做了並在這裡報。
★★E2（`known_issues.md`／`progress.md`）**我沒有動**（那是你寫的那兩行）。
