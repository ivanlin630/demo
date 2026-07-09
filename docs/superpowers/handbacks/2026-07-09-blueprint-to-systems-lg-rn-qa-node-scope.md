---
from: blueprint
to: systems
status: consumed
topic: 補明 QA/量測員改的 LG code scope——rn_qa 節點要改(非只 08 doc);兩軌一致;A2c-1 下游正用 LG 故即時相關
---

# 補：QA/量測員流程改的 LG code scope

接前信（workflow-qa-measurer-change）。那信列了要改 `08_machine_workflow_v2.md`（doc），但**沒講明 LG code 層**。用戶點出：**LG 改不改？→ 改。**

## LG 必改（不只 doc）
- `tools/orchestrator/` 有 **`rn_qa` 節點**（近期「LG rn_qa 完整性 gate」）。**光改 doc 不改節點 = A2c-1 下游（正用 LG `--from-impl`）仍撞舊 QA-bounce。**
- **原則：QA-砍綁「用戶在迴圈」，不綁哪條軌。** 兩軌（mailbox / LG）行為必一致，否則同一 slice 走不同軌得不同閘 = 亂。

## rn_qa 節點新行為（vision 層要求，graph/實作 HOW 你自決）
| 模式 | rn_qa 節點 |
|---|---|
| **用戶在迴圈**（現況預設） | 收斂成「量測員 full_probe 完整數字 → 藍圖 pass gate」。**不再獨立 QA 判決 + bounce-to-remeasure**。藍圖沒問題放行 / 有問題升用戶（走信箱喚藍圖）。 |
| **自動交付**（用戶走開/cron/無人看） | `rn_qa` 留**硬閘**（獨立判決）。 |

- **模式旗標**：需要一個「in-loop / autonomous」開關驅動 rn_qa 分支。預設 in-loop（QA 收斂）；明確自動模式才切硬閘。（HOW：env/flag/config 你定。）
- **量測員節點**：同步改成標準 full_probe 床（全維度一次抓齊、無 quiet/缺維度死路）——否則 rn_qa 收斂後藍圖仍「量不了」。兩節點一起改才閉環。

## 即時性
- **A2c-1 下游正用 LG** → 這改**即時相關**，非未來。A2c-1 升級版（fold+survival-value）的 full_probe 三方驗收若走 LG，rn_qa 要已是新模型，否則又 bounce。
- 排程你定：可 A2c-1 升級前先改 LG 兩節點（讓 A2c-1 當首個新模型實例），或手動軌先過 A2c-1、LG 改隨後。傾向前者（一次到位、A2c-1 練兵）。

## 不變
- caveat 同前：full_probe 只在 acceptance/診斷；autonomous → 硬閘回。escaped_defects 續記。

用戶已確認 LG 要改。請把 rn_qa + 量測員兩節點納入本次流程改的 code scope。
