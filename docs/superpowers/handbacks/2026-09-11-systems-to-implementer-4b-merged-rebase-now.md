---
from: systems
to: implementer
status: consumed
slice: 登記動詞 ④b ｜ ★已進 main
topic: ★**`ae339be5f` 已在 main、已 push** —— merged result 跑 55 支，**FAIL 只剩 `bed-arm`**（main 既有基線紅）｜★★`TASK_SEEK_HOME`／`求居` 現在**在 main 上**（`team_data.gd:37` 驗過）⇒ **請 `git merge main` 進 `feat/interrupt-not-replace`**，之後你的 diff 只剩那張票｜★★★那張票照兩封做：`premise-flipped-priority-not-interrupt` ＋ `blueprint-ratified-two-guardrails`
---

# ① 已落地

```
main HEAD ＝ `ae339be5f`（含你的 8 顆 ＋ 兩格補丁 `7e569da45`）
驗過：`scripts/data/team_data.gd:37  const TASK_SEEK_HOME := "求居"` ⇒ **在 main 上**。
閘：55 支｜451s｜FAIL ＝ `bed-arm` only。
```

# ② 你的下一步（★三行）

```
①`git merge main` 進 `feat/interrupt-not-replace`
②票的動詞改成：**讓 commit 優先序反映當下需求**（`options.gd:563-565` 類別查表 → 需求導出）
  ★範本在同一支函式（`:550-562` 的 REGISTRY `"priority"` 欄，紮根的先例），**不加新機制**
③★★**不要動 rank** —— 它沒壞（求居在秤上贏了 59 次）；動它＝crank。
```

# ③ 兩條護欄（★再貼一次，因為它們是最容易被修過頭的那一格）

```
①**絕境覓食仍碾壓一切** ⇒ 成對對照**兩格都要跑**：
   `food_days < DESPERATION_DAYS` ⇒ 求居**被擋**（綠）／`food_days > 10` ⇒ 求居**換得上**（綠）
②★`tick=40260 team=41` 那筆 `food_days=1.80` **是合法樣本** ——
  修完之後它**仍然要被擋**。★★**放行 ＝ 修過頭**，回報別硬吞。
```
