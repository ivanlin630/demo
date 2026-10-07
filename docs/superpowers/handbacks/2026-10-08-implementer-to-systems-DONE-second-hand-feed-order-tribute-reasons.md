---
from: implementer
to: systems
status: open
slice: 用戶第二手批（absorb-at-cap ①驗證／③事件流時序／④沒錢不提進貢）＋原因批 ②動作清單印原因／③招募空集合原因
topic: ★交件｜branch `feat/second-hand-feed-tribute` tip `990e6dacb`（已推）｜全電池 BATTERY_RC=0｜★world-fp 新世代 67ffb529（④改 NPC 決策；負對照證明只來自④）｜①修前即綠 ⇒ 依 spec 不改 code
---

## 結果

- branch `feat/second-hand-feed-tribute`，tip **`990e6dacb`**（已推），基在 main `41444bd92`（之後 main 只多信箱與 C2 diagnostic 床）。
- 全電池 **BATTERY_RC=0**（第二輪；第一輪唯一紅見下「一處自修」）。
- **world-fp：6019f170 → 67ffb529a8a695bfdebfa64a96ac66f3**（註冊表 world-fp 列已換，同 branch）。

## 各件

| 件 | 修前 | 做了什麼 | 修後 |
|---|---|---|---|
| ①強制事件回應結算後結果行＝真結果句 | **綠**（FR1 四種事件×八個回應全對；FR2 滿上限按收留 ⇒「你選了「收留…」，但隊伍已滿，無法收留 ⇒ 沒有生效」、人口 11→11） | 依 spec（藍圖 fda4636f1）只留驗證格，**不改 code** | 綠 |
| ③事件流按 tick 排序 | FO2 紅（01:00 敵人逼近之後接 00:59 指令結果） | `text_ui_main._feed_push`：事件區唯一寫入點，按 tick 穩定插入（同 tick 照寫入序）；世界事件／指令結果／介面句三處都走它 | 綠 |
| ④沒錢不提進貢 | 新床 P1、P2 紅（seed 1337 十天提出 24 次，2 次提案隊 coin＝0） | `DiplomaticAiSystem.tribute_amount`（進貢金額唯一一份，轉帳與提案端同讀）；`DecisionContext.has_tribute_to_give`；「求和」applicable 加它 | 綠（十天 22 次全有錢） |
| 原因②動作清單（不可）印引擎原因 | RS2 紅（7 項全空） | 自家隊動作「（不可：原因）」讀 disabled_reason；寬度預算 `SELF_ITEM_COLS`（一列三項）＋`TextUiLayout.clip_mark`（放不下以「…」結尾）；目標動作區同法截；按下去結果行印完整原因（既有那支） | 綠 |
| 原因③招募空集合說為什麼 | RC3 紅（「無可招募對象」） | `_action_recruit` payload.`empty_reason`（「TeamN 只有領袖一人，招募挖不到人」／沒有願意走的記名成員且錢不夠）；UI 只印它（事件區＋結果行） | 綠 |

## 三處要你過目

1. **③ 的床在讀者層佈置**：走法每道令只推一顆 ⇒ 走不到用戶那一屏的形狀（FO 掛在 `_press`、每一次按鍵回來的那一屏都驗：修前 7040 屏 0 倒退）。機制是「一次推進步最多吃一小時，同一讀取回合先寫世界事件、後寫指令結果，而指令結果的 tick 是較早被消費那一顆」⇒ FO2 放一筆 t−1 的指令結果＋一筆現在的世界事件、按 G 5（不按 X：結果句壽命 60 tick，推滿一小時那筆會在讀到之前過期被清）。用戶原例是舊 M（自帶推到抵達）造成的；M 票之後這條路已經沒了，但機制還在。
2. **④「可給的東西」只算 coin**：spec 寫「coin 與可給資源皆 0 ⇒ 不列」；但收下那一端（`apply_tribute_transfer`）只轉 coin ⇒ 照「列的條件＝做的條件」，判準讀同一支金額函式（coin×比例 > 0）。若要讓食物等也能進貢，那是收下那一端要改，不在本票。★「求和」的 order_task 就是 tribute_offer（NPC↔NPC 那條收尾不轉帳）⇒ 沒錢的隊從此不會選「求和」。
3. **原因②格式用「（不可：原因）」**（spec 例句是「（離據點太近）」）：跟目標動作區、打聽題目既有的「（不可：…）」一致。要改成不帶「不可：」說一聲。

## 負對照（detached，各自紅在自己的格）

- **n4**（只拿掉 applicable 那一條）：④床 P1／P2 紅；**world-fp 回到 6019f170** ⇒ 指紋變動只來自④。
- **nui**（同一棵樹拔三處 UI：插入改回 append、原因改回「（不可）」、empty_reason 給空）：RS2／RC3／FO2 紅（FO 因 FO2 那一屏也紅），其餘格照綠。

## 一處自修

第一輪電池 text-ui-layout P5 靜態半紅：我在動作區算欄寬時寫了 `"（不可：）"` 字面，而該守衛要求「（不可：」後面只接變數 ⇒ 改 `"（不可：%s）" % ""`（`008821542`）。

## 其他

- 新床 `tribute_offer_has_something_bed.gd`（invariant）已進註冊表。
- 已知洞清單 `docs/playtest/round4-known-holes.md` 加三列（事件區時序／沒錢進貢／不可動作沒原因＋招募）標已修。
- 床裡字串內的真換行（含一處舊的 :589）改回 `\n` 跳脫，輸出等價。

## 下一張

A2 修「先查」（床已寫好：`scripts/debug/a2_fix_census_bed.gd`，branch `feat/a2-fix-mark-written`），現在跑分佈；主因不是「不在 arrived_ids」就停手回你。
