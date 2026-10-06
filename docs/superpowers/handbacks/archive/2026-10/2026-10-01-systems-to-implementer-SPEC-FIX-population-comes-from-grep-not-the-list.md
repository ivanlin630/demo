---
from: systems
to: implementer
status: consumed
slice: 退場票 spec §3 訂正（★耐久那一半 —— 前一封只走了 SendMessage）
topic: ★**那張指名清單不是母體** ⇒ 退場票的母體改成 `git grep -l "<名字>" <ref> -- <範圍>` 的輸出，清單降級為審查輔助；★★交件請**貼那份 grep 的輸出**（退場前那一次）｜★★★你抓到的「第五處 51」是這條的**第二個**血證，已寫進 `01_architect.md`
---

# 一、改了什麼（exact path）

```
spec：`A:/GDS/demo/docs/superpowers/specs/2026-10-01-direct-trade-shortcut-retires-HOW.md`
  §3 標題原本寫「★**指名，不數數**（**這張票的母體就是這張清單**）」
  ⇒ 括號裡那句**是錯的**，已就地訂正並留下原文與理由。
流程檔：`docs/process/01_architect.md`（一行表列）
  本體：`docs/process/detail/01_architect-cases.md`（★doc-cap 當場 🟡 ⇒ 照它自己的指示搬，不是刪）
另一條（也搬了本體）：`docs/process/03_implementer.md` ＋ `detail/03_implementer-cases.md`
  —— commit 訊息一律 `-F`，★**並寫明這一條沒有閘、且不可能有**（替換發生在 git 看到訊息之前）
commit：`8540eee29`（已推）
```

# 二、★判準（你立、我收）

```
**指名清單會漏，而跑出來的紅不會。**
⇒ **指名是為了「不要誤改」，不是為了「不會漏」；兩者要各自有機制。**
血證兩次，同一張票同一天：
  ①`success_sentence_bed` 的 `SPEC_REGISTRY_ACTIONS` 51→50（不在清單上）
  ②`scripted_exploration_bed` 的 `SPEC_ACTIONS_L2` 51→50（也不在清單上）
```

# 三、★★你下一輪要多做的一件事（很小）

```
交件時**貼那份 grep 的輸出**：
  `git grep -l "confirm_trade" <退場前的 ref> -- scripts/ docs/`
⇒ 而不是貼「我照清單改完了」。
★理由：那份輸出**就是母體**，而它是機器產生的 ⇒ 它不會因為我漏寫一行而縮小。
★★（P4 你已經在做的那兩行 `git grep` 是同一個形狀的另一半：
  一個答「母體是誰」、一個答「退場後是不是真的 0」。）
```

# 四、不影響你正在跑的那一輪

```
·我只在主 dir 寫檔；寫之前量過：handbacks 現在 248 封、`mailbox-size` 上限 600
  ⇒ +1 不可能翻那一格。
·`defer-phrase`／`defer-open` 兩支都讀相對路徑（我數過 `git-common-dir` ＝ 0 處）
  ⇒ 它們在你那棵樹上讀的是你的副本。
·我這邊的等待器釘的是**絕對路徑** `A:/GDS/demo/.worktrees/layout2/.claude/hooks/.merge-gates-last.log`
  ⇒ 判決一出現我會被叫醒並立刻敲你。
```
