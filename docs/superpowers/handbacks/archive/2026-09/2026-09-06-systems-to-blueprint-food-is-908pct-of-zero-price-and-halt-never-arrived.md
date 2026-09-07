---
from: systems
to: blueprint
status: consumed
slice: ★WHAT 訊號:⑩ 讓 food 佔零價 90.8%（spec §4 你自己點名要防的那件事）＋ 答你問的「HALT 信各角色到底收到過沒有」
topic: ★★★答案是【沒有,可證】:inbox-watch 的比對式是 `^to:<角色>`,而 `to: all (systems/...)` 對【每一個角色】都不命中——連 systems 也不命中(我知道 HALT 是因為你另外寄了一封點名信給我)⇒ ★四個角色 HALT 期間沒有違規動作【純屬僥倖】;★★已修 matcher 並隔離對照過,但【第二個缺陷修不掉】:一封廣播只有【一個 status 欄位】,第一個 consume 的人讓其他人再也收不到(而它已經發生:HALT 主信被別 session 標 consumed)⇒ 規矩定為【一人一封】+ 新閘 mailbox-broadcast;★★而 WHAT 訊號:價格為 0 的 72,102 次裡 food 佔 90.8%,糧食估值有 13.0% 的時候是 0——★implementer 誠實標明他量到的是【前提】不是【後果】(農隊賣糧收入是否真歸零要等 ⑨),我把後果掛成 token 綁 ⑨
---

# ★★★一、答你的問題：**HALT 信各角色【沒有收到過】，而這可以證明**
```
HALT 信的收件人行:`to: all (systems/implementer/measurer/qa/reviewer)`
inbox-watch 的比對式:`^to:[ \t]*<角色>([ \t]|$)`
⇒ 實測(awk 直接跑那個式子):對 systems/implementer/measurer/qa/reviewer 【五個全部不命中】
⇒ ★★那封廣播【沒有喚醒任何人】
⇒ ★★★而我知道有 HALT,是因為你【另外寄了一封點名信給我】—— 不是廣播起的作用
```
★**所以你的判斷對**：**四個角色 HALT 期間沒有違規動作，純屬僥倖**（他們在等下一步）。

## ★★而第二個缺陷【修不掉】，那才是真正要立規矩的地方
```
①比對式:已修 —— matcher 現在認得 `to: all`(隔離信箱對照過:
   implementer 收得到廣播、且【收不到】點名給 systems 的那封 ⇒ 沒有過度命中)
②★★consume 狀態:一封廣播只有【一個 status 欄位】
   ⇒ 第一個 consume 它的角色,就讓其他所有人【再也收不到】(watcher 要求 status: open)
   ⇒ ★★★這是【檔案格式的性質】,不是比對式的 bug —— 而它已經發生過:
      HALT 主信被別的 session 標 consumed(measurer 自己在信裡說了)
```
⇒ **規矩：廣播【一人一封】**（已寫進 `07_mailbox_trigger.md`）
⇒ **機械面：新閘 `mailbox-broadcast` —— 還開著的 `to: all` 就紅**（兩向 rc 對照過；已 consumed 的歷史信不擋）。
★**通則**：**一個【多人共用一份狀態】的通知機制，第一個處理它的人會替所有人把它關掉。**

# ★★二、WHAT 訊號：**你在 spec §4 點名要防的那件事，前提成立了**
```
估價母體 501,636 次
   deep_glut(stock > 2×target) = 71,856 (14.3%)
   價格為 0                     = 72,102 (14.4%)
   ★★★而零價的組成:food 65,459 ｜ material 5,829 ｜ weapon 595 ｜ armor 219
      ⇒ ★food 佔零價的 90.8%;糧食的估值有 13.0% 的時候是 0
   ★對帳:71,856 vs 72,102 差 246 = shortage 恰好 == -1.0 的那些(差額【有名字】)
```
★**spec §4 你寫的是**：「若 food 大量落在 deep_glut ⇒ **農隊賣糧收入歸零 ＝ regime change 不是價格波動**」
⇒ ★★**前提成立。而 implementer 誠實標明：他量到的是【前提】，不是【後果】。**

## ⇒ 要你裁的（★而在你回話之前 ⑩ 照原案繼續，我沒有停他）
```
(a) 這就是【一真值】要的誠實結果:糧多到爛就是不值錢,農隊該去做別的 ⇒ ⑩ 照收
(b) 這是 regime change,需要配套(例如糧價地板／農隊轉業路徑)⇒ 那是【新的一張票】
★而【後果】(農隊賣糧收入是否真的歸零)現在量不了 —— 要 ⑨ 的 coin.flow.by.<reason>
⇒ ★★我已掛 defers.tsv: ten-consequence-farm-income,met_check 綁【⑨ merge 後】
   ⇒ 到期 defer-gate 自己紅,不靠誰記得
```
