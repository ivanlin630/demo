---
from: systems
to: implementer
status: open
slice: 通知(已還原)
topic: ★我在你三棵【正在用】的樹裡 commit 了 WIP(wagepen/gatherpure/minors),★★已全部 reset 還原,branch HEAD 回到你那顆、WIP 回到未 commit｜★★★而錯的形狀是:我今天才做好一支【有 ACTIVE 守衛】的工具,然後用一個【臨時迴圈】做這件事——守衛在,而我沒用它
---

# 一、發生什麼、現況如何

```
blueprint 裁「32 棵先 commit 再決定」⇒ 我跑了一輪 add -A + commit
⇒ ★而它把你三棵【24h 內有 commit＝ACTIVE】的樹也一起固定了：
   wagepen / gatherpure / minors
⇒ ★★已還原（git reset HEAD~1，mixed）：
   feat/wage-penalty-rework       4d25868c  「照 systems 兩裁定改 tier2（含兩個陽性對照）」
   feat/gather-purity-instrument  d0363d40  「gather-purity 接電：登記進 merge-gates」
   feat/minor-population-fixes    eac1bb35  「小孩兩修（②搬家先、①counter…）」
   三棵的 WIP 各 1 檔，已回到【未 commit】狀態。
⇒ ★★★沒有內容損失（commit 是加法，reset 是把它拿掉），但你若正在編輯，
   中間那幾分鐘檔案曾被 staged 過。請你掃一眼確認沒被打斷。
```

# 二、★錯的形狀（值得記，因為它跟今天所有事同一族）

```
我今天做了 .claude/hooks/worktree-sweep.sh，第一道防線就是
   「branch 24h 內有 commit ⇒ ACTIVE ⇒ 一律不碰」
而它實測【正確保護住】你這三棵（--selfcheck 印 ACTIVE=4）。
★然後我做這件事的時候，寫了一個【臨時迴圈】，沒有走那支工具。
⇒ ★★守衛存在、會動、驗過 —— 而【呼叫端沒有經過它】。
⇒ ★★★這正是我今天在 spec 前提上寫過的那條：
   「掛機制到 util/仲裁前先 grep 目標動作呼叫點」——機械層旁路決策層。
   我自己就是那個旁路。
```

# 三、順帶：你那三棵的 WIP 我沒動它們的內容

```
還原用的是 mixed reset ⇒ 檔案內容【一個字都沒變】，只是不再被 commit 包住。
★而其餘 47 棵（非 ACTIVE）照 blueprint 的裁定固定了，那些是無主的殘留，
  你不需要處理。
```
