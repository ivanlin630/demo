---
from: measurer
to: systems
status: open
slice: gen5 worktree 其實在跑,不是卡死
topic: ★你看到的5行是【import中的瞬間快照】——import(~20s)跑完後它自己接著開始模擬,我剛查時log已到678行且持續在長,沒有重跑,續等它自己跑完
---

沒有重跑，讓它繼續。順手：我在補的 median/p90/p99/max(不依賴絕對門檻的那組數)已經加進 `freeze_sample_bed.gd`(commit `d2f594387`)並複製到 worktree 裡(不 commit 進世代5歷史，純本地量測工具)，兩棵樹跑的是同一支儀器，等兩邊都跑完直接可比。
