# 附身隊後續三件（多格移動 merge 後小票）——HOW

狀態：收 R²（2026-10-13-reviewer-to-systems-R2-possessed-followups-ISSUES）
來源：多格移動交件信 §5（2026-10-13-implementer-to-systems-DONE-multi-hop-move-3-rulings）；藍圖裁定 2026-10-13-blueprint-to-systems-RULING-idle-possessed-team-does-not-forage-is-intent（「開始挨餓」進推進停點；買賣單小票同意）
基底：main 67e95edb3（多格移動已 merge，`TeamData.possessed` 事實欄在）
known_issues：三筆（附身隊掛單／loop3 其餘寫者未分類／挨餓不停推進）

玩家看得到：甲、乙。丙是分類報告（不改 code，除非分出來的項是甲同型、修法逐字同甲）。

---

## 甲、AI 不替附身隊掛買賣單（#12 的 orders）

### 事實（file:line，main 67e95edb3）
- 唯一呼叫點 `faction_ai_system.gd:1611` `OrderSystem.new().tick_team_orders(state, team)`。
- `order_system.gd:245` `tick_team_orders`：①到期清理＋`release_order_escrow`＋失敗記憶（:246-275）②餘量發賣盤（:280-293，含 `_tick_food_granary_sell`）③短缺買單（:294-305）④糧買單（:306-315）。
- ②③④ 都經 `post_order`（:32），把貨／錢放進 escrow ⇒ 玩家背包裡的東西會被 AI 拿去掛單。

### 改法
- `tick_team_orders`：①照跑（到期與退貨是物理與記帳，不是決策）；`team.possessed` ⇒ ①之後 return，②③④不跑。
- **不改** `post_order` 本體：玩家自己的交易指令若走它，照舊可用（那是 PLAYER 來源）。
  ⇒ 實作端先列出 `post_order` 全部呼叫端（含玩家指令路徑），逐條標「決策層／玩家指令」，交件信附表。
- 附身開始時隊上已有的 AI 單：預設不撤，照 `ORDER_LIFETIME`（5 天）到期退貨。
  - 交件信量：在附身 30 天世界（同乙的量測世界）附身那一刻殘單數、各單貨量、佔玩家「可動糧」（effective_food）與各資源持有的比例。
  - **任一資源被扣住 >20% ⇒ 改成附身時撤**：撤的寫入路就是 `release_order_escrow` 本身（同一條守恆路，不算新路），掛在 `sync_possession` 的 false→true 邊。≤20% ⇒ 不撤。
  - 查 `release_order_escrow` 到期退貨有沒有玩家可見句（scripts/ui、player_query_api、player_api_mapper 目前對 active_orders／escrow 零引用）；沒有 ⇒ 我記 known_issues「掛單與 escrow 對玩家不可見」（玩家自己的單也一樣，不在本票修）。

### 驗收
- A1（修前紅）：附身隊身上有餘量、站在市集，推 ≥1 天 ⇒ 新增 AI 單數 0；同條件非附身隊 >0（同床對照，證明條件真的會觸發掛單）。
- A2：附身隊身上已有一張 AI 賣單 ⇒ 到期照退貨（或依上面的 20% 線在附身時撤），守恆 audit 零違反。
  - 佈置：訂單沒有來源欄（AI／玩家混在 active_orders）⇒ 「AI 單」由床自己造：附身**之前**直接呼 `post_order`，再附身。驗收不宣稱分得出來源。
- A3：玩家自己的交易指令仍可成立（走 `player_command_api.gd:153-163` → `post_order`，R² 已核）。
- 負對照：拿掉 possessed return ⇒ A1 紅。

---

## 乙、自家隊開始挨餓 ⇒ 推進停下

### 事實
- 事件已存在：`resource_system.gd:247` `WorldEvents.emit(state, "famine_crossed", [team.team_id])`，在 `famine_days` 由 0 轉正那一刻（池耗盡且滿足度 < `FAMINE_SATISFACTION_THRESHOLD`）。
- 它已經會進玩家事件流（`emit` → `_feed_player`），但句子走 `describe` 的預設分支 ⇒「TeamN：饑荒」。
- 推進停點清單 `world_events.gd:106` `ADVANCE_STOP_KINDS` 不含它。

### 先量（動 code 前）
`famine_days` 歸零有兩處（`resource_system.gd:234` 吃飽、`:252` 滿足度 ≥ 0.3）⇒ 糧在 0 附近、有零星進項的隊會在一天內多次 0→正。停點若每次都停，推進會被反覆打斷。
- 量：附身 30 天真世界（玩家不下令＝本意下的常態），對玩家隊印 `famine_crossed` 次數／天的逐日直方、>1 次／天的天數、最多那天占總數比例；附 seed 與 tick 數。另跑一個「玩家每天下一次覓食」的世界作對照（有進項的情形）。
- 兩個世界都 ≤1 次／天 ⇒ 照下面改法做，不節流。
- 任一世界 >1 次／天 ⇒ **停手，量測結果交我**，節流規則由我設計（方向：距上一次停點至少一段由既有常數推出的時間，不新增絕對值）。不要預設節流。

### 改法
- `ADVANCE_STOP_KINDS` 加 `"famine_crossed"`（停點只看「主體含玩家隊」，`stop_event_since` 已是這個寫法 ⇒ 別隊挨餓不停）。
- `describe` 給專屬句：「<隊>：存糧吃完，開始挨餓（再 N 天開始有人餓死）」，N 讀 `ResourceSystem.FAMINE_GRACE_DAYS`，不抄數字。
- 註解改 `world_events.gd:103-105` 那段停點說明，加上挨餓。

### 驗收
- B1（修前紅）：玩家隊糧（隊上與糧倉）寫死 0（觸發條件是池耗盡分支 `:235 else` 且滿足度 < 0.3，「不夠一天」不保證走到），按 X（推進到事件）⇒ 停在 `famine_crossed` 那一 tick，結果行是上面那句。
- B2：別隊挨餓 ⇒ 推進不停。
- B3：已在挨餓中（famine_days > 0）再推進 ⇒ 不重複停。
- B3b：進項→耗盡震盪：糧給一日量的 1.2 倍，分兩次餵（第二次在第一次耗盡後）⇒ 停點次數＝耗盡次數（預期 2），床寫出預期值；若量測後加了節流，預期值照節流規則改寫。
- 負對照：從 `ADVANCE_STOP_KINDS` 拿掉 ⇒ B1 紅。
- terminal E2E 照綠（若有既有步驟會因為多停一次而改變，交件信逐條列出）。

---

## 丙、loop3 對附身隊仍會寫的其他欄位：分類（報告）

交件信 §5 列的每一個寫者（決策節奏、求生 `current_option`／`order_target_id`、`survival_committed_*`、`ambition_rung`、`CoinTreasury.consider_extraction`、`prosperity_target_id`、pursuit 直寫 `move_target`、據點駐留欄、裝備欄；以及玩家為勢力首領／成員時 `_decide_unified` 本體先跑的那段）：

- 逐條給 file:line＋分類：**決策**（AI 替這隊選了一件事 ⇒ #12 管）／**物理或記帳**（不論誰操控都會發生 ⇒ 照跑）／**不可達**（附身隊走不到，附理由）。
- 判準三問，任一為「會」⇒ 決策：
  1. 玩家沒下任何指令，這一行會不會讓他的隊伍做出他沒選的事？
  2. 會不會讓他的東西變少？
  3. 這個欄位會不會被 arbiter、選項評分或玩家指令的前置檢查讀到，而改變玩家之後下的指令的結果？（例：`faction_ai_system.gd:640-646` 的 crisis 免疫窗——沒做事、沒扣東西，卻讓 M 被擋。同族候選：`order_target_id` 鎖、persist_strength／承諾持守、`FailureMemory.record` 是否折價玩家的買糧、各 `*_next_tick` 節奏欄要分類並說理由。）
- **「不可達」要跑出來**：用多格移動票的寫入觀察（`mt_watch_tid` 那一支）擴到被標不可達的每個欄位／函式，對附身 30 天世界跑，命中次數＝0，附 seed＋tick 數。讀碼只能證寫者存在，證不了走不到。
- 「物理或記帳」要防決策偽裝：`CoinTreasury.consider_extraction` 判準＝抽的錢有沒有走玩家隊的 coin／resources（帳本 tap 證），以及抽的時機與金額是不是 AI 評分決定（是 ⇒ 決策）。
- 分類是**決策**、且修法就是「入口對 possessed return」的 ⇒ 可在本票一起修，各自一格修前紅床＋負對照。
- 其餘（修法要設計的）只列不修，交件信寫出來，我另開票。

---

## 範圍外
- 玩家隊的自動覓食開關：藍圖裁不做。
- 附身開始時撤掉 AI 殘單：依甲的 20% 線決定。
- world-fp：甲、乙應不動 fp（world-fp 那個世界沒有附身隊）；動了 ⇒ 先二分再報，不換基準。
