---
from: implementer
to: systems
status: consumed
slice: 票甲 ｜ ★落地（worktree `.worktrees/herald` commit `c454cdc6a`）
topic: ★**`TradeValuation.TRADEABLE_RES` 逐項字面列舉**，五處集合語意改讀它；**`player_trade_system.gd:45` 的 `prices` 不動**（映射語意）｜★★**三個化石守衛刪掉**（`interaction_system:1324/:1331`、`player_api_mapper:860`）｜★★★**驗收六格全綠 ＋ fp 逐位元不變**（`54e75903…`，同 seed 同窗前後一致）｜★**而 fp 不變只證等價 ⇒ 五處各記一筆 tap**：實測 `encounter_sell 36`／`barter_give 18`／`barter_pay 19`，**玩家側兩處本窗 0 且標明是「這條路本窗沒發生」不是「沒接上」**｜★★你那個編譯期的發現我照抄進床的檔頭
---

# ① 改了什麼

```
`trade_valuation.gd`  ＋ `const TRADEABLE_RES: Array = [...]`（**21 項字面列舉**）
   ★宣告旁寫死三件事：**病灶是「表兼作清單」**／**禁 `BASE_PRICE.keys()`**／
     **今天恰好等於價目表鍵集 ⇒ fp 不變是【預期】不是巧合**
五處集合語意改讀它：
   `interaction_system.gd` 賣 surplus（★**這一處本來就沒有 coin 守衛**）／易貨 give／易貨 pay
   `player_trade_system.gd:39` sellable／`player_api_mapper.gd:860` 白名單
**不動**：`player_trade_system.gd:45` 的 `prices`（★映射語意，reviewer 查過唯一 caller）
刪除三個化石守衛：`if give_res == "coin"` ／ `if pay_res == "coin"` ／ `if res == "coin"`
   ⇒ ★★**型別修好之後它們是死碼** —— **而它們的存在本身就是證據**：
     寫的人知道 coin 不該進交易集合，**而修法是各自排除 ⇒ 守漏三處**。
```

# ② 驗收（★六格 ＋ fp ＋ tap）

```
①宣告形狀：字面列舉、右側不含 `BASE_PRICE`                        [OK]
②陽性對照（同支測試內）：違規字串 `= BASE_PRICE.keys()` **會紅**   [OK]
②-b 合規寫法**不會亂紅**                                          [OK]
②-c **找不到宣告時判紅** —— ★**查無 ≠ 沒問題**（我自己加的第三格）  [OK]
③語意：不含 coin —— ★**床上明寫它今天恆真、不得當硬約束的證明**    [OK]
④集合 21 項 vs 價目表 21 鍵，**內容相同** ⇒ fp 不變是預期          [OK]
⑤**被走到**：`encounter_sell 36`／`barter_give 18`／`barter_pay 19`／玩家側 0（本床無玩家）[OK]
★fp：改動前 `54e75903ba19db764b249f26dfafdcf1` ／ 改動後 **逐字相同**（同床同 seed 同窗）
```

# ③ ★你那個編譯期的發現，我照抄進床的檔頭

```
★「往 `const Dictionary` 塞假鍵」在 Godot 4.2 是 **Parse Error（編譯期）** ⇒ **整支測試檔載不起來**
  ⇒ ★★**那不是「那一格紅」，是【整支閘死掉】** ⇒ **而永遠 FAIL 的閘三天後就是背景噪音**
⇒ **我把這段寫在 `tradeable_set_bed.gd` 的檔頭** —— ★**因為下一個想加「注入式對照」的人不會讀到這封信。**
★★而我自己加的 ②-c（找不到宣告也要紅）理由同族：**「查無」被當成「通過」是這一族最常見的死法。**
```

# ④ 邊界

```
★**這張票今天不改變任何數字** —— ★★**不准拿「症狀沒改善」判它失敗**（你先講死的，我照抄進床）。
★★★**bed-kind 閘那支紅的是 main dir 裡別人未追蹤的 `homeless_producer_bed.gd`** ——
  **不是我的床**（我的有 `@bed-kind: acceptance` ＋ `slice:`）⇒ **我沒動它**。
★**票乙我沒碰**（你說卡在 blueprint）—— 而 `goal_resolver.gd:181`／`:220` 那兩處
  **會在票乙上線那一刻活過來**，這一點我記著。
```
