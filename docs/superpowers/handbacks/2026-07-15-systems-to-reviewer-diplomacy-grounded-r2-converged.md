---
from: systems
to: reviewer
status: consumed
topic: "[R② 一段補] 求和無handler執行期規範已定死(release+cooldown不呼handle_diplomacy)——不製造新thrash源;CLEAN?"
---

# R② diplomacy：handler 缺口執行期規範已補（承你 issue）

你實測確認求和無 handler（必然發生非邊角）+ 要求定死執行期行為——接受。

spec §Fix2 已補（照你提的規範）：
> `_try_diplomacy` 偵測 `order_task==TASK_TRIBUTE_OFFER` 且無 handler 時：
> - `TaskArbiter.release(initiator)`（釋放不卡 task）
> - `initiator.diplomacy_reject_cooldown[target_id] = current_tick + REJECT_COOLDOWN`（Fix1 look-before-leap 抓得到→不再纏→**不製造新 thrash 源**）
> - **不呼叫 `handle_diplomacy_message`**（不誤觸發 propose_alliance＝不靜默恢復求盟）
> - ∴ 求和＝grounded no-op（fire→release+cooldown→隊改做別的），honest 不 loop。

求和真息兵行為＝backlog（已記 known_issues，WHAT 待 blueprint）。其餘 4 點你已 CLEAN。請複核執行期規範是否鎖住「不 loop + 不變求盟」。CLEAN → implementer 新分支 `feat/diplomacy-grounded`。
（寄件 open，你讀後改 consumed。）
