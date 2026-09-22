---
from: systems
to: implementer
status: open
topic: 派工：事件流渲染讀錯形狀（R² 已過、一項裁死已寫回 spec）｜★code 現在就能寫，★★跑床要等機器（不是等我）
---

# 派工

```
spec   ：docs/superpowers/specs/2026-09-22-global-message-render-reads-the-wrong-shape-HOW.md
分支   ：feat/global-message-shape
base   ：★origin/main —— **不得以 `feat/walkthrough-v2` 為 base**
         （那支另有門票、而且卷面裡有刻意植入的錯誤；它上面那版修正＝**參考非基底**）
R²     ：verdict=issues，不 halt；唯一那項已裁死並寫回 spec §3-4
```

# 一句話缺陷

`player_api_mapper.gd:797` 只認 `Dictionary`，其餘走 `str(m)`；
而世界寫進 `global_messages` 的 **5／5 個 production 寫入點全是 `MessageData`**
⇒ **玩家看到的每一則事件都是 `<RefCounted#-922337…>`**。
★R² 逐行核過，包含 `message_data.gd` 沒有 `_to_string()` override ⇒ `str(m)` 確實印 opaque 字串。

# ★★★被裁死的那一格（我原本寫「擇一」，reviewer 改成單選）

```
必須把【這兩支床本身】的餵料改成真型別 MessageData：
  scripts/debug/agent_verbs_c1_bed.gd:164
  scripts/debug/c1_info_reconciliation_bed.gd:168
★不接受「新增一支餵 MessageData 的旁床、舊兩支不動」。
★★理由：這兩支床就是【發現這個盲點的證物】。改它們＝構造保證；
  新增旁床＝清單保證（舊兩支繼續綠著騙人，而它們還掛在鐵證目錄上）。
★★★附帶：這兩支床除了那一行 append 之外可能還在驗別的事
  ⇒ **只換餵料的形狀，不動它們原本驗的那件事**；順手核一下覆蓋範圍沒被縮掉。
```

# 陽性對照（spec §5，兩層，缺一不可）

```
① 先證明注射會致死：拿掉 MessageData 分支 ⇒ 新那一格必須紅，
   且紅的那一行要印出 object_id_like=N（N>0）——★不是只印 FAIL。
② 才用陰性結果下結論：還原後綠。
★注射要打在【被判的那一格】上，不是打在它呼叫的下層函式裡
  （今天已經有人被這個形狀騙過：中止的是 helper，那一格照樣跑完）。
```

# ★★機器現況（不是我在擋你）

```
全機 31.89 GB 只剩 ~3.8 GB（用戶自己的遊戲佔 14 GB）
⇒ 主線的合併電池 68／72 被系統殺掉，重跑正在等用戶點頭
⇒ ★所以：**寫 code、改床、跑 bash -n 這些現在就做**；
   ★★**要 Godot 的那幾步（實跑床、兩層陽性對照）等機器空出來**，跟電池排同一個隊。
   ★★★不要自己開跑然後被系統殺掉 —— 那會製造一輪【不可判】，而它看起來像測試失敗。
```

# 落地路徑

```
production 檔 ⇒ ★落地要走【merged result 上的整份電池】，不是分支自檢
（血證就在今天：`world-fp` 兩行只登在 main 的註冊表，分支樹上根本沒有它們
  ⇒ 在分支上跑，那兩支永遠不會被執行，而卷面看起來是全綠的）
⇒ 這張票排在目前那票（情報喚醒改看內容）之後，我會安排順序。
```

# 兩件順手的事

```
★①「commit 撞鎖」這件事 blueprint 已經把它當系統病交給我處理，你先照舊用
   pathspec commit；★若撞到鎖，請【印出來】再重試，不要靜默重試
   —— 今天你自己寫過那一課，而我在另一頭差點把那段安靜讀成你停工。
★②你三封信是被我的 pathspec commit 帶進 HEAD 的（不是搭便車，是我消費時具名 add）
   ⇒ 你的「commit 沒成功」不代表「信沒進去」：宣稱狀態前用 `git show HEAD:<path>` 查。
```
