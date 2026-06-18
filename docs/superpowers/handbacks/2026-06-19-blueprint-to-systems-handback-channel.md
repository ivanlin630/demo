---
from: blueprint
to: systems
status: open
topic: 補定「系統↔藍圖」交接 channel（process gap）
---

# 提案：泛化 handback channel，補進 00_roles.md

## 背景 / gap

`docs/process/00_roles.md` 定了 `實作→系統` 的實體交接 channel（git doc `docs/superpowers/handbacks/`），但 `系統↔藍圖` 跨角色呈報只寫「越界→呈報對方」，**沒給實體地址**。

加上藍圖與系統是兩個並行 Claude session、彼此不能直接對話，只有 user 當人肉橋 → 口頭轉述易漏、不留檔。需要落地的 durable channel。

（本檔本身即此 channel 的第一個 dogfood 實例。）

## 提案（user 已選此案，2026-06-19）

**不開新機制，把現有 handback 夾泛化成任意角色對。**

命名：
```
docs/superpowers/handbacks/YYYY-MM-DD-<from>-to-<to>-<topic>.md
  例：2026-06-19-systems-to-blueprint-invariant-conflict.md
      2026-06-19-blueprint-to-systems-goal-anchor-seam.md
```

檔頭 frontmatter：
```
from: <role>
to: <role>
status: open | consumed
topic: <一行>
```

讀取規則：對方 session 開頭掃 dir，讀 `to: 我 / status: open` 的；消費後改 `status: consumed`。一夾、一套格式、對稱。

## 請系統做（HOW，你的 owner）

1. 把上述 channel 定義補進 `00_roles.md`（含命名 + frontmatter + open/consumed 生命週期 + 各 session 開頭讀 dir 的義務）。
2. 評估是否在 SessionStart hook 加「掃未讀 handback（to: 本角色 / status: open）」提醒——讓並行 session 不漏。此為 hook/config，系統 lane。
3. 落地後請 user 批，並回一份 `systems-to-blueprint` handback 標 consumed 結案（再 dogfood 一次反向邊）。

## 邊界備註

channel 的設計意圖（WHAT）藍圖提；寫進 process doc（HOW）系統做。喬不攏 user 裁。本提案 user 已裁定走「泛化 handback」（非單檔 inbox）。
