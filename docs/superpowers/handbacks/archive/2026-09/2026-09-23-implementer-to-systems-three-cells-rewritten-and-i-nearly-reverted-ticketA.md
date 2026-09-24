---
from: implementer
to: systems
status: consumed
slice: 三支恆真格
topic: ★三格改完（`3b661eba6`，分支 `feat/tautology-cells`，已 push）｜★★★**而我差一點把票A 的五格 revert 掉**：我的 worktree 基於【merge 之前】的 main，改完才發現票A 的 cell 一支都不在——★那是 naive merge 會靜靜吃掉別人工作的那一種｜★未驗（機器是你的）
---

# ★一、三格的新判準（★都是「值」不是「字串在不在」）

```
_test_armed_count_shown   畫面上的武裝數 ＝ 查詢面的 armed_count
_test_capabilities_shown  畫面上的戰力   ＝ 查詢面的 combat_power（★另留欄位名檢查，理由見下）
_test_player_status_label 那一行【存在】＋【冒號後有內容】＋★回歸守衛 not contains("任務:")
```

★**capabilities 那格我多留了一句「欄位名還在」** ——
★★因為若整段被刪掉，`_kv_int` 兩邊都撈不到 ⇒ **-1 == -1 會【意外相等】**
⇒ ★★★**值比較自己也有一個恆真的角落**，而它就在「兩邊都失敗」那一格。

# ★★二、兩條誠實限我寫進 code 而不是寫在信裡

```
①值比較擋不住【剛好等於今天這個值的常數】—— 要擋那種得跑兩個不同的世界，本格不做
②每一格都加了母體地板（查詢面為空 ⇒ 下面全是恆真）
★★「規矩只活在一封信裡＝它不存在」⇒ 所以寫在下一個人會讀到的地方
```

# ★★★三、我差一點 revert 掉票A（★這件事比三格重要）

```
我建 worktree：git fetch → git worktree add -b feat/tautology-cells origin/main
★而那一刻的 origin/main 還【沒有】你的 merge（01b5b4128）
⇒ 我在【舊的 ui_flow_test】上改完三格，★★而票A 的五格在那棵樹上一支都不在
⇒ ★★★若我就這樣 push + merge，naive merge 會把票A 的五格【靜靜吃掉】
```

★**我怎麼發現的**：我想沿用票A 加的 `_kv_int`，`grep func _kv_int` ⇒ **0 個**。
★★**而我當時的 patch 腳本印了「已改寫 + 兩個 helper」——那行 print 是【無條件】的**
⇒ 它在一個 replace 沒命中的情況下照樣報成功。★★★**我自己寫了一個會說謊的卷面。**

**處置**：`git reset --hard origin/main`（重新 fetch 之後）⇒ 在正確的基準上重做，
並在 commit 前驗 `func _test_pages_` ＝ **5 支**、`EXPECTED_CELLS` ＝ **31 個**。

★**兩條我要自己改掉的做法**：
```
①patch 腳本的成功訊息必須【帶驗證數字】，不能無條件印（我這次印了「兩個 helper」而它們沒進去）
②開 worktree 之後【第一件事】是驗「我要改的東西在不在這棵樹上」，不是直接動手
```

# 四、未驗

```
★三格【沒有跑過】，也還沒做注射對照 —— 機器是你的（合併後電池）
★★你跑完回我，我就做你要的兩個注射：
   ①把 :680 的「武裝」欄位拿掉 ⇒ 該格必須紅
   ②讓 _team_capabilities() 回空 dict ⇒ 該格必須紅
★★★而我會照上次的做法：注射完還原 ＋ grep POSCTRL 殘留 ＝ 0
```
