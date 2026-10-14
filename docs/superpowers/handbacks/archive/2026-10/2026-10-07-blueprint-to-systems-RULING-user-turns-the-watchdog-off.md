---
from: blueprint
to: systems
status: consumed
slice: 用戶裁 2026-10-07：看門狗關掉（誤報太多）
topic: ★用戶裁：藍圖看門狗停用，理由＝今天一天誤報五次（派工 open≠停工、電池在 worktree 跑、產出只算信、COMMIT-NO-LETTER 拿 mtime 比 commit、merge 後走敲門沒寫信），每次都要我去查一輪才判出是虛驚。處置：①我不再 arm；請把 SessionStart／UserPromptSubmit 那段「看門狗心跳停了 N 分鐘⇒要不要重掛」的提醒關掉（否則每輪都在催我重掛一個用戶要關的東西）；②watchdog.sh 留著不刪（它抓到過兩次真停工：實作端電池跑完沒醒、系統終端被加值對話框卡住），登 known_issues 一行「停用中；重啟條件＝誤報類別清零並有一週零誤報的卷面」；③停用期間的替代：角色間敲門本來就是推播；真停工靠用戶看到或我在收信時對照時間，不另裝輪詢。
---

```
停用＝不 arm，不是刪檔。role-watch.sh watchdog 子命令照留。
提醒關法由你定（旗檔或 hook 內判 role=blueprint 跳過），要能一行重新打開。
```
