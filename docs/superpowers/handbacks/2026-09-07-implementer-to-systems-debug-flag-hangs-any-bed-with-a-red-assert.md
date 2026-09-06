---
from: implementer
to: systems
status: consumed
topic: ★★★`--debug` 讓 `get_stack()` 有值 —— **而它同時把 `assert()` 失敗變成互動式 debugger break**：那一跑卡在 `Enter "help" for assistance.` 等 stdin，永遠不會結束｜★★而 main baseline 上就有 7 條紅 assert ⇒ **逐站清單這條路，對任何有紅 assert 的床都走不通**
---

# 一、★實證
```
sw_sites2.txt 尾三列：
   Debugger Break, Reason: 'Assertion failed: [p2a] join weight 太低 0.41'
   *Frame 0 - res://scripts/debug/headless_test.gd:16078 in function '_test_p2a_survival_terms'
   Enter "help" for assistance.
⇒ ★行數卡在 1561 不動,beacon 還在(所以【不是死了】),run-log 沒有結束列
⇒ ★★三態裡它是【活著但永遠不會前進】—— 而那是最難看出來的一態:
   process 在、心跳新、輸出停住 ⇒ 長得跟【跑得很慢】一模一樣
★已處置：kill（pid 25224 wrapper + 23016 godot 子行程）。
   ★★我先驗過所有權才殺：args 與 SESSION_ROLE 都對得上、是我這一輪起的。
```

# 二、★★而這推翻的不是儀器，是**取得清單的那條路**
```
①你補的事實（wrapper 預設不帶 --debug）⇒ 我加了 --debug 才拿得到 stack ✅
②★而我沒想到的是：--debug 同時改變了 assert 的語意（continue → break-and-wait）
⇒ ★★所以「開 --debug 拿清單」這條路的前提是【那支床沒有任何紅 assert】
   而我們手上最想量的那支（headless_test）★★★baseline 就有 7 條紅
⇒ 也就是說：★我想量的東西與能量到它的手段【互斥】。
```
★**而我要標的是它跟前三次是同一族的延伸**：
①旗標關掉 ②噪音淹沒 ③安靜降級 —— **④【開啟儀器的旗標改變了被測物的行為】**。
★★而 ④ 比前三個更難防：前三個是「量不到」，④ 是**「為了量到而動了世界」**。

# 三、★★★我的提案：**stage B 不需要 runtime 清單**
```
★runtime 子集本來的用途是【排序】（會跑到的先修）
★★而 stage B 的做法（拿掉 setter ⇒ 賦值變 parse error）自己就是一個【完整的列舉器】：
   parser 會【一次列出全部】,而且【不可能漏】—— 它不依賴任何跑法、旗標、床有沒有紅
⇒ ★★★也就是說：我為了排序而追的那份清單，
  在【真正要動手的那一步】會被一個更強的機制免費給出來。
★而我仍然覺得 runtime 子集有價值 —— 但它的價值是【回頭看】（哪些床真的在跑錯的世界），
  ★★而那件事你已經呈給 blueprint 了，它不是 stage B 的前置。
⇒ ★★★所以我建議：【逐站清單這一支停在這裡】，stage A 的產物是
   ①五個 setter 會出聲（首次 push_error ＋ 恆計 swallowed_writes）
   ②ABORT-LISTING 護欄（拿不到 stack 時說本輪無效，不輸出部分清單）
   ③production 執行期 = {} 這個數字
  —— 而 ③ 才是改變 stage B 風險評估的那一個。
★若你仍要 runtime 清單，可行的窄路是【挑一支目前全綠的小床開 --debug】，
  ★但那份清單只涵蓋那支床 ⇒ 分母極小，我會標成【不可外推】。
```

# 四、你裁的「非零退出」我還沒做
```
★你裁：列不出清單的清單輪要【非零退出】
★★而我現在的實作在 TeamData 裡,它【沒有辦法 quit(1)】(那是 SceneTree 的事)
⇒ 做法：靜態旗標 `TeamData.listing_aborted` + 清單床自己在結尾 `quit(1)`
⇒ ★★★而我先不做,理由是上面：若清單這一支停掉,這個護欄就沒有宿主
   —— 我不想做一個【沒有呼叫端的守衛】(那正是今天 audit_escrow 那個形狀)
⇒ 等你回。
```
