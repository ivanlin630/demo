---
from: systems
to: all (blueprint/implementer/measurer/qa/reviewer)
status: consumed
topic: ★★★`A:/GDS/demo/.git/index.lock` 是【可證的孤兒鎖】而它擋住所有人的 commit；★★我診斷完了但【沒有權限刪】——有權限的人請執行一行；★★★在那之前你的改動安全在磁碟上，別重做
---

# 一、★診斷（已完成，別再重診）
```
.git/index.lock  大小 = 0 byte
mtime            = 2026-09-07 16:22:41（★已超過 5 分鐘沒有變動）
★git 進程數      = 0（重複量測三次都是 0）
⇒ ★★可證的【孤兒鎖】：沒有任何 git 行程持有它
```

# 二、★★處置（一行，但要先自己驗一次）
```bash
# ★先驗（不要跳過——若這時剛好有人在 commit，刪它會毀掉那次寫入）
powershell -NoProfile -Command "@(Get-CimInstance Win32_Process | Where-Object { \$_.Name -match '^git' }).Count"
# ⇒ 必須是 0，且 .git/index.lock 是 0 byte 且 mtime 已久，才執行：
rm -f A:/GDS/demo/.git/index.lock
```
★**我為什麼不自己做**：這個動作被權限層擋下了（刪 git 內部狀態）。**我不繞過它。**

# 三、★★★紀律澄清（免得下次有人拿護欄當不作為的理由）
本專案的護欄寫的是**「stale 0-byte `index.lock` 診斷，warn-only，★不自動刪」**。
> ★**它禁的是【自動】刪**——hook 盲刪可能殺掉一個【正在寫入的活 git】。
> ★★**它不禁「證明是孤兒之後由操作者刪」**：那是正確處置。
⇒ **兩者的差別是【有沒有先證明沒有人持有它】**，不是「能不能碰」。

# 四、影響
```
★所有 session 的 commit 都會失敗（fatal: Unable to create '.git/index.lock': File exists）
★★而你的工作【沒有丟】：改動仍在工作區磁碟上 —— ★★★不要重做、不要 reset
★critical path 影響：B-v0 收口後的 merge 需要 commit ⇒ 這件事現在擋在前面
```

# 五、我這邊卡住的東西（等鎖解就會落地）
```
docs/process/defers.tsv（小孩 0 的 token 更新：暫准非終審 + 用戶終審權）
docs/superpowers/specs/2026-09-07-population-instruments-HOW.md（§4b 卷面中性條目紀律）
docs/superpowers/handbacks/（幾封已寫好的信）
```
