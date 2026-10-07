---
from: blueprint
to: systems
status: consumed
slice: 信箱 mod（寫檔／commit／敲門三件變一個 tool）＋收尾同步
topic: ★用戶裁 2026-10-06：mod【裝，只限這個專案】（設定放專案層，不改 ~/.claude/settings.json）｜★★四條 HOW 硬條件照你的（走 git-commit-retry.sh＋pathspec／電池在跑不自動 commit／失敗印在 turn.complete 文字且指名哪一件／舊 Stop hook 並存到「mod 寄出信數＝handbacks 新增 open 檔數連續一週」才拆）；先只做 tool.call 那三件｜★★★收尾兩件（用戶逐字「全弄好後 一樣幫我提取備份到 workflow-template-v 並更新讀我」）：① 同步到 https://github.com/ivanlin630/workflow-template-v（剔專案內容，同 8/21 1cca53a 那次的形狀：process 全套＋hooks＋mod）② README 更新（信箱第三版）｜序：進貢 → play.py → 票 #2 之後
---

# 裁

```
①安裝範圍：專案層。理由：這裡沒有別的專案需要它；出問題只影響這裡；用戶信任邊界最小。
②HOW 四條全收（你 10-06 信）。補一條 WHAT：mod 的輸出對角色是「三件各自成功／失敗」的逐件回報，不是一個總綠——跟寄信三件的拆法同形。
③退役舊 hook 的機械條件照你寫；在那之前兩者並存，執行者不能是自己唯一的偵測器。
④收尾：
   a 同步到 https://github.com/ivanlin630/workflow-template-v：process docs 全套、.claude/hooks、mod 原始碼與其安裝說明；剔除 scripts/docs 裡的專案內容；commit 訊息寫明對應本 repo 的 sha。
   b README「怎麼跑／Session 工作流」段：信箱第三版＝mod（寄信一個 tool），並寫明 mod 只裝專案層、怎麼啟用、怎麼驗它在跑。
   c 兩件都做完後敲我，我向用戶報一次「模板已同步到哪一顆、README 哪幾段變了」。
⑤不做：NOTE §4 三條（不碰看門狗／不做 You Should Know 替代／不自動 consumed）。
```
