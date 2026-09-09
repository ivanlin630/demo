---
from: implementer
to: systems
status: consumed
slice: C1 票② 走查 ＋ 常駐狀態列
topic: ★交件 17bbb7204：走查可重跑（一行指令）＋狀態列四件全走查詢面且【自陳 sources】｜★★驗收④的成對對照真的做出來了：刀下在查詢面【上游】(WALK_DROP_FIELD 抹掉 team.ctx_snapshot 一欄) ⇒ 逐欄 diff【只差那一行】食物 383.289→★未接出 ⇒ 證明畫面不是快取重播｜★★★而床第一次跑就撞到一個【我們兩個都沒想過】的缺陷：get_decision_snapshot 交出去的是 t.ctx_snapshot 的【本體】不是副本 —— 觀測者可以改被觀測物，而它的症狀是把我的對照變成【跟自己比】
---

# ① 交件（commit 17bbb7204）

```
scripts/simulation/player_query_api.gd   ＋get_world_clock ＋get_status_line（★只組合既有動詞）
scripts/debug/c1_walkthrough.gd          走查腳本（@bed-kind: diagnostic）
scripts/debug/c1_ticket2_bed.gd          驗收床（acceptance）4/4 段 0 fail
docs/measurements/2026-09-10-c1-walkthrough.txt   ★跑出來的那一份（132 行欄位）
```

一行指令：`.\tools\godot.ps1 --headless --script scripts/debug/c1_walkthrough.gd`
（`WALK_DAYS=2` / `WALK_ERRORS=1` / `WALK_DROP_FIELD=<欄位>` 三個環境變數）

# ② §4 逐格

```
①可重跑          ✅ 在 repo，一行指令，seed 固定 ⇒ 用戶隨時再看一次
②五頁＋狀態列    ✅ 天窗印【具名 who】不靜默（本次唯一天窗＝關係圖全貌，指向 todo 票）
③四件全走查詢面  ✅ 床驗值真（who=領袖名／where 有 tile／doing 來自快照／clock 第 2 天）
                 ★★而我加了一格 spec 沒要求的：狀態列【自陳 sources】
                    ⇒ 「它有沒有走查詢面」從【要相信】變成【可以查】
                 ★成對對照：沒跑過決策的世界 ⇒ 明說【尚無快照】，不是填一個看起來正常的 idle
④成對對照        ✅ ★見 §③（下面），diff 只差一行
⑤fp 不變         ✅ 五支查詢動詞前後 fp 相同；★對照：動 unrest_turns ⇒ fp 真的變（擋恆真）
```

# ③ ★★驗收④：我把刀下在【上游】

```
做法：WALK_DROP_FIELD=food_stock ⇒ 從 team.ctx_snapshot 抹掉那一欄
      ★★而不是在印的時候跳過它 —— 印畫面那段程式碼【不知道有這回事】。
結果（兩次跑的逐欄 diff，全檔只差這一行）：
  <   food_stock                       383.289
  >   food_stock                       ★未接出（player_query_api.get_decision_snapshot）
⇒ ★你（R²）說這格防的是【畫面接的是快照/快取不是即時查詢】—— 對照落在那個區間上。
```

# ④ ★★★床撞出來的缺陷（已修，並就地變成守衛）

```
get_decision_snapshot 原本 "fields": t.ctx_snapshot ⇒ 交出去的是【本體】。
症狀：我拿 f0 = fields，然後 erase 一欄，再拿 f1 —— ★f0 被一起改掉，
      size 斷言 119→118 讀成 118→118 ⇒ ★★對照變成【跟自己比】而它看起來只是「數字不對」。
修法：duplicate(true)。★釘一格守衛：改回傳值 ⇒ 引擎快照不得跟著變。
```

★**我要指名的是它的形狀**：這個缺陷**不是走查發現的，是【對照】發現的** ——
★★而它發現的方式是**對照自己失效**：如果我當時只看「拿掉之後查詢面回不出它」（那一格是綠的），
★★★**我會帶著一個「觀測者可以改世界」的查詢面交件，而所有驗收格都是綠的**。
⇒ 這是「成對對照要兩半」的第 N 次兌現，只是這次**紅的那一半救的不是這張票，是查詢面本身**。

# ⑤ 人話層清單（本票第二個產物，第一批）

```
camp_target_est        〈物件〉尚未轉成可讀值（畫面上是一個 RefCounted）
leader_values          {11 鍵} 原始浮點（"野心": 0.4218…）—— 玩家要的是「他野心不小」
survival_stall_active  [0 項] ／ faction_stakes [0 項]
   ★★★空陣列在畫面上【分不出「是空」還是「沒接」】—— 而這正是天窗要防的那個病，
      只是它以【空值】的形態溜過去了 ⇒ 建議：集合類欄位空的時候印「（無）」而不是「[0 項]」。
```

# ⑥ 下一站

```
★這一份要【給用戶看】才算完成（分頁的批准閘在他那裡）⇒ 呈 blueprint 轉。
  ★★開場已明示埋了 1 顆錯（N 講明、位置不講）；答案在檔尾 WALK_ANSWER 行。
★★★而【漏抓只重審那一頁】那條也印在畫面上了，事前講好，不是事後搬。
我這邊接著做：is_live_actor（你排的下一張）。
```
