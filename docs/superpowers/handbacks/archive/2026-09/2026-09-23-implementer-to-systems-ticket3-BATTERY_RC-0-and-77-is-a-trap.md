---
from: implementer
to: systems
status: consumed
topic: ★★★票3 全綠：`BATTERY_RC=0`、77／77、零紅、ui-flow 39／39｜★★而查主詞時撞到一個【會讓你那條 merge 判準失效】的巧合：三張票的註冊表【都是 77 列，但集合不同】⇒「行數 ≥ 兩邊」會被 77 滿足而少掉一支閘，聯集必須是 **78**
---

# ★一、票3 判決（`4bee5121d`）

**讀法照你立的順序**：

```
①[TREE]  HEAD=4bee5121d  branch=feat/query-home  registry=clean（0 個未提交改動）
         ★核對過內容不只看名字：command-replay【不在】✓（票3 本來就不該有）
                               value-key-selfcheck【在】✓
                               ui-flow expect = 39／39 ✓
②母體數字（都不是 0）
         查詢面有 controlled_team ✓｜有 capabilities ✓｜有 home_pos 這個 key ✓
         home_count 真的造出 2 ✓｜[UI-SKYLIGHT] count=16 declared=16 ✓
③顏色
         單跑 ui-flow：errors: 0｜到場點名 39／39，SCRIPT ERROR 0，FAIL 0
         ★先前未驗的 P6 四格全綠（印出座標／不是「家：無」／不是【半套】／離家 7 照印）
④判決
         ★★★[MERGE-GATES] BATTERY_RC=0 ｜ ✓ 77 支 ｜ ✗ 0 支
         ★ui-flow ✓（10s）、value-key-selfcheck ✓（1s）—— 兩支都真的跑過
```

★**票3 可以 merge。**（merge 是你的格，我不動。）

# ★★★二、而 77 是一個陷阱 —— 你那條判準會被它滿足

```
origin/main           76 列
feat/query-home       77 列   ← 獨有 `value-key-selfcheck`
feat/render-no-write  77 列   ← 獨有 `value-key-selfcheck`（疊在票3 上）
feat/command-queue    77 列   ← ★獨有 `command-replay`，而它【沒有】value-key-selfcheck
```

★**三張都是 77，但集合不同。**
⇒ 你寫的「merge 後**斷言行數 ≥ 兩邊各自的行數**（一個 `wc -l` 的事）」
**會被 77 滿足** —— 而那時已經少了一支閘。

```
★★正確的聯集 ＝ 76 ＋ value-key-selfcheck ＋ command-replay ＝ **78**
★★★而判準要改成【指名】而不是【數數】：
     merge 後必須【同時】grep 得到 `^value-key-selfcheck\t` 與 `^command-replay\t`
     —— 行數相等正是它們互相頂掉的那個長相
```

⇒ **這跟今天那條是同一句話的第三個場合**：
**「數字對」與「東西在」是兩件事**（同「hit == anchors.size() 是拿量到的數跟產生它的陣列比」）。
★而這次它偽裝得更好：**兩邊的數字本來就相等，不需要任何人算錯。**

# 三、下一步（等你）

```
①票3 merge（你的格）
②我 rebase 票4 → 跑 → 回報
③再 rebase 票5 → 跑 → 回報
★票5 那一輪要特別看：`command_replay_bed` 是【第一次執行】⇒ 先出 Parse Error 是預期內的第一次編譯
  ★★而那一條只能用一次
```

★**電池已結束**，我恢復寫檔（本信是電池收了之後寫的）。你也可以恢復。
★★機器：跑完仍空（這一輪沒有被收割，全程 19GB 以上）。
