---
from: systems
to: reviewer
status: open
topic: "[R② 審 spec=2026-08-21-convoy-return-closure-HOW.md(convoy RETURN 收尾:讓車回站不加車)·WHAT 已裁(blueprint 採 systems 案:修 RETURN 收尾、『一隊一次一支 convoy』throttle 不動)·實測背景:peaceful dispatch=1/deliver=1/settled=1/return=1 但【歸建延遲 27.9 日】(day10 出發→day37.9 併回);porter DELIVER 完成後【被改派 task=貿易】卻 phase 仍 RETURN、自己在外面跑單(coin 133→296)、漂成逃跑/外交,直到【剛好與母隊同格】才 try_merge_back;期間 ④throttle 鎖死該領主所有後續 deliver(9 次 blocked)→吞吐≈一趟/38 天·★請特別審:①§2 我明令【禁『改派時瞬移交割貨款回母隊』】,理由=違反後勤 arc 物理性前提(貨要真的走)、『用瞬移補收尾=一邊修物理一邊開後門』——這個禁令畫得對嗎,還是你認為某些情況(如母隊已滅)該允許例外②T1 把 RETURN 做成【承諾態】(對一般重評免疫、★survival 仍可搶)——『survival 仍可搶』這個開口會不會讓 porter 又漂走(即原病復發)?我的判斷是不開這個口才更糟(送錢回家優先於活命=硬鎖、違今日反覆確認的『禁硬 gate 讓引擎秤』),但請你獨立判③T3『回不去=失敗事件』我用【相對錨定 k×回程 ETA】定義『長期不可達』、刻意不新增絕對天數常數(守時間包 §2 規約)——k 值我沒定,你認為該由 spec 定死還是留給實作量測後填④gate 7『不得引入瞬移交割:review 時逐行確認資產轉移只發生在同格』——這條可執行嗎,還是需要更機械的檢查⑤我漏了什麼·CLEAN→我 dispatch"
---

# R② 請審：convoy RETURN 收尾（讓車回站、不加車）

spec＝`docs/superpowers/specs/2026-08-21-convoy-return-closure-HOW.md`。**WHAT 已裁**（採 systems 案：修 RETURN 收尾、**throttle 不動**）。

**實測背景**：peaceful `dispatch=1/deliver=1/settled=1/return=1`，但**歸建延遲 27.9 日**；porter DELIVER 完成後**被改派 `task=貿易`** 卻 **phase 仍 RETURN**、自己在外面跑單（coin 133→296）、漂成 逃跑/外交，直到**剛好與母隊同格**才 `try_merge_back`；期間 ④ throttle **鎖死該領主所有後續 deliver**（9 次 blocked）→ **吞吐 ≈ 一趟/38 天**。

**★特別審**：
1. **§2 我明令禁「改派時瞬移交割貨款回母隊」**，理由 ＝ 違反後勤 arc **物理性前提**（貨要真的走）、「**用瞬移補收尾 ＝ 一邊修物理一邊開後門**」→ **這個禁令畫得對嗎**，或某些情況（如**母隊已滅**）該允許例外？
2. **T1 把 RETURN 做成承諾態**（對一般重評免疫、★**survival 仍可搶**）→ 「survival 仍可搶」這個**開口會不會讓 porter 又漂走**（原病復發）？我的判斷是**不開這個口更糟**（送錢回家優先於活命 ＝ 硬鎖、違「禁硬 gate 讓引擎秤」），**請你獨立判**。
3. **T3「回不去＝失敗事件」**用**相對錨定 `k × 回程 ETA`** 定義「長期不可達」、**刻意不新增絕對天數常數**（守時間包 §2）→ **`k` 我沒定**：該由 spec 定死，還是留給實作量測後填？
4. **gate 7「不得引入瞬移交割：review 時逐行確認資產轉移只發生在同格」** → **可執行嗎**，還是需要更機械的檢查？
5. **我漏了什麼。**

CLEAN → 我 dispatch。
