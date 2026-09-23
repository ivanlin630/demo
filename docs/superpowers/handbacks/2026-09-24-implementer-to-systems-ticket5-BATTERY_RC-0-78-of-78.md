---
from: implementer
to: systems
status: consumed
topic: ★★★票5 全綠：`BATTERY_RC=0`｜✓ 78｜✗ 0 —— 可以 merge｜★七支指名的閘全部真的跑過（含新加的三支與剛重設基準的兩支）｜★★這一輪的產出清單附在最後：第一次跑抓到 1 個死鎖 ＋ 1 個殭屍隊守衛缺口 ＋ 1 件我漏做的裁定
---

# ★一、判決

```
[TREE] HEAD=22aa38987  branch=feat/command-queue（rebase 到 a299dd296 之上）
       registry 78 列，指名核：value-key-selfcheck ✓在｜command-replay ✓在
★★★[MERGE-GATES] BATTERY_RC=0 ｜ ✓ 78 ｜ ✗ 0
```

**指名核（不數數）—— 七支關鍵閘都在卷面上**：
```
✓ headless            （22s）  ← 曾紅：儀器沒跑到
✓ ui-flow             （10s）  ← 44／44
✓ command-replay      （24s）  ← ★新閘，11／11
✓ value-key-selfcheck （1s）   ← ★票3 帶進來的那一列，沒有在 merge 中消失
✓ live-team-ratchet   （0s）   ← 曾紅：殭屍隊守衛
✓ world-fp            （259s） ← 曾紅：基準
✓ world-fp-ctrl       （258s） ← 同上
```

# ★★二、這一輪（第一次跑）真正換到的東西

**(1) 一個死鎖（真缺陷）**
```
game_over／choose_heir 在 `_advance_tick_body` 被呼叫【之前】就 return，而消費點在它裡面
⇒ 凍結世界裡每一條指令【靜默丟棄】，而唯一能解凍的那條也在裡面 ⇒ 永久卡住
處置：兩個分支各加一次消費（你裁的 (乙)）＋ P16 把它釘成守衛
★實測：凍結中玩家現在收到「移動到 (9999,9999)：被拒絕（目標格不在地圖內）」
```

**(2) 一個我漏了的既有守衛**
```
`teams.has()` 對【待刪除的殭屍隊】也是 true ⇒ 玩家會對正在被移除的隊開選單
正確守衛 `can_be_player_target()` 全庫兩個玩家面路徑都在用 ⇒ ★我漏的是既有那道，不是棘輪太嚴
```

**(3) 一句我漏做的裁定**
```
(乙) 寫「當場那一關只擋 dispatch 的 match 認不認得這個 name」——我沒做
★它是 headless_test 的「unknown cmd: ok=false」紅出來的
判準走 VERB，而 P9 保證 VERB ≡ dispatch 名單 ⇒ 用那份【有守衛的】白名單
```

**(4) 三個【我自己的守衛】的缺陷，全部由地板或對照抓出**
```
·P16 斷錯時點（凍結檢查在消費之前 ⇒ 那一顆必然仍回 awaiting_heir）
  ★而它紅的那一行同時印出 leader_id 已換人 ⇒ 分得出「我問錯了」不是「產品錯了」
·P15 直呼 bridge ⇒ 繞過印回音那一行 ⇒ 畫面 0 次 ⇒「≤2」恆真（★地板抓到）
·負對照擾動第 0 條指令 ⇒ 效果被後面五條覆蓋 ⇒ fp 不變（★改成擾動最後一條）
```

**(5) 兩個環境事實**
```
·`chr()` 是 Godot 3 的全域函式（Godot 4 是 String.chr）—— ★我用它取代反斜線，而我「確認」它可用的方式是【它在 Python 裡 work】
·`state.world.tiles` 鍵是 q*1000+r，不是 `state.tiles[Vector2i]`
```

# ★★★三、兩件我留給後面的（沒有順手做）

```
①P13b 印出的事實：`confirm_gather_intel` 5 次都成功而 fp 不變
  ⇒ blueprint 要的「指令層」今天在 code 裡還沒有落點 —— ★那是 WHAT 的決定，我不補
②world-fp-ctrl 釘絕對值的結構問題（你登記過）：它要證明「多觀測不改變世界」
  ⇒ 該斷言「與 world-fp 這一輪的輸出相同」，控制組本來就該是相對的
  ⇒ 排在三張票 merge 之後
```

★**已 push**：`origin/feat/command-queue` = `22aa38987`。等你 merge。
