---
from: blueprint
to: systems
status: open
slice: 第三輪玩測回饋 #11（用戶 2026-10-01，截圖 pic/1.png pic/2.png）
topic: ★用戶更正：「重複選項」不是選項重複，是【外交回應跳未知提案 ⇒ Team11 一直重複來外交】。截圖坐實：19:00 Team11「要向你進貢」→ 玩家按接受 → 「未知提案類型：tribute_offer ⇒ 沒有生效」→ 21:00 Team11 再來一次（兩小時一輪）｜★★真因兩半：①player_command_system.gd:1717 刻意不接 tribute_offer（怕併進 _pay_extortion 變玩家倒付）⇒ 結果是【玩家永遠收不到貢品】②這條 proposal 由 interaction_system 經 npc.order_task 寫入、不走 _send_diplomacy_message ⇒ 沒有 REJECT_COOLDOWN ⇒ 對方每輪重提｜裁：接受＝收貢（coin 由對方→玩家，金額用 NPC 側 TASK_TRIBUTE_OFFER 自己算的那份）、拒絕＝婉拒＋對方記得（同 NPC 被拒的後果）、結果必有一句；提案者要讀上次結果不得同日重提｜另附截圖抓到的六個畫面缺陷當終端自驗的陽性對照
---

# 一、截圖讀到的（pic/2.png，逐字）

```
第1天19:00  forced_event_arrived   Team11 找上門：要向你進貢
第1天19:01  forced_event_resolved  你對Team11 的「要向你進貢」回應了「✓ 接受」：未知提案類型：tribute_offer
第1天21:00  forced_event_arrived   Team11 找上門：要向你進貢
結果：✗ 回應事件：你選了「✓ 接受」，但未知提案類型：tribute_offer ⇒ 沒有生效
```

# 二、真因（file:line）

```
player_command_system.gd:1717-1726  match 刻意沒有 tribute_offer：理由是併進 "tribute" arm 會走 _pay_extortion（玩家付錢）。
  ⇒ 擋了「倒付」這個更糟的 bug，但留下「收不到」這個 bug，且畫面印「未知提案類型」＝畫面對玩家說它不認得一個它自己發出來的提案。
player_api_mapper.gd:357/380  面板已會印「要向你進貢」「接受＝收下對方的貢品」⇒ 承諾了，handler 沒兌現。
diplomatic_ai_system.gd:7  REJECT_COOLDOWN = 7 天——但 tribute_offer 不走 _send_diplomacy_message（:164），由 interaction_system 經 npc.order_task 寫 proposal ⇒ 冷卻從沒設 ⇒ 兩小時一輪。
```

# 三、裁（WHAT）

```
①接受＝收貢：coin 從對方→玩家，金額＝NPC 側 TASK_TRIBUTE_OFFER 已經算好要給的那份（它去進貢時本來就有數，禁另抄常數）；結果句「收下 TeamX 的貢品 N coin」；守恆走 ResourceBank 兩 tag；對方那邊走它進貢成功的既有後果（名聲／好感同 NPC↔NPC）。
②拒絕＝婉拒：結果句「你婉拒了 TeamX 的貢品」；對方走它被拒的既有後果。
③提案者要讀上次結果：接受 ⇒ 它的進貢任務完成不再提；拒絕 ⇒ 同一對象走既有冷卻／怨（同 NPC 被拒）。★「每兩小時重提同一件」＝禁；判準：同一提案者對玩家同一提案類型，一天內不得第二次到達（床印到達序列）。
④「未知提案類型」這句對玩家永遠不該出現：面板會印的提案，handler 必須有 arm（床：mapper 提案字串表 × handler match 集合，差集必空——同源比對）。
⑤倒付守衛（forced_event_panel_bed 那格「按接受後 coin 不得減少」）保留，加正向格「接受後 coin 增加 N」。
```

# 四、截圖另外抓到的六個畫面缺陷（pic/1.png）—— 全部當【終端自驗】的陽性對照，舊 Label 版面不另修

```
a 字型是比例字型（TextUI.tscn 沒設 monospace）⇒ 框線、地圖列、右欄全部對不齊——六區版面「排版爛」的物理根因；終端版天生 monospace，但全形寬度要算。
b 「— 生存 (1/5) —」標題在右框印了兩次（分頁標題列＋內容第一行）。
c 「聚焦: { "health": "", "stress": 0, "loyalty": 0 }」原始字典印給玩家。
d 內部備註漏到玩家面：「未分類（票B 將搬走：2 行，皆為跨頁混合（拆行是另一張票）」「糧食跑道（缺趨勢）：未接出（票B）」「Tick: 0 (Day 0)」。
e 事件流印英文識別字：「order_sell｜Team15：order_sell」「order_buy」「intel_arrived」「forced_event_arrived」——探索床的 d 規則只掃結果句沒掃事件流 ⇒ 母體要補事件流。
f 兩條鍵位提示並存（舊底欄「[WASD]游標 [M]移動 …」＋新提示列「鍵：[1-9]…」），內容還不一致（舊的有 [H]回玩家 [Z]確認警報，新的沒有）。
⇒ 終端自驗 ④ 的六條裡 b d e f 直接對應；a 由媒介解決；c 歸「無英文識別字／無原始結構」那條。截圖請搬進 docs/measurements/2026-10-01-round3-screenshots/ 當對照原件。
```

# 五、序

```
#11 ①③④ 是真 bug 且玩家每兩小時被打斷一次 ⇒ 排在終端骨架之前或併行（引擎側改動，與媒介無關）。
```

# 六、用戶補充（2026-10-01）：「不管答應或拒絕 都會因未知提案重複」

```
⇒ 重提與玩家的回答無關：拒絕路（respond_to_forced "refuse" 回 ok「拒絕外交提案」）也不會讓 Team11 停。
⇒ 真因在【提案者那端】：TASK_TRIBUTE_OFFER 的任務沒有讀到任何結果（接受／拒絕／逾時都沒回饋到它）⇒ 任務仍在 ⇒ 下一輪再提。
⇒ 修的重心＝③：提案者必須消費結果（任務完成／被拒走冷卻與怨／逾時視同拒絕），accept 的 arm 只是其中一半。
床：接受一次 ⇒ 24h 內零再到達；拒絕一次 ⇒ 24h 內零再到達；逾時一次 ⇒ 同上。三格各自獨立紅。
```
