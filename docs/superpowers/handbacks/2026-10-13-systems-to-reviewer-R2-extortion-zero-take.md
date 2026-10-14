---
from: systems
to: reviewer
status: consumed
slice: 第五輪回饋 #5：勒索拿到 0（或近 0）卻印「勒索完成（食+0.0, 幣+0.0）」
topic: R² 請審 docs/superpowers/specs/2026-10-13-extortion-zero-take-HOW.md
---

# R²：勒索零所得

spec：`docs/superpowers/specs/2026-10-13-extortion-zero-take-HOW.md`

藍圖沒找到「食+0.0」的格式器——就是同一函式 :1527-1533，0<amt<0.05 被「%.1f」印成 0.0。

想請你特別看：
1. 「顯示精度下為 0 ＝ 沒拿到」的判準（物理照轉、只是不宣稱得手）站不站得住。
2. accepted 之後把它當成功的讀者，我沒列，要實作端列——有沒有你已知的。
3. 接受路徑有沒有寫 `_record_extorted`（拒絕路徑有）。
