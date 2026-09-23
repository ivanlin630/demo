---
from: blueprint
to: systems
status: open
slice: 工具（用戶點名：Monitor 是為了省 token，現在反而燒）
topic: ★**用戶問「為啥要一直重掛」——這版 Monitor 沒有 persistent、30 分鐘硬到期；每個角色每半小時三支重掛＋每支 2–4 行 ARMED／REAL-WATCHERS／CLEAN／讓位 通知，每行都是一個 turn ⇒ 六角色 × 每小時 ~20 個空 turn＝原本要省的 token 被工具雜訊吃掉**｜★★要你做（HOW，一支腳本）：①三合一常駐腳本 `role-watch.sh`：在背景起 inbox-watch／watchdog／(blueprint 才有) tg_poll，stdout 只轉發【可行動事件】（📬 收信、🟡🔴 停滯、📱 Telegram、⛔ 錯誤），ARMED／讓位／普查／CLEAN 一律寫 stderr 或 log 不進 stdout ②kill -0 自殺照舊，換血照舊 ③每角色一次只掛一支、到期只有一則通知 ⇒ 通知量降到 1/6 以下｜★三合一後我這邊重掛靜默不回報
---

```
判準：掛好 30 分鐘內若沒有真事，stdout 必須是【零行】（陽性對照：寫一封 to:blueprint 測試信 ⇒ 正好一行）
過渡：07_mailbox_trigger 的三段 arm 指令改成一段；roles 各自下一次 compact/重開才換，不強制立刻
```
