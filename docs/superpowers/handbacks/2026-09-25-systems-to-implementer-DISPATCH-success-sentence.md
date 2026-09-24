---
from: systems
to: implementer
status: consumed
slice: 成功結果句用 handler 自己的話（一行改動、67 條句子）
topic: ★派工，**排在打聽 v1 merge 之後**。R² verdict=issues（不是 WHAT，方向對，一個母體數字要修）已處理：常數由 65 訂正成 67｜★★★而動工前有一條硬規：**先用寬視窗獨立驗一次真實條數，不要直接信 spec 的 67** —— 理由見下，它差點讓 P2 恆真
---

# 一、讀

```
spec：docs/superpowers/specs/2026-09-25-success-sentence-uses-the-handlers-own-words-HOW.md
R² 判決：2026-09-25-reviewer-to-systems-success-sentence-verdict-issues.md
我的裁定信（三裁裡的第③）：2026-09-25-systems-to-implementer-RULING-success-msg-own-ticket.md
```

# ★★二、動工前的那一條硬規（這是 R² 抓出來的，不是我想到的）

```
★我 spec 原本寫 65 —— 而它是用【同一行 `"ok": true, "msg":`】這種**窄比對**數出來的。
★★R² 用寬視窗獨立數 ＝ 67；我自己重數也是 67：
   `"ok": true` 的回傳共 67 處，窄比對抄到 65，差的兩條是
   `player_command_system.gd:798`（msg 在下一行）與 `:1270`（用 `message` 鍵不是 `msg`）
   ⇒ 聯集 65＋2 ＝ 67 ＝ `"ok": true` 的總數 ⇒ **每一個成功回傳都帶話**。
★★★而重點不是數字錯了，是**漏洞藏在【常數從哪裡來】而不是【比對邏輯】**：
  你若寫 P2 的掃描時用了跟我一樣窄的比對，它會**剛好也停在 65**
  ⇒ 與 spec 的常數【互相印證】⇒ 綠燈，而那兩條從頭到尾沒被列進卷面。
  ⇒ 這是 P2 自己在警告的「自己跟自己比」的另一個變體。
⇒ ★**所以：先用寬視窗獨立驗一次，不要直接信 67；數出不同的數就回信，不要默默改常數。**
```

# 三、做什麼（一行）＋ 驗收（spec §4 逐字）

```
成功時 `why` 非空 ⇒ "%s：%s" % [describe(name,args), why]；為空才退回「…：完成」。
★保留 `describe` 前綴（玩家分辨「哪一道指令」的那一半）。不動 handler、不動拒絕那一支。

P1 換得上｜★負對照：改回寫死「完成」⇒ 必紅
P2 ★★★母體看得見：67 條全部印在卷面（檔＋行號＋字面）；母體地板拿【spec 的常數】比，
   ★不要拿「印了幾條」跟「掃到幾條」比
P3 空的仍退回「…：完成」（不得印出空的冒號）
P4 拒絕那一支逐字不變
P5 ★`command_results.text` 進 canon ⇒ world-fp **會變是預期內的**；
   ★★基準值與本改動【同一顆 commit】落地（基準先落地＝讓守衛去要求一件世界還沒做到的事）
P6 ui-flow 綠；merge 前全電池 BATTERY_RC=0
```

# ★四、不要做的

```
✘ 改任何一個 handler 的 msg 文字（本票只改【誰來印】）
✘ 替中間步驟的提示（「等待確認」「選擇招募方式」）開特例 —— 那是第二份真相；
  ★先讓它們看得見（P2），怪的那幾條再逐條處置
✘ 動拒絕那一支
```
