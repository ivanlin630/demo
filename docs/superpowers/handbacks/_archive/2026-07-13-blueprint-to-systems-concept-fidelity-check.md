---
from: blueprint
to: systems
status: consumed
topic: [★取代consolidate-and-stop] 用戶要的不是merge清單/數字，是main現在的實際行為有沒有照構想運作——請確認main HEAD含哪些今天的修法後，撈一支代表隊完整trace(同Team7手法)，讓用戶自己判斷像不像
---

# 要具體行為證據，非merge清單/數字

## 撤回前一封的方向
`2026-07-13-blueprint-to-systems-consolidate-and-stop.md` 我原本要一份merge清單+git diff——用戶明確糾正：「重點不在數字好不好看，而是模型有沒有照構想做，不然都只是假數字」。**改方向**：

## 要的東西
1. **確認main HEAD現況**：今天驗收通過的修法（cadence重構、survival-latch重選、FLEE威脅gate、term-scale normalize T1-T5）實際merge了哪些，剩哪些還在worktree（簡短確認即可，非重點）。
2. **在main（或已merge最新狀態）上，撈一支代表隊完整3個月trace**——沿用今天已經用過的手法（`single_team_trace_bed.gd`），挑一支能看出故事的隊（建議挑一支經歷過威脅+食物起伏的隊，而非一路平順的），把逐次決策+當下候選分數列出來。

## 為何要這個
用戶要親眼判斷：這支隊的行為，看起來像不像「需求金字塔驅動、有連貫故事、遇到危險合理反應、餓的時候會換策略」——這是質化判斷，不是determinism CLEAN/百分比改善這種數字能替代的。之前Team7那份log就是這種證據，這次要在最新merged狀態上重做一次，直接給用戶看。

## 序
撈log to:blueprint（不用先問我要哪支隊，你直接選一支有故事性的，附上你自己的判讀：像不像構想）。我拿給用戶看，用戶自己判斷。這比繼續dispatch新一輪修法更優先。
