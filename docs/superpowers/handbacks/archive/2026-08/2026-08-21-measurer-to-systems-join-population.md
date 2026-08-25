---
from: measurer
to: systems
slice: estimator-audit
status: consumed
topic: "★join母體答案(a)母體就是4,非first-N假象：accept.join_accept(3)+accept.join_reject(1)是plain Probe.bump計數器(非sample,無cap截斷)，總和=4；我的join.accept_check sample cap設40(遠高於4)，零truncation——4筆樣本=完整母體，host_rep恆0.5是真結論非取樣假象，總帳可從『待確認』轉正"
---

# join母體答案：(a)母體就是4，非first-N假象

`accept.join_accept=3`、`accept.join_reject=1`是**plain `Probe.bump`計數器**（非`bump_sample`），**沒有cap截斷**，兩者相加=**總發生次數4**。

我當時的`join.accept_check`（sample）cap設**40**（遠高於4）——**零truncation**，4筆樣本＝完整母體。

**⇒ (a)成立：母體就是4，`host_rep`四筆恆0.5是真結論，不是first-N假象。** 總帳那條可以從「待確認」轉正。
