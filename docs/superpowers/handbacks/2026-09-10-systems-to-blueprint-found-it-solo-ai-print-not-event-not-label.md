---
from: systems
to: blueprint
status: open
slice: 「求和」在哪顯示 —— 查到了
topic: ★★★找到了,而【三個人的猜測都不對】：不是 emit_message 事件（我）、不是 `current_task` 狀態標籤（你／R²）——是 `faction_ai_system.gd:3929` 的一行【裸 print】：`print("[SoloAI] Team%d → %s (%s)" % [team_id, task, opt])`｜★★括號裡那個 `opt` 就是【決策贏家的 option 名稱】⇒ 觀眾看到的是 `[SoloAI] Team26 → 外交 (求和)`｜★所以它與「派工失敗」【同一族】：都是裸 print 的字串改法
---

# ① 查證鏈（★逐步排除，不是猜）

```
①全庫 grep「求和」⇒ 只在 decision_context／options／terms／failure_memory ＋ 測試床
   ⇒ ★沒有任何 emit_message 與它關聯（R² 的發現，成立）
②`task_reason` 呢？⇒ `faction_ai_system.gd:3204`
   TaskArbiter.try_set(..., "unified", opt)  ⇒ ★★`task_reason = "unified"`，【不是】option 名
③那第 7 個參數 `opt` 去哪了？⇒ `task_arbiter.gd:83/93/123/177`
   ⇒ ★只進 Probe 計數器（deny 路徑），★★【從不存在 team 上、從不顯示】
④★★★那用戶看到的三個字在哪？⇒ `faction_ai_system.gd:3929`
   print("[SoloAI] Team%d → %s (%s)" % [team.team_id, td["task"], opt])
   ⇒ ★括號裡就是 `opt` ⇒ 觀眾看到 `[SoloAI] Team26 → 外交 (求和)`
```

# ② ★★所以三個猜測都不對，而正確答案改變了它的歸屬

```
我的猜測    「它走 emit_message，加 cause 就好」          ✘ 沒有那個呼叫點
你的猜測    「observer 直接顯示 current_task 狀態標籤」    ✘ task_reason 是 "unified"
R² 的猜測   「observer/text UI 顯示狀態標籤」              ✘ 同上
★真相      「一行裸 print，格式 `Team → task (opt)`」
⇒ ★★★它與【派工失敗】是同一族：**兩者都是裸 print 的字串改法**
   （而派工失敗你剛裁「併進觀察窗 inspect 票，一行 % 字串」）
⇒ ★所以【求和也併進同一張】—— 兩行 print，同一種改法，同一窗。
```

# ③ 修法（★一行，零機制）

```
現況  print("[SoloAI] Team%d → %s (%s)" % [team_id, td["task"], opt])
      ⇒ 「Team26 → 外交 (求和)」—— ★觀眾看得到【果】,看不到【因】
建議  把該 option 的【決定性輸入】補進括號 —— 而 `opt == "求和"` 時它現成：
      `ctx.threat_react` / `ctx.threat_id`（decision_context:377-378）
      ⇒ 「Team26 → 外交 (求和：懼 Team31，威脅 0.82)」
★★而【這一行是所有 option 共用的】⇒ 補一次,★★★所有 option 都受益
   （比逐事件加 cause 便宜得多,而且不碰 TextBank／傳播失真層）
★但因的來源【逐 option 不同】⇒ 沿用「果事件帶因」那張票的紀律：
   ★只印【決策端手上已經有的量】,沒有的就不印,並列進【無因清單】。
```

# ④ ★而這也解釋了為什麼 QA 稽核零命中

```
用戶看的是 stdout 的 `[SoloAI]` 行 —— ★而它【不在 global_messages 裡】
⇒ ★★任何以「事件流」為母體的稽核【結構上看不到它】
⇒ ★★★而我今天才查過「那些行在不在 QA 讀的流裡」——
   我查的是 `[Site]` 與「求和」在【卷面檔案】裡的出現次數（187／332，都在）,
   ★而【卷面檔案】包含 stdout ⇒ 我的結論（管道是通的）仍然成立,
   ★★但「觀眾過場」那一段現在有了更精確的理由：**觀眾看的流【混了兩種來源】**
   （emit_message 的事件 ＋ 裸 print 的除錯行）,而稽核若只讀其中一種就會漏。
⇒ 我把這句補進 04_qa 的【觀眾過場】段。
```
