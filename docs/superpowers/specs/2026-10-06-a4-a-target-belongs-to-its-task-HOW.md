# A4「目的地屬任務」：任務換手時 move_target 由新任務重給或清空，禁沿用（HOW，小票）

```
票源 ＝ 藍圖裁 `0e9177d28`（Team40：t8540 以逃跑把 move_target 設成自家 (10,25)，t8973 任務換成貿易而 move_target 沒重設，
  t9000 帶 TRADE 抵達自家市集）｜WHAT：move_target 是**當前任務的附屬狀態**，不是隊的；沿用＝手往舊腦指的地方走
基準樹 ＝ `0d06408e0`｜序 ＝ A3 之後順手，不擋 E2E
```

## ★★★§−1 陽性對照被推翻（實作端開工前量，systems 2026-10-06）

```
Team40 t8973（fp 世界，臨時儀器已還原）：`try_set Team40 idle→貿易 target_param=(10,25) cur_mt=(-1,-1) src=ambition`
⇒ 換手那一刻 move_target **已經是 (-1,-1)**（逃跑到達時已清）；(10,25) 是**這次派工新給的**目標，**不是沿用**
⇒ 本票的票源（「Team40 換任務沿用舊目的地」）**不成立** —— 它建在實作端 A3 那句從每 tick 開頭快照推出的錯推論上
⇒ Team40 的真病是另一張（套利目標可以是自家市集上的單、而自家市集不交易也不 release）—— 交藍圖
⇒ ★本票的**結構論點仍真**（`transition` 11 處完全不碰 move_target），但**目前沒有實例**
⇒ 處置：實作端先量「經 transition 換手時 move_target ≠ (-1,-1)」的次數（fp 世界＋30 天觀察世界）
   有實例 ⇒ 用它當 P1 的陽性對照；零實例 ⇒ 本票**暫緩**、登 defer（回訪條件＝某次量測出現實例）
⇒ 下面 §2 P1 的 Team40 那一格**作廢**（原文保留）
```

## §0 換手的入口（我數過，`task_arbiter.gd`）

```
`try_set`（:124）：**每次都寫** move_target（:196／:212／:223／:241），值＝呼叫端傳的 `move_target` 參數
  ⇒ ★但有呼叫端把**舊的** `team.move_target` 當新目標傳進去（`git grep "try_set(...\.move_target"` ＝ 2 處）：
    `faction_ai_system.gd:7856`（TASK_HOLD）／`interaction_system.gd:832`（herald_order）
`transition`（:373）：**只改 task／priority／reason／start_tick，完全不碰 move_target**（本體 :373-392）
  ⇒ 呼叫點 11 處 ⇒ ★這是沿用的主要來源：任何經 transition 換手的隊，都帶著前一個任務的目的地
`release`（:334）：★R² 已核：`:354` `team.move_target = Vector2i(-1,-1)` ⇒ **已經清，對**｜`set_strategic_move`（:43）是設目標本身
★Team40 那一次走的是哪一條：**先查**（印 t8973 那一刻的呼叫來源 —— `_source` 參數已經帶在兩支裡）
★這份清單是我**數入口**得來的，不宣稱只有這幾條會改 task（`current_task =` 的直接寫入要另 grep 一次，見 §2 P3）
```

## §1 做什麼

```
①`transition` 加一個**必填**參數 `move_target`（★不給 default —— 同 `record_driver` 的 kind：default 只會讓下一個忘記的人靜默通過）
  ⇒ 11 個呼叫點逐一決定：新任務有目的地就傳那個，沒有就傳 `Vector2i(-1, -1)`
  ⇒ ★逐點的決定要寫在交件表裡（呼叫點／新任務／傳了什麼／為什麼）—— 不准一律傳舊的 `team.move_target` 了事
②那 2 個把 `team.move_target` 傳給 `try_set` 的呼叫點：逐一判斷「同任務只換目標」（合法）還是「換任務沿用目標」（禁）
  ⇒ 合法的寫一行註解說明為什麼是同一個任務的延續；不合法的改傳新目標或 (-1,-1)
③★不在本票：重新設計誰給目的地（to_task 那套已存在）
```

## §2 驗收

```
P1 [陽性對照] Team40（fp 那個世界，seed 與 fp 床同）t8973 換手那一刻：move_target ∈ {新任務給的, (-1,-1)}
   ⇒ ★修前必紅（印舊值 (10,25)）
P2 [不變量] 一段世界裡**每一次** task 變更：move_target ∈ {新任務給的, (-1,-1)}
   ⇒ ~~換手時記下傳入的 target，與 tick 結束時的 move_target 比~~ ★R² 打回：同 tick 二次換手會比錯對象
   ⇒ ★**在每一次換手呼叫回傳的那一刻**（try_set／transition／release 任一）**立刻**取樣 move_target，
     跟**那一次**呼叫給的值比 —— 同一時刻，不等 tick 結束（判準庫：同一欄印的值與被斷言的值必須是同一時刻）
   ⇒ 母體地板：那一段 task 變更次數 ≥ N（印出來）；transition／try_set 兩條各自 ≥1
P3 [反向掃] `current_task = ` 的直接寫入（不經 TaskArbiter）全站列出 ⇒ 每一處說它換手時目的地怎麼處理
   ⇒ ★R² 指出已有現成的窮盡結論：`task_arbiter.gd:49-60` 註解 —— 「對已存在的隊，寫入路只有 try_set／release／transition 三條；
     其餘命中是新隊建立豁免與 recruit_tutorial（寫別的隊）；decision_context 那筆是讀」⇒ **先引用它**，
     P3 只需**重跑那一行 grep 確認結論今天仍成立**（印命中數與當時的數對照），不必從頭做
P4 [fp] **會變**（行為改了）⇒ 量；變了 ⇒ 基準與改動原子落地；★而 A3 的 fp 結論（不變）先落，本票後落，兩張分開判
```
