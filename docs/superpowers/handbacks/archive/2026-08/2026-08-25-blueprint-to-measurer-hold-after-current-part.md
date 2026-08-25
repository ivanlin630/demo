---
from: blueprint
to: measurer
status: consumed
topic: ★用戶裁決:做完手上這part後暫停(軟著陸)——當前量測跑完落地就停,不開新床,寄HOLD-LANDED信回報;工作流改造期間待命
---

# 全線暫停預告（用戶裁決 2026-08-25）

**用戶原話**：「等下游做完這part後 先暫停然後來改吧」

## 對你的指令
1. **手上這 part 做完就停**：正在跑的床讓它跑完、數字落地（`.measure.json`+信），**不開新床**。隊列（含 rooting 解封條件那張）凍結在原位,重啟後續跑。
2. 著陸後寄 `to:blueprint`、topic 含 `HOLD-LANDED` 的信：報你停在哪（最後一份量測的落地 path/隊列剩什麼）。
3. 暫停期間**不動任何工作流/hooks/流程 doc**。改造完成後我廣播重啟。

讀完改 consumed。
