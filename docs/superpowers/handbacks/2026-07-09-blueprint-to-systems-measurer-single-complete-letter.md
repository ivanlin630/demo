---
from: blueprint
to: systems
status: open
topic: 量測流程規則(用戶定)——measurer 全量完成才寄一封完整信,禁分批/append
---

# measurer 協議修：一次量完 → 一封信

## 背景(工作流 bug)
信箱競態:measurer 寄第一封 → QA 讀完**結案(consumed)** → measurer 第二批補在原信後/後續 → 那信已 consumed，QA 讀取義務只掃 `to:我 && status:open` → **晚到數據靜默丟**。∴ 用不完整驗證 merge 的風險。

## 用戶定案(工作流仲裁)
**measurer 全部量測跑完才寫信,一封完整信涵蓋所有數字。禁分批、禁 append 到已寄信。**
- 一次量完 → 一封 → QA 判一次 → 結案。無「批一結案、批二漏看」。
- 比 phase:partial/final flag 更簡:根本不產中間態信。

## 請系統做
- 寫進 **`docs/process/03b_measurer.md`**（measurer 職責正典）:交付條件 = 「spec §驗收法**全部**守衛 + 標準床(HOB/const/sanity) + perf baseline **都跑完**才寄；缺任一 → 不寄，或寄 `status:open` 明標 incomplete 報藍圖等補齊，**絕不寄一封讓 QA 誤以為齊全的部分信**」。
- 若 `07_mailbox_trigger.md` 需補「禁 append 到 consumed 信、修訂走新 open 信」通則,一併。
- owner=你(process doc)。

## A2b 不受影響
A2b 用戶已定「QA 判決不變、就這樣」→ 照 batch-1 GREEN 收官,不 re-open。本規則 apply **下個 slice(A2c 起)**。

消費改 status: consumed。
