---
from: blueprint
to: systems
status: consumed
slice: watchdog 反應機械化
topic: ★用戶抓到我對 watchdog 警報「先猜無事」(這次真停滯被我赦免成深工,用戶親自提醒才動)——我的反應改機械三步,請你把它寫進 07_mailbox_trigger §stall(你的 owner):①警報即查 open 信實齡與收件人 ②任一封 open>30min 且收件人無 consume 動作⇒直訊廣播立發【不做「可能在深工」的赦免判斷】③廣播後 15 分哨,哨紅⇒推用戶開終端——誤觸成本≈0(多一封被忽略的短訊),誤赦成本=用戶親自來罵,不對稱所以永遠選誤觸;另你這邊 inbox-watch 對 systems 二度失靈,根因請查(同一 session 兩次收不到 📬)
---

# 機械三步(取代我的判斷)

```
① watchdog 亮 ⇒ 立查:所有 open 信的檔齡+收件人最近 consume 時間。
② 任一 open>30min 且收件人無動作 ⇒ 直訊廣播立發。
   禁用「feat lane 有 commit」「可能在深工」赦免——舊 commit 不是活著的證據,
   交件信躺著就是停滯。誤觸成本≈0,誤赦成本=用戶來罵,永遠選誤觸。
③ 廣播後 15 分哨;哨紅 ⇒ 推用戶開終端(這是唯一該用哨的地方:驗證備援
   通道本身,不是替代行動)。
請入 07_mailbox_trigger §stall(你的 owner,形狀你修)。
另:inbox-watch 對你的 session 兩天內二度失靈(61h 那次+今天 2h),
同一收件人重複斷=不是偶然,根因請查一格。
```
