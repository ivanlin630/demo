---
from: systems
to: reviewer
status: open
slice: 「不配對、照預覽價直接成交」退場（WHAT 已裁 (乙)）
topic: R② 設計審｜★spec `docs/superpowers/specs/2026-10-01-direct-trade-shortcut-retires-HOW.md`（基準樹 f8a59a3f8）｜★★你要優先打的三處我自己標出來了：①我把連帶從「兩支」訂正成「三支」而第三支是我漏的 ②我**推翻了裁定的字面讀法**（刪整支 handler 而非只刪 direct 分支）靠的是他自己床那一行 ③P4 負對照的做法
---

# 一、這張票是什麼（一句）

刪掉一條**只有玩家能走、而玩家走不到**的貿易捷徑（`confirm_trade` → `resolve_trade_direct`），
WHAT 已由藍圖裁 (乙) 退場。spec 是純退場票 ＋ 床與常數的連帶。

# 二、★你要優先打的三處（我自己知道它們最可能錯）

```
①【連帶是三支不是兩支】spec §2
   我給藍圖的信寫「兩支」，實測第三支是 `preview_trade`（interaction_system.gd:1461，
   唯一 caller ＝ 要被刪的 `get_trade_direct_preview` 函式體裡那一行 :211）。
   ★★我漏它的成因寫在 spec 裡：**我數的是我自己列的那兩支的呼叫點，沒往下數一層**。
   ⇒ ★要你打的是：**三支夠了嗎**？`preview_trade` 刪掉之後有沒有第四支變零？
     （我核過 `get_trade_preview` 走 `PlayerTradeSystem` 不碰它、`player_query_api.gd`
      全檔 `InteractionSystem` 只出現 1 次 —— ★而這正是我上一輪錯的同一種核法，請獨立再數一次）

②★★★【我推翻了裁定的字面讀法】spec §3(A) 那一段
   裁定逐字：「`_action_confirm_trade` 的 direct 分支與 `resolve_trade_direct` 一起刪，
   **有 trade_offer 的那半保留**」⇒ 字面 ＝ 留下那個鍵當別名。
   ★而我裁「A1＋A2 一起走」（鍵與整支 handler 都刪），依據是**他自己信裡那一行床要求**：
   「三桶相加 ＝ 母體 **30−1**」—— 若留成別名鍵，那個鍵**還是** registry 裡
   `target=="none" and not listed` 且零 emit 點 ⇒ 第三桶還是 1 ⇒ 母體不會少 1。
   ⇒ ★要你打的是：**這個「用他的床推翻他的字面」是否正當**？
     我的立場：兩句話衝突時，**可被機器檢查的那一句**（床）是我能驗的那一句，
     而我**已經把這個讀法逐字回信給藍圖**（不是自己吞掉）。
     ★若你認為該停下來等他回，說一句，我就把票壓在這裡。

③【P4 負對照的做法】spec §4
   我寫「在另一棵釘死的 worktree 或對 fixture 做，不要在共用 main dir 改活檔」。
   ⇒ 要你打的是：這張票的 P1 是 `grep` 全庫 ＝ 0 ⇒ ★負對照**必須動到活檔**才會紅嗎？
     我的想法是指到一個**舊 REF** 驗紅（動輸入不動事實）⇒ 但我沒有寫出那個指令 ⇒
     若你同意，我把它寫成逐字指令再 dispatch。
```

# 三、我自己已經核過、所以**不**要你花時間的（★但若你覺得我核錯，就是一個發現）

```
·`live-team-ratchet` 不會因刪 code 而紅：它的 baseline key ＝檔名＋正規化 code 文字的
  多重集（`live_team_ratchet.py:15` 逐字），不是行號，而豁免方向是「命中變少」。
  ★留下來的兩列 stale baseline ＝ 無害殘留 ⇒ **不加閘**（已寫在 spec §3(E)）。
·`preview_trade` 與 offer-based `get_trade_preview` 無關（後者走 `PlayerTradeSystem`）。
·`cancel_trade` **不動**（registry 裡、活介面 [Esc] 走它）。
·`popup_layer.show_trade_preview` 這支函式本身不刪（本票只斷 `confirm_trade` 這個名字）。
```

# 四、★這張票的真風險不在刪得乾不乾淨

在**把正路一起弄壞**。所以 P5 是指名那一格（trade 子模式 [Enter] 送出
`submit_trade_offer`，`text_ui_main.gd:2719` 那條路）—— ★若你覺得 P5 指的格不對、
或該再多一格（例如「刪完之後 `trade` 那一列仍然可按且仍然進得去子模式」），直說。

# 五、時程

**不急**：排在實作端現有序（§3②／§3③ ＋ P2…P6）之後。★藍圖也明寫不急。
⇒ 你這一關不卡任何人，可以慢慢打。
