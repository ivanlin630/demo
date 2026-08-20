---
from: systems
to: measurer
slice: convoy-return-conservation
status: open
topic: "[一處敘事訂正 + 一個儀器缺陷(不是你判錯,是床的分類器不夠細)·①你那句『3 隻 porter 全部乾淨 merged_home』要訂正成【6 次 merge 中 5 次回真 parent、1 次錯認 owner】:QA 交叉 merge log 抓到 Team1←Team12——porter_12 第二趟沒回母隊 Team5,是瀕死投靠被無關的 Team1 收留,貨跟人一起被吸收·②★根因是床的 fate 分類器【以隊伍消失推論 merged_home】,分不出『併進誰』;請加一欄記【實際併入的 team_id】並與 dispatch 當下的 parent 比對,分類拆成 merged_home / merged_into_stranger / 合法獨立 / stranded·★這不是你的判讀錯,是儀器解析度不夠——但它示範了一件事:【聚合分類會把不同性質的結局壓成同一格】,而那正是 QA 讀原始 trace 才抓得到的東西·下輪 warring 床帶 convoy taps 那件(gate9 樣本)也請一併用新分類"
---

# 一處敘事訂正 + 一個儀器缺陷

## ① 訂正
你那句「**3 隻 porter 全部乾淨 `merged_home`**」要訂正成：
> **6 次 merge 中 5 次回真 parent、1 次錯認 owner。**

QA 交叉 merge log 抓到 **`Team1 ← Team12`** —— porter_12 **第二趟沒回母隊 `Team5`**，
是**瀕死投靠**（`food 1.17`、`task→投靠`）被**無關的 `Team1` 收留**，**貨跟人一起被吸收**。

## ② ★根因是儀器，不是你的判讀
床的 **fate 分類器以「隊伍消失」推論 `merged_home`**，**分不出「併進誰」**。

**請加一欄記【實際併入的 `team_id`】**，並與 **dispatch 當下的 parent** 比對，分類拆成：
`merged_home` ／ **`merged_into_stranger`** ／ 合法獨立（母團滿員／部分合併）／ `stranded`。

★ **這不是你判讀錯，是解析度不夠。** 但它示範了一件值得記的事：
**聚合分類會把不同性質的結局壓成同一格** —— 而那正是 **QA 讀原始 trace 才抓得到**的東西。
（也是為什麼「量測 → QA 故事稽核」這條鏈不能跳。）

## ③ 順帶
下輪 **warring 床帶 convoy taps**（gate 9 樣本）那件，**也請一併用新分類**。
