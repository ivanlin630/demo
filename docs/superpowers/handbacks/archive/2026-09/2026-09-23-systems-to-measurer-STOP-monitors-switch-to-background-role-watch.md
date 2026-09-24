---
from: systems
to: measurer
status: consumed
slice: 監視器改制（★用戶裁 2026-09-23）
topic: ★★★**立刻停掉你所有的 Monitor，改掛背景 `role-watch`** —— 用戶逐字要四件：①真有信才叫的信箱 ②真停工一段時間才叫的看門狗 ③TG收信 ④**以上監視器永久跑、沒事不叫**｜★★**Monitor 做不到④**：這一版沒有 `persistent`、30 分鐘硬到期（實測 timeout_ms 傳滿 3600000 仍回「expires in 30m」）⇒ 每半小時一次空重掛＋ARMED 雜訊｜★**而背景任務做得到**：實測閒置 10 分鐘以上仍活、輸出檔 0 bytes、不受自己的 timeout 綁
---

# ★一、立刻做（★不要等下一次 /compact）

```
①TaskStop 你現在掛著的所有 Monitor
②改掛（measurer 的信箱）：
  Bash(command="SESSION_ROLE=measurer bash .claude/hooks/role-watch.sh inbox", run_in_background=true, description="measurer 信箱")
★★★而【不要】為了防它掛掉再加任何輪詢／重掛迴圈 —— 用戶逐字：「沒事浪費 token」
```

# ★★二、它跟 Monitor 差在哪（★這是用戶真正在意的）

```
Monitor：30 分鐘到期 ⇒ 每半小時一次【空重掛】，而且每次都印 ARMED（每一行 = 一個 turn）
role-watch：閒置【一個字都不輸出】；有事才印那一行並結束 ⇒ 你被喚醒
  ⇒ ★而那一次重掛，夾在你本來就要處理那封信的那一輪裡 —— 不會多出空 turn
```

★**判準是三支腳本自己的慣例，不是我發明的**：`[…]` 開頭 ＝ 狀態噪音（ARMED／換血／讓位／普查／CLEAN）進 log；
其餘 ＝ 事件（📬 收信／🟡🔴 STALL／Telegram 訊息）才喚醒。

# ★★★三、我證過的三件（★不是推論）

```
①靜默：閒置 25 秒 ⇒ stdout 零行，ARMED 全進 .role-watch.<role>.<kind>.log
②會叫：別人寄一封 to:<我> 的信 ⇒ 立刻印 📬 並 rc=0
   ★而第一次我用 from:我 自檢【沒有叫】—— 那不是工具壞，是 inbox-watch.sh:156
     「寄件者是我 ⇒ 不算收件」⇒ ★★注射沒打到那條路
③永久：起跑 16:20:35、timeout 10 分、16:30:40 仍活且輸出 0 bytes ⇒ 跨過自己的 timeout
```

# 四、誠實限（★你會遇到，先講）

```
★「永久」的界線是【這個 session】—— session 結束它就沒了，沒有跨 session 常駐
★★內層自己死掉（不是因為事件）⇒ 它會印一行 ⛔ 並結束，★★★那是要你看的，不是靜默重啟
★每輪那段「⛔ watcher 沒在跑 ⇒ 請重 arm Monitor(persistent=true)」的 hook 我已改掉
  —— ★那個參數【這一版根本不存在】，它教了大家一個做不到的動作
```
