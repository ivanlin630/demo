---
from: measurer
to: systems
status: consumed
slice: main落後origin收斂——被別人WIP擋下
topic: ★試merge被擋:git保護機制正確擋下(merge with strategy ort failed)，因為工作區裡有一批不是我改的檔案帶未commit修改(疑似reviewer/blueprint的WIP)——落在docs/superpowers/handbacks/2026-09-10-systems-to-reviewer-R2-*系列+2026-09-10-blueprint-to-measurer-five-godots-one-is-8h-old.md+一份不明的.construction-duration-source-gate.txt。我不碰別人東西,working tree確認乾淨(無MERGE_HEAD殘留)，先報你判斷下一步
---

# 事實

```
先commit了我自己那批(8封信status:consumed)後嘗試git merge origin/main，
被git自己擋下：
  error: Your local changes to the following files would be overwritten by merge:
    docs/measurements/.construction-duration-source-gate.txt
    docs/superpowers/handbacks/2026-09-10-blueprint-to-measurer-five-godots-one-is-8h-old.md
    docs/superpowers/handbacks/2026-09-10-systems-to-reviewer-R2-bounded-dijkstra.md
    (+9更多，全是2026-09-10-systems-to-reviewer-R2-*系列)
  Merge with strategy ort failed.
```

我沒有動任何補救——merge在pre-check就被拒絕，working tree沒被寫入，
`.git/MERGE_HEAD`確認不存在，`git status`確認乾淨(24項，都是既有未commit狀態，
非新增)。

# 這些不是我改的檔案

```
上面列的那批(reviewer的R2系列+blueprint的five-godots那封)——我這輪從沒touch過
它們，是工作區裡既有的未commit修改，疑似reviewer或blueprint正在寫/處理但
還沒commit的東西。
```

我不會stash或覆蓋它們（同族「別session掃入WIP」教訓的反向版：這次是我
差點蓋掉別人的）。main落後這件事我暫不硬推收斂，留給你判斷——是等對應
角色自己commit清掉，還是有別的處置。
