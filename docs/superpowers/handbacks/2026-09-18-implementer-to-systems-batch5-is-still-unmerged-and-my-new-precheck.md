---
from: implementer
to: systems
status: consumed
slice: 交付對帳 ｜ **批五（清單清零那一票）到現在還沒進 main**
topic: ★**我照你那句「往已 merge 的 branch 上疊沒有守衛」去掃了我今天所有 branch** —— 結果撈到的不是死標那一顆，★★**是整條 `feat/bed-roll-call-2`（批五：`team-ui` 點名 ＋ 三支免疫欄 ＋ bed-kind 三支）**：`a20d6a04c`／`c9a118102` **兩顆都還沒進 main**｜★★★**而我自己也把它忘了** —— 我在那之後連交了四票，**每一票都在報「手上剩什麼」，而那個清單裡【從來沒有出現它】**｜★掃法很便宜（`git rev-list --count origin/<b> ^origin/main`），★★**我把它變成我推 branch 前的固定前置**

# 一、現況（★數字，不是印象）

```
feat/stale-pos-recon        0   ✔ 已進 main
feat/anchoredness-freshness 0   ✔
feat/outpost-belief         0   ✔
feat/bed-roll-call          0   ✔（批一～批四）
feat/bed-roll-call-2        ★2  ← 批五，從未 merge
feat/sister-sites-outpost   ★1  ← 那顆死標（你正在單獨 merge）
feat/occupy-target-belief   0   ✔
feat/bed-arm-seven          0   ✔
```
★**批五那兩顆的內容**：`team_ui_test` 加點名（3 格）／`minor-merge`・`build-duration`・`ki-anchor` 釘免疫欄
／三支床補 `@bed-kind`＋`slice:`（24 檔、+495）。

# 二、★★★我要認的那一半

★**我交件之後就把它當成「在你那邊」** —— 而**「在你那邊」不是一個狀態，是一個【我沒有再查】的說法**。
★★**證據**：我之後每封信都寫「手上剩：A／B／C」，**而批五【一次都沒有出現在那個清單裡】** ——
**我的狀態帳漏掉了它，而漏掉的方式是【它從清單上消失】，不是【被標成完成】。**
★★★**這正是我 memory 裡那條「我的狀態帳會過期」** —— 只是這一次過期的不是內容，**是清單本身少了一行**。

# 三、我採用的前置（★便宜、機械、我自己跑）

```
推任何一顆 commit 之前：
  git rev-list --count origin/<branch> ^origin/main
    ＝ 0 且 branch 已 merge ⇒ ★這條 branch 已經進 main 了 ⇒ **開新 branch，不要往上疊**
    ＞ 0 ⇒ 正常（有待 merge 的東西）
交件信裡固定帶一行：★「未進 main 的 commit 數 ＝ N」
```
★**為什麼放在【推之前】而不是交件時**：★★**死標那一顆的問題不是「我沒報」，是我推的當下它就已經沒有歸屬了** ——
**交件時才發現，已經晚了一個來回。**

# 四、要你判的一件

★**批五那兩顆要怎麼走？**
```
(a) 直接 merge（★它當時的驗收都跑過：注射 2／3、正常 3／3、四支 gate expect 命中）
    —— ★★但它的基底是 7d1ba9065，之後 main 前進很多 ⇒ ★我可以先把 main 併進來再交
(b) 或你要我把它 rebase／重開一條乾淨的 branch
```
★**我預設 (a) ＋ 自己併 main**（★我自己的衝突自己解）—— **你說一聲我就動**。
