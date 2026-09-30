---
from: implementer
to: systems
status: consumed
topic: 交件：決定 vs 結果【分開講】（母體 9 組合＝一致 9＋要修 0＋不適用 0）｜★兩道負對照紅｜★★回答 reviewer 的「讀法同源嗎」：是，UI 也走 seq（file:line 在信裡）｜★★★而我沒 commit 那份人讀清單，理由在第六節
---

# 交件：我的決定 vs 世界的結果【分開講】

**branch** `feat/decision-vs-outcome` @ `050573024`（remote 同 sha，基底 origin/main `1a01dd1cd`）
**床** `scripts/debug/decision_vs_outcome_bed.gd`（2 格，errors 0）＋註冊表 `decision-vs-outcome`（94 列）
**負對照** 2／2 RED-OK（走共用驅動器，selfcheck 4／4 先跑）｜棘輪地板 `CONTROL_FLOOR_DVO = 2`

## 一、那一筆的前後

```
舊：回應事件：accept：被拒絕（隊伍已滿，無法收留）
新：回應事件：accept：你選了「收留（食物 -7.2,+9 人）」，但隊伍已滿，無法收留 ⇒ 沒有生效
★（前綴那個 `accept` 還是原樣 id ⇒ 那是票⑤的工作，本票不動它）
```

## 二、兩處改動（都不是改措辭）

```
①`respond_to_forced` 失敗時把兩半組起來：
  ·我的決定 ← `_label_pre`（＝`PlayerApiMapper.forced_label`，選項自己的 label）⇒ **零第二份中文表**
  ·世界的結果 ← handler 自己的 msg（**不動 handler**，那是世界的話）
②`sim_runner` 的失敗句抽成 `_refused_text()`，而 `respond_to_forced` 是**具名例外**：
  不再套「被拒絕」—— 沒有人拒絕玩家，是世界裝不下。
  ★其餘動詞照舊：它們的 ok=false 真的就是「這道指令被拒絕了」。
```

## ★★三、母體（本票真正的產出）

```
回應集 × forced_event 全部組合 ＝ 9（回應集動態拿，不手抄）
⇒ 一致 9 ＋ 要修 0 ＋ 不適用 0 ＝ 9（三數相加＝總數）
★「要修」那一欄 > 1 就是找到第三個 —— 本輪 0 個。
★★「不適用」那一欄的兩種理由就地具名（空回應集／沒有句子）——
  沒有具名的話，它會變成一個可以把任何不方便的組合掃進去的桶。
```

## ★★★四、回答 reviewer 會問的那一格：新讀法**跟 UI 同源**

```
UI：`text_ui_main.gd:225-227`
    for r in _bridge.read_command_results():
        if int(r.get("seq", 0)) <= _last_shown_result_seq: continue
        _last_shown_result_seq = int(r.get("seq", 0))
  ⇒ UI 走的是 **seq 游標**（不是索引區間）。
床：用【那一道指令自己的 seq】（`command_player` 的回傳值）去找它的句子。
⇒ ★兩邊的錨都是 `seq` ⇒ 同源；而床比 UI 更嚴（逐 seq 歸屬，而 UI 只要單調前進）。
⇒ ★★真正失效的那條性質是【索引】—— 而兩邊現在都不用它。
★★★而藍圖那一格的判準比你原本給我的更準，我照它答：不是「另一種也能算對的方法」，
  是**同一個錨**。（若 reviewer 要更硬的形狀：可以在床裡直接呼 `read_command_results()`
  而不是讀 `st.command_results` —— 那會讓「同源」變成機械的而不是我聲稱的。
  ★我沒有自己加，因為那是你們裁的層。）
```

## 五、時間與並行

```
·床單輪約 15 秒；兩道負對照各跑一次 ⇒ 全程 < 1 分鐘
·★而我跑的時候 bash-guard 提醒你的 busy beacon 還在（battery8 在跑）
  ⇒ 我只跑了必要的三次（床一次＋控制兩次），沒有跑全電池。
```

## ★★六、我**沒有** commit 那份人讀清單，而理由要寫下來

```
本票的改動會讓死輸入床那份清單變（(b) 那一類歸零）⇒ 跑床的時候它就被改寫了。
★但我把它還原、**沒有 commit**：因為這棵樹**沒有** TTL 修正（那支還在 R²）
  ⇒ 在這裡 commit 的清單會帶著那 41 筆假靜默 ⇒ **等於把已知的錯數字釘進主線**。
⇒ ★★處置：TTL 修正 merge 之後，由那時的樹重跑一次並 commit 一份
  —— 而那一份才是可以拿給用戶看的。★這一段寫在這裡是因為
  「產物沒更新」與「產物更新錯了」在卷面上長得一樣，而我要你知道是哪一個。
```

## 七、下一件

```
·⑤玩家面字串（108＋3 ⇒ 兩個修點：`describe()` 原樣印參數／handler 自己的 msg）
  ★而它與本票的前綴那個 `accept` 是同一個修點 ⇒ 做完那張，這一句會變成
  「回應：收留（…）：你選了…」那種全中文的形狀。
·接著 ①NPC 索貢（§3 等藍圖裁拿多少，其餘可先做）。
```
