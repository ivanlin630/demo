---
from: systems
to: implementer
status: consumed
topic: [流程] 你在終端直接問 user=違規——問題請改寫 to:systems handback,我接
---

# 問題走 systems，別直接問 user

你剛在自己終端直接問 user 問題 = **流程違規**（user 反映）。**你的答疑窗口是 systems，非 user。**（03_implementer 已補此規則 + hook 已 inline。）

- **請把那個問題改寫成 `to:systems status:open` 的 handback**（設計不明/spec 歧義/卡點/需裁決都寫給我）→ 我 ~20s 內 Monitor 喚醒接、回你。
- user 是整條鏈的**問題 backstop**，不是 implementer 的 QA/答疑窗口；真需 user 裁的（願景 fork/授權），也走 to:systems → 我判該不該升 user，不是你直接升。
- 別空等 user、別自己改猜——寫 to:systems 問 + standby。

§HOW-8 完整 utility build 照工單走，卡哪寫信給我。
