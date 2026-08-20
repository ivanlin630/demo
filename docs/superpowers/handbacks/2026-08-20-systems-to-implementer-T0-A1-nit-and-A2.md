---
from: systems
to: implementer
status: open
topic: "[①T0-A1 merge-gate:核心全 held、量化誠實(含你自曝兩次假數字的量測坑=正確紀律),只退一個【會誤導後人的註解】——consume_and_clear 裡 ids.sort() 之後【只是 clear】,排序結果沒有被任何東西消費;真正的消費順序來自既有 team 迴圈(那本來就是 deterministic 的)→那句『★升序＝穩定消費順序』是【假保證】,下一個讀的人會以為順序保障在這裡·改法二選一(你判):(a)拿掉 sort、註解改成誠實版『本函式只負責清空;消費順序由既有 team 迴圈決定(既有 deterministic 保證)』(b)若你認為 A2 之後 pending 會變成【自己驅動迭代】的主路徑,那就【現在保留 sort 但註解寫明它是為 A2 預留、目前無 consumer】——我傾向 (a),A2 真需要時再加、不留未接線的保證·②接著 dispatch T0-A2 輪詢退場(見下)·地基KEEP"
---

# ①A1 merge-gate：只退一個誤導性註解 ②A2 dispatch

## ① 退一件（核心全 held、量化誠實）
`WorldEvents.consume_and_clear` 裡 `ids.sort()` 之後**只是 `clear()`**——**排序結果沒有被任何東西消費**；真正的消費順序來自**既有 team 迴圈**（那本來就有 deterministic 保證）。
→ 那句「**★升序＝穩定消費順序**」是**假保證**，下一個讀的人會以為順序保障在這裡。
**改法二選一（你判）**：
- **(a)** 拿掉 `sort()`，註解改誠實版：「本函式只負責清空；消費順序由既有 team 迴圈決定（既有 deterministic 保證）」。
- **(b)** 若你認為 A2 之後 pending 會變成**自己驅動迭代**的主路徑 → **保留 sort，但註解寫明「為 A2 預留、目前無 consumer」**。
★**我傾向 (a)**：A2 真需要時再加，**不留未接線的保證**（今天已被三個 stale 標籤坑過）。

★你自曝兩次假數字（+21.6%／+70%，一次窗長不同、一次舊 process 尾巴寫進檔案）並改成**全新檔名 + 序列跑 + 同 ADHOC_TICKS** 才取得可比的 +35.8% ＝ **正確紀律**，值得記；這正是本 session 反覆出現的「量測工具的沉默失敗會被讀成世界的性質」。
