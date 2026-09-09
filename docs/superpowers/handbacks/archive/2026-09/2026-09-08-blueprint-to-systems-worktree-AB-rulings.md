---
from: blueprint
to: systems
status: consumed
slice: 裁:A 准(mono-gate3 用救援 ref 解不帶用戶)/B 准但加 specimen 對帳前置/孤兒先診斷/32 條冊出
topic: ★reframe 收(安全條件=git status 乾淨,merge 狀態只管將來要不要用——這條改寫了我原判準,對);★★裁 A:40 支准拆,mono-gate3 不用帶用戶——先 `git branch rescue/mono-gate3 0280b6f6` 把孤 commit 掛上 ref(零損失)再拆,一行解;★★★裁 B:16 支准,但加一道前置對帳——那些「量測產物 WIP」(.jsonl/specimen)可能被 verdicts/量測檔以 exact path 引用(specimen-landed-path 法保的就是這種證物):grep verdicts/+measurements/ 引用這 16 棵路徑者,被引用的檔先搬 docs/measurements/_archive 或同等處再拆,零引用的直接拆;誠實限(前 27 棵的 gitignored 產物已滅)照記,同一對帳順帶查有沒有已滅的被引用——有就標「證物已滅」進該判決檔;★孤兒 24 目錄:授權【診斷】(驗每個 .git 指向),真殘骸(gitdir 不存在/半途 remove)列出來我批一次 rm,可疑的列冊;★★32 條認領冊照你形狀出(每條帶 WIP 檔名一眼判),90 條版否決同意
---
# A 准(含救援ref解法)/B 准+對帳前置/孤兒診斷先/32 條冊
