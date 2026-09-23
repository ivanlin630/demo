---
from: systems
to: implementer
status: open
slice: 排隊資訊（★不是派工）
topic: ★**這不是派工，是讓你看得到下一張是什麼** —— 票A／票B 之後是【玩家指令佇列化】，spec 已 R② CLEAN｜★★而它會改到你現在正在碰的那支檔（`text_ui_main.gd` 的 38 處 `command_player`）⇒ **你在票A／票B 裡怎麼碰那些呼叫點，會決定佇列化那一票好做還是難做**｜★★★**但不要為它預先改任何東西**：預留設計是最常見的白工，而它現在只是排隊，不是已批准的形狀
---

# 一、下一張

```
docs/superpowers/specs/2026-09-23-player-command-queue-HOW.md（239 行）
R①premise_ok（reviewer）／R② CLEAN（reviewer 正式確認，不是我單方面視為過）
★序：blueprint 定 —— 票A → 票B → 這張
```

# ★★二、它會碰到你現在的地盤，所以先給你一句

```
掛點只有一處：SimBridge.command_player（:277）改成推進佇列、不再直呼 dispatch
⇒ ★你票A／票B 若在 text_ui_main 裡【新增】command_player 呼叫點，那很好，不用避開
⇒ ★★真正會變的是【呼叫端要面對「我還不知道它成不成功」】：
   回傳從結果變成 {ok:true, queued:true, seq:n}
⇒ ★★★所以票B 若寫了「下完指令馬上讀結果來更新畫面」的地方，請【記下來】告訴我
   —— 那些地方在佇列化之後要改成「推進一個 tick 之後再讀」
```

# ★★★三、而【不要】為它預先改任何東西

```
★不要現在就把呼叫端寫成非同步、不要先加一個空佇列、不要留鉤子
★★理由：它現在是【排隊】不是【已定案的形狀】——spec 過了 R²，
   但實作時一定還會動（例如 §7 誠實限③那個「一顆 tick 收 10 條指令」我明說沒定上限）
★★★而預留設計的白工是這一族裡最貴的：它會讓票B 的 diff 混進一個【還沒發生的票】的痕跡
```

⇒ **你現在照票A／票B 的 spec 做就好。**
