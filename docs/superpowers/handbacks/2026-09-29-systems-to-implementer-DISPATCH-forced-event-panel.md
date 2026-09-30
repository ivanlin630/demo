---
from: systems
to: implementer
status: consumed
consumed-by: docs/superpowers/handbacks/2026-09-29-implementer-to-systems-forced-event-panel-13-done-7-controls-red.md（①③ 做完、7 支負對照全紅、電池 85／85）
consumed-note: ★②面板鎖＋去重與④真因指認【沒有做】—— 依 systems 2026-09-29 的裁定等 #8 落地後由【新的一封】重派；本檔不留著當待辦。
slice: 強制事件面板＋生命週期三點＋「按 T 變拒絕」先量後修（第二輪回饋第一張）
topic: ★派工。spec = docs/superpowers/specs/2026-09-29-forced-event-panel-and-lifecycle-HOW.md｜R² CLEAN（0f9743818，他把整條資料流從寫到讀追完）｜★★★而 P4 的形狀是【指認】不是【通過】：床把四個候選各自的證據欄印出來，由卷面挑真因 —— **不要因為我和 R² 都指向 (c) 就直接修它**
---

# 一、讀

```
spec：docs/superpowers/specs/2026-09-29-forced-event-panel-and-lifecycle-HOW.md
上游票：2026-09-29-blueprint-to-systems-TICKET-forced-event-panel-…-feedback-7.md（consumed）
R² 判決：2026-09-29-reviewer-to-systems-forced-event-panel-verdict-clean.md（consumed）
用戶逐字在上游票的「一、用戶逐字」段 —— ★先讀那一段，它是這張票的全部理由。
```

# ★★二、最重要的一條紀律：P4 是【指認】不是【通過】

```
★我核出、而 R² 把整條資料流追到底的那個機制（(c)）：
  diplomatic_ai_system.gd:146/149 寫 "propose_alliance"／"propose_trade"
  → :174 原樣存進 state.player_forced_event["proposal"]
  → player_command_system.gd:942 原樣讀出
  → :1159 _accept_diplomacy 的 match 只認 alliance/surrender/tribute/demand_tribute
  ★中間【沒有任何正規化／映射層】⇒ 機制上釘死
★★而【機制存在】不等於【它是這次玩測踩到的那一個】：
  (a) 逾時競態 (b) 重複回應的「無待處理強制事件」 (d) 措辭撞車
  仍可能同時或單獨發生 —— ★★★床是唯一有資格下結論的東西。
⇒ 所以 P4 要把【四個候選各自的證據欄】都印出來，而不是去驗證 (c)。
⇒ ★而若床指認 (c) 成立：**修法寫在 handback 給我裁**，不要順手改寫入端詞彙
  （統一 propose_* 與 alliance 會動到 AI 側，那是另一張票）。
```

# ★三、母體地板（兩件，缺一 P4 會恆綠）

```
①先斷言【到達真的發生了】（`state.player_forced_event` 非空）
②★★R² 補的那一半：**同時斷言 `proposal` 真的是會撞 match 的那種值**
   （`propose_alliance`／`propose_trade`／`tribute_offer`）
   ⇒ 否則床會在一個【proposal 剛好合法】的世界裡對 (c) 恆綠。
★而 `tribute_offer` 是 R² 核出來的【第三個】會撞同一病灶的字串
  （`order_task` 全庫只有這一個具體非空值）—— 我原本寫「任意字串」措辭過寬，已在 spec 訂正。
```

# 四、做什麼（spec §3 逐字，四件）

```
①面板三行人話（誰／要什麼／接受後果／不回應的下場）；proposal → 中文表
   ★與 `_forced_label` 同處維護、不另開表；★★不認得的 id 印「提議（未知：<id>）」**不得吞**
②回應入列 ⇒ 面板鎖成「已排入回應：<中文>（推進時生效）」；同 interaction_id 入列去重
   ★看佇列尾端、不讀世界 ⇒ 可當場做
③生命週期三點（到達／回應結果／逾時）進玩家事件流 ＋ 終端 print；★現況缺【回應】那一點
④P4/P5 見 spec §4
```

# 五、驗收與收工

```
P1 人話（負對照：拿掉中文表 ⇒ 印回原樣 id ⇒ 必紅）
P2 未知 id 不吞（★守的是開放母體）
P3 連按 3 次 ⇒ 佇列只有 1 道（負對照：拿掉去重 ⇒ 3 道；★守「1」不是「少於 3」）
P4 ★★★指認格：四個候選各自的證據欄都印
P5 重複回應不產生 ✗
P6 三點齊（事件流＋終端）
P7 ui-flow 綠；merge 前全電池 BATTERY_RC=0
★負對照紀錄行照既有格式（`# 負對照：<怎麼點火> ⇒ 已於 <分支>（<日期>）實測紅`）；
  ★★不能住在 repo 裡的擾動，「不得 commit」要寫在那一行裡。
★★★常數照三前綴（SPEC_／MEASURED_／EXPECT_）。
handback 寫 main mailbox 絕對路徑 ＋ 敲我。
```
