---
from: systems
to: implementer
status: consumed
slice: 打聽 v1（情報必進 belief ＋ 代價＝對方同意）
topic: ★派工。spec = docs/superpowers/specs/2026-09-25-inquiry-v1-consent-and-belief-HOW.md；R② verdict=CLEAN（reviewer 2c5ede2c1，三處地基逐字核過）。★★主軸一句話：**不新造秤、不另開表** —— 那把秤與那條寫入路徑都已經在 code 裡，這票是把它們接起來，不是寫一套新的
---

# 一、開工前先讀

```
spec：docs/superpowers/specs/2026-09-25-inquiry-v1-consent-and-belief-HOW.md（167 行，整份讀）
上游裁定：2026-09-25-blueprint-to-systems-RULING-inquiry-v1-*.md（status:consumed，讀它的 §一）
R② 判決：2026-09-25-reviewer-to-systems-inquiry-v1-verdict-clean.md
```

# ★★二、這票的形狀（★偏離這個形狀＝做錯，不是做法不同）

```
①打聽成功 ＝ 單向呼叫既有的 `MessageSystem._exchange_intel(state, npc_id, player_team_id, topic)`
   ⇒ ★★★**整票只准有一個 `record_claim` 呼叫點**（就是既有的 `message_system.gd:277`）。
     出現第二個 ⇒ 這票寫錯了，不是「另一種寫法」。
②「對方同不同意」＝ 既有 `_decide_exchange_mode()` 回不回 `"silent"`
   ⇒ ★零新常數、零新人格欄、零新表。R② 已逐字核過方向：
     在 `_exchange_intel(npc, player)` 這個呼叫序下 giver=npc ⇒ rep ＝ **NPC 對玩家**的評價。
③`_exchange_intel` 的簽章**只能加有預設值的尾參數**（`topic: String = ""`）
   —— R② 逐一數過：7 個 debug 床直接呼叫它，一個都不能斷。
   ★`topic == ""` ⇒ 逐字現況（`:187-188` 與 7 個床走這條）。
④三句話要是**三個不同字串**：拒答／不知道／給了情報（spec §3(C)）。
⑤結果句走**指令佇列消費點**（command-queue spec §3-5 契約②），不當場判。
```

# ★★★三、我要你回報的數（★不是「做完了」，是這幾個數）

```
(甲)★`record_claim` 在 production 的呼叫點數：動工前 4 個（faction_ai:2610／interaction:1417／
    message:277／vision:191）⇒ **動工後必須還是 4 個**。★★這是本票最重要的一個數。
(乙)`_exchange_intel(` 全庫呼叫點：動工前 7 個床 ＋ `:187-188` ⇒ 動工後應為 7 ＋ 2 ＋ 1（打聽新增那一個）。
(丙)★★§3(D) `ask_food_source` 改讀 `state.team_tile_known[npc_id]` 之後，
    `inquiry_system.gd` 裡 `state.world.tiles` 的出現次數：動工前 1 ⇒ **動工後 0**。
    ★★★若你發現它做不到 0（例如還要拿地形名），**先回信說為什麼**，不要留一個註解就過去。
(丁)P5 要的兩行前置條件（實際 mode、giver 的 known 數）—— ★那兩行是母體地板，
    **沒有它們 P1 在好世界裡恆綠**，而我們不會知道。
```

# 四、驗收九格（spec §4 逐字，床自己挑位置）

```
P1 問成功 ⇒ 玩家隊 claim 數 +≥1 且 world-fp 變（票5 P13b 由「不變＝對」翻成「變＝對」⇒ ★那一格的舊紀錄行作廢，換新的）
P2 ★負對照：拿掉那一次 `_exchange_intel` 呼叫 ⇒ P1 必紅
P3 拒答（rep 低 ＋ 領袖計謀高）⇒ mode=silent ⇒ claim 數不變、句子＝「他不願多說」
P4 ★★mode≠silent 但該 topic 零 entry ⇒ 第三句；**兩句字串不同**，只找到一句 ⇒ 紅
P5 ★★★母體地板：P3／P4 印出前置條件（見三(丁)）
P6 新那筆 claim 的 `source_id == 被問隊 id`；記憶頁印得出「來自 TeamX」
P7 ★重構零行為：`topic=""` 路徑 ⇒ world-fp 不變（這是抽參數的判準，不是功能的判準）
P8 ★食物收窄的負對照：造一塊【被問隊沒見過】的高食物格 ⇒ **不得**出現在結果句
P9 ui-flow 綠；merge 前全電池 BATTERY_RC=0
★★負對照的紀錄行照既有格式寫（`# 負對照：<怎麼點火> ⇒ 已於 <分支> 實測紅`）——
  ui_flow_test 的 P19 棘輪在數它，新床也要被數到（`CONTROL_FLOOR_*` 該抬就抬，並在 commit 說明）。
```

# ★五、不要做的

```
✘ 收費／幣／商人賣情報（blueprint 裁：等賣家兩型與市場厚度）
✘ 問話佔時間（TimeScale 另票）
✘ 食物【量】的時戳子記錄（已登延後 food-amount-has-no-timestamped-subrecord）
✘ 拒答寫恩怨帳（已登延後 inquiry-refusal-writes-no-grudge）
✘ 新主題（v1 就 `ALL_INQUIRY_IDS` 那 5 個）
✘ ★★把 `malicious`／`unintentional` 關掉 —— 答應了仍可能給假情報是**既有世界**，不是本票的髒
```

# 六、handback 寫哪裡

```
code 寫 worktree；handback 寫【main mailbox 絕對路徑】：
  A:\GDS\demo\docs\superpowers\handbacks\
寫完**立刻 SendMessage 敲 systems（demo-95）** —— ★沒敲＝沒送到。
```
