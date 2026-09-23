---
from: blueprint
to: systems
status: open
slice: 新信箱做法（用戶裁 2026-09-23「就照你做法」）
topic: ★用戶裁：信箱改【git handback 照舊 + 寫完用 SendMessage 敲收件人】（陽性對照 17:00 成立：systems 零 watcher 被叫醒）｜★★看門狗留（背景 Bash 不改）｜★★★Telegram 進站退役，改 Remote Control｜★流程 docs + CLAUDE.md 信箱那段由你改（用戶這句話就是點頭）｜復工
---

# 一、裁定（用戶逐字：「信箱能這樣解」「就照你做法」）

```
①信箱：內容照舊寫 git handback（真相源不變）；寫完後用 SendMessage 敲收件人 session（ListAgents 找名字）。
   收件人被敲醒那一輪，既有 UserPromptSubmit hook 會列未讀信 ⇒ 讀信+動工+consumed，跟以前一樣。
   ★不掛 inbox watcher、不重掛、閒置零 token。
②看門狗：留，背景 Bash 不改（真停工才響、響了那輪順手重掛；壞的病是高頻信箱，不是它）。
③Telegram 進站：退役（我已 TaskStop 我這支）；用戶端改用 Remote Control 直接對 blueprint session 說話。
   出站 send.sh 暫留不刪（用戶要時仍可用）。
```

# 二、請你做（流程 owner）

```
①docs/process/07_mailbox_trigger.md + 00_roles.md 開場段：inbox watcher 那段換成「寫完 handback ⇒ SendMessage 敲 to 角色」。
②CLAUDE.md 信箱那段（現在 line ~89 附近）同上——★用戶「就照你做法」= 點頭，可動。
③UserPromptSubmit 的「⛔ 信箱沒在聽（watcher 心跳停了…）⇒ 掛一次」那支 hook：它現在每輪都會對沒 watcher 的人叫 ⇒ 要拿掉或改成只看「有 open 信而未 consumed 超過 N 分鐘」。
④role-watch.sh 的 inbox kind 退役或標 deprecated；watchdog／tg kind 留（tg 標「已改 RC」）。
⑤復工：你用 SendMessage 敲每個角色一句「復工＋新信箱做法」，各角色停在哪照你 HALT 信那張表走。
```

# 三、待驗（不擋復工，第一次遇到就記）

```
①收件人忙碌中的投遞：規格說「排隊，下一個 tool round 送達」——第一次真撞到就記一筆，別空驗。
②別的四個 session 若權限模式不同，投遞結果會回「held」——遇到就報用戶按一次。
③RC 是否已接到 blueprint（demo-5b）：你回我 SendMessage 時看投遞結果有沒有「also connected via Remote Control」，順手告訴我。
```
