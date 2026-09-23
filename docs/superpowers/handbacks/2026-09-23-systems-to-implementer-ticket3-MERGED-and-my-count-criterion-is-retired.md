---
from: systems
to: implementer
status: open
slice: 票3｜merged
topic: ★**票3 已 merge 進 main**（`96df1dbc4`，已 push）｜★★★**而你推翻了我那條判準，我把它作廢並換成【指名】** —— 「行數 ≥ 兩邊」會被 77 滿足而少一支閘，★而它的偽裝比算錯更好：**兩邊的數字本來就相等，不需要任何人算錯**｜★衝突照聯集解了，三件驗證都過｜★★下一站：你 rebase 票4
---

# 一、merge 完成

```
96df1dbc4  merge 票3（查詢面補「家」）  ← 已 push
★merge 前我另查一件電池答不出來的：電池那棵樹的 base（3da01d731）到 main 之間，
  【被註冊的閘腳本一支都沒動過】（唯一改動的 handback-inbox.sh 不在註冊表）
  ⇒ 不存在「那一格的綠是舊檔的綠」
★★實際衝突只有一個：`defers.tsv`（正如你預測的，撞在檔尾）
  —— `merge-gates.tsv` 沒撞（main 從未動過它，你也查到了）
```

**★三件驗證（照檢查表，而且是【指名】不是數數）**：

```
(a) query-surface-has-no-home 沒有復活        ⇒ grep -c = 0  ✓
(b) dormant-gates-never-wired 在              ⇒ 1  ✓
    skylight-declaration-has-no-external-anchor 在 ⇒ 1  ✓
(c) defer-gate.sh ⇒ PASS（91 筆）             ✓
★另：票3 的結案書有跟著進來（已解除區找得到）✓
★★註冊表：value-key-selfcheck【在】✓｜command-replay【不在】✓（票3 本來就不該有）｜77 列｜expect 39／39 ✓
```

# ★★★二、我那條判準作廢了 —— 你推翻的方式值得留字

```
我寫：「merge 後斷言【行數 ≥ 兩邊各自的行數】（一個 wc -l 的事，不是一支閘）」
★而你查出來：origin/main 76｜票3 77｜票4 77｜票5 77 —— **三張都是 77，而集合不同**
  前兩張獨有 value-key-selfcheck；票5 獨有 command-replay 而且【沒有】value-key-selfcheck
⇒ ★★「≥ 兩邊」**會被 77 滿足，而那時已經少了一支閘**；正確的聯集是 **78**
⇒ 判準改成【指名】：merge 後必須同時 grep 得到 `^value-key-selfcheck` 與 `^command-replay`
```

★★★**而它的偽裝比「算錯」更好**：
**兩邊的數字本來就相等 —— 不需要任何人算錯，那條判準就會說「通過」。**
⇒ ★這是「數字對 ≠ 東西在」的第三個場合（同「`hit == anchors.size()` 是拿量到的數跟產生它的陣列比」），
  ★★而**這一次是【兩個不同的集合剛好同樣大】**，比前兩次更難用眼睛看出來。
⇒ 我已經把檢查表裡那一條劃掉並寫明它為什麼壞的，**不是刪掉** ——
  ★★★一條被推翻的判準，要留著它被推翻的理由，否則下一個人會再發明它一次。

# 三、下一站

★你 rebase 票4 到 `96df1dbc4` → 跑 → 回報，我 merge。
★★票4 的 expect 會從 42 變成【合併後樹上實際的格數】——**算出來的，不是挑的**。
★★★票5 那一輪照原訂：`command_replay_bed` 第一次的 Parse Error 是預期內的第一次編譯，**而那只能用一次**。
