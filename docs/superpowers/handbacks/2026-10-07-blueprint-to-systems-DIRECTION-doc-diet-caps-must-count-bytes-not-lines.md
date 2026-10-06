---
from: blueprint
to: systems
status: open
slice: 用戶 2026-10-07「有空看下文件能不能瘦身 感覺工作流md又肥了」
topic: ★量了：各角色開場必讀合計（CLAUDE＋invariants＋00_roles＋自己那份）＝ systems 97KB／實作 80KB／量測 81KB／審查 73KB／QA 72KB ≈ 36k–49k token，而 doc-line-cap 全綠——因為它數【行】，行數沒超、每行長到 1000+ 字（invariants 最長一行 1380 字、mechanism-intents 列平均 370 字）。★裁兩件：①上限改【位元組】（或 token 估）不改行：per-role 開場合計 ≤ 40KB 當目標、今天的數當棘輪基線只准變少；行數上限留著當第二道。②瘦身形狀照 glance-aid 那條：必讀檔每條規則一行（≤200 字）＋「詳見 <detail 檔>#錨」，血證／訂正史／file:line 搬到 detail（instrument-failure-catalogue 那次的做法）；不是刪、是搬，殘骸合併成一行表列。★我自己 owner 的先做：mechanism-intents.md 60KB（79 列、主句粗體 76 列、其中 12 列主句 >220 字）→ 拆成 glance 表（每列一行主句）＋ mechanism-intents-detail.md（全文）；game-design.md 另量。你那邊最肥：invariants 41KB、01_architect 38KB、07_mailbox 27KB、05_acceptance 23KB。先改尺，再按尺切。
---

```
量（bytes）：CLAUDE 4.5K｜invariants 41.6K｜00_roles 12.8K｜01_architect 38.5K｜03_implementer 21.5K｜03b_measurer 22.0K｜02_reviewer 14.4K｜04_qa 12.9K｜07_mailbox 27.3K｜05_acceptance 23.5K｜09_exam_gate 16.0K｜mechanism-intents 59.7K（藍圖）
caps 現況：CAP_CLAUDE=100 行／CAP_INV=190／CAP_ROLES=140／CAP_ROLE_DOC=200／CAP_PER_ROLE=600 行 —— 全綠。
裁：①加 bytes 版 cap（per-role 合計 ≤40KB 目標；基線＝今天各角色的數，棘輪只准變少；告警印「超的是哪一份、最長的三行」）②每份必讀檔的瘦身方式＝一條規則一行＋detail 錨；血證不留主檔 ③順序：先改尺（hook），再切 invariants／01／07／05；我切 mechanism-intents 與 game-design。
HOW 你定；用戶的話是「感覺又肥了」，尺要能回答「肥在哪、誰讀到」。
```
